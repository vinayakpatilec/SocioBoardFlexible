//
//  Feeds.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 30/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "Feeds.h"
#import "UIImageView+WebCache.h"
#import "GroupViewController.h"
#import "FeedInboxViewController.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "RePostViewController.h"
#import "CustomFeedCell.h"
#import "ComposeMessageViewController.h"
#import "FHSTwitterEngine.h"
#import "NewTaskViewController.h"
#import "MBProgressHUD.h"
#import "TweetAccountCell.h"
#import "MenuViewController.h"

//#define TwitterConsumerKey @"3MKDaNRYQLNXQWPrO04DA"
//#define TwitterSecretKey @"JtdwKArwEVreno1F0EDgap9r3W0Si7ZogOwBCss"


@interface Feeds () <FeedInboxViewVontrollerDelegate, MBProgressHUDDelegate>{
    int width1;
    int height1;
    CGRect screenRect;

}
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation Feeds

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    indexTwitterCell=0;
       
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    //Add observer for handle Notification
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllFeedArray:) name:@"Update Linkedin Table" object:nil];
    //Create UI
    //self.headerView.backgroundColor=[UIColor clearColor];

    
    UIButton  *composeMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    composeMsg.frame = CGRectMake(width1-50, 15*height1/480,35*width1/320, 30*height1/480);
        //[composeMsg setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        // composeMsg.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    [composeMsg addTarget:self action:@selector(goToComposerMessage:) forControlEvents:UIControlEventTouchUpInside];
    [composeMsg setBackgroundImage:[UIImage imageNamed:@"edit_btn@3x.png"] forState:UIControlStateNormal];
        //[composeMsg setTitle:@"Save" forState:UIControlStateNormal];
    [self.view addSubview:composeMsg];
    
    
    UIButton  *logoBut = [UIButton buttonWithType:UIButtonTypeCustom];
    logoBut.frame = CGRectMake(10*width1/320, 15*height1/480, 40*width1/320,30*height1/480);
    [logoBut addTarget:self action:@selector(goToConnectedAccountInfo:) forControlEvents:UIControlEventTouchUpInside];
    [logoBut setBackgroundImage:[UIImage imageNamed:@"sb_icon@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoBut];

    
    
    self.feedSettingBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.feedSettingBtn.frame=CGRectMake(60*width1/320,15*height1/480, 200*width1/320,30*height1/480);
    self.feedSettingBtn.layer.borderWidth=1.0f;
    self.feedSettingBtn.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    self.feedSettingBtn.layer.cornerRadius = 7.0f;
    self.feedSettingBtn.clipsToBounds = YES;
    self.feedSettingBtn.backgroundColor = [UIColor whiteColor];
    [self.feedSettingBtn addTarget:self action:@selector(inboxSettingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.feedSettingBtn];

    
    
    

    self.titleLable=[[UILabel alloc]initWithFrame:CGRectMake(width1*60/320, 17*height1/480, 180*width1/320, 25*height1/480)];
    _titleLable.backgroundColor=[UIColor clearColor];
    _titleLable.textColor=[UIColor blackColor];
    _titleLable.font=[UIFont systemFontOfSize:width1/20];
    //
    _titleLable.text=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"feedsMsg"];
    self.titleLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_titleLable];
    
    
    UIImageView *dropDown=[[UIImageView alloc]initWithFrame:CGRectMake(170*width1/320, 5*height1/480, 25*width1/320, 20*width1/320)];
    dropDown.image=[UIImage imageNamed:@"drop_down_inbox@3x.png"];
    [self.feedSettingBtn addSubview:dropDown];
    

    
    currentSelection = -1;
    _buttonNum=-1;
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    conDict = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
}


//Display Connected Account Count switch to MenuViewController
- (IBAction)goToConnectedAccountInfo:(id) sender{
    MenuViewController *obj = [[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];
    
    [self presentViewController:obj animated:YES completion:nil];

    
}


- (IBAction) goToComposerMessage:(id)sender;
 {
       ComposeMessageViewController *composeViewController = [[ComposeMessageViewController alloc] initWithNibName:@"ComposeMessageViewController" bundle:nil];
    
    [self.tabBarController presentViewController:composeViewController animated:YES completion:nil];
    
}


//Display FeedInboxViewController
-(IBAction)inboxSettingButtonClicked:(id)sender{
    selectedTable=1;
    FeedInboxViewController *feed = [[FeedInboxViewController alloc]initWithNibName:@"FeedInboxViewController" bundle:nil];
    feed.delegate=self;
    [self presentViewController:feed animated:YES completion:nil];
}
#pragma mark -
/*
 Notification Observer Method for Update All Feed Table View
 ------------------*/
-(void) updateAllFeedArray:(NSNotification *)notificationInfo{
    if (self.allFeedArray && [self.selectedAccTypeStr isEqualToString:@"linkedin"]) {
        NSMutableDictionary *newDict = [notificationInfo object];
        NSLog(@"NewDict==%@",newDict);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void) {
            
            [self.allFeedArray insertObject:newDict atIndex:0];
            [self.feedTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
            NSLog(@"all message count==%lu",(unsigned long)self.allFeedArray.count);
        });
    }
    else{
        NSLog(@"Linledin Account not selected");
    }
}
#pragma mark -
#pragma mark Feed Inbox Setting Delegate
/*
 Delegate method of FeedInboxViewController pass acccInfo of selected account
 ---------------*/
-(void)selectedAccountInfo:(NSDictionary *)accInfo{

    @synchronized(self)
    {
        // your code goes here
        [NSThread detachNewThreadSelector:@selector(fetchedAllFeeds:) toTarget:self withObject:accInfo];
    }
    
    
}

#pragma mark -
-(void) displayActivityIndicator{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.dimBackground = YES;
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}
-(void)hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}
#pragma mark -
//Fetch All Feeds on the basis of Selected Account Type
-(void) fetchedAllFeeds:(NSDictionary *)accInfo{
     [self.tabBarController.tabBar setUserInteractionEnabled:NO];
    NSLog(@"Selected Account Info = %@",accInfo);
    //Check Expiry Date
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    self.selectedAccountDict = accInfo;
    self.allFeedArray=[[NSMutableArray alloc]init];
    NSString *str = [accInfo objectForKey:@"ProfileName"];
    self.titleLable.text = [NSString stringWithFormat:@"%@-%@",feedsMsg ,str];
    NSString *proType = [NSString stringWithFormat:@"%@",[accInfo objectForKey:@"ProfileType"]];
    NSString *proID = [NSString stringWithFormat:@"%@",[accInfo objectForKey:@"ProfileId"]];
    NSMutableArray *response = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if ([proType isEqualToString:@"facebook"]) {
        NSLog(@"Fetch facebook feeds");
        self.selectedAccTypeStr = @"facebook";
        response = [self fetchFacebookmessages:proID];
    }
    if ([proType isEqualToString:@"twitter"]) {
        myIndexPath=0;
        NSLog(@"Fetch Twiter messages");
        self.selectedAccTypeStr = @"twitter";
        response = [self fetchTwittermessages:proID];
    }
    
    else if([proType isEqualToString:@"tumblr"]){
        //NSLog(@"Fetch Linkedin Messages");
        self.selectedAccTypeStr = @"tumblr";
        response = [self fetchTumblrAccountFeeds:proID];
    }
    else if([proType isEqualToString:@"instagram"]){
        NSLog(@"Fetch Twitter messages");
        self.selectedAccTypeStr = @"instagram";
        response = [self getInstagramAccountDetail:proID];
    }
    else if([proType isEqualToString:@"linkedin"]){
        NSLog(@"Fetch Linkedin Messages");
        self.selectedAccTypeStr = @"linkedin";
        response = [self fetchLinkedinAccountFeed:proID];
    }
    
    else if([proType isEqualToString:@"youtube"]){
        //NSLog(@"Fetch Linkedin Messages");
        self.selectedAccTypeStr = @"youtube";
        response = [self fetchYoutubeAccountFeeds:proID];
    }
    


    
    //response = [self fetchLinkedinAccountFeed:@"3R5_mk6PGO"];
    for (int i =0; i<response.count; i++) {
        NSMutableDictionary *dict = [response objectAtIndex:i];
        NSString *postDate = nil;
        //Fetch Unix Time Stamp date
        if ([self.selectedAccTypeStr isEqualToString:@"linkedin"]) {
            postDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedsDate"]];
        }
        
        else if([self.selectedAccTypeStr isEqualToString:@"tumblr"])
        {
             postDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
        }
        else{
            postDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDate"]];
        }
        // Get Unix TimeStamp date in date Format and to All Feeds Array
        
        NSString *newDate = [self convertTodate:postDate];
        [dict setObject:newDate forKey:@"NewDate"];
        [tempArray addObject:dict];
    }
    
    //Sort Feeds on the basis if Date
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"NewDate" ascending:NO];
    NSArray *descriptors=[NSArray arrayWithObject: descriptor];
    NSArray *sortedArray=(NSMutableArray *)[tempArray sortedArrayUsingDescriptors:descriptors];

    self.allFeedArray = [NSMutableArray arrayWithArray:sortedArray];
    NSLog(@"All Feed Array = \n%@",self.allFeedArray);
    currentSelection = -1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //UI Code for display Feeds in Table View
    //if (self.feedTableView) {
         //   [self.feedTableView reloadData];
       // }
       // else{
        if(self.allFeedArray.count>0){
        feedCount=0;
        indexTwitterCell=0;
            self.feedTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,55*height1/480,width1-10,height1-(65*height1/480)) style:UITableViewStylePlain];
            self.feedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.view addSubview:self.feedTableView];
            self.feedTableView.delegate = self;
            self.feedTableView.dataSource = self;
        //}
        [self.feedTableView setContentOffset:CGPointZero animated:NO];
        }
        if (self.allFeedArray.count==0) {
            for(UITableView *view in self.view.subviews){
                if ([view isKindOfClass:[UITableView class]]) {
                    [view removeFromSuperview];
                }
            }
            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SorryMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"noMsgMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
           [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
            //self.feedTableView.hidden=YES;
            
        }
         [self.tabBarController.tabBar setUserInteractionEnabled:YES];
        [self.hud hide:YES];
    });
    
}
//Convert Unix Time Stamp Date to simple date format
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
    [_formatter setLocale:[NSLocale currentLocale]];
    NSLog(@"%@",_formatter);
    [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSLog(@"%@",_formatter);
    //[_formatter setDateFormat:@"MMM dd,yy hh:mm:ss a"];
    [_formatter setDateFormat:@"yyyy MM dd hh:mm:ss"];
    NSLog(@"%@",_formatter);
    entryDate=[_formatter stringFromDate:date];
    NSLog(@"Final Date --- %@",entryDate);
    
    return entryDate;
}
#pragma mark -
//Get Twitter Feeds
-(NSMutableArray *)fetchTwittermessages:(NSString *)twitterID{
    
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    
    NSLog(@"Twitter Id -==- %@",twitterID);
    @try {
        
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<GetAllTwitterFeedsByUserIdAndProfileId1 xmlns=\"http://tempuri.org/\">\n"
                                 "<UserId>%@</UserId>\n"
                                 "<ProfileId>%@</ProfileId>\n"
                                 "<count>%d</count>\n"
                                 "</GetAllTwitterFeedsByUserIdAndProfileId1>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",strUserid,twitterID,indexTwitterCell];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/TwitterFeed.asmx?op=GetAllTwitterFeedsByUserIdAndProfileId1",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/GetAllTwitterFeedsByUserIdAndProfileId1" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse   * response;
        NSError *error = nil;
        NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"Error try Again");
        }
        else{
            NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
             NSLog(@"respo==%@",responseString);
            NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
            if (response.length<1) {
//                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something Went Wrong" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                return nil;
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSLog(@"respo==%@",jsonArray);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
       //long int num=100;
           // NSLog(@"-----------------------%ld",jsonArray.count);
           // if(jsonArray.count>num)
              //  num=jsonArray.count;
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                [tempDict setObject:@"Twitter_Feed" forKey:SocialAccountType];
                [tempArray addObject:tempDict];
            }
            NSLog(@"Twitter Feed = %@",tempArray);
            return tempArray;
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
//        NSString * str = [NSString stringWithFormat:@"%@",exception];
//        
//        NSLog(@"Exception = %@",str);
    }
    @finally {
        //[self.hud hide:YES];
         NSLog(@"Finally Block");
    }
    
    return nil;
}



