//
//  SchedulerVC.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "SchedulerVC.h"
#import "GroupViewController.h"
#import "MenuViewController.h"
#import "ComposeMessageViewController.h"
#import "SingletonClass.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "CustomScheduleCell.h"
#import "ReScheduleViewController.h"
#import "MBProgressHUD.h"
#import "SchedulerSettingViewController.h"
#import "ComposeMessageViewController.h"
#import "UIImageView+WebCache.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface SchedulerVC ()<ReScheduleViewControllerDelegate, MBProgressHUDDelegate, SchedulerSettingViewControllerDelegate,ComposeMessageViewControllerDelegate>
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation SchedulerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

}
/*-------------------
//Notification Observer Method Listen "AddNewScheduleMessage"
 and Update Schedule Table
--------------------------------*/
-(void)addNewScheduledMessage{
    dispatch_async(dispatch_get_main_queue(), ^{
        // send your notification here instead of in updateFunction
        //[[NSNotificationCenter defaultCenter] post...];
        [self fetchAllScheduledMessages];
        
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame = CGRectMake(0, 0, width1, height1);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    // Do any additional setup after loading the view from its nib.
    //Add Observer Method for new schedule message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewScheduledMessage) name:@"AddNewScheduleMessage" object:nil];
    
    //Creating UI
    
    UIButton  *composeMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    composeMsg.frame = CGRectMake(width1-50, 15*height1/480,35*width1/320, 30*height1/480);
        //[composeMsg setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        // composeMsg.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    [composeMsg addTarget:self action:@selector(goToComposerMessage:) forControlEvents:UIControlEventTouchUpInside];
    [composeMsg setBackgroundImage:[UIImage imageNamed:@"edit_btn@3x.png"] forState:UIControlStateNormal];
        //[composeMsg setTitle:@"Save" forState:UIControlStateNormal];
    [self.view addSubview:composeMsg];
    
    
    UIButton  *logoBut = [UIButton buttonWithType:UIButtonTypeCustom];
    logoBut.frame = CGRectMake(10*width1/320, 15*height1/480, 40*width1/320,30*height1/480);        //[composeMsg setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        // composeMsg.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    [logoBut addTarget:self action:@selector(webserviceConnectedAccount) forControlEvents:UIControlEventTouchUpInside];
    [logoBut setBackgroundImage:[UIImage imageNamed:@"sb_icon@3x.png"] forState:UIControlStateNormal];
        //[composeMsg setTitle:@"Save" forState:UIControlStateNormal];
    [self.view addSubview:logoBut];
    
    
    
    
    
    
    UIButton *titleBut=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    titleBut.frame=CGRectMake(60*width1/320,15*height1/480, 200*width1/320,30*height1/480);
    titleBut.layer.borderWidth=1.0f;
    titleBut.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    [titleBut setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"scheduleMsg"] forState:UIControlStateNormal];
    [titleBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleBut.titleLabel.font=[UIFont systemFontOfSize:width1/20];
    titleBut.layer.cornerRadius = 7.0f;
    titleBut.clipsToBounds = YES;
    titleBut.backgroundColor = [UIColor whiteColor];
    [titleBut addTarget:self action:@selector(gotTOScheduleSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:titleBut];
    
    
    //CAGradientLayer *gradient2 = [CAGradientLayer layer];
   // gradient2.frame = self.settingBtn.bounds;
    //UIColor *firstColor2 = [UIColor colorWithRed:(CGFloat)85 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.5];
    //UIColor *lastColor2 =[UIColor colorWithRed:(CGFloat)110/255 green:(CGFloat)197/255 blue:(CGFloat)234/255 alpha:.5];
    //gradient2.colors = [NSArray arrayWithObjects:(id)[firstColor2 CGColor], (id)[lastColor2 CGColor],(id)[firstColor2 CGColor], nil];
    [self fetchAllScheduledMessages];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark -
- (void) displayActivityindicator{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.dimBackground = YES;
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}
-(void) hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}
#pragma mark -
#pragma mark All Scheduled Message

//Fetch All Schedule Method
-(void) fetchAllScheduledMessages{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityindicator) toTarget:self withObject:nil];
    
    NSString *profileID = [SingletonClass sharedSingleton].profileID;
    NSString *groupID=[SingletonClass sharedSingleton].groupID;
    NSLog(@"%@",profileID);
    NSLog(@"%@",groupID);
    
    //Prepare Soap message body
    NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                              <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                              <soap:Body>\
                              <GetAllScheduledMessageByUserId xmlns=\"http://tempuri.org/\">\
                              <UserId>%@</UserId>\
                              </GetAllScheduledMessageByUserId>\
                              </soap:Body>\
                              </soap:Envelope>",profileID];
    NSLog(@"Soap Message ==%@",soapmessages);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/ScheduledMessage.asmx?op=GetAllScheduledMessageByUserId",WebLink];
    
    //Creating a Mutable Request
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetAllScheduledMessageByUserId" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
   
    // Creating a URLConnecton with prepared request
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        NSString *errorString = [NSString stringWithFormat:@"%@",error];
        [self.hud hide:YES];
        if ([errorString rangeOfString:@"The request timed out"].location != NSNotFound) {
            [[[UIAlertView alloc] initWithTitle:@"Eror" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        }
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String =%@", responseString);
        if ([responseString rangeOfString:@"faultstring"].location != NSNotFound) {
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please try after again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            [self.hud hide:YES];
            NSLog(@"Error==");
            return;
        }
        NSString *jsonString = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
        jsonString = [NSString stringWithFormat:@"%@}]",jsonString];
        NSLog(@"Response yy= %@",jsonString);
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([parse isKindOfClass:[NSError class]]) {
            NSLog(@"Error");
            [self.hud hide:YES];
        }//End if block kind of error class
        else{
            
            NSMutableArray *temp2 = [[NSMutableArray alloc] init];
            if ([parse isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Dictionary Class");
                NSMutableDictionary *dict = [jsonString JSONValue];
                NSString *str1 = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ScheduleTime"]];
                NSString *schDate = [self convertTodate:str1];
                [dict setObject:schDate forKey:@"ScheduleDate"];
                [temp2 addObject:dict];
            }//if block dictionary kind class
            else if([parse isKindOfClass:[NSArray class]]){
                NSLog(@"Array Kind Class");
                NSArray *tempary = [jsonString JSONValue];
                for (int i=0; i<tempary.count; i++) {
                    NSMutableDictionary *dict = [tempary objectAtIndex:i];
                    NSString *str1 = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ScheduleTime"]];
                    NSString *schDate = [self convertTodate:str1];
                    [dict setObject:schDate forKey:@"ScheduleDate"];
                    [temp2 addObject:dict];
                }//End for loop
            }// end if else block array kind class
            else{
                NSLog(@"unknown kind of class");
            }
            
            NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"ScheduleDate" ascending:NO];
            NSArray *descriptors=[NSArray arrayWithObject: descriptor];
            NSArray *sortedArray=(NSMutableArray *)[temp2 sortedArrayUsingDescriptors:descriptors];
            
            //Display Scedule Tabel on Main Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                self.allScheduleMesgArray = [NSMutableArray arrayWithArray:sortedArray];
                NSLog(@"All List===0== %@",self.allScheduleMesgArray);
                if (self.allScheduleMesgArray.count>0) {
                    if (self.scheduleTableView) {
                        [self.scheduleTableView reloadData];
                        [self.scheduleTableView setContentOffset:CGPointZero animated:NO];
                        
                    }//End if block allScheduleTableView
                    else{
                        self.scheduleTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,55*height1/480,width1-10,height1-(65*height1/480)) style:UITableViewStylePlain];
                        self.scheduleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                        [self.view addSubview:self.scheduleTableView];
                        self.scheduleTableView.backgroundColor=[UIColor clearColor];
                        self.scheduleTableView.delegate = self;
                        self.scheduleTableView.dataSource = self;
                    }                   // self.scheduleTableView.backgroundColor=[UIColor clearColor];
                }                else{
                    NSLog(@"No Schedule message");
                   
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SorryMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"noresultMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
                    [alertView show];
                    [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
                    
                }
                 [self.hud hide:YES];
            }) ;
            
            
            
        }//End else block Error kind class
        
    }//End else block Error
   
}
#pragma mark -
#pragma mark Tableview Data Source and Delegate
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.searchTableView) {
        return self.searchArray.count;
    }
    return self.allScheduleMesgArray.count;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==self.scheduleTableView) {
        return 30;
    }
    return 0;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView==self.scheduleTableView) {
        self.scheduleSearchBar = [[UISearchBar alloc] init];//WithFrame:CGRectMake(0,70, width1, 30)];
        //self.tweetSearchBar.frame = CGRectMake(0, 0, 320, 44);
        self.scheduleSearchBar.barStyle = UIBarStyleDefault;
        self.scheduleSearchBar.showsCancelButton=NO;
        self.scheduleSearchBar.autocorrectionType= UITextAutocorrectionTypeYes;
        self.scheduleSearchBar.placeholder = [[SingletonClass sharedSingleton] languageSelectedStringForKey:@"searchMsg"];
        self.scheduleSearchBar.delegate=self;
        self.scheduleSearchBar.tintColor = [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)235/255 blue:(CGFloat)235/255 alpha:1.0];
        for (UIView *subView in self.scheduleSearchBar.subviews){
            
            if([subView isKindOfClass:[UITextField class]]){
                subView.layer.borderWidth = 1.0f;
                subView.layer.borderColor =[UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)176/255 blue:(CGFloat)176/255 alpha:1.0].CGColor;
                subView.layer.cornerRadius = 15;
                subView.clipsToBounds = YES;
                
            }
        }
        return self.scheduleSearchBar;
    }
    return nil;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    
    CustomScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
    
        cell = [[CustomScheduleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.messageLable.font = [UIFont fontWithName:@"Arial" size:width1/22];
        cell.dateLabel.font = [UIFont fontWithName:@"Arial" size:width1/30];
         cell.statusLable.font = [UIFont fontWithName:@"Arial" size:width1/24];
        cell.textLabel.numberOfLines = 0;
        cell.messageLable.numberOfLines=0;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)250/255 blue:(CGFloat)250/255 alpha:1];
    NSDictionary *dict = nil;
    if (tableView==self.searchTableView) {
        dict = [self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        dict = [self.allScheduleMesgArray objectAtIndex:indexPath.row];
    }
    
    NSString *name = [SingletonClass sharedSingleton].userName;
    NSString *message = nil;
    CGFloat xx = 115;
    if (messageType == 3) {
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
        cell.statusLable.hidden = YES;
                xx = 100*width1/320;
        cell.nameLable.text = [SingletonClass sharedSingleton].userName;
        cell.profileImageView.image = [UIImage imageNamed:@"SB.png"];
    
    }
    else{
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ShareMessage"]];
        cell.byScheduleLable.text = @"Scheduled by";
        NSString *status = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Status"]];
        cell.statusLable.hidden = NO;
        if ([status isEqualToString:@"0"]) {
            cell.statusLable.text = @"False";
        }
        else{
            cell.statusLable.text = @"True";
        }
        
        NSString *pro_name = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_Name",[dict objectForKey:@"ProfileId"]]];
        
        NSString *pro_imageStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_ImageUrl",[dict objectForKey:@"ProfileId"]]];
        
        if (pro_name==nil) {
            cell.nameLable.text = name;
        }
        else{
            cell.nameLable.text = pro_name;
        }
        
        if (pro_imageStr == nil) {
            cell.profileImageView.image = [UIImage imageNamed:@"SB.png"];
        }
        else{
            [cell.profileImageView setImageWithURL:[NSURL URLWithString:pro_imageStr] placeholderImage:[UIImage imageNamed:@"SB.png"]];
        }
    }
    cell.dateLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ScheduleDate"]];
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
  
    CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:190*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
    cell.messageLable.frame =CGRectMake(45*width1/320, 35*height1/480, 190*width1/320, textHeight);
    cell.messageLable.text = message;
    cell.byScheduleLable.frame = CGRectMake(10*width1/320, textHeight+(35*height1/480), 280*width1/320, 20*height1/480);
    if(messageType==3){
        
    
        cell.byScheduleLable.text =[NSString stringWithFormat:@"Saved by:%@",[SingletonClass sharedSingleton].userName];

    }
    else{
        
        
        //cell.usernameLable.frame = CGRectMake(145*width1/320, lblSize.height+(35*height1/480), 200*width1/320, 20*height1/480);
        cell.byScheduleLable.text =[NSString stringWithFormat:@"Scheduled by:%@",[SingletonClass sharedSingleton].userName];
        cell.byScheduleLable.textColor=[UIColor colorWithRed:(CGFloat)93/255 green:(CGFloat)145/255 blue:(CGFloat)230/255 alpha:1];
    }
        cell.byScheduleLable.font=[UIFont systemFontOfSize:width1/22];
    
    
    
   
    //cell.usernameLable.font=[UIFont systemFontOfSize:width1/20];
    //cell.usernameLable.text = [SingletonClass sharedSingleton].userName;
    //[cell addSubview:cell.nameLable];
    UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(0,0,width1,4*height1/480)];
   
        devider.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
  
    
    [cell addSubview:devider];
    return cell;
}
/*
-(CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGFloat result = font.pointSize + 4;
    if (text)
    {
        CGSize textSize = { widthValue, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            //iOS 7
            CGRect frame = [text boundingRectWithSize:textSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName:font }
                                              context:nil];
            size = CGSizeMake(frame.size.width, frame.size.height+1);
        }
        else
        {
            //iOS 6.0
            size = [text sizeWithFont:font constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
        }
        result = MAX(size.height, result); //At least one row
    }
    return result;
}

*/

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat h=70*height1/480;
    NSDictionary *dict = nil;
    if (tableView==self.searchTableView) {
        dict = [self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        dict = [self.allScheduleMesgArray objectAtIndex:indexPath.row];
    }
    NSString *message = nil;
    
    if (messageType == 3) {
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
    }
    else{
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ShareMessage"]];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
     CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:190*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
    //CGSize lblSize = [message sizeWithFont:[UIFont fontWithName:@"Arial" size:width1/20] constrainedToSize:CGSizeMake(180*width1/320,1000)];
    h = h + textHeight;
    return h;
    
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    
    NSDictionary *dict = nil;
    NSIndexPath *selectedIndexPath = nil;
    if (tableView==self.searchTableView) {
        dict = [self.searchArray objectAtIndex:indexPath.row];
        
        if ([self.allScheduleMesgArray containsObject:dict]) {
            NSInteger ii = [self.allScheduleMesgArray indexOfObject:dict];
            NSLog(@"ii==%ld",(long)ii);
            selectedIndexPath = [NSIndexPath indexPathForRow:ii inSection:0];
        }
    }
    else{
        dict = [self.allScheduleMesgArray objectAtIndex:indexPath.row];
        selectedIndexPath = indexPath;
    }
    
    if (messageType==3) {
       ComposeMessageViewController *compose = [[ComposeMessageViewController alloc] initWithNibName:@"ComposeMessageViewController" bundle:nil];
        compose.isDraftMessages = YES;
        compose.draftDict = (NSMutableDictionary*)dict;
        compose.delegate = self;
        [self presentViewController:compose animated:YES completion:nil];
    }
    else{
        ReScheduleViewController *reschedule = [[ReScheduleViewController alloc] initWithNibName:@"ReScheduleViewController" bundle:nil];
        reschedule.scheduleDict = [self.allScheduleMesgArray objectAtIndex:selectedIndexPath.row];
        reschedule.selectedIndexPath = selectedIndexPath;
        reschedule.delegate = self;
        [self presentViewController:reschedule animated:YES completion:nil];
    }
    
}
#pragma mark -
#pragma mark UISearchBar Delegate
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton=YES;
    if (!self.dimLightView) {
        self.dimLightView = [[UIView alloc] initWithFrame:CGRectMake(0,(57*height1/480)+31, width1, height1)];
        
        self.dimLightView.backgroundColor = [UIColor blackColor];
        self.dimLightView.alpha=.4;
    }
    for (UIView *subView in searchBar.subviews) {
        //Find the button
        if([subView isKindOfClass:[UIButton class]])
        {
            //Change its properties
            UIButton *cancelButton = (UIButton *)[searchBar.subviews lastObject];
            [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        }
    }
    self.dimLightView.hidden=NO;
    [self.view addSubview:self.dimLightView];
}
-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    self.dimLightView.hidden=YES;
    [self.scheduleTableView setContentOffset:CGPointZero];
    [self.view addSubview:self.scheduleTableView];
    self.searchTableView.hidden=YES;
    self.searchTableView = nil;
    [self.searchTableView removeFromSuperview];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Search Text==%@",searchText);
    [searchBar setShowsCancelButton:YES animated:YES];
    [self filterContentForSearchText:searchText scope:@"All"];
    
    if (self.searchTableView) {
        self.searchTableView = nil;
        [self.searchTableView removeFromSuperview];
    }
    
    CGRect frame = CGRectMake(self.scheduleTableView.frame.origin.x, self.scheduleTableView.frame.origin.y+45, self.scheduleTableView.frame.size.width, self.scheduleTableView.frame.size.height);
    self.searchTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.searchTableView.backgroundColor= [UIColor clearColor];
    self.searchTableView.dataSource=self;
    self.searchTableView.delegate=self;
    [self.view addSubview:self.searchTableView];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
}
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
	
    // Remove all objects from the filtered search array
	[self.searchArray removeAllObjects];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.ShareMessage contains[c] %@",searchText];
    
    
    
	// Filter the array using NSPredicate
    
    NSArray *tempArray = [self.allScheduleMesgArray filteredArrayUsingPredicate:predicate];
    
    if(![scope isEqualToString:@"All"]) {
        // Further filter the array with the scope
        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    }
    
    self.searchArray = [NSMutableArray arrayWithArray:tempArray];
    
}

