//
//  TaskVC.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "TaskVC.h"
#import "GroupViewController.h"
#import "MenuViewController.h"
#import "ComposeMessageViewController.h"
#import "SingletonClass.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "CustomTaskCell.h"
#import "ManageTaskViewController.h"
#import "MBProgressHUD.h"

@interface TaskVC ()<ManageTaskViewControllerDelegate, MBProgressHUDDelegate>
@property (nonatomic, strong) MBProgressHUD *hud;
@end
#define RefreshTask @"woosuiterefreshtask"
@implementation TaskVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    alertDisplay = 1;
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    alertDisplay = 0;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllTask) name:@"RefresAfterResign" object:nil];
    
    //Create UI
    UIButton  *composeMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    composeMsg.frame = CGRectMake(width1-50, 15*height1/480,35*width1/320, 30*height1/480);
    [composeMsg addTarget:self action:@selector(goToComposerMessage:) forControlEvents:UIControlEventTouchUpInside];
    [composeMsg setBackgroundImage:[UIImage imageNamed:@"edit_btn@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:composeMsg];
    
    
    UIButton  *logoBut = [UIButton buttonWithType:UIButtonTypeCustom];
    logoBut.frame = CGRectMake(10*width1/320, 15*height1/480, 40*width1/320,30*height1/480);        //[composeMsg setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        // composeMsg.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    [logoBut addTarget:self action:@selector(webserviceConnectedAccount) forControlEvents:UIControlEventTouchUpInside];
    [logoBut setBackgroundImage:[UIImage imageNamed:@"sb_icon@3x.png"] forState:UIControlStateNormal];
        //[composeMsg setTitle:@"Save" forState:UIControlStateNormal];
    [self.view addSubview:logoBut];
    
    
   UILabel *titleLable=[[UILabel alloc]initWithFrame:CGRectMake(60*width1/320,15*height1/480, 200*width1/320,30*height1/480)];
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.layer.borderWidth=1.0f;
    titleLable.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    titleLable.textColor=[UIColor blackColor];
    titleLable.clipsToBounds=YES;
    titleLable.backgroundColor=[UIColor whiteColor];
    titleLable.layer.cornerRadius=5*width1/320;
    titleLable.text=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"taskMsg"];
    titleLable.font=[UIFont systemFontOfSize:width1/20];
    titleLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLable];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllTask) name:RefreshTask object:nil];

    
    //[self getAllTask];
    [NSThread detachNewThreadSelector:@selector(getAllTask) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 
-(void)displayActivityIndicator{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.dimBackground=YES;
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}
-(void)hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}