-(NSMutableArray *)fetchFacebookmessages:(NSString *)ID{
    
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"Twitter Id -==- %@",ID);
    @try {
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<getAllFacebookFeedsByUserIdAndProfileId1 xmlns=\"http://tempuri.org/\">\n"
                                 "<UserId>%@</UserId>\n"
                                 "<ProfileId>%@</ProfileId>\n"
                                  "<count>%d</count>\n"
                                 "</getAllFacebookFeedsByUserIdAndProfileId1>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",strUserid,ID,indexTwitterCell];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/FacebookFeed.asmx?op=getAllFacebookFeedsByUserIdAndProfileId1",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/getAllFacebookFeedsByUserIdAndProfileId1" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse   * response;
        NSError *error = nil;
        NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"Error try Again");
        }
        else{
            NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
            NSLog(@"respo==%@",responseString);
            NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
            if (response.length<1) {
                //                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something Went Wrong" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                return nil;
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSLog(@"respo==%@",jsonArray);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                [tempDict setObject:@"facebook" forKey:SocialAccountType];
                [tempArray addObject:tempDict];
            }
            NSLog(@"Twitter Feed = %@",tempArray);
            return tempArray;
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
        //        NSString * str = [NSString stringWithFormat:@"%@",exception];
        //
        //        NSLog(@"Exception = %@",str);
    }
    @finally {
        //[self.hud hide:YES];
        NSLog(@"Finally Block");
    }
    
    return nil;
}











//Get LickedinFeeds
-(NSMutableArray *) fetchLinkedinAccountFeed:(NSString *)accID{
    
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id -=-= %@",[SingletonClass sharedSingleton].profileID);
    @try {
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<GetLinkedInFeeds1 xmlns=\"http://tempuri.org/\">\n"
                                 "<UserId>%@</UserId>\n"
                                 "<LinkedInId>%@</LinkedInId>\n"
                                 "</GetLinkedInFeeds1>\n"
                                  "<count>%d</count>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",strUserid,accID,indexTwitterCell];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/LinkedInFeed.asmx?op=GetLinkedInFeeds1",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/GetLinkedInFeeds1" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse   * response;
        NSError *error = nil;
        NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"Error try Again");
        }
        else{
            NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
            //NSLog(@"respo==%@",responseString);
            NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
            if (response.length<1) {
                return nil;
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                [tempDict setObject:@"Linkedin" forKey:SocialAccountType];
                [tempArray addObject:tempDict];
            }
             NSLog(@"Linkedine Feed = %@",tempArray);
            return tempArray;
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
//        NSString * str = [NSString stringWithFormat:@"%@",exception];
//        
//        NSLog(@"Exception = %@",str);
    }
    @finally {
        //[self.hud hide:YES];
         NSLog(@"Finally Block");
    }
    
    return nil;
}
//Get Instagram Feeds

//-(void)getInstagramAccountDetail:(NSString*)accID{
    
    
    
    
    
//}