#pragma mark -
//Convert Unix TimeStamp to Date
-(NSString *)convertTodate:(NSString *)entryDate{
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@"/" withString:@""];
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@"Date" withString:@""];
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@"(" withString:@""];
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@")" withString:@""];
    double  number = [entryDate doubleValue];
    double unixTimeStamp = number/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    //NSLog(@"%@", date);
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    //[_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-6:00"]];
    //[_formatter setDateFormat:@"MMM dd,yy hh:mm:ss a"];
    //[_formatter setDateFormat:@"dd/MM/yy hh:mm a"];
    [_formatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
    
    entryDate=[_formatter stringFromDate:date];
    NSLog(@"Final Date --- %@",entryDate);
    
    return entryDate;
}
//Display All Connected Account count with Logout OPtion
-(IBAction)webserviceConnectedAccount{
    
    MenuViewController *obj = [[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];
    
    //obj.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:obj animated:YES completion:nil];
}
//Display Compose Message View
- (IBAction) goToComposerMessage:(id)sender{
    ComposeMessageViewController *compose = [[ComposeMessageViewController alloc] initWithNibName:@"ComposeMessageViewController" bundle:nil];
    compose.isDraftMessages = NO;
    [self presentViewController:compose animated:YES completion:nil];
}
#pragma mark -
#pragma mark RescheduleDelegate
/*-----------------------------------------
 Delegate method of ReScheduleViewController
 get updated value and Update Schedule Table
 -------------------*/
-(void) updateScheduleTable:(NSDictionary *)dict{
    NSIndexPath *indexpath = [dict objectForKey:@"SelectedIndexPath"];
    [self.allScheduleMesgArray removeObjectAtIndex:indexpath.row];
    
    [self.allScheduleMesgArray insertObject:dict atIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        // send your notification here instead of in updateFunction
        //[[NSNotificationCenter defaultCenter] post...];
        [self.scheduleTableView reloadData];
        
    });
}