#pragma mark -
//Get All Task
-(void) getAllTask{
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    NSString *selectedGroupID=[SingletonClass sharedSingleton].groupID;
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSString *soapMessage = [[NSString alloc] initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                             <soap:Body>\
                             <GetAllTasks xmlns=\"http://tempuri.org/\">\
                             <custid>%@</custid>\
                             </GetAllTasks>\
                             </soap:Body>\
                             </soap:Envelope>",strUserid];
    
    NSLog(@"soapMessg facebook %@",soapMessage);
    NSString *urlstring = [NSString stringWithFormat:@"%@/Services/Tasks.asmx?op=GetAllTasks",WebLink];
    NSURL *url = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetAllTasks" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        [self.hud hide:YES];
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
       // NSLog(@"XML String = %@",responseString);
        NSString *jsonString = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"false" withString:@"\"false\""];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"true" withString:@"\"true\""];
        jsonString = [NSString stringWithFormat:@"%@}]",jsonString];
        NSArray *tempArray = [jsonString JSONValue];
        if (tempArray.count==0 ) {
            if (alertDisplay==1) {
                [self.hud hide:YES];
                UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SorryMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"notaskAdded"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
                [myAlert show];
                 [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
                
            }
            
            return;
        }
        
    NSMutableArray *tempArray2= [[NSMutableArray alloc] init];
        
        //convert Unix Timestamp to simiple date and add to allTaskArray
       for (int i =0; i<tempArray.count; i++) {
            NSMutableDictionary *newDict= [tempArray objectAtIndex:i];
         NSString *grpID = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"GroupId"]];
                      if([grpID isEqualToString:selectedGroupID])
         [tempArray2 addObject:newDict];
            //NSLog(@"new Date ==%@",newDate);
        }//End for Loop
        if(tempArray2.count==0){
            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SorryMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"notaskAdded"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
            [self.hud hide:YES];
            return;
            
        }
        
        //Sort Tasks on the basis on Date
        NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"NewAssignDate" ascending:NO];
        NSArray *descriptors=[NSArray arrayWithObject: descriptor];
        NSArray *sortedArray=(NSMutableArray *)[tempArray2 sortedArrayUsingDescriptors:descriptors];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{

            //UI for display all taks on TableView
            self.allTaskArray = [NSMutableArray arrayWithArray:sortedArray];
            NSLog(@"Sorted Array = %@",self.allTaskArray);
            if (self.taskTableView) {
                [self.taskTableView reloadData];
                self.taskTableView.backgroundColor=[UIColor clearColor];
            }
            else{
                self.taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,55*height1/480,width1-10,height1-(65*height1/480))style:UITableViewStylePlain];
                self.taskTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [self.view addSubview:self.taskTableView];
                self.taskTableView.backgroundColor=[UIColor clearColor];
                self.taskTableView.delegate = self;
                self.taskTableView.dataSource = self;
                //tableViewController.tableView = self.taskTableView;
            }
            [self.taskTableView setContentOffset:CGPointZero];
            
            [self.hud hide:YES];
        });
    }
    
}
/*
 -(void) getAllTask{
 [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
 
 NSString *strUserid = [SingletonClass sharedSingleton].profileID;
 NSString *soapMessage = [[NSString alloc] initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
 <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
 <soap:Body>\
 <GetAllTasks xmlns=\"http://tempuri.org/\">\
 <custid>%@</custid>\
 </GetAllTasks>\
 </soap:Body>\
 </soap:Envelope>",strUserid];
 
 NSLog(@"soapMessg facebook %@",soapMessage);
 NSString *urlstring = [NSString stringWithFormat:@"%@/Services/Tasks.asmx?op=GetAllTasks",WebLink];
 NSURL *url = [NSURL URLWithString:urlstring];
 NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
 
 NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
 [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
 [req addValue:@"http://tempuri.org/GetAllTasks" forHTTPHeaderField:@"SOAPAction"];
 [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
 [req setHTTPMethod:@"POST"];
 [req setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
 
 NSError *error = nil;
 NSHTTPURLResponse *response = nil;
 
 NSLog(@"%@",msglength);
 NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
 if (error) {
 NSLog(@"Error == %@", error);
 [self.hud hide:YES];
 }
 else{
 NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
 // NSLog(@"XML String = %@",responseString);
 NSString *jsonString = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
 jsonString = [jsonString stringByReplacingOccurrencesOfString:@"false" withString:@"\"false\""];
 jsonString = [jsonString stringByReplacingOccurrencesOfString:@"true" withString:@"\"true\""];
 jsonString = [NSString stringWithFormat:@"%@}]",jsonString];
 NSArray *tempArray = [jsonString JSONValue];
 if (tempArray.count==0 ) {
 if (alertDisplay==1) {
 [self.hud hide:YES];
 [[[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"No task added yet" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
 
 }
 
 return;
 }
 
 NSMutableArray *tempArray2= [[NSMutableArray alloc] init];
 
 //convert Unix Timestamp to simiple date and add to allTaskArray
 for (int i =0; i<tempArray.count; i++) {
 NSMutableDictionary *newDict= [tempArray objectAtIndex:i];
 NSString *comDateStr = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"AssignDate"]];
 
 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
 [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
 NSDate *composeDate = [formatter dateFromString:comDateStr];
 NSLog(@"Date ==%@",[NSString stringWithFormat:@"%@",composeDate]);
 [formatter setDateFormat:@"yyyyMMdd"];
 
 NSString *newDate = [formatter stringFromDate:composeDate];
 if (newDate!=nil) {
 [newDict setObject:newDate forKey:@"NewAssignDate"];
 }
 
 [tempArray2 addObject:newDict];
 NSLog(@"new Date ==%@",newDate);
 }//End for Loop
 
 //Sort Tasks on the basis on Date
 NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"NewAssignDate" ascending:NO];
 NSArray *descriptors=[NSArray arrayWithObject: descriptor];
 NSArray *sortedArray=(NSMutableArray *)[tempArray2 sortedArrayUsingDescriptors:descriptors];
 
 
 dispatch_async(dispatch_get_main_queue(), ^{
 
 //UI for display all taks on TableView
 self.allTaskArray = [NSMutableArray arrayWithArray:sortedArray];
 NSLog(@"Sorted Array = %@",self.allTaskArray);
 if (self.taskTableView) {
 [self.taskTableView reloadData];
 }
 else{
 self.taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 52, self.view.bounds.size.width-20, self.view.bounds.size.height-52) style:UITableViewStylePlain];
 self.taskTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
 [self.view addSubview:self.taskTableView];
 self.taskTableView.delegate = self;
 self.taskTableView.dataSource = self;
 //tableViewController.tableView = self.taskTableView;
 }
 [self.taskTableView setContentOffset:CGPointZero];
 
 [self.hud hide:YES];
 });
 }
 
 }
*/