-(NSMutableArray *) getInstagramAccountDetail:(NSString *)accID{

        NSString *strUserid = [SingletonClass sharedSingleton].profileID;
        NSLog(@"profile id -=-= %@",[SingletonClass sharedSingleton].profileID);
    @try {
        
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetLinkedInFeeds xmlns=\"http://tempuri.org/\">\n"
                              "<UserId>%@</UserId>\n"
                             "<LinkedInId>%@</LinkedInId>\n"
                             "</GetLinkedInFeeds>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>",strUserid,accID];
    
            
            NSLog(@"soapMessg  %@",soapmessage);
    
    
 
    
    
    NSLog(@"soapMessg  %@",soapmessage);
            NSString *str= [NSString stringWithFormat:@"%@/Services/InstagramFeed.asmx?op=GetLinkedInFeeds",WebLink];
            NSURL *url = [NSURL URLWithString:str];
            
            NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
            
            NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
            [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [req addValue:@"http://tempuri.org/GetLinkedInFeeds" forHTTPHeaderField:@"SOAPAction"];
            [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
            [req setHTTPMethod:@"POST"];
            [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSHTTPURLResponse   * response;
            NSError *error = nil;
            NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
            
            if (error) {
                NSLog(@"Error try Again");
            }
            else{
                
                NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
                NSLog(@"respo==%@",responseString);
                NSString *response = [HelperClass stripTags:responseString startString:@"[{" upToString:@"}]"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
        NSMutableArray *jsonArray = [jsonString JSONValue];
        //NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSLog(@"----------%@",jsonArray);
        //return tempArray;
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for (int i=0; i<jsonArray.count; i++) {
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                    
                    tempDict =[jsonArray objectAtIndex:i];
                    [tempDict setObject:@"Instagram" forKey:SocialAccountType];
                    [tempArray addObject:tempDict];
                    NSLog(@"%@",[tempDict objectForKey:SocialAccountType]);
                }
                
                NSLog(@"=========%@",tempArray);
                return tempArray;
                
            }
        
                
        }
    
    @catch (NSException *exception) {
        [self.hud hide:YES];
       
    }
    @finally {
                NSLog(@"Finally Block");
    }

    
    
    
    
    
    
    
    
    }

//+++++++++++++++++++++++++++++++++++=====================
-(NSMutableArray *) fetchTumblrAccountFeeds:(NSString *)accID{
    
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id -=-= %@",[SingletonClass sharedSingleton].profileID);
    
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetAllTumblrFeedOfUsers xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<ProfileId>%@</ProfileId>\n"
                             "</GetAllTumblrFeedOfUsers>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserid,accID];
    NSLog(@"soapMessg  %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/TumblrFeed.asmx?op=GetAllTumblrFeedOfUsers",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetAllTumblrFeedOfUsers" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse   * response;
    NSError *error = nil;
    NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error try Again");
    }
    else{
        NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
        NSLog(@"respo===================================%@",responseString);
        NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
          NSLog(@"respo=============================================%@",jsonString);
        NSMutableArray *jsonArray = [jsonString JSONValue];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSLog(@"%d",(int)jsonArray.count);
        for (int i=0; i<jsonArray.count; i++) {
            NSMutableDictionary *tempDict = nil;
            tempDict =[jsonArray objectAtIndex:i];
            [tempDict setObject:@"Tumblr" forKey:SocialAccountType];
            [tempArray addObject:tempDict];
        } NSLog(@"respo===========================================%@",tempArray);
        return tempArray;
    }
    return nil;
}


-(NSMutableArray *) fetchYoutubeAccountFeeds:(NSString *)accID{
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id -=-= %@",[SingletonClass sharedSingleton].profileID);
    
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetYoutubeChannelVideos xmlns=\"http://tempuri.org/\">\n"
                             "<userid>%@</userid>\n"
                             "<profileid>%@</profileid>\n"
                             "</GetYoutubeChannelVideos>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserid,accID];
    NSLog(@"soapMessg  %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/Youtube.asmx?op=GetYoutubeChannelVideos",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetYoutubeChannelVideos" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse   * response;
    NSError *error = nil;
    NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error try Again");
    }
    else{
        NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
        NSLog(@"respo===================================%@",responseString);
        NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
        NSLog(@"respo=============================================%@",jsonString);
        NSMutableArray *jsonArray = [jsonString JSONValue];
    
    
        return jsonArray;

    }
    return nil;
}


#pragma mark -
#pragma mark TableView Delegate and DataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView || tableView == self.searchTableView) {
        return [self.searchArray count];
    }
    else if (tableView == self.tweeterAccountTableView){
        return self.twitterAccountArray.count;
        
    }
     //NSString *proType = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfileType"]];
    //if([proType isEqualToString:@"twitter"]){
      //  return indexTwitterCell+10;
   // }
    //else
    return self.allFeedArray.count;
    //return 50;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tweeterAccountTableView) {
        return 40;
    }
    
    NSDictionary *dict = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView || tableView == self.searchTableView) {
        dict = [self.searchArray objectAtIndex:indexPath.row];
        //return 100;
    }
    else{
        dict = [self.allFeedArray objectAtIndex:indexPath.row];
    }
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    CGFloat h=0;
    
    NSLog(@"%@",accountType);
    if ([accountType isEqualToString:@"facebook"]) {
        NSString *str=[NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDescription"]];
        NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:str attributes:conDict];
        //get height for display Feed
        h = [self textViewHeightForAttributedText:messtr andWidth:width1-70];
        if (h<30) {
            h = 30;
        }
        h = h + 55;
    }

    
    if ([accountType isEqualToString:@"Twitter_Feed"]) {
        NSString *str=[NSString stringWithFormat:@"%@",[dict objectForKey:@"Feed"]];
        NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:str attributes:conDict];
        //get height for display Feed
        h = [self textViewHeightForAttributedText:messtr andWidth:width1-70];
        if (h<30) {
            h = 30;
        }
        h = h + 55;
    }
    else if ([accountType isEqualToString:@"Linkedin"]){
        NSString *str=[NSString stringWithFormat:@"%@",[dict objectForKey:@"Feeds"]];
        NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:str attributes:conDict];
        //get height for display Feed
        h = [self textViewHeightForAttributedText:messtr andWidth:width1-70];
        if (h<30) {
            h = 30;
        }
        h = h + 55;
    }
    else if ([accountType isEqualToString:@"Instagram"]){
        h=280;
    }
        
    else if ([accountType isEqualToString:@"Tumblr"]){
        NSString *str=[NSString stringWithFormat:@"%@",[dict objectForKey:@"description"]];
        NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:str attributes:conDict];
        //get height for display Feed
        h = [self textViewHeightForAttributedText:messtr andWidth:width1-70];
        if (h<30) {
            h = 30;
        }
        NSLog(@"------------%@",[dict objectForKey:@"imageurl"]);
        if([[NSString stringWithFormat:@"%@",[dict objectForKey:@"imageurl"]] isEqualToString:@"<null>"]){
            h=h+50;
        }else{
            h=h+260;
        }
    }
    if (currentSelection == indexPath.row) {
        h=h+50;
    }
    
    return (h+20);
}
//return appropriate height for display Feeds
- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    heightofText=size.height;
    return size.height;
}


    

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    static NSString *CellIdentifier = @"Cell Identifier";
   //table to display account when favorit button is pressed
    if (tableView==self.tweeterAccountTableView) {
        TweetAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil) {
            cell = [[TweetAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        //check selected cell row count
        if (selectedTwitterAccountRow==indexPath.row) {
            cell.backView.image = [UIImage imageNamed:@"select.png"];
        }
        else{
            cell.backView.image = [UIImage imageNamed:@"unselect.png"];
        }
        NSDictionary *dict = [self.twitterAccountArray objectAtIndex:indexPath.row];
        NSString *imageUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfilePicUrl"]];
        NSString *nameString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]];
        [cell.profilePic setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        cell.nameLable.textColor = [UIColor blackColor];
        cell.nameLable.text = nameString;
        return cell;
    }
    
//table to display feeds
    
CustomFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        
        cell = [[CustomFeedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.nameLable.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
                }
    
    [cell.moreButton addTarget:self action:@selector(moreButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
    
    //[cell.moreButton addTarget:self action:@selector(moreButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
    //[cell.taskButton addTarget:self action:@selector(taskButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.menuButton.tag=indexPath.row;
    [cell.menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
   
    if (tableView==self.feedTableView) {
        self.currentSelectedTable = @"FeedTable";
    }
    else if (tableView==self.searchTableView){
        self.currentSelectedTable = @"SearchTable";
    }
    
    
    if (currentSelection == indexPath.row) {
        cell.menuView.frame = menuCellFrame;
        cell.menuView.hidden = NO;
    }
    else{
        cell.menuView.frame = CGRectZero;
        cell.menuView.hidden = YES;
    }
    
    NSDictionary *dict = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView || tableView == self.searchTableView) {
        dict = [self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        dict = [self.allFeedArray objectAtIndex:indexPath.row];
    }
    
   cell.dateLable.text = [[[NSString stringWithFormat:@"%@",[dict objectForKey:@"NewDate"]] substringToIndex:10] stringByReplacingOccurrencesOfString:@" " withString:@"/"];
    
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    //[self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    if ([accountType isEqualToString:@"facebook"]) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [self.hud hide:YES];
        if (!(tableView == self.searchDisplayController.searchResultsTableView || tableView == self.searchTableView)){
            if(self.allFeedArray.count>(9+indexTwitterCell)){
                if(indexPath.row==(self.allFeedArray.count-10))
                {
                    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
                    
                    indexTwitterCell=indexTwitterCell+10;
                    NSString *proID = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfileId"]];
                    NSMutableArray *response = [[NSMutableArray alloc] init];
                    response=[self fetchFacebookmessages:proID];
                    
                    for (int i =0; i<response.count; i++) {
                        NSMutableDictionary *dict = [response objectAtIndex:i];
                        
                        NSString *postDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDate"]];
                        NSString *newDate = [self convertTodate:postDate];
                        [dict setObject:newDate forKey:@"NewDate"];
                        
                        [tempArray addObject:dict];
                    }
                    NSLog(@"%@",tempArray);
                    [self.allFeedArray addObjectsFromArray:tempArray];
                    [self.feedTableView reloadData];
                    
                }
            }
        }

        
        
        
              cell.picView.frame=CGRectMake(0, 0, 0, 0);
        NSString *proPic = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:proPic] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        
        NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDescription"]];
        message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:message attributes:conDict];
        CGFloat height = [self textViewHeightForAttributedText:str andWidth:width1-70];
        if (height<30) {
            height = 30;
        }
        cell.messageTxtView.frame = CGRectMake(50, 30, width1-70, height);
        cell.messageTxtView.attributedText = str;
        cell.nameLable.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromName"]];
        cell.taskButton.frame=CGRectMake(135, 9, 35, 35);
        cell.moreButton.frame=CGRectMake(40, 9, 35, 35);
        [cell.menuView addSubview:cell.moreButton];
        [cell.menuView addSubview:cell.taskButton];
        //[cell.menuView addSubview:cell.repostButton];
        [cell addSubview:cell.menuButton];
    }
    

    
 //cell for twitter account
    if ([accountType isEqualToString:@"Twitter_Feed"]) {
                     myIndexPath=indexPath.row;
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [self.hud hide:YES];
        if (!(tableView == self.searchDisplayController.searchResultsTableView || tableView == self.searchTableView)){
            if(self.allFeedArray.count>(9+indexTwitterCell)){
        if(indexPath.row==(self.allFeedArray.count-10))
        {
            [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
            
            indexTwitterCell=indexTwitterCell+10;
            NSString *proID = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfileId"]];
            NSMutableArray *response = [[NSMutableArray alloc] init];
            response=[self fetchTwittermessages:proID];
            
            for (int i =0; i<response.count; i++) {
                NSMutableDictionary *dict = [response objectAtIndex:i];
            
           NSString *postDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDate"]];
            NSString *newDate = [self convertTodate:postDate];
            [dict setObject:newDate forKey:@"NewDate"];
               
            [tempArray addObject:dict];
            }
            NSLog(@"%@",tempArray);
            [self.allFeedArray addObjectsFromArray:tempArray];
            [self.feedTableView reloadData];
            
        }
        }
        }

        cell.picView.frame=CGRectMake(0, 0, 0, 0);
        NSString *proPic = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:proPic] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        
        NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feed"]];
       
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:message attributes:conDict];
        CGFloat height = [self textViewHeightForAttributedText:str andWidth:width1-70];
        if (height<30) {
            height = 30;
        }
        cell.messageTxtView.frame = CGRectMake(50, 30, width1-70, height);
        cell.messageTxtView.attributedText = str;
        cell.nameLable.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromScreenName"]];
        
        [cell.menuView addSubview:cell.moreButton];
        [cell.menuView addSubview:cell.taskButton];
        [cell.menuView addSubview:cell.repostButton];
        [cell addSubview:cell.menuButton];
    }
    
    
    
//cell for linkedin account
    else if ([accountType isEqualToString:@"Linkedin"]){
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [self.hud hide:YES];
        if(self.allFeedArray.count>(9+indexTwitterCell)){
         if (!(tableView == self.searchDisplayController.searchResultsTableView || tableView == self.searchTableView)){
        if(indexPath.row==(self.allFeedArray.count-10))
        {
            [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
            
            indexTwitterCell=indexTwitterCell+10;
            NSString *proID = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfileId"]];
            NSMutableArray *response = [[NSMutableArray alloc] init];
            response=[self fetchLinkedinAccountFeed:proID];
            
            for (int i =0; i<response.count; i++) {
                NSMutableDictionary *dict = [response objectAtIndex:i];
                
                NSString *postDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDate"]];
                NSString *newDate = [self convertTodate:postDate];
                [dict setObject:newDate forKey:@"NewDate"];
                
                [tempArray addObject:dict];
            }
            NSLog(@"%@",tempArray);
            [self.allFeedArray addObjectsFromArray:tempArray];
            [self.feedTableView reloadData];
            
            
        }

         }
        }
        cell.picView.frame=CGRectMake(0, 0, 0, 0);
        NSString *proPic = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromPicUrl"]];
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:proPic] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feeds"]];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:message attributes:conDict];
        CGFloat height = [self textViewHeightForAttributedText:str andWidth:width1-70];
        if (height<30) {
            height = 30;
        }
        cell.messageTxtView.frame = CGRectMake(50, 30, width1-70, height);
        cell.messageTxtView.attributedText = str;
        cell.nameLable.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromName"]];
        [cell.menuView addSubview:cell.moreButton];
        [cell.menuView addSubview:cell.taskButton];
        [cell.menuView addSubview:cell.repostButton];
        [cell addSubview:cell.menuButton];
    }
    
    
//cell for tumblr account
    else if([accountType isEqualToString:@"Tumblr"])
    {
        
        
        cell.nameLable.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"blogname"]];
        cell.nameLable.frame=CGRectMake(10, 10, 200, 30);
               [cell.profileImageView setImage:[UIImage imageNamed:@"heart-icon.png"]];
         NSString *noteStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"notes"]];
        int note=[noteStr intValue];
      
       
        cell.like1.text=[NSString stringWithFormat:@"%d",note];
        NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"description"]];
        NSString *slug=[NSString stringWithFormat:@"%@",[dict objectForKey:@"slug"]];
        message = [message stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
       NSAttributedString *str = [[NSAttributedString alloc] initWithString:message attributes:conDict];
        CGFloat height = [self textViewHeightForAttributedText:str andWidth:width1-70];
        if (height<30) {
                            height = 30;
                       }
        
        
        NSString *PicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"imageurl"]];
        
        
        if(![PicStr isEqualToString:@"<null>"]){
          
        cell.like1.frame = CGRectMake(width1/2-90,260, 180, 25);
         cell.profileImageView.frame=CGRectMake(width1/2-110, 263,16,16);
        cell.picView.frame=CGRectMake(width1/2-110,40,220,220);
        [cell.picView setImageWithURL:[NSURL URLWithString:PicStr]];
        cell.messageTxtView.frame = CGRectMake(25,280, width1-70, height);
            cell.messageTxtView.attributedText = str;
            
        }
        else{
            cell.like1.frame = CGRectMake(width1/2-110,35, 180, 25);
            cell.profileImageView.frame=CGRectMake(width1/2-130,38,16,16);
            if([message isEqual:@""]){
                cell.picView.frame=CGRectMake(0,0,0,0);
                NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:slug attributes:conDict];
                CGFloat height2 = [self textViewHeightForAttributedText:str2 andWidth:width1-70];
                if (height2<30) {
                    height2 = 30;
                            }
                

                cell.messageTxtView.text=slug;
                cell.messageTxtView.frame = CGRectMake(35, 57, width1-70, height2);
           
            }
            else{
                cell.messageTxtView.attributedText = str;
                cell.picView.frame=CGRectMake(0,0,0,0);
                cell.messageTxtView.frame = CGRectMake(35,57, width1-70, height);
                
            }
        
        }
    }