//Dissplay Schedule Setting View Controller
- (IBAction) gotTOScheduleSetting:(id) sender{
    SchedulerSettingViewController *schsetting = [[SchedulerSettingViewController alloc] initWithNibName:@"SchedulerSettingViewController" bundle:nil];
    schsetting.delegate = self;
    [self presentViewController:schsetting animated:YES completion:nil];
}

#pragma mark -
#pragma mark ScheduleSettingDelegate
/*---------------------------------
 Delegate Method of ScheduleSettingViewController
 Pass selected type for Schedule message
 0 = AllScheduleMessage
 1 = AllUnSentMessage
 2 = AllSocioQueueMessages
 3 = AllDraftMessages
 ---------------------------------*/
-(void) selectedMessageRow:(NSInteger)selectedRow{
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    
    
    @synchronized(self)
    {
        // your code goes here
        NSLog(@"Selected Row == %ld",(long)selectedRow);
        messageType = selectedRow;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Update Draft Message" object:nil];
        
        if (selectedRow==0) {
            //[self fetchAllScheduledMessages];
            [NSThread detachNewThreadSelector:@selector(fetchAllScheduledMessages) toTarget:self withObject:nil];
        }
        else if (selectedRow==1){
            [NSThread detachNewThreadSelector:@selector(allUnSentMessages) toTarget:self withObject:nil];
        }
        else if (selectedRow == 2){
            [NSThread detachNewThreadSelector:@selector(getAllSocioQueueMessages) toTarget:self withObject:nil];
        }
        else if (selectedRow == 3){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDraftTable) name:@"Update Draft Message" object:nil];
            
            [NSThread detachNewThreadSelector:@selector(getAllDraftMessages) toTarget:self withObject:nil];
        }
    }
    
}

