//
//  InboxSettingViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 16/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "InboxSettingViewController.h"
#import "SingletonClass.h"
#import "UIImageView+WebCache.h"

#define FacabookWallPostValue @"facebookwallpostValue"
#define SentMessagesValue @"sentmessagesvalue"
#define FacebookCommentsValue @"commentsValue"
#define TwitterPublicMentionsValue @"publicMentionsValue"
#define TwitterMessagesValue @"twitterMessagesValue"
#define TwitterRetweetsValue @"twitterRetwttesValue"
#define GooglePlusActivitiesValue @"GooglePlusActivitiedValue"
#import <sys/utsname.h>
@interface InboxSettingViewController ()

@end

@implementation InboxSettingViewController

//@synthesize tableContents;
@synthesize arrKeywords,arrMessageTypes;
//@synthesize profileType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
       //self.view.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)211/255 blue:(CGFloat)155/255 alpha:1];
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame = CGRectMake(0, 0, width1, height1);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];

    
    UIImageView *logo=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320,35*height1/480, 40*width1/320, 40*width1/320)];
    [logo setImage:[UIImage imageNamed:@"SB.png"]];
    //[self.view addSubview:logo];
    
    UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(20*width1/320, 20*height1/480,280*width1/320, 45*width1/320)];
    [logoTxt setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:logoTxt];

    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, height1);
    
    self.allProfileInfoArray =[[NSMutableArray alloc]init];
    self.arrMessageTypes = [[NSMutableArray alloc] init];
    //Fetch All Connected  Twitter and Facebook Accounts
    self.allProfileInfoArray = [SingletonClass sharedSingleton].messagePageAccountArray;
    self.arrMessageTypes = [SingletonClass sharedSingleton].messageTypeArray;
    
    
    NSLog(@"Message Type Array = %@",arrMessageTypes);
    self.arrKeywords = [[NSMutableArray alloc] initWithObjects:[SingletonClass sharedSingleton].userName, nil];
    
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(5,75*height1/480, 310*width1/320, height1-(100*height1/480)) style:UITableViewStyleGrouped];
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:@"SimpleTableIdentifier"];
    UIView *devide = [[UIView alloc] initWithFrame:CGRectMake(0,84, 320,.4)];
    devide.backgroundColor = [UIColor blackColor];
    //[self.view addSubview:devide];

    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    tableView.opaque=NO;
    tableView.backgroundColor=[UIColor clearColor];
    tableView.backgroundView=nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled=YES;
    [self.view addSubview:tableView];
    
    UIButton *doneBtn= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneBtn.frame = CGRectMake(2,height1-(46*height1/480), width1-4, 45*height1/480);
    
    [doneBtn setTitle:@"DONE" forState:UIControlStateNormal];
    doneBtn.titleLabel.textColor=[UIColor whiteColor];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneBtn.titleLabel.font=[UIFont systemFontOfSize:width1/15];
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"title_bar@3x.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
    
    userDefault = [NSUserDefaults standardUserDefaults];
    self.accountValueArray = [[NSMutableArray alloc]init];
    
    self.messageTypeValueArray = [[NSMutableArray alloc]init];
    
    
    NSMutableArray *firstAry = [userDefault objectForKey:@"WoosuiteAccountValue"];
    NSMutableArray *secAry = [userDefault objectForKey:@"WoosuiteMessageTypevale"];
    for (int i =0; i<firstAry.count; i++) {
        [self.accountValueArray addObject:[firstAry objectAtIndex:i]];
    }
    
    for (int i=0; i<secAry.count; i++) {
        [self.messageTypeValueArray addObject:[secAry objectAtIndex:i]];
    }
    
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark -
/*------------------------
 Pass a messsage to Delegate Method defined in InboxVC
 --------------------*/