//-------------------------------
    
        else if([accountType isEqualToString:@"Instagram"])
        {
            UIButton *instLike=[[UIButton alloc]initWithFrame:CGRectMake(10, 18,17,17)];
            [instLike setBackgroundImage:[UIImage imageNamed:@"heart-icon.png"]forState:UIControlStateNormal];
            [cell addSubview:instLike];
            instLike.tag=indexPath.row;
            [instLike addTarget:self action:@selector(instagramLike:) forControlEvents:UIControlEventTouchUpInside];
            
            //cell.profileImageView.frame=CGRectMake(10, 18,16,16);
            //[cell.profileImageView setImage:[UIImage imageNamed:@"heart-icon.png"]];
            NSString *noteStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"LikeCount"]];
            int note=[noteStr intValue];
            cell.nameLable.frame = CGRectMake(30, 13, 180, 25);
            cell.nameLable.text=[NSString stringWithFormat:@"%d",note];
            NSString *message = [NSString stringWithFormat:@"comment:%@",[dict objectForKey:@"CommentCount"]];
            
           
            
            
            NSString *PicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedImageUrl"]];
            
            
          
                
                cell.picView.frame=CGRectMake((width1-10)/2-110,40,220,220);
                [cell.picView setImageWithURL:[NSURL URLWithString:PicStr]];
                cell.messageTxtView.frame = CGRectMake(20,260, width1-70, 30);
            cell.messageTxtView.font=[UIFont systemFontOfSize:16.0f];
                cell.messageTxtView.text = message;
          
        }
        
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    CustomFeedCell* ccell = (CustomFeedCell*)cell;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGstur:)];
    tap.numberOfTapsRequired = 1;
    ccell.profileImageView.userInteractionEnabled = YES;
    ccell.profileImageView.tag=indexPath.row;
    [ccell.profileImageView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGstur1:)];
    tap.numberOfTapsRequired = 1;
    ccell.picView.userInteractionEnabled = YES;
    ccell.picView.tag=indexPath.row;
    [ccell.picView addGestureRecognizer:tap1];
    

    ccell.menuButton.frame=CGRectMake(width1-60,heightofText+ccell.messageTxtView.frame.origin.y, 40, 40);
    [ccell.menuButton setBackgroundImage:[UIImage imageNamed:@"hiddenView.jpg"] forState:UIControlStateNormal];

}




-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==self.tweeterAccountTableView) {
        selectedTwitterAccountRow = (int)indexPath.row;
        [tableView reloadData];
        return;
    }
    
    if (currentSelection == indexPath.row) {
        return;
    }
    int row = (int)[indexPath row];
    currentSelection = row;
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.allFeedArray.count!=0){
    if (tableView==self.feedTableView) {
        NSDictionary *dict = [self.allFeedArray objectAtIndex:0];
        NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
        if(([accountType isEqualToString:@"Instagram"])||([accountType isEqualToString:@"Tumblr"])){
            return 0;
        }
        return 30;
    }
    }
    return  0;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (tableView==self.feedTableView) {
        NSDictionary *dict = [self.allFeedArray objectAtIndex:0];
        NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
        if(([accountType isEqualToString:@"Instagram"])||([accountType isEqualToString:@"Tumblr"])){
            return nil;
        }
        self.tweetSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 52, 320, 30)];
        //self.tweetSearchBar.frame = CGRectMake(0, 0, 320, 44);
        self.tweetSearchBar.barStyle = UIBarStyleDefault;
        self.tweetSearchBar.showsCancelButton=NO;
        self.tweetSearchBar.layer.cornerRadius=5.0f;
        self.tweetSearchBar.autocorrectionType= UITextAutocorrectionTypeYes;
        self.tweetSearchBar.placeholder = [[SingletonClass sharedSingleton] languageSelectedStringForKey:@"searchMsg"];
        self.tweetSearchBar.tintColor = [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)235/255 blue:(CGFloat)235/255 alpha:1.0];
        for (UIView *subView in self.tweetSearchBar.subviews){
            
            if([subView isKindOfClass:[UITextField class]]){
                subView.layer.borderWidth = 1.0f;
                subView.layer.borderColor =[UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)176/255 blue:(CGFloat)176/255 alpha:1.0].CGColor;
                subView.layer.cornerRadius = 15;
                subView.clipsToBounds = YES;
                
            }
        }
        self.tweetSearchBar.delegate=self;
        return self.tweetSearchBar;
    }
    return nil;
}
#pragma mark -
#pragma mark instagramlike