//Convert Unix TimeStamp to Date
-(NSString *)convertTodate:(NSString *)entryDate{
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@"/" withString:@""];
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@"Date" withString:@""];
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@"(" withString:@""];
    entryDate = [entryDate stringByReplacingOccurrencesOfString:@")" withString:@""];
    double  number = [entryDate doubleValue];
    double unixTimeStamp = number/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    NSLog(@"%@", date);
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    //[_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-6:00"]];
    //[_formatter setDateFormat:@"MMM dd,yy hh:mm:ss a"];
    [_formatter setDateFormat:@"dd/MM/yy hh:mm a"];
    entryDate=[_formatter stringFromDate:date];
    NSLog(@"Final Date --- %@",entryDate);
    
    return entryDate;
}

#pragma mark -
#pragma mark Tableview Delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.searchTableView) {
       return  self.searchArray.count;
    }
    return self.allTaskArray.count;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==self.taskTableView) {
        return 30;
    }
    return 0;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView==self.taskTableView) {
        self.taskSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 52, width1,40*height1/480)];
        //self.tweetSearchBar.frame = CGRectMake(0, 0, 320, 44);
        self.taskSearchBar.tintColor = [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)235/255 blue:(CGFloat)235/255 alpha:1.0];
        
        
        //self.taskSearchBar.
        self.taskSearchBar.barStyle = UIBarStyleDefault;
        self.taskSearchBar.showsCancelButton=NO;
        self.taskSearchBar.autocorrectionType= UITextAutocorrectionTypeYes;
        self.taskSearchBar.placeholder = [[SingletonClass sharedSingleton] languageSelectedStringForKey:@"searchMsg"];
        self.taskSearchBar.delegate=self;
        
        for (UIView *subView in self.taskSearchBar.subviews){
            
            if([subView isKindOfClass:[UITextField class]]){
                subView.frame=CGRectMake(0, 0, width1, 30*height1/320);
                subView.layer.borderWidth = 1.0f;
                subView.layer.borderColor =[UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)176/255 blue:(CGFloat)176/255 alpha:1.0].CGColor;
                subView.layer.cornerRadius = 15;
                subView.clipsToBounds = YES;
                
            }
        }
        return self.taskSearchBar;
    }
    return nil;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict= nil;
    if (tableView==self.taskTableView) {
        dict = [self.allTaskArray objectAtIndex:indexPath.row];
    }
    else if (tableView == self.searchTableView){
        dict = [self.searchArray objectAtIndex:indexPath.row];
    }
    NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TaskMessage"]];
     CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:250*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
    //CGSize lblSize = [message sizeWithFont:[UIFont fontWithName:@"Arial" size:width1/20] constrainedToSize:CGSizeMake(250*width1/320,1000)];

    return textHeight+135;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    CustomTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        
        cell = [[CustomTaskCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.nameLable.font=[UIFont systemFontOfSize:width1/20];
        cell.messageLable.font = [UIFont fontWithName:@"Arial" size:width1/22];
        cell.dataLable.font = [UIFont fontWithName:@"Arial" size:width1/22];
        cell.statusLable.font = [UIFont fontWithName:@"Arial" size:width1/20];
        cell.textLabel.numberOfLines = 0;
        cell.messageLable.numberOfLines=0;
        cell.assigedBy.font = [UIFont fontWithName:@"Arial" size:width1/20];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)250/255 blue:(CGFloat)250/255 alpha:1];
    NSDictionary *dict= nil;
    if (tableView==self.taskTableView) {
        dict = [self.allTaskArray objectAtIndex:indexPath.row];
    }
    else if (tableView == self.searchTableView){
       dict = [self.searchArray objectAtIndex:indexPath.row];
    }
    
    NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TaskMessage"]];
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
     CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:250*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
    
    cell.profileImageView.image = [UIImage imageNamed:@"task_pin.png"];
    cell.nameLable.frame = CGRectMake(50*width1/320, 15, 150*width1/320, 20*height1/480);
    cell.nameLable.text = [SingletonClass sharedSingleton].userName;
    NSString *status = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TaskStatus"]];
    cell.statusLable.frame = CGRectMake(230*width1/320, 15, 80*width1/320, 20*height1/480);
    if ([status isEqualToString:@"false"]) {
        cell.statusLable.text = @"Incomplete";
    }
    else if ([status isEqualToString:@"true"]){
        cell.statusLable.text = @"Complete";
    }
    cell.dataLable.frame = CGRectMake(50*width1/320, 33*height1/480, 180*width1/320, 20*height1/480);
    cell.dataLable.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"AssignDate"]];
    cell.messageLable.frame = CGRectMake(50*width1/320, 60*height1/480, 250*width1/320, textHeight);
    cell.messageLable.text = message;
    cell.assigedBy.frame = CGRectMake(10*width1/320, textHeight+(70*height1/480), 260*width1/320, 25);
    cell.assigedBy.text = [NSString stringWithFormat:@"Assigned by %@",cell.nameLable.text];
    UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(0,0,width1,4*height1/480)];
    devider.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
    [cell addSubview:devider];
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    //Display ManageTaskViewController
    ManageTaskViewController *manageTask = [[ManageTaskViewController alloc] initWithNibName:@"ManageTaskViewController" bundle:nil];
    NSDictionary *dict= nil;
    if (tableView==self.taskTableView) {
        dict = [self.allTaskArray objectAtIndex:indexPath.row];
    }
    else if (tableView == self.searchTableView){
        dict = [self.searchArray objectAtIndex:indexPath.row];
    }
    NSLog(@"aselected Dict == %@",dict);
    manageTask.dataDict = dict;
    manageTask.delegate = self;
    [self presentViewController:manageTask animated:YES completion:nil];
}