#pragma mark -
//Get all not sent Schedule Messages
-(void) allUnSentMessages{
    [NSThread detachNewThreadSelector:@selector(displayActivityindicator) toTarget:self withObject:nil];
    
    NSString *profileID = [SingletonClass sharedSingleton].profileID;
    //Prepare Soap Message fro fetching all not sent schedule messages
    NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                              <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                              <soap:Body>\
                              <GetAllUnSentMessagesOfUser xmlns=\"http://tempuri.org/\">\
                              <UserId>%@</UserId>\
                              </GetAllUnSentMessagesOfUser>\
                              </soap:Body>\
                              </soap:Envelope>",profileID];
    NSLog(@"Soap Message ==%@",soapmessages);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/ScheduledMessage.asmx?op=GetAllUnSentMessagesOfUser",WebLink];
    
    //Prepare a Request
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetAllUnSentMessagesOfUser" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",msglength);
    [self sendRequest:req];
   
}
//Get all SocioQueue Messages
-(void) getAllSocioQueueMessages{
    [NSThread detachNewThreadSelector:@selector(displayActivityindicator) toTarget:self withObject:nil];
    
    NSString *profileID = [SingletonClass sharedSingleton].profileID;
    NSString *groupID=[SingletonClass sharedSingleton].groupID;
    NSLog(@"%@",profileID);
    NSLog(@"%@",groupID);
    
    //Prepare Soap message body
    NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                              <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                              <soap:Body>\
                              <GetSociaoQueueMessageByUserIdAndGroupId xmlns=\"http://tempuri.org/\">\
                              <UserId>%@</UserId>\
                              <GroupId>%@</GroupId>\
                              </GetSociaoQueueMessageByUserIdAndGroupId>\
                              </soap:Body>\
                              </soap:Envelope>",profileID,groupID];
    NSLog(@"Soap Message ==%@",soapmessages);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/ScheduledMessage.asmx?op=GetSociaoQueueMessageByUserIdAndGroupId",WebLink];
    
    //Creating a Mutable Request
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetSociaoQueueMessageByUserIdAndGroupId" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",msglength);
    
    
    [self sendRequest:req];
    
}
//Get All Draft Message
-(void) getAllDraftMessages{
    NSLog(@"Get All Draft Messages");
    [NSThread detachNewThreadSelector:@selector(displayActivityindicator) toTarget:self withObject:nil];
    
    NSString *profileID = [SingletonClass sharedSingleton].profileID;
    NSString *grpID=[SingletonClass sharedSingleton].groupID;
    //Prepare Soap Message fro fetching all Draft messages
    NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                              <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                              <soap:Body>\
                              <GetDraftMessageByUserIdAndGroupId xmlns=\"http://tempuri.org/\">\
                              <UserId>%@</UserId>\
                              <GroupId>%@</GroupId>\
                              </GetDraftMessageByUserIdAndGroupId>\
                              </soap:Body>\
                              </soap:Envelope>",profileID,grpID];
    NSLog(@"Soap Message ==%@",soapmessages);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/Drafts.asmx?op=GetDraftMessageByUserIdAndGroupId",WebLink];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetDraftMessageByUserIdAndGroupId" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",msglength);
    [self sendRequest:req];
    
}
#pragma mark -
//Create URLConnectiong with received request and Fetch JSON response and display/Update Schedule Table
-(void) sendRequest:(NSMutableURLRequest *)req{
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error == %@", error);
        NSString *errorString = [NSString stringWithFormat:@"%@",error];
        if ([errorString rangeOfString:@"The request timed out"].location != NSNotFound) {
            [self.hud hide:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
            
        }
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String =%@", responseString);
        if ([responseString rangeOfString:@"faultstring"].location != NSNotFound) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"plzTryAfterAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
            [self.hud hide:YES];
            NSLog(@"Error==%@",error);
            return;
        }
        NSString *jsonString = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
        jsonString = [NSString stringWithFormat:@"%@}]",jsonString];
        NSLog(@"Response yy= %@",jsonString);
        
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if ([parse isKindOfClass:[NSError class]]) {
            NSLog(@"Error");
            [self.hud hide:YES];
        }//End if block kind of error class
        
        else{
            
            
            NSMutableArray *tempArray2 = [[NSMutableArray alloc] init];
            
            if ([parse isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Dictionary Class");
                NSMutableDictionary *dict = [jsonString JSONValue];
                NSString *str1 = nil;
                if (messageType==3) {
                    str1 =[NSString stringWithFormat:@"%@",[dict objectForKey:@"CreatedDate"]];
                    
                }
                else{
                    str1 =  [NSString stringWithFormat:@"%@",[dict objectForKey:@"ScheduleTime"]];
                }
                NSString *schDate = [self convertTodate:str1];
                [dict setObject:schDate forKey:@"ScheduleDate"];
                [tempArray2 addObject:dict];
            }//if block dictionary kind class
            else if([parse isKindOfClass:[NSArray class]]){
                NSLog(@"Array Kind Class");
                NSArray *tempary = [jsonString JSONValue];
                
                for (int i=0; i<tempary.count; i++) {
                    NSMutableDictionary *dict = [tempary objectAtIndex:i];
                    NSString *str1 = nil;
                    if (messageType==3) {
                        str1 =[NSString stringWithFormat:@"%@",[dict objectForKey:@"CreatedDate"]];
                        
                    }
                    else{
                       str1 =  [NSString stringWithFormat:@"%@",[dict objectForKey:@"ScheduleTime"]];
                    }
                    
                    NSString *schDate = [self convertTodate:str1];
                    [dict setObject:schDate forKey:@"ScheduleDate"];
                    [tempArray2 addObject:dict];
                }//End for loop
            }// end if else block array kind class
            else{
                NSLog(@"unknown kind of class");
            }
            
            NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"ScheduleDate" ascending:NO];
            NSArray *descriptors=[NSArray arrayWithObject: descriptor];
            NSArray *sortedArray=(NSMutableArray *)[tempArray2 sortedArrayUsingDescriptors:descriptors];
            
            //Preapre UI for display Scheduled Messages
            dispatch_async(dispatch_get_main_queue(), ^{
                self.allScheduleMesgArray = [NSMutableArray arrayWithArray:sortedArray];
                
                NSLog(@"All List===0== %@\n count==%lu",self.allScheduleMesgArray,(unsigned long)self.allScheduleMesgArray.count);
                
                if (self.allScheduleMesgArray.count>0) {
                    if (self.scheduleTableView) {
                        [self.scheduleTableView reloadData];
                        [self.scheduleTableView setContentOffset:CGPointZero];
                    }//End if block allScheduleTableView
                    else{
                        self.scheduleTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,70,width1-10, height1-70) style:UITableViewStylePlain];
                        self.scheduleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                        [self.view addSubview:self.scheduleTableView];
                        self.scheduleTableView.delegate = self;
                        self.scheduleTableView.dataSource = self;
                    }//End Else block allScheduleTableView
                    
                    [self.scheduleTableView setContentOffset:CGPointZero animated:NO];
                }//End if block allschduleMessageCount
                else{
                    NSLog(@"No  message");
                    self.allScheduleMesgArray = nil;
                    [self.scheduleTableView reloadData];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SorryMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"noresultMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
                    [alertView show];
                    [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
                }
                [self.hud hide:YES];
            });
            
            
        }//End else block Error kind class
        
    }//End else block Error
}
#pragma mark -
-(void) updateDraftTable{
    dispatch_async(dispatch_get_main_queue(), ^{
        // send your notification here instead of in updateFunction
        //[[NSNotificationCenter defaultCenter] post...];
        [self getAllDraftMessages];
    });
}
#pragma mark -
#pragma mark ComposeViewDelegate
/*--------------------------------
 Delegate method of ComposerViewController
 received updated message and update Table
 ---------------------------------*/
-(void)updateSelectedDraftMessage:(NSDictionary *)dict{
    
    if ([self.allScheduleMesgArray containsObject:dict]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // send your notification here instead of in updateFunction
            //[[NSNotificationCenter defaultCenter] post...];
            [self.scheduleTableView reloadData];
        });
    }
}
/*--------------------------------
 Delegate method of ComposerViewController
 received message for deleted message and update Table
 ---------------------------------*/
-(void) removeDeletedDraftMessage:(NSDictionary *)dict{
    if ([self.allScheduleMesgArray containsObject:dict]) {
        [self.allScheduleMesgArray removeObject:dict];
        dispatch_async(dispatch_get_main_queue(), ^{
            // send your notification here instead of in updateFunction
            //[[NSNotificationCenter defaultCenter] post...];
            [self.scheduleTableView reloadData];
        });
    }
}



-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