-(void)instagramLike:(UIButton*)like{
       NSDictionary *dict2=[self.allFeedArray objectAtIndex:like.tag];
    NSString *likeCount=[dict2 objectForKey:@"LikeCount"];
    NSLog(@"%@",likeCount);
     NSString *FeedId=[dict2 objectForKey:@"FeedId"];
     NSLog(@"%@",FeedId);
     NSString *InstagramId=[dict2 objectForKey:@"InstagramId"];
     NSLog(@"%@",InstagramId);
     NSString *userId=[SingletonClass sharedSingleton].profileID;
     NSLog(@"%@",userId);
    NSString *isLike=[dict2 objectForKey:@"IsLike"];
    isLike=@"1";
    NSLog(@"%@",isLike);
    //if([isLike isEqualToString:@"0"]){
    
  // }
    //else{
      // isLike=@"0";
   // }
    
    @try {
        
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<InstagramLikeUnLike xmlns=\"http://tempuri.org/\">\n"
                                 "<LikeCount>%@</LikeCount>\n"
                                 "<IsLike>%@</IsLike>\n"
                                 "<FeedId>%@</FeedId>\n"
                                 "<InstagramId>%@</InstagramId>\n"
                                 "<UserId>%@</UserId>\n"                                 "</GetLinkedInFeeds>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>",likeCount,isLike,FeedId,InstagramId,userId];
        
        
        NSLog(@"soapMessg  %@",soapmessage);
        
        
        
        
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/Instagram.asmx?op=InstagramLikeUnLike",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/InstagramLikeUnLike" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse   * response;
        NSError *error = nil;
        NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        if (error) {
            NSLog(@"Error try Again");
        }
        else{
            
            NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
            NSLog(@"respo==%@",responseString);
            NSString *response = [HelperClass stripTags:responseString startString:@"[{" upToString:@"}]"];
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
           
            return;
        }
        
        
    }

    
    @catch (NSException *exception) {
        [self.hud hide:YES];
        
    }
    @finally {
        NSLog(@"Finally Block");
    }
    

    
}




#pragma mark -
#pragma mark handleGesture



-(void)handleTapGstur:(UITapGestureRecognizer*)sender{
    //UIView *v = (UIControl *)sender;
    //UITapGestureRecognizer *tap = (UITapGestureRecognizer*)v;
    self.tabBarController.tabBar.hidden = YES;
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    UIImageView *img = (UIImageView *)sender.view;
    NSDictionary *dict=nil;
    if(selectedTable==1){
        dict= [self.allFeedArray objectAtIndex:img.tag];
    }else{
        dict= [self.searchArray objectAtIndex:img.tag];
    }
    NSLog(@"%d",(int)img.tag);
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    
    NSLog(@"%f",screenRect.size.height);
    _picView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,width1 , height1)];
    _picView.backgroundColor=[UIColor blackColor];
   
    
    
    UIView *header=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1,45*height1/480)];
    [header setBackgroundColor:[UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1]];
    [_picView addSubview:header];
    UIButton  *savePicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    savePicVw.frame = CGRectMake(250*width1/320, 10*height1/480, 60*width1/320, 30*height1/480);
    [savePicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    savePicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [savePicVw addTarget:self action:@selector(saveImage1) forControlEvents:UIControlEventTouchUpInside];
    [savePicVw setTitle:@"Save" forState:UIControlStateNormal];
    [header addSubview:savePicVw];

    
    
    UIButton  *cancelPicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelPicVw.frame = CGRectMake(5*width1/320, 10*height1/480, 35*height1/480,30*height1/480);
    //[cancelPicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //cancelPicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [cancelPicVw addTarget:self action:@selector(cancelPicView) forControlEvents:UIControlEventTouchUpInside];
    [cancelPicVw setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    //[cancelPicVw setTitle:@"Back" forState:UIControlStateNormal];
    [header addSubview:cancelPicVw];

    NSString *proPicStr=@"";
    
    if ([accountType isEqualToString:@"Twitter_Feed"]) {
        
        proPicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
         proPicStr = [proPicStr stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
        NSLog(@"%@",proPicStr);
        
                            
    }
    else if([accountType isEqualToString:@"Linkedin"]){
        proPicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromPicUrl"]];

        
    }
    else if([accountType isEqualToString:@"facebook"]){
       proPicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
        proPicStr = [proPicStr stringByReplacingOccurrencesOfString:@"small" withString:@"large"];
        
    }
    
    [self.view bringSubviewToFront:_picView];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:proPicStr]];
    UIImage *Im=[UIImage imageWithData:data];
    
    UIImageView *proPic=[[UIImageView alloc]init];
    
    int imgHeight=0;
    int imgWidth=0;
    int imgStartx=3;
    int imgStarty=0;
    if(Im.size.width>(width1-6)){
        Im=[self imageWithImage:Im scaledToWidth:(width1-6)];
        imgWidth=(width1-6);
    }
    else{
        imgWidth=Im.size.width;
        imgStartx=(screenRect.size.width/2)-(Im.size.width/2);
    }
    if(Im.size.height>(screenRect.size.height-50)){
        imgHeight=(screenRect.size.height-50);
        imgStarty=50;
    }
    else{
        imgStarty=((screenRect.size.height+50)/2)-(Im.size.height/2);
        imgHeight=Im.size.height;
        
        
        
    }
    
    
    proPic=[[UIImageView alloc]initWithFrame:CGRectMake(imgStartx,imgStarty,imgWidth,imgHeight)];
    
    
    _imageSave=Im;

    [proPic setImage:Im];
    _picView.hidden=NO;
    [self.view addSubview:_picView];
    [_picView addSubview:proPic];
    [self.hud hide:YES];

}


-(void)handleTapGstur1:(UITapGestureRecognizer*)sender{
    
    self.tabBarController.tabBar.hidden = YES;
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    UIImageView *img = (UIImageView *)sender.view;
    NSDictionary *dict=[self.allFeedArray objectAtIndex:img.tag];
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    

 NSLog(@"%f",screenRect.size.height);
    _picView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,width1 , 0)];
    _picView.backgroundColor=[UIColor blackColor];
    
    
    
    UIView *header=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 45*height1/480)];
    [header setBackgroundColor:[UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1]];
    [_picView addSubview:header];
    
    UIButton  *savePicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    savePicVw.frame = CGRectMake(250*width1/320, 10*height1/480, 60*width1/320, 30*height1/480);
    [savePicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    savePicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [savePicVw addTarget:self action:@selector(saveImage1) forControlEvents:UIControlEventTouchUpInside];
    [savePicVw setTitle:@"Save" forState:UIControlStateNormal];
    [header addSubview:savePicVw];
    
    
    
    UIButton  *cancelPicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelPicVw.frame = CGRectMake(5*width1/320, 10*height1/480, 35*height1/480, 30*height1/480);
    [cancelPicVw setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];

    //[cancelPicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //cancelPicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [cancelPicVw addTarget:self action:@selector(cancelPicView) forControlEvents:UIControlEventTouchUpInside];
    
    //[cancelPicVw setTitle:@"Back" forState:UIControlStateNormal];
    [header addSubview:cancelPicVw];
    
    
    NSString *proPicStr=@"";
    if ([accountType isEqualToString:@"Tumblr"]) {
        
    proPicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"imageurl"]];
        
    }
    else if([accountType isEqualToString:@"Instagram"]){
        proPicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedImageUrl"]];
    
    }
   
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:proPicStr]];
    UIImage *Im=[UIImage imageWithData:data];
  
    NSLog(@"%f",Im.size.width);
     NSLog(@"%f",Im.size.height);
    UIImageView *proPic=[[UIImageView alloc]init];
    int imgHeight=0;
    int imgWidth=0;
    int imgStartx=3;
    int imgStarty=0;
    if(Im.size.width>(width1-6)){
        Im=[self imageWithImage:Im scaledToWidth:(width1-6)];
        imgWidth=(width1-6);
    }
    else{
        imgWidth=Im.size.width;
        imgStartx=(screenRect.size.width/2)-(Im.size.width/2);
    }
    if(Im.size.height>(screenRect.size.height-50)){
        imgHeight=(screenRect.size.height-50);
        imgStarty=50;
    }
    else{
         imgStarty=((screenRect.size.height+50)/2)-(Im.size.height/2);
        imgHeight=Im.size.height;
       
        
       
    }
  
        proPic=[[UIImageView alloc]initWithFrame:CGRectMake(imgStartx,imgStarty,imgWidth,0)];
        
    
    
    [proPic setImage:Im];

       _picView.hidden=NO;
    [self.view addSubview:_picView];

    [self.view bringSubviewToFront:_picView];

     _imageSave=img.image;
    [_picView addSubview:proPic];
    [self.hud hide:YES];
    [UIView animateWithDuration:.4 animations:^{
         _picView.frame=CGRectMake(0, 0,screenRect.size.width , screenRect.size.height);
        proPic.frame=CGRectMake(imgStartx,imgStarty,imgWidth,imgHeight);
    }];
    
}
-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    NSLog(@"%f",scaleFactor);
    float newHeight = sourceImage.size.height * scaleFactor;
    NSLog(@"%f",newHeight);
    
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
//http://api.linkedin.com/v1/people/rS04fxQbOM/picture-url

-(void)cancelPicView{
    self.tabBarController.tabBar.hidden =NO;
    _picView.hidden=YES;
}