/*
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    //UIEdgeInsets inset = scrollView.contentInset;
    
    if (offset.y < -120) {
       NSLog(@"offset: %f", offset.y);
        NSLog(@"content.height: %f", size.height);
        NSLog(@"bounds.height: %f", bounds.size.height);
    }
//    float y = offset.y + bounds.size.height - inset.bottom;
//    float h = size.height;
//    NSLog(@"Y======%f",y);
//    NSLog(@"h======%f",h);
//    NSLog(@"offset: %f", offset.y);
//    NSLog(@"content.height: %f", size.height);
//    NSLog(@"bounds.height: %f", bounds.size.height);
//    NSLog(@"inset.top: %f", inset.top);
//    NSLog(@"inset.bottom: %f", inset.bottom);
}
*/

#pragma mark -
#pragma mark Search Bar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    if (!self.dimLightView) {
        self.dimLightView = [[UIView alloc] initWithFrame:CGRectMake(0, (57*height1/480)+31,width1, height1)];
        
        self.dimLightView.backgroundColor = [UIColor blackColor];
        self.dimLightView.alpha=.4;
    }
    self.dimLightView.hidden=NO;
    [self.view addSubview:self.dimLightView];
    
    
    for (UIView *subView in searchBar.subviews) {
        //Find the button
        if([subView isKindOfClass:[UIButton class]])
        {
            //Change its properties
            UIButton *cancelButton = (UIButton *)[searchBar.subviews lastObject];
            [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        }
    }

}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //[searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text=@"";
    self.dimLightView.hidden=YES;
    [self.taskTableView setContentOffset:CGPointZero];
    [self.taskTableView reloadData];
    searchBar.showsCancelButton=NO;
    //[searchBar resignFirstResponder];
    
    [self.view addSubview:self.taskTableView];
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
    
    CGRect frame = CGRectMake(self.taskTableView.frame.origin.x, self.taskTableView.frame.origin.y+30, self.taskTableView.frame.size.width, self.taskTableView.frame.size.height);
    self.searchTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.searchTableView.backgroundColor= [UIColor redColor];
    //self.searchTableView.backgroundColor= [UIColor clearColor];
    self.searchTableView.dataSource=self;
    self.searchTableView.delegate=self;
    [self.view addSubview:self.searchTableView];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
}
//Filter All Message Array on the basis of entered Keyword on Search Bar
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
	
    // Remove all objects from the filtered search array
	[self.searchArray removeAllObjects];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.TaskMessage contains[c] %@",searchText];
    
    
    
	// Filter the array using NSPredicate
    
    NSArray *tempArray = [self.allTaskArray filteredArrayUsingPredicate:predicate];
    
    if(![scope isEqualToString:@"All"]) {
        // Further filter the array with the scope
        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    }
    
    self.searchArray = [NSMutableArray arrayWithArray:tempArray];
    
}
#pragma mark -
//Display MenuViewController(All Connected account numbers)
-(IBAction)webserviceConnectedAccount{
    
    MenuViewController *obj = [[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];
    
    //obj.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:obj animated:YES completion:nil];
}
//Display Compose Message View Controller
- (IBAction) goToComposerMessage:(id)sender{
    ComposeMessageViewController *compose = [[ComposeMessageViewController alloc] initWithNibName:@"ComposeMessageViewController" bundle:nil];
    compose.isDraftMessages = NO;
    [self presentViewController:compose animated:YES completion:nil];
}
#pragma mark -
#pragma mark ManageTaskViewControllerDelegate
//Receive message from ManageTaskViewController and Update Taks Table
- (void) taskUpdated:(NSDictionary *)updatedDict{
    if ([self.allTaskArray containsObject:updatedDict]) {
        NSLog(@"Task Updated");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.taskTableView reloadData];
        });
        
    }
}

-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}



@end