-(void)doneAction{
    
    if (self.myDelegate != nil && [self.myDelegate respondsToSelector:@selector(passSelectedVlue:)]&& [self.accountValueArray containsObject:@"1"]) {
        [self.myDelegate passSelectedVlue:self.accountValueArray];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger sec=0;
    if (section == 0) {
        sec =  [self.allProfileInfoArray count];
	}
    
    else if (section == 1) {
		sec =  [arrMessageTypes count];
	}
    return sec ;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
    // return [self.sortedKeys count];
}
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *header = nil;
    if (section==0) {
        header=[NSString stringWithFormat:@"%@",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accountsMsg"]];
    }
    else if (section==1){
        header = [[SingletonClass sharedSingleton] languageSelectedStringForKey:@"msgTypeMsg"];
        
    }
    return header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30*height1/480;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45*height1/480;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font=[UIFont systemFontOfSize:width1/20];
    //cell.textLabel.backgroundColor =[UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:0.3];
    
    cell.backgroundColor = [UIColor clearColor];
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.contentView.backgroundColor=[UIColor whiteColor];
    header.layer.cornerRadius=5.0f;
    header.clipsToBounds=YES;
    header.textLabel.textColor = [UIColor blackColor];
    header.textLabel.font=[UIFont boldSystemFontOfSize:width1/18];
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:SimpleTableIdentifier forIndexPath:indexPath];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    for(UIImageView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    accessoryImageView = [[UIImageView alloc] init];
    accessoryImageView.frame = CGRectMake(width1-(45*width1/320), 5*height1/480, 25*width1/320, 25*width1/320);
    
    accessoryImageView.userInteractionEnabled=YES;
    [cell.contentView addSubview:accessoryImageView];
   
    
    if (indexPath.section==0) {
        
        NSString *str = [self.accountValueArray objectAtIndex:indexPath.row];
        if ([str isEqualToString:@"1"]) {
            accessoryImageView.image = [UIImage imageNamed:@"checkbox_clicked@3x.png"];
        }
        else{
            accessoryImageView.image = [UIImage imageNamed:@"checkbox@3x.png"];
        }
        
        //Assigning tag Value
        /*--------------------------------------
         Tag Value of Accery Button(Check Mark button) for First section  is combination of 1 and indexPath.row
         for EX: tag value for second row in first section
         is 1indexPath.row means ==  11
         ----------------------------*/
        NSString *tagString = [NSString stringWithFormat:@"1%d",(int)indexPath.row];
        accessoryImageView.tag=[tagString intValue];
        //------
        NSDictionary *dict = [self.allProfileInfoArray objectAtIndex:indexPath.row];
        cell.imageView.frame=CGRectMake(5, 0,40*width1/320 ,40*width1/320);
        NSString *proType = [dict objectForKey:@"ProfileType"];
        if ([proType isEqualToString:@"facebook"]) {
            cell.imageView.image=[UIImage imageNamed:@"facebook_icon.png"];
        }
        else if ([proType isEqualToString:@"twitter"]){
            cell.imageView.image=[UIImage imageNamed:@"twitter_icon.png"];
        }
        else if ([proType isEqualToString:@"googleplus"]){
            cell.imageView.image=[UIImage imageNamed:@"google_plus.png"];
        }
        else if ([proType isEqualToString:@"instagram"]){
            cell.imageView.image=[UIImage imageNamed:@"instagram.png"];
        }
        else if ([proType isEqualToString:@"linkedin"]){
            cell.imageView.image=[UIImage imageNamed:@"linkedin.png"];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]];
        
    }
    else if (indexPath.section==1){
        NSString *mesType = [arrMessageTypes objectAtIndex:indexPath.row];
        NSLog(@"Mes Type = %@",mesType);

        
        if (indexPath.row >! self.messageTypeValueArray.count-1) {
            NSString *str = [self.messageTypeValueArray objectAtIndex:indexPath.row];
            if ([str isEqualToString:@"1"]) {
                accessoryImageView.image = [UIImage imageNamed:@"checkbox_clicked@3x.png"];
            }
            else{
                accessoryImageView.image = [UIImage imageNamed:@"checkbox@3x.png"];
            }
        }
        //Assigning tag Value
        /*--------------------------------------
         Tag Value of Accery Button(Check Mark button) for Second section  is combination of 6 and indexPath.row
         for EX: tag value for second row in first section
         is 1indexPath.row means ==  61
         ----------------------------*/
        NSString *tagString = [NSString stringWithFormat:@"6%d",(int)indexPath.row];
        accessoryImageView.tag=[tagString intValue];
        NSString *messType = [arrMessageTypes objectAtIndex:indexPath.row];
        cell.textLabel.text= messType;
        
        if ([messType isEqualToString:@"Public Mentions"] || [messType isEqualToString:@"Messages"] || [messType isEqualToString:@"Retweets"]) {
            cell.imageView.image=[UIImage imageNamed:@"twitter_icon.png"];
        }
        else if ([messType isEqualToString:@"Comments"] || [messType isEqualToString:@"Wall Posts"]){
            cell.imageView.image=[UIImage imageNamed:@"facebook_icon.png"];
        }
        else if ([messType isEqualToString:@"Activities"]){
            cell.imageView.image=[UIImage imageNamed:@"google_plus.png"];
        }
        else{
            cell.imageView.image=[UIImage imageNamed:@"msgbox.png"];
            
        }
    }
    
    cell.textLabel.textColor=[UIColor whiteColor];
    
    return cell;
}