- (void)saveImage1
{
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    UIImageWriteToSavedPhotosAlbum(_imageSave, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self.hud hide:YES];
    if (error == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"imgSaved"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [alertView show];
        [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
        [self cancelPicView];
        //NSLog(@"Couldn't save image");
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"couldntImgSaved"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [alertView show];
        [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
        [self cancelPicView];

        //NSLog(@"Saved image");
    }
}


#pragma mark -
#pragma mark Search Bar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    if (!self.dimlightView) {
        self.dimlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 105, width1,height1)];
        
        self.dimlightView.backgroundColor = [UIColor blackColor];
        self.dimlightView.alpha=.4;
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
    self.dimlightView.hidden=NO;
    [self.view addSubview:self.dimlightView];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //[searchBar setShowsCancelButton:NO animated:YES];
    selectedTable=1;
    searchBar.text=@"";
    currentSelection = -1;
    self.dimlightView.hidden=YES;
    [self.feedTableView setContentOffset:CGPointZero];
    [self.feedTableView reloadData];
    searchBar.showsCancelButton=NO;
    [searchBar resignFirstResponder];
    
    [self.view addSubview:self.feedTableView];
    self.searchTableView.hidden=YES;
    self.searchTableView = nil;
    [self.searchTableView removeFromSuperview];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Search Text==%@",searchText);
    searchWord=searchText;
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar setShowsCancelButton:YES animated:YES];
    [self filterContentForSearchText:searchWord scope:@"All"];
    currentSelection = -1;
    if (self.searchTableView) {
        self.searchTableView = nil;
        [self.searchTableView removeFromSuperview];
    }
    
    CGRect frame = CGRectMake(self.feedTableView.frame.origin.x, self.feedTableView.frame.origin.y+30, self.feedTableView.frame.size.width, self.feedTableView.frame.size.height);
    self.searchTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.searchTableView.backgroundColor= [UIColor redColor];
    self.searchTableView.dataSource=self;
    self.searchTableView.delegate=self;
    //self.searchTableView.backgroundColor= [UIColor clearColor];
    [self.view addSubview:self.searchTableView];
    selectedTable=2;
    [searchBar resignFirstResponder];
}

//Filter All feeds on the basis on entered keyword on the Search Bar
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
	
    // Remove all objects from the filtered search array
	//[self.searchArray removeAllObjects];
    
    NSPredicate *predicate = nil;
    if ([self.selectedAccTypeStr isEqualToString:@"twitter"]) {
        predicate = [NSPredicate predicateWithFormat:@"SELF.Feed contains[c] %@",searchText];
    }
    else if ([self.selectedAccTypeStr isEqualToString:@"linkedin"]){
        predicate = [NSPredicate predicateWithFormat:@"SELF.Feeds contains[c] %@",searchText];
    }
    else if ([self.selectedAccTypeStr isEqualToString:@"facebook"]){
        predicate = [NSPredicate predicateWithFormat:@"SELF.Feeds contains[c] %@",searchText];
    }
    else{
        
    }
    
	// Filter the array using NSPredicate
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.Feed contains[c] %@",searchText];
    NSArray *tempArray = [self.allFeedArray filteredArrayUsingPredicate:predicate];
    
    if(![scope isEqualToString:@"All"]) {
        // Further filter the array with the scope
        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    }
   
    self.searchArray = [NSMutableArray arrayWithArray:tempArray];
    //[self.feedTableView reloadData];
    
    
}
//***********************************************************
#pragma mark -
#pragma mark Cell Menu button Action
/*
 Menu Option(Selected Cell)
 //More Button Action
 ---------------*/


-(void)menuButtonAction:(UIButton*)button
{
    if(currentSelection!=(int)button.tag)
   {
        
        currentSelection=(int)button.tag;
        _buttonNum=currentSelection;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
       CustomFeedCell *cell;
       if(selectedTable==1){
        cell = (CustomFeedCell *)[_feedTableView cellForRowAtIndexPath:indexPath];
        [_feedTableView beginUpdates];
       }else{
           cell = (CustomFeedCell *)[_searchTableView cellForRowAtIndexPath:indexPath];
           [_searchTableView beginUpdates];
       }
        cell.menuView.frame = CGRectMake(0, cell.contentView.bounds.size.height, 320, 48);
        
        menuCellFrame = cell.menuView.frame;
        cell.menuView.hidden=NO;
       
        [cell.moreButton addTarget:self action:@selector(moreButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
        [cell.taskButton addTarget:self action:@selector(taskButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.repostButton addTarget:self action:@selector(rePostButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        cell.menuView.hidden=NO;
        
       if(selectedTable==1){
        [_feedTableView endUpdates];
        [_feedTableView reloadData];
    }else
    {
        [_searchTableView endUpdates];
        [_searchTableView reloadData];
    }


}
}



-(void)moreButtonAction1:(id)sender{
    NSLog(@"More Action Called");
    NSLog(@"Selected Row = %d",currentSelection);
    //FeedTable  SearchTable
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    
    NSDictionary *dict = nil;
    if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
      dict = [self.allFeedArray objectAtIndex:currentSelection];
    }
    else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
       dict = [self.searchArray objectAtIndex:currentSelection];
    }
    
    
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    //Check Selected Messgae (from twitter or Linkedin)
    
     if ([accountType isEqualToString:@"facebook"]) {
         accountTypeNum=3;
         
         _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, height1)];
         _bgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
         [self.view addSubview:_bgView];
         
         _moreActionView=[[UIView alloc]initWithFrame:CGRectMake(width1/2-110, height1/2-150, 220, 300)];
         _moreActionView.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1];
         _moreActionView.hidden=NO;
         _moreActionView.layer.cornerRadius=4.0f;
         [self.view addSubview:_moreActionView];
         [_bgView bringSubviewToFront:_moreActionView];
         
         
         UIButton *emailBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
         emailBt.frame=CGRectMake(20, 40, 180, 40);
         emailBt.layer.cornerRadius=7.0f;
         emailBt.layer.borderColor=[UIColor redColor].CGColor;
         emailBt.layer.borderWidth=3.0f;
         emailBt.titleLabel.textColor=[UIColor blackColor];
         
         UIButton *shareBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
         shareBt.frame=CGRectMake(20, 110, 180, 40);
         shareBt.layer.cornerRadius=7.0f;
         shareBt.layer.borderColor=[UIColor redColor].CGColor;
         shareBt.layer.borderWidth=3.0f;
         shareBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
         shareBt.titleLabel.textColor=[UIColor blackColor];
         
         [shareBt addTarget:self action:@selector(openMessageBluetoothView1) forControlEvents:UIControlEventTouchUpInside];
         
         shareBt.titleLabel.textAlignment=NSTextAlignmentCenter;
         [shareBt setTitle:@"share" forState:UIControlStateNormal];
         shareBt.backgroundColor=[UIColor whiteColor];
         [_moreActionView addSubview:shareBt];
         
         emailBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
         [emailBt addTarget:self action:@selector(openMailComposer:) forControlEvents:UIControlEventTouchUpInside];
         emailBt.titleLabel.textAlignment=NSTextAlignmentCenter;
         [emailBt setTitle:@"Email" forState:UIControlStateNormal];
         emailBt.backgroundColor=[UIColor whiteColor];
         [_moreActionView addSubview:emailBt];
         
         
         UIButton *cancelBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
         cancelBt.frame=CGRectMake(20, 180, 180, 40);
         cancelBt.layer.cornerRadius=7.0f;
         cancelBt.titleLabel.textAlignment=NSTextAlignmentCenter;
         cancelBt.layer.borderColor=[UIColor redColor].CGColor;
         cancelBt.layer.borderWidth=3.0f;
         cancelBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
         cancelBt.titleLabel.textColor=[UIColor blackColor];
         
         [cancelBt addTarget:self action:@selector(cancelView) forControlEvents:UIControlEventTouchUpInside];
         [cancelBt setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] forState:UIControlStateNormal];
         cancelBt.backgroundColor=[UIColor whiteColor];
         [_moreActionView addSubview:cancelBt];

     }
    
    
    if ([accountType isEqualToString:@"Twitter_Feed"]) {
        accountTypeNum=1;
        _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, height1)];
        _bgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.view addSubview:_bgView];
        

        _moreActionView=[[UIView alloc]initWithFrame:CGRectMake(width1/2-110, height1/2-150, 220, 300)];
        _moreActionView.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1];
        _moreActionView.hidden=NO;
        _moreActionView.layer.cornerRadius=4.0f;

        [self.view addSubview:_moreActionView];
        [_bgView bringSubviewToFront:_moreActionView];
        
                
        UIButton *emailBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        emailBt.frame=CGRectMake(20, 40, 180, 40);
        emailBt.layer.cornerRadius=7.0f;
        emailBt.layer.borderColor=[UIColor redColor].CGColor;
        emailBt.layer.borderWidth=3.0f;
        emailBt.titleLabel.textColor=[UIColor blackColor];
        
        UIButton *shareBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        shareBt.frame=CGRectMake(20, 110, 180, 40);
        shareBt.layer.cornerRadius=7.0f;
        shareBt.layer.borderColor=[UIColor redColor].CGColor;
        shareBt.layer.borderWidth=3.0f;
        shareBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        shareBt.titleLabel.textColor=[UIColor blackColor];
        [shareBt addTarget:self action:@selector(openMessageBluetoothView1) forControlEvents:UIControlEventTouchUpInside];
        
        shareBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [shareBt setTitle:@"share" forState:UIControlStateNormal];
        shareBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:shareBt];
        
        emailBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        [emailBt addTarget:self action:@selector(openMailComposer:) forControlEvents:UIControlEventTouchUpInside];
        emailBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [emailBt setTitle:@"Email" forState:UIControlStateNormal];
        emailBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:emailBt];
        
        
        UIButton *cancelBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelBt.frame=CGRectMake(20, 180, 180, 40);
        cancelBt.layer.cornerRadius=7.0f;
        cancelBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        cancelBt.layer.borderColor=[UIColor redColor].CGColor;
        cancelBt.layer.borderWidth=3.0f;
        cancelBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        cancelBt.titleLabel.textColor=[UIColor blackColor];
        
        [cancelBt addTarget:self action:@selector(cancelView) forControlEvents:UIControlEventTouchUpInside];
        [cancelBt setTitle:@"cancel" forState:UIControlStateNormal];
        cancelBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:cancelBt];
        //[self.twitterActionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    else if ([accountType isEqualToString:@"Linkedin"]){
        accountTypeNum=2;
            
        _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, height1)];
        _bgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.view addSubview:_bgView];
        
        
        _moreActionView=[[UIView alloc]initWithFrame:CGRectMake(width1/2-110, height1/2-150, 220, 300)];
        _moreActionView.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)250/255 blue:(CGFloat)240/255 alpha:1];
        _moreActionView.hidden=NO;
        _moreActionView.layer.cornerRadius=4.0f;
        [self.view addSubview:_moreActionView];
        [_bgView bringSubviewToFront:_moreActionView];
        
        
        UIButton *emailBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        emailBt.frame=CGRectMake(20, 40, 180, 40);
        emailBt.layer.cornerRadius=7.0f;
        emailBt.layer.borderColor=[UIColor redColor].CGColor;
        emailBt.layer.borderWidth=3.0f;
        emailBt.titleLabel.textColor=[UIColor blackColor];
        
        UIButton *shareBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        shareBt.frame=CGRectMake(20, 110, 180, 40);
        shareBt.layer.cornerRadius=7.0f;
        shareBt.layer.borderColor=[UIColor redColor].CGColor;
        shareBt.layer.borderWidth=3.0f;
        shareBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        shareBt.titleLabel.textColor=[UIColor blackColor];
        [shareBt addTarget:self action:@selector(openMessageBluetoothView1) forControlEvents:UIControlEventTouchUpInside];
        
        shareBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [shareBt setTitle:@"share" forState:UIControlStateNormal];
        shareBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:shareBt];
        
        emailBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        [emailBt addTarget:self action:@selector(openMailComposer:) forControlEvents:UIControlEventTouchUpInside];
        emailBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [emailBt setTitle:@"Email" forState:UIControlStateNormal];
        emailBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:emailBt];
        
        
        UIButton *cancelBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelBt.frame=CGRectMake(20, 180, 180, 40);
        cancelBt.layer.cornerRadius=7.0f;
        cancelBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        cancelBt.layer.borderColor=[UIColor redColor].CGColor;
        cancelBt.layer.borderWidth=3.0f;
        cancelBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        cancelBt.titleLabel.textColor=[UIColor blackColor];
        
        [cancelBt addTarget:self action:@selector(cancelView) forControlEvents:UIControlEventTouchUpInside];
        [cancelBt setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] forState:UIControlStateNormal];
        cancelBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:cancelBt];

        }
    else{
        NSLog(@"unknown Account Type");
    }
}
-(void)cancelView{
    [_bgView removeFromSuperview];
    _moreActionView.hidden=YES;
}



//Task Button Action
//Display NewTaskViewController
-(void)taskButtonAction:(id)sender{
    NSLog(@"Task Action Called");
    NSLog(@"Selected Row = %d",currentSelection);
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    
    NewTaskViewController *newTask = [[NewTaskViewController alloc] initWithNibName:@"NewTaskViewController" bundle:nil];
    if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
        newTask.dataDict = [self.allFeedArray objectAtIndex:currentSelection];
    }
    else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
        newTask.dataDict = [self.searchArray objectAtIndex:currentSelection];
    }
    //newTask.dataDict = [self.allFeedArray objectAtIndex:currentSelection];
    [self presentViewController:newTask animated:YES completion:nil];
    
}
//Replay on selected Message
-(void)rePostButtonAction:(id)sender{
    NSLog(@"RepostButton Action Called");
    NSLog(@"Selected Row = %d",currentSelection);
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    NSDictionary *dict = nil;
    if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
        dict = [self.allFeedArray objectAtIndex:currentSelection];
    }
    else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
        dict = [self.searchArray objectAtIndex:currentSelection];
    }
    
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    
    //Go To RePostViewController and Pass all require data
    RePostViewController *repost = [[RePostViewController alloc] initWithNibName:@"RePostViewController" bundle:nil];
    NSString *profileImageString=nil;
    if ([accountType isEqualToString:@"Linkedin"]) {
        
        profileImageString = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfilePicUrl"]];
        repost.accountType = @"Linkedin";
        repost.profileName = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfileName"]];
        repost.message = [NSString stringWithFormat:@"@%@",[self.selectedAccountDict objectForKey:@"ProfileName"]]; //[NSString stringWithFormat:@"%@",[dict objectForKey:@"FromName"]];
        
    }
    
    else if ([accountType isEqualToString:@"facebook"]){
        profileImageString = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"FromProfileUrl"]];
        repost.accountType = @"facebook";
        repost.profileName = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"FromName"]];
        repost.message = [NSString stringWithFormat:@"@%@",[self.selectedAccountDict objectForKey:@"FeedDescription"]];
    }
    
    else if ([accountType isEqualToString:@"Twitter_Feed"]){
        profileImageString = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfilePicUrl"]];
        repost.accountType = @"Twitter_Feed";
        repost.profileName = [NSString stringWithFormat:@"%@",[self.selectedAccountDict objectForKey:@"ProfileName"]];
        repost.message = [NSString stringWithFormat:@"@%@",[self.selectedAccountDict objectForKey:@"ProfileName"]];
    }
    repost.dataDict = (NSMutableDictionary *)dict;
    repost.profileImage = profileImageString;
    [self presentViewController:repost animated:YES completion:nil];
}



#pragma mark -
//Display All Connect twitter Accounts
-(void) displayAllTwitterAccount:(int)accType{
    NSString *buttonTitle = nil;
    accType=1;
    //Fetch all connected Twitter Account
    buttonTitle = @"Favorite";
        self.twitterAccountArray = [SingletonClass sharedSingleton].connectedTwitterAccount;
    _moreActionView.hidden=YES;
    
    
        self.secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        self.secondView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:self.secondView];
        
        UIView *sec_header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        sec_header.backgroundColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
        [self.secondView addSubview:sec_header];
//------------------------------------------------------
      /*  self.can_two_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.can_two_btn.frame = CGRectMake(10, 30, 50, 27);
        [self.can_two_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.can_two_btn.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
        
        self.can_two_btn.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
        self.can_two_btn.layer.borderWidth=1.0f;
        self.can_two_btn.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
        self.can_two_btn.layer.cornerRadius = 5.0f;
        self.can_two_btn.clipsToBounds = YES;
        [self.can_two_btn addTarget:self action:@selector(hidesecondView:) forControlEvents:UIControlEventTouchUpInside];
        [self.can_two_btn setTitle:@"Cancel" forState:UIControlStateNormal];
        */
        self.can_two_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.can_two_btn.frame = CGRectMake(10, 35, 35, 30);
        self.can_two_btn.clipsToBounds = YES;
        [self.can_two_btn addTarget:self action:@selector(hidesecondView:) forControlEvents:UIControlEventTouchUpInside];
        [self.can_two_btn setTitle:@"" forState:UIControlStateNormal];
        [self.secondView addSubview:self.can_two_btn];
        
        UIImageView *logo=[[UIImageView alloc]initWithFrame:CGRectMake(10,35, 30, 40)];
        [logo setImage:[UIImage imageNamed:@"flash_logo.png"]];
        [self.secondView addSubview:logo];
        UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(47, 35,180, 40)];
        [logoTxt setImage:[UIImage imageNamed:@"logo_txt.png"]];
        [self.secondView addSubview:logoTxt];

        
        
        //[self.secondView addSubview:self.can_two_btn];