-(void) tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        NSLog(@"First Section Selected");
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.accountValueArray];
        NSString *value=[tempArray objectAtIndex:indexPath.row];
        [tempArray removeObjectAtIndex:indexPath.row];
        if ([value isEqualToString:@"0"]) {
            [tempArray insertObject:@"1" atIndex:indexPath.row];
        }
        else{
            [tempArray insertObject:@"0" atIndex:indexPath.row];
            
        }
        NSLog(@"%@",tempArray);
        self.accountValueArray = tempArray;
        [userDefault setObject:self.accountValueArray forKey:@"WoosuiteAccountValue"];
        
    }
    else{
        NSLog(@"Second Section Selected");
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.messageTypeValueArray];
         NSString *value=[tempArray objectAtIndex:indexPath.row];
        [tempArray removeObjectAtIndex:indexPath.row];
        //NSString *value=[tempArray objectAtIndex:indexPath.row];
        if ([value isEqualToString:@"0"]) {
            [tempArray insertObject:@"1" atIndex:indexPath.row];
        }
        else{
            [tempArray insertObject:@"0" atIndex:indexPath.row];
        }
         NSLog(@"%@",tempArray);
        self.messageTypeValueArray = tempArray;
        NSLog(@"%@",tempArray);
        [userDefault setObject:self.messageTypeValueArray forKey:@"WoosuiteMessageTypevale"];
        NSString *mesType = [arrMessageTypes objectAtIndex:indexPath.row];
        NSLog(@"Mes Type = %@",mesType);
        if ([mesType isEqualToString:@"Wall Posts"]) {
            if ([value isEqualToString:@"0"]) {
                [userDefault setObject:@"1" forKey:FacabookWallPostValue];
            }
            else{
                [userDefault setObject:@"0" forKey:FacabookWallPostValue];
            }
        }
        else if ([mesType isEqualToString:@"Comments"]){
            
        }
        else if ([mesType isEqualToString:@"Activities"]){
            if ([value isEqualToString:@"0"]) {
                [userDefault setObject:@"1" forKey:GooglePlusActivitiesValue];
            }
            else{
                [userDefault setObject:@"0" forKey:GooglePlusActivitiesValue];
            }
        }
        else if ([mesType isEqualToString:@"Public Mentions"]){
            if ([value isEqualToString:@"0"]) {
                [userDefault setObject:@"1" forKey:TwitterPublicMentionsValue];
            }
            else{
                [userDefault setObject:@"0" forKey:TwitterPublicMentionsValue];
            }
        }
        else if ([mesType isEqualToString:@"Messages"]){
            if ([value isEqualToString:@"0"]) {
                [userDefault setObject:@"1" forKey:TwitterMessagesValue];
            }
            else{
                [userDefault setObject:@"0" forKey:TwitterMessagesValue];
            }
        }
        else if ([mesType isEqualToString:@"Retweets"]){
            if ([value isEqualToString:@"0"]) {
                [userDefault setObject:@"1" forKey:TwitterRetweetsValue];
            }
            else{
                [userDefault setObject:@"0" forKey:TwitterRetweetsValue];
            }
        }
        else if ([mesType isEqualToString:@"Sent Messages"]){
            if ([value isEqualToString:@"0"]) {
                [userDefault setObject:@"1" forKey:SentMessagesValue];
            }
            else{
                [userDefault setObject:@"0" forKey:SentMessagesValue];
            }
        }
        else{
            NSLog(@"Mes Type Unknown");
        }
    }
    [userDefault synchronize];

    [tableView reloadData];
    
    
}
    
    
    
    

@end