//----------------------------------------------------------
        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favoriteButton.frame = CGRectMake(250,40, 60, 27);
        [self.favoriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.favoriteButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
        [self.favoriteButton setTitle:@"" forState:UIControlStateNormal];
        
        self.favoriteButton.backgroundColor=[UIColor clearColor];
        
        //self.favoriteButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;
        self.favoriteButton.layer.borderWidth=0.5f;
        self.favoriteButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
        self.favoriteButton.layer.cornerRadius = 1.0f;
        self.favoriteButton.clipsToBounds = YES;
        [self.favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *proceedImg=[[UIImageView alloc]initWithFrame:CGRectMake(250, 40, 60, 27)];
        [proceedImg setImage:[UIImage imageNamed:@"proceed_button.png"]];
        [self.secondView addSubview:self.favoriteButton];
        [self.secondView addSubview:proceedImg];

        
        //self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
//--------------------------------------------------------
        
        
        
        self.tweeterAccountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 320, self.secondView.frame.size.height) style:UITableViewStylePlain];
        self.tweeterAccountTableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
        [self.secondView addSubview:self.tweeterAccountTableView];
        
       
        
        //[self.secondView.layer insertSublayer:gradient2 atIndex:0];
        self.secondView.backgroundColor=[UIColor whiteColor];
        self.tweeterAccountTableView.opaque=NO;
        self.tweeterAccountTableView.backgroundColor=[UIColor clearColor];
        self.tweeterAccountTableView.backgroundView=nil;
        
        selectedTwitterAccountRow = -1;
        self.tweeterAccountTableView.delegate = self;
   
       // selectedTwitterAccountRow = -1;
        //[self.tweeterAccountTableView reloadData];
    
    
    [UIView animateWithDuration:.40 animations:^{
        self.secondView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    }];
}
-(void) hidesecondView:(id)sender{
    [UIView animateWithDuration:.10 animations:^{
        self.secondView.frame = CGRectMake(self.view.frame.size.width, 0, 320, self.view.frame.size.height);
    }];
    _moreActionView.hidden=NO;
}
//Add to Favourite on twitter
-(void) favoriteButtonAction:(id)sender{
    NSDictionary *dict = [self.twitterAccountArray objectAtIndex:selectedTwitterAccountRow];
    NSLog(@"Dict ===%@",dict);
    
    [self getTwitterUserDetails:dict];
    
    [UIView animateWithDuration:.40 animations:^{
        self.secondView.frame = CGRectMake(self.view.frame.size.width, 0, 310, self.view.frame.size.height);
    }];
}
#pragma mark -
#pragma mark Twitter Favorite
//get Twitter user Account Details
-(void) getTwitterUserDetails: (NSDictionary *)dataDict{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    NSString *proID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"UserId"]];
    NSLog(@"profile id Twitter-=-= %@",proID);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetTwitterAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<ProfileId>%@</ProfileId>\n"
                             "</GetTwitterAccountDetailsById>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserId,proID];
    
    NSLog(@"soapMessg twitter  %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/TwitterAccount.asmx?op=GetTwitterAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/UserInformation" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"Rersponse String = %@", responseString);
        
        NSString *response = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
        NSLog(@"Info Dict = %@", dict);
        
//        NSString *aOthToken = [NSString stringWithFormat:@"%@",[dict objectForKey:@"OAuthToken"]];
//        NSString *aOthSecrate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"OAuthSecret"]];
//        NSLog(@"aOthToken = %@",aOthToken);
//        NSLog(@"aothSecrate = %@",aOthSecrate);
        
        
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TwitterConsumerKey  andSecret:TwitterSecretKey];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSError *returnCode = nil;
        
        NSDictionary *Feeddict = nil;
        if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
            Feeddict = [self.allFeedArray objectAtIndex:currentSelection];
        }
        else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
            Feeddict = [self.searchArray objectAtIndex:currentSelection];
        }
        
        NSString *mesId = [[NSString alloc] initWithFormat:@"%@",[Feeddict objectForKey:@"MessageId"]];
        
        returnCode = [[FHSTwitterEngine sharedEngine]markTweet:mesId asFavorite:YES aouthTokenDictionary:dict];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.hud hide:YES];
        if (!returnCode) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"successMsg"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
            [av show];
             [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];
        }
        else{
            NSLog(@"Error to Pos Twitter==%ld",(long)returnCode.code );
            if (returnCode.code == 139) {
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"alreadyFavorited"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
                [av show];
                 [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];
            }
            else if (returnCode.code == 89){
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"InvalidToken"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
                [av show];
                 [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];
            }
            else if (returnCode.code==32){
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cantauntheticateU"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
                [av show];
                 [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];
            }
            else{
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
                [av show];
                 [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];
            }
            
        }
        
    }
}
#pragma mark -
#pragma mark Open message n Bluetooth Composer
-(void)openMessageBluetoothView1{
    NSDictionary *dict = nil;
    
    if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
        dict = [self.allFeedArray objectAtIndex:currentSelection];
    }
    else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
        dict = [self.searchArray objectAtIndex:currentSelection];
    };
    NSString *message = nil;
    if (accountTypeNum == 1) {
        NSLog(@"Twitter Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feed"]];
    }
    else if ((accountTypeNum == 2)||(accountTypeNum == 3)){
        //NSLog(@"Linkedin Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDescription"]];
    }
    NSArray *objectsToShare = @[message];

    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    // Present the controller
    [self presentViewController:controller animated:YES completion:nil];
    
    
    
    /*
    mesgBluetoothView=[[UIView alloc] initWithFrame:CGRectMake(30, 180, 260, 140)];
    mesgBluetoothView.layer.cornerRadius=5.0f;
    
    mesgBluetoothView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:mesgBluetoothView];
    
    UIButton *messageBut=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    messageBut.frame=CGRectMake(170,45,70,60);
    //messageBut.layer.cornerRadius=7.0f;
    //messageBut.layer.borderColor=[UIColor redColor].CGColor;
   // messageBut.layer.borderWidth=3.0f;
   // messageBut.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
    [messageBut setBackgroundImage:[UIImage imageNamed:@"message5.jpg"] forState:UIControlStateNormal];
    //messageBut.titleLabel.textColor=[UIColor blackColor];
    [messageBut addTarget:self action:@selector(openMessageComposer:) forControlEvents:UIControlEventTouchUpInside];
    [mesgBluetoothView addSubview:messageBut];
    
    
    UIButton *blueTooth=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    blueTooth.frame=CGRectMake(30,45,70,60);
    //blueTooth.layer.cornerRadius=7.0f;
    //blueTooth.layer.borderColor=[UIColor redColor].CGColor;
    //blueTooth.layer.borderWidth=3.0f;
   // blueTooth.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
    //blueTooth.titleLabel.textColor=[UIColor blackColor];
    [blueTooth setBackgroundImage:[UIImage imageNamed:@"bluetooth5.jpg"] forState:UIControlStateNormal];
    [blueTooth addTarget:self action:@selector(openBluetoothView) forControlEvents:UIControlEventTouchUpInside];
    [mesgBluetoothView addSubview:blueTooth];
    
    
    UIButton  *cancelPicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelPicVw.frame = CGRectMake(3,3, 60, 30);
    [cancelPicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    cancelPicVw.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [cancelPicVw addTarget:self action:@selector(cancelPicView1) forControlEvents:UIControlEventTouchUpInside];
    
    [cancelPicVw setTitle:@"Back" forState:UIControlStateNormal];
    [mesgBluetoothView addSubview:cancelPicVw];
    mesgBluetoothView.hidden=NO;

    _moreActionView.hidden=YES;
    */
}
/*
-(void) openMessageComposer:(int)accType{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    NSDictionary *dict = nil;
    
    if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
        dict = [self.allFeedArray objectAtIndex:currentSelection];
    }
    else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
        dict = [self.searchArray objectAtIndex:currentSelection];
    };
    NSString *message = nil;
    if (accountTypeNum == 1) {
        NSLog(@"Twitter Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feed"]];
    }
    else if (accountTypeNum == 2){
        NSLog(@"Linkedin Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feeds"]];
    }
    else if (accountTypeNum == 3){
        NSLog(@"facebook Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDescription"]];
    }

    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    [self presentViewController:messageController animated:YES completion:nil];
    

    
    
}



-(void)openBluetoothView{
   
    NSDictionary *dict = nil;
    
    if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
        dict = [self.allFeedArray objectAtIndex:currentSelection];
    }
    else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
        dict = [self.searchArray objectAtIndex:currentSelection];
    };
    NSString *message = nil;
    if (accountTypeNum == 1) {
        NSLog(@"Twitter Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feed"]];
    }
    else if (accountTypeNum == 2){
        NSLog(@"Linkedin Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDescription"]];
    }
    NSArray *objectsToShare = @[message];

        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        // Exclude all activities except AirDrop.
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeMessage, UIActivityTypeMail,
                                        UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        controller.excludedActivityTypes = excludedActivities;
        
        // Present the controller
        [self presentViewController:controller animated:YES completion:nil];
    
}


-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    if (result == 0) {
        NSLog(@"Cancel");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 1){
        NSLog(@"Saved");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 2){
        NSLog(@"Sent");
        [[[UIAlertView alloc] initWithTitle:@"" message:@"message has been sent" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 3){
        NSLog(@"Failed");
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your bal" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
    
    
}

 

-(void)cancelPicView1{
    
    mesgBluetoothView.hidden=YES;
    _moreActionView.hidden=NO;
}
*/

#pragma mark -
#pragma mark OpenEmail Composer
-(void) openMailComposer:(int)accType{
    
    if([MFMailComposeViewController canSendMail]){
        NSLog(@"Send Mail");
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSDictionary *dict = nil;
        if ([self.currentSelectedTable isEqualToString:@"FeedTable"]) {
            dict = [self.allFeedArray objectAtIndex:currentSelection];
        }
        else if([self.currentSelectedTable isEqualToString:@"SearchTable"]){
            dict = [self.searchArray objectAtIndex:currentSelection];
        };
        NSString *emailBody = nil;
        if (accountTypeNum == 1) {
            NSLog(@"Twitter Account");
            emailBody = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feed"]];
        }
        else if (accountTypeNum == 2){
            NSLog(@"Linkedin Account");
            emailBody = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feeds"]];
        }
        else if (accountTypeNum == 3){
            NSLog(@"facebook Account");
            emailBody = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FeedDescription"]];
        }

        emailBody = [emailBody stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [mailer setSubject:@"A Message from SOCIOBOARD"];
        // NSString *emailBody = @"Have you seen the MobileTuts+ web site?";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cantsendmail"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"configMail"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
    }
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSLog(@"Result==%d",result);
    
    if (result == 0) {
        NSLog(@"Cancel");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 1){
        NSLog(@"Saved");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 2){
        NSLog(@"Sent");
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"msgnoSent"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 3){
        NSLog(@"Failed");
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:@"Please check youe internet connection and try again" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
    }
}



-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end