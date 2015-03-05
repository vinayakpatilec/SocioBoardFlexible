//
//  InboxVC.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "InboxVC.h"
#import "ViewController.h"
#import "TabBarView.h"
#import "UIImageView+WebCache.h"
#import "InboxSettingViewController.h"
#import "HelperClass.h"
#import "SBJson.h"
#import "MessageCustomCell.h"
#import "MenuViewController.h"
#import "RePostViewController.h"
#import "ComposeMessageViewController.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "FHSTwitterEngine.h"

#import "MBProgressHUD.h"
#import "TweetAccountCell.h"


#define FacabookWallPostValue @"facebookwallpostValue"
#define SentMessagesValue @"sentmessagesvalue"
#define FacebookCommentsValue @"commentsValue"
#define TwitterPublicMentionsValue @"publicMentionsValue"
#define TwitterMessagesValue @"twitterMessagesValue"
#define TwitterRetweetsValue @"twitterRetwttesValue"
#define GooglePlusActivitiesValue @"GooglePlusActivitiedValue"


@interface InboxVC () <MBProgressHUDDelegate>{
    CGRect screenRect;
    CGFloat height;
    UIScrollView *scrolview;
}
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation InboxVC

#pragma mark -
#pragma mark View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame = CGRectMake(0, 0, width1, height1);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
  
    height = [[UIScreen mainScreen] bounds].size.height;
    NSLog(@"Height==%f",height);
    
    
    // Add Observer method for Passing Update Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllMessageArray:) name:@"Update Message Table" object:nil];
        //self.headerView.backgroundColor=[UIColor clearColor];
        //self.headerView.alpha=0;
    
    //Set Setting Button Appearance
    
    
    
    
    UIButton  *composeMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    composeMsg.frame = CGRectMake(width1-50, 15*height1/480,35*width1/320, 30*height1/480);
    [composeMsg addTarget:self action:@selector(composeMessage:) forControlEvents:UIControlEventTouchUpInside];
    [composeMsg setBackgroundImage:[UIImage imageNamed:@"edit_btn@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:composeMsg];
    
    
    UIButton  *logoBut = [UIButton buttonWithType:UIButtonTypeCustom];
    logoBut.frame = CGRectMake(10*width1/320, 15*height1/480, 40*width1/320,30*height1/480);
    [logoBut addTarget:self action:@selector(webserviceConnectedAccount) forControlEvents:UIControlEventTouchUpInside];
    [logoBut setBackgroundImage:[UIImage imageNamed:@"sb_icon@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:logoBut];

    
    
    
    
    
    self.inboxSettingBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.inboxSettingBtn.frame=CGRectMake(60*width1/320, 15*height1/480, 200*width1/320,30*height1/480);
    self.inboxSettingBtn.layer.borderWidth=1.0f;
    self.inboxSettingBtn.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    [self.inboxSettingBtn setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"inbosMsg"] forState:UIControlStateNormal];
    [self.inboxSettingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.inboxSettingBtn.titleLabel.font=[UIFont systemFontOfSize:width1/20];
    self.inboxSettingBtn.layer.cornerRadius = 7.0f;
    self.inboxSettingBtn.clipsToBounds = YES;
    self.inboxSettingBtn.backgroundColor = [UIColor whiteColor];
    [self.inboxSettingBtn addTarget:self action:@selector(actionInbox:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.inboxSettingBtn];
    UIImageView *dropDown=[[UIImageView alloc]initWithFrame:CGRectMake(170*width1/320, 5*height1/480, 30*width1/320, 20*width1/320)];
    dropDown.image=[UIImage imageNamed:@"drop_down_inbox@3x.png"];
    [self.inboxSettingBtn addSubview:dropDown];
    
    
    
    currentSelection = -1;
    _buttonNum=-1;
//diplay Account imformation.
[self accView];
   
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)viewWillAppear:(BOOL)animated {
    
    NSString *strHeading = [NSString stringWithFormat:@"INBOX - %@",[SingletonClass sharedSingleton].userName];
    labelHeading.text = strHeading;
    if (self.AllMessageTableView && self.twitterAccountArray.count>0) {
        [self.AllMessageTableView reloadData];
        self.AllMessageTableView.hidden = NO;
        [SingletonClass sharedSingleton].typeOfCell=YES;
        
    }
    if([SingletonClass sharedSingleton].typeOfCell==NO){
        scrolview.hidden=NO;
    }
    else{
        scrolview.hidden=YES;
    }
    
    
}




#pragma mark -
#pragma mark accountimformation view
-(void)accView{
   scrolview=[[UIScrollView alloc]initWithFrame:CGRectMake(20*width1/320, 65*height1/480, width1-(40*width1/320), height1-(100*height1/480))];
    scrolview.contentSize = CGSizeMake(320,500*height1/480);
     scrolview.delegate = self;
    [self.view addSubview:scrolview];
    scrolview.accessibilityActivationPoint = CGPointMake(100, 100);
    scrolview.showsVerticalScrollIndicator = NO;
    _accInfoVw=[[UIView alloc]initWithFrame:CGRectMake(0,0,width1,height1-135)];
    _accInfoVw.backgroundColor=[UIColor clearColor];
    
 //display no of facebookaccount
    UIImageView *facebookImg=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320, 00, 45*width1/320, 45*width1/320)];
    [facebookImg setImage:[UIImage imageNamed:@"facebook_icon@3x.png"]];
    [_accInfoVw addSubview:facebookImg];
    NSString *noofAcc1=[NSString stringWithFormat:@"%@: %d",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"fbAccMsg"],(int)[SingletonClass sharedSingleton].connectedFacebookAccount.count];
    UILabel *name1=[[UILabel alloc]initWithFrame:CGRectMake(75*width1/320, 0, 200*width1/320, 30*height1/480)];
    name1.textColor=[UIColor whiteColor];
    name1.text=noofAcc1;
    name1.font=[UIFont systemFontOfSize:width1/20];
    name1.backgroundColor=[UIColor clearColor];
    [_accInfoVw addSubview:name1];
    
    
    
    UIImageView *twitterImg=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320, 60*height1/480, 45*width1/320, 45*width1/320)];
    [twitterImg setImage:[UIImage imageNamed:@"twitter_icon@3x.png"]];
    [_accInfoVw addSubview:twitterImg];
    NSString *noofAcc2=[NSString stringWithFormat:@"%@: %d",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"twittAccMsg"],(int)[SingletonClass sharedSingleton].connectedTwitterAccount.count];
    UILabel *name2=[[UILabel alloc]initWithFrame:CGRectMake(75*width1/320, 60*height1/480, 200*width1/320, 30*height1/480)];
    name2.textColor=[UIColor whiteColor];
    name2.text=noofAcc2;
    name2.font=[UIFont systemFontOfSize:width1/20];
    name2.backgroundColor=[UIColor clearColor];
    [_accInfoVw addSubview:name2];
    
    
    UIImageView *linkedinImg=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320,120*height1/480, 45*width1/320, 45*width1/320)];
    [linkedinImg setImage:[UIImage imageNamed:@"linkedin_icon@3x.png"]];
    [_accInfoVw addSubview:linkedinImg];
    NSString *noofAcc3=[NSString stringWithFormat:@"%@: %d",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"linkdinAccMsg"],(int)[SingletonClass sharedSingleton].connectedLinkedinAccount.count];
    UILabel *name3=[[UILabel alloc]initWithFrame:CGRectMake(75*width1/320, 120*height1/480, 200*width1/320, 30*height1/480)];
    name3.textColor=[UIColor whiteColor];
    name3.text=noofAcc3;
    name3.font=[UIFont systemFontOfSize:width1/20];
    name3.backgroundColor=[UIColor clearColor];
    [_accInfoVw addSubview:name3];
    
    
    
    UIImageView *instagramImg=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320, 180*height1/480, 45*width1/320, 45*width1/320)];
    [instagramImg setImage:[UIImage imageNamed:@"instagram_icon@3x.png"]];
    [_accInfoVw addSubview:instagramImg];
    NSString *noofAcc4=[NSString stringWithFormat:@"%@: %d",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"InstagrmAccMsg"],(int)[SingletonClass sharedSingleton].connectedInstagramAccount.count];
    UILabel *name4=[[UILabel alloc]initWithFrame:CGRectMake(75*width1/320, 180*height1/480, 200*width1/320, 30*height1/480)];
    name4.textColor=[UIColor whiteColor];
    name4.text=noofAcc4;
    name4.font=[UIFont systemFontOfSize:width1/20];
    name4.backgroundColor=[UIColor clearColor];
    [_accInfoVw addSubview:name4];
    
    
    
    UIImageView *tumblerImg=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320, 240*height1/480, 45*width1/320, 45*width1/320)];
    [tumblerImg setImage:[UIImage imageNamed:@"tumblr_icon@3x.png"]];
    [_accInfoVw addSubview:tumblerImg];
    NSString *noofAcc5=[NSString stringWithFormat:@"%@: %d",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"tumblrAccMsg"],(int)[SingletonClass sharedSingleton].connectedTumblerAccount.count];
    UILabel *name5=[[UILabel alloc]initWithFrame:CGRectMake(75*width1/320, 240*height1/480, 200*width1/320, 30*height1/480)];
    name5.textColor=[UIColor whiteColor];
    name5.text=noofAcc5;
    name5.font=[UIFont systemFontOfSize:width1/20];
    name5.backgroundColor=[UIColor clearColor];
    [_accInfoVw addSubview:name5];
    
    
    
    UIImageView *utubeImg=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320,300*height1/480, 45*width1/320, 45*width1/320)];
    [utubeImg setImage:[UIImage imageNamed:@"youtube_icon@3x.png"]];
    [_accInfoVw addSubview:utubeImg];
    NSString *noofAcc6=[NSString stringWithFormat:@"%@: %d",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"YoutubeAccMsg"],(int)[SingletonClass sharedSingleton].connectedUtubeAccount.count];
    UILabel *name6=[[UILabel alloc]initWithFrame:CGRectMake(75*width1/320, 300*height1/480, 200*width1/320, 30*height1/480)];
    name6.textColor=[UIColor whiteColor];
    name6.text=noofAcc6;
    name6.font=[UIFont italicSystemFontOfSize:width1/20];
    name6.backgroundColor=[UIColor clearColor];
    [_accInfoVw addSubview:name6];
    
    [scrolview addSubview:_accInfoVw];
    
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
    NSLog(@"%@", date);
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    //[_formatter setDateFormat:@"MMM dd,yy hh:mm:ss a"];
    [_formatter setDateFormat:@"yyyy MM dd hh:mm:ss"];
    entryDate=[_formatter stringFromDate:date];
    NSLog(@"Final Date --- %@",entryDate);
    
    return entryDate;
}

#pragma mark

- (BOOL)textView:(UITextView *)atextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [atextView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark

//Prepare Service for Fetching All Facebook Messages for Selected User ID.
-(NSMutableArray *) fetchFacebookWallPosts:(NSString *)fbID{
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];
    NSString *strProfileId = [SingletonClass sharedSingleton].profileID;
    @try {
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<UserHome xmlns=\"http://tempuri.org/\">\n"
                                 "<UserId>%@</UserId>\n"
                                 "<FacebookId>%@</FacebookId>\n"
                                 "<count>0</count>\n"
                                 "</UserHome>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",strProfileId,fbID];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/FacebookMessage.asmx?op=UserHome",WebLink];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/UserHome" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSLog(@"mes lenght---%@",msglength);
        // webdata = [[NSMutableData alloc]init];
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
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *sentMesValue = [userDefaults objectForKey:SentMessagesValue];
            NSString *wallPost = [userDefaults objectForKey:FacabookWallPostValue];
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                [tempDict setObject:[tempDict objectForKey:@"Message"] forKey:@"DisplayMessage"];
                
                if ([sentMesValue isEqualToString:@"1"] && [wallPost isEqualToString:@"1"]) {
                    [tempDict setObject:@"Facebook" forKey:SocialAccountType];
                    [tempArray addObject:tempDict];
                }
                else{
                    NSString *fromID = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"FromId"]];
                    if ([sentMesValue isEqualToString:@"1"]) {
                        
                        if ([fromID isEqualToString:fbID]) {
                            [tempDict setObject:@"Facebook" forKey:SocialAccountType];
                            [tempArray addObject:tempDict];
                        }
                    }
                    
                    if ([wallPost isEqualToString:@"1"]) {
                        if (![fromID isEqualToString:fbID]) {
                            [tempDict setObject:@"Facebook" forKey:SocialAccountType];
                            [tempArray addObject:tempDict];
                        }
                    }
                }
            }
            NSLog(@"Temp Array = \n%@",tempArray);
            [self.tabBarController.tabBar setUserInteractionEnabled:YES];
            return tempArray;
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
//
    }
    @finally {
        
        NSLog(@"Finally Block");
    }
    
    return nil;
}

//Prepare Service for Fetching All Twitter Messages for Selected User ID.
-(NSMutableArray *)fetchTwittermessages:(NSString *)twitterID{
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];

    NSString *strProfileId = [SingletonClass sharedSingleton].profileID;
    NSLog(@"Twitter Id -==- %@",twitterID);
    @try {
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<GetTwitterMessages xmlns=\"http://tempuri.org/\">\n"
                                 "<TwitterId>%@</TwitterId>\n"
                                 "<Userid>%@</Userid>"
                                 "</GetTwitterMessages>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",twitterID,strProfileId];
        
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/TwitterMessage.asmx?op=GetTwitterMessages",WebLink];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/GetTwitterMessages" forHTTPHeaderField:@"SOAPAction"];
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
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *publicMentions = [userDefaults objectForKey:TwitterPublicMentionsValue];
            NSString *messages = [userDefaults objectForKey:TwitterMessagesValue];
            NSString *retweets = [userDefaults objectForKey:TwitterRetweetsValue];
            
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                [tempDict setObject:[tempDict objectForKey:@"TwitterMsg"] forKey:@"DisplayMessage"];
                if ([publicMentions isEqualToString:@"1"] && [messages isEqualToString:@"1"] && [retweets isEqualToString:@"1"]) {
                    [tempDict setObject:@"Twitter" forKey:SocialAccountType];
                    [tempArray addObject:tempDict];
                }
                else{
                    BOOL isAdd=NO;
                    NSString *mesType = [NSString stringWithFormat:@"%@",[tempDict objectForKey:@"Type"]];
                    if ([mesType isEqualToString:@"twt_usertweets"]) {
                        if ([messages isEqualToString:@"1"]) {
                            isAdd = YES;
                        }
                    }
                    else if([mesType isEqualToString:@"twt_mentions"]){
                        if ([publicMentions isEqualToString:@"1"]) {
                            isAdd = YES;
                        }
                    }
                    else if ([mesType isEqualToString:@"twt_retweets"]){
                        if ([retweets isEqualToString:@"1"]) {
                            isAdd = YES;
                        }
                    }
                    if (isAdd==YES) {
                        [tempDict setObject:@"Twitter" forKey:SocialAccountType];
                        [tempArray addObject:tempDict];
                    }
                }
                
            }//For loop End
            NSLog(@"Twitter Messages = \n%@",tempArray);
            [self.tabBarController.tabBar setUserInteractionEnabled:YES];

            return tempArray;
            
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
//
    }
    @finally {
       
         NSLog(@"Finally Block");
    }
    
    return nil;
}
//Prepare Service for Fetching All Google Plus Messages for Selected User ID.
-(NSMutableArray *)fetchGooglePlusActivities:(NSString *)proID{
    
    NSLog(@"profile id -=-= %@",[SingletonClass sharedSingleton].profileID);
    @try {
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<GetGooglePlusActivities xmlns=\"http://tempuri.org/\">\n"
                                 "<GpUserId>%@</GpUserId>\n"
                                 "</GetGooglePlusActivities>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",proID];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/GooglePlus.asmx?op=GetGooglePlusActivities",WebLink];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/GetGooglePlusActivities" forHTTPHeaderField:@"SOAPAction"];
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
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict = [jsonArray objectAtIndex:i];
                [tempDict setObject:[tempDict objectForKey:@"Content"] forKey:@"DisplayMessage"];
                [tempDict setObject:@"GooglePlus" forKey:SocialAccountType];
                [tempArray addObject:tempDict];
            }
            return tempArray;
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
        
    }
    @finally {
                NSLog(@"Finally Block");
    }
    
    return nil;
}
//Display MenuViewController(change group)
-(IBAction)webserviceConnectedAccount{
    
    MenuViewController *obj = [[MenuViewController alloc]initWithNibName:@"MenuViewController" bundle:nil];

    [self presentViewController:obj animated:YES completion:nil];

}

//Dispaly Setting ViewController
-(IBAction)actionInbox:(id)sender{
    selectedTable=1;
    InboxSettingViewController *obj = [[InboxSettingViewController alloc] initWithNibName:@"InboxSettingViewController" bundle:nil];
    obj.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    obj.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    obj.myDelegate = self;
    //NSLog(@"Profile ids -==- %@ \n\n Profile Types -==- %@",obj.profileIds,obj.profileType);
    
    [self presentViewController:obj animated:YES completion:nil];
    
}

#pragma mark -
#pragma mark Connected Account Delegate
/*
 InboxSettingViewController Delegate
 pass a message form InboxSettingViewController by Done Button Actoin
 with all selected Account information
 ---------------------*/
-(void)passSelectedVlue:(NSMutableArray *)selAccounts{

    @synchronized(self)
    {
        // your code goes here
        [NSThread detachNewThreadSelector:@selector(findAllMessage:) toTarget:self withObject:selAccounts];
        //[self findAllMessage:selAccounts];
    }
    
}
//Display Activity Indicator
-(void)displayActivityIndicator{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.dimBackground = YES;
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}
//MBProgressView Delegate method
-(void) hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}
#pragma mark -
#pragma mark Find All Messages
// Fetch All Messages for Selected Account
-(void)findAllMessage:(NSMutableArray *)dict{
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        return;
    }
    //--------------------------------------------------
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *allAccount= [SingletonClass sharedSingleton].messagePageAccountArray;
    //--------------------------------------------------
    //Fetch All Selected account Info(Selected in InboxSettingViewController)
    NSMutableArray *valueArray = [userDefaults objectForKey:@"WoosuiteAccountValue"];
    
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    NSMutableArray *selArray = [[NSMutableArray alloc] init];
    currentSelection = -1;
    menuCellFrame = CGRectZero;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];

    int accountCount = 0;
    for (int i =0; i<valueArray.count; i++) {
        NSMutableArray *response=[[NSMutableArray alloc]init];
        NSString *str = [valueArray objectAtIndex:i];
        //Check Value
        //if 1 means account is selected or 0 means account not selected
        if ([str isEqualToString:@"1"]) {
            accountCount = accountCount +1 ;
            //Fetch selected Account info
            
            NSDictionary *dict = [allAccount objectAtIndex:i];
            NSString *proType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
            NSLog(@"Selected Account name = %@",proType);
            NSString *proID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileId"]];
            [selArray addObject:proID];
            //--------------------------
            // Check type of selected account
            if ([proType isEqualToString:@"twitter"]) {
                NSLog(@"Fetch Twitter messages");
                
                response = [self fetchTwittermessages:proID];
            }
            else if ([proType isEqualToString:@"facebook"]){
                NSLog(@"Facebook Messages");
                response = [self fetchFacebookWallPosts:proID];
                
            }
            else if ([proType isEqualToString:@"googleplus"]){
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *acti = [userDefaults objectForKey:GooglePlusActivitiesValue];
                if ([acti isEqualToString:@"1"]) {
                    response = [self fetchGooglePlusActivities:proID];
                }
            }
            else{
                NSLog(@"Unknown type of Account");
            }
            
            //Add Date with All Messages
            for (int i =0; i<response.count; i++) {
                NSMutableDictionary *dict = [response objectAtIndex:i];
                NSString *postDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"MessageDate"]];
                NSString *newDate = [self convertTodate:postDate];
                [dict setObject:newDate forKey:@"NewDate"];
                [tempArray addObject:dict];
            }
        }
    }//End For Loop
    NSLog(@"Selected Acco== %@",selArray);
    [SingletonClass sharedSingleton].messageSelectedAccounts=selArray;
    //----------------------------
    //Sort All Messages on the Basis of Date
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"NewDate" ascending:NO];
    NSArray *descriptors=[NSArray arrayWithObject: descriptor];
    NSArray *sortedArray=(NSMutableArray *)[tempArray sortedArrayUsingDescriptors:descriptors];
    
  
    
    
    //if (accountCount<4) {
    // sleep(3/accountCount);
    // }
    _buttonNum=-1;
     currentSelection=-1;
    double delayInSeconds =0;
    //3/accountCount;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        @try {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (sortedArray.count==0) {
                    UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"Sorry" message:@"no messages" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [myAlert show];
                     [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
                    [self.hud hide:YES];
                   // scrolview.hidden=YES;
                    //[self.AllMessageTableView setContentOffset:CGPointZero animated:NO];
                    //[self.AllMessageTableView reloadData];
                    

                    return;

                }
                
                //Display All Message Table View
               
               /* if (self.AllMessageTableView) {
                    self.allMessageArray = [NSMutableArray arrayWithArray:sortedArray];

                    [self.AllMessageTableView setContentOffset:CGPointZero animated:NO];
                    [self.AllMessageTableView reloadData];
                    
                     //scrolview.hidden=YES;
                }
                else{
                */
                    self.allMessageArray = [NSMutableArray arrayWithArray:sortedArray];
                    self.AllMessageTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,75,width1-10,height1-(75+10*height1/480)) style:UITableViewStylePlain];
                    self.AllMessageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    self.AllMessageTableView.backgroundColor=[UIColor clearColor];
                    [self.view addSubview:self.AllMessageTableView];
                    self.AllMessageTableView.delegate = self;
                    self.AllMessageTableView.dataSource = self;
                    //scrolview.hidden=YES;
                    if(scrolview){
                    for(UIScrollView *view in self.view.subviews){
                        if ([view isKindOfClass:[UIScrollView class]]) {
                            [view removeFromSuperview];
                        }
                    }
                    
                    [self.view addSubview:self.AllMessageTableView];
                }
               
                [self.hud hide:YES];
                
            });
        }
        @catch (NSException *exception) {
            [self.hud hide:YES];
        }
        @finally {
            //[self.hud hide:YES];
            NSLog(@"Finally Block");
        }
        

    });
   
    //[self performSelector:@selector(createMessageTable) withObject:nil afterDelay:0];
    
}


//Notification Observer Method
-(void) updateAllMessageArray:(NSNotification *)notificationInfo{
    if (!self.allMessageArray) {
        return;
    }
    NSMutableDictionary *newDict = [notificationInfo object];
    NSLog(@"NewDict==%@",newDict);
    
        NSString *proId = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"ProfileId"]];
        NSMutableArray *selArray = [SingletonClass sharedSingleton].messageSelectedAccounts;
        NSLog(@"all message count==%lu",(unsigned long)self.allMessageArray.count);
        if ([selArray containsObject:proId]) {
            // NSLog(@"Update Table");
            [self.allMessageArray insertObject:newDict atIndex:0];
            
            [self.AllMessageTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        NSLog(@"all message count==%lu",(unsigned long)self.allMessageArray.count);
   
}
//==========================================================
#pragma mark -
#pragma mark Go To Compose View
//Display Compose Message View Controller
- (IBAction)composeMessage:(id)sender {
    
    ComposeMessageViewController *composeViewController = [[ComposeMessageViewController alloc] initWithNibName:@"ComposeMessageViewController" bundle:nil];

    [self.tabBarController presentViewController:composeViewController animated:YES completion:nil];
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//==========================================================
#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   // NSLog(@"Final aar user Dates -==--= %@",twitterMess);
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView==self.searchTableView) {
        return self.searchArray.count;
    }
    else if (tableView == self.tweeterAccountTableView){
        return self.twitterAccountArray.count;
    }
     NSLog(@"%d",self.allMessageArray.count);
    return self.allMessageArray.count;
   
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView==self.AllMessageTableView) {
        self.messageSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 52,width1,40)];
        //self.tweetSearchBar.frame = CGRectMake(0, 0, 320, 44);
        self.messageSearchBar.barStyle = UIBarStyleDefault;
        self.messageSearchBar.showsCancelButton=NO;
        self.messageSearchBar.autocorrectionType= UITextAutocorrectionTypeYes;
        self.messageSearchBar.placeholder= [[SingletonClass sharedSingleton] languageSelectedStringForKey:@"searchMsg"];
        self.messageSearchBar.delegate=self;
        self.messageSearchBar.tintColor = [UIColor colorWithRed:(CGFloat)235/255 green:(CGFloat)235/255 blue:(CGFloat)235/255 alpha:1.0];
        for (UIView *subView in self.messageSearchBar.subviews){
            
            if([subView isKindOfClass:[UITextField class]]){
                subView.layer.borderWidth = 1.0f;
                subView.layer.borderColor =[UIColor colorWithRed:(CGFloat)176/255 green:(CGFloat)176/255 blue:(CGFloat)176/255 alpha:1.0].CGColor;
                subView.layer.cornerRadius = 15;
                subView.clipsToBounds = YES;
                
            }
        }
        return self.messageSearchBar;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.backgroundColor=[UIColor clearColor];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView==self.AllMessageTableView) {
        return 30;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
        return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath  *)indexPath{
    if (tableView == self.tweeterAccountTableView) {
        return 60*height1/480;
    }
    CGFloat h=0;
    
    NSDictionary *dict = nil;
    if (tableView==self.searchTableView) {
        dict =[self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        NSLog(@"%d",indexPath.row);
        dict =[self.allMessageArray objectAtIndex:indexPath.row];
    }
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *conDict = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    
    if ([accountType isEqualToString:@"Facebook"]) {
        NSString *str=[NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:str attributes:conDict];
        
        NSString *addedImage = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Picture"]];
        
        //Fetch height for Display Message
        h = [self textViewHeightForAttributedText:messtr andWidth:width1-70];
        
        if (h<30) {
            h = 30;
        }
        
        if ([addedImage  rangeOfString:@"null"].location == NSNotFound) {
            //return lblSize.height+100;
            h = h+140;
        }
        else{
            h = h+55;
        }
        
        
    }
    else if ([accountType isEqualToString:@"Twitter"]){
         NSString *str=[NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterMsg"]];
        NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:str attributes:conDict];
        //Fetch height for Display Message
        h = [self textViewHeightForAttributedText:messtr andWidth:width1-70];
        if (h<30) {
            h = 30;
        }
        h = h + 55;
    }
    
    else if ([accountType isEqualToString:@"GooglePlus"]){
        NSString *str=[NSString stringWithFormat:@"%@",[dict objectForKey:@"Content"]];
        NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:str attributes:conDict];
        //Fetch height for Display Message
        h = [self textViewHeightForAttributedText:messtr andWidth:width1-70];
        if (h<30) {
            h = 30;
        }
        h = h + 45;
    }
   //=================================
    
    if (currentSelection==indexPath.row) {
        h = h+50;
    }
    
    //heightOfRow=h;
   // NSLog(@"aheight=%f",*aheight);
    return (h+20);
}

//Return hight for display message

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    heightofText=size.height;
    return size.height;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.tweeterAccountTableView) {
        //cell.backgroundColor=[UIColor blackColor];
    }
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell Identifier";
    
    //Check Table View
    
    if (aTableView==self.searchTableView) {
        self.currentTable = @"SearchTable";
    }
    else{
        self.currentTable = @"MessageTable" ;
    }
    if (aTableView==self.tweeterAccountTableView) {
        
        TweetAccountCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil) {
            cell = [[TweetAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        for(UIImageView *view in cell.contentView.subviews){
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }

        cell.backgroundColor=[UIColor clearColor];
        cell.layer.cornerRadius=5.0f;
        UIImageView *selectIndi=[[UIImageView alloc]initWithFrame:CGRectMake(width1-(45*width1/320), 18*height1/480, 25*height1/480,25*height1/480)];
        if (selectedTwitterAccountRow==indexPath.row) {
           
           selectIndi.image = [UIImage imageNamed:@"radiobtn_clicked@3x.png"];
        }
        else{
            selectIndi.image = [UIImage imageNamed:@"radiobtn@3x.png"];
        }
       // cell.backView.backgroundColor=[UIColor whiteColor];
        
        
        [cell.contentView addSubview:selectIndi];
        NSDictionary *dict = [self.twitterAccountArray objectAtIndex:indexPath.row];
        NSString *imageUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfilePicUrl"]];
        NSString *nameString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]];
        UIImageView *proImgView=[[UIImageView alloc]initWithFrame:CGRectMake(10*width1/320,10*height1/480, 40*height1/480, 40*height1/480)];
        [proImgView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        [cell addSubview:proImgView];
        cell.nameLable.frame=CGRectMake(75*width1/320,15*height1/480,200*width1/320, 30*height1/480);
        cell.nameLable.textColor = [UIColor blackColor];
        cell.nameLable.backgroundColor=[UIColor clearColor];
        cell.nameLable.font=[UIFont systemFontOfSize:width1/18];
        cell.nameLable.text = nameString;
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
        return cell;
        
    }
    
    MessageCustomCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
   
    for (UIView *view in [cell.contentView subviews])
    {
        [view removeFromSuperview];
    }
   // if (cell == nil) {
    
    
        cell = [[MessageCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     
        cell.nameLable.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell.moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.taskButton addTarget:self action:@selector(taskButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
    [cell.repostButton addTarget:self action:@selector(rePostButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
    [cell.menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];

//to identify which button is pressed
    cell.menuButton.tag=indexPath.row;
    
    if (currentSelection == indexPath.row) {
        cell.menuView.frame = menuCellFrame;
        cell.menuView.hidden=NO;
    }
    else{
        cell.menuView.hidden=YES;
    }
    
    NSDictionary *dict = nil;
    if (aTableView==self.searchTableView) {
        dict =[self.searchArray objectAtIndex:indexPath.row];
    }
    else{
        dict =[self.allMessageArray objectAtIndex:indexPath.row];
    }
    
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *condict = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    
    cell.dateLable.text = [[[NSString stringWithFormat:@"%@",[dict objectForKey:@"NewDate"]] substringToIndex:10] stringByReplacingOccurrencesOfString:@" " withString:@"/"];
    
    //Check Account Type
    if ([accountType isEqualToString:@"Facebook"]) {
        
        NSString *profileUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
        [cell.profilePicImageView setImageWithURL:[NSURL URLWithString:profileUrl] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
        message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:message attributes:condict];
        
        height = [self textViewHeightForAttributedText:str andWidth:width1-70];
        
        if (height<30) {
            height = 30;
        }
        
        cell.messageTxtView.frame = CGRectMake(50, 30,width1-70, height);
        
        cell.messageTxtView.attributedText = str;
        
        cell.nameLable.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromName"]];
        NSString *addedImage = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Picture"]];
        //
        if ([addedImage  rangeOfString:@"null"].location == NSNotFound) {
            isImage=1;
            cell.picImageView.frame = CGRectMake((width1-10)/2-40,height+45, 80, 80);
            [cell.picImageView setImageWithURL:[NSURL URLWithString:addedImage] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        }
        else{
            isImage=0;
            cell.picImageView.frame = CGRectMake(0, 0, 0, 0);
        }
       
    }
    else if ([accountType isEqualToString:@"Twitter"]){
        isImage=0;
        cell.picImageView.frame=CGRectMake(0, 0, 0, 0);
        NSString *proPic = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
        [cell.profilePicImageView setImageWithURL:[NSURL URLWithString:proPic] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterMsg"]];
        message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:message attributes:condict];
        CGFloat hite = [self textViewHeightForAttributedText:str andWidth:width1-70];
        if (hite<30) {
            hite = 30;
        }
        

        cell.messageTxtView.frame = CGRectMake(50, 30, width1-70, height);
        cell.messageTxtView.attributedText = str;
        cell.nameLable.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromScreenName"]];
    }
    else if ([accountType isEqualToString:@"GooglePlus"]){
        cell.picImageView.frame=CGRectMake(0, 0, 0, 0);
        NSString *proPic = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileImage"]];
        [cell.profilePicImageView setImageWithURL:[NSURL URLWithString:proPic] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        NSString *message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Content"]];
        message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:message attributes:condict];
        CGFloat hite = [self textViewHeightForAttributedText:str andWidth:width1-70];
        if (hite<30) {
            hite = 30;
        }
        
        cell.messageTxtView.frame = CGRectMake(50, 30, width1-70, height);
        cell.messageTxtView.attributedText = str;
       cell.nameLable.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromUserName"]];
     }
    [self configureCell:cell atIndexPath:indexPath];
   
    return cell;
    }
-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath
{
    
   MessageCustomCell* ccell = (MessageCustomCell*)cell;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGstur:)];
    tap.numberOfTapsRequired = 1;
    
    ccell.profilePicImageView.userInteractionEnabled = YES;
    ccell.profilePicImageView.tag=indexPath.row;
    [ccell.profilePicImageView addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGstur1:)];
     ccell.picImageView.tag=indexPath.row;
    ccell.picImageView.userInteractionEnabled=YES;
    [ccell.picImageView addGestureRecognizer:tap1];
    
    if(isImage==1){
        ccell.menuButton.frame=CGRectMake(width1-60,heightofText+ccell.messageTxtView.frame.origin.y+80, 40, 40);
        [ccell.menuButton setBackgroundImage:[UIImage imageNamed:@"hiddenView.jpg"] forState:UIControlStateNormal];
    }
    else if(isImage==0){
        [ccell.menuButton setBackgroundImage:[UIImage imageNamed:@"hiddenView.jpg"] forState:UIControlStateNormal];
    ccell.menuButton.frame=CGRectMake(width1-60,heightofText+ccell.messageTxtView.frame.origin.y, 40, 40);
    }
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"selected row = %d",indexPath.row);
    
    if (tableView==self.tweeterAccountTableView) {
        selectedTwitterAccountRow = (int)indexPath.row;
        [tableView reloadData];
        return;
    }
    
    if (currentSelection == indexPath.row) {
        return;
    }
    
    if (tableView==self.searchTableView) {
        self.currentTable = @"SearchTable";
    }
    else{
        self.currentTable = @"MessageTable" ;
    }
    
}

#pragma mark-
#pragma mark Handle gesture
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return NO;
}

-(void)handleTapGstur:(UITapGestureRecognizer*)sender{
   
    self.tabBarController.tabBar.hidden =YES;
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    UIImageView *img = (UIImageView *)sender.view;
     _imageSave=img.image;
    NSDictionary *dict=nil;
    if(selectedTable==1){
    dict= [self.allMessageArray objectAtIndex:img.tag];
    }else{
         dict= [self.searchArray objectAtIndex:img.tag];
    }
    _picView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,screenRect.size.width , screenRect.size.height)];
     _picView.backgroundColor=[UIColor blackColor];
    
    
    UIView *header=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 45*height1/480)];
    [header setBackgroundColor:[UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1]];
    [_picView addSubview:header];

    
    UIButton  *savePicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    savePicVw.frame = CGRectMake(250*width1/320, 10*height1/480,60*width1/320,30*height1/480);
    [savePicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    savePicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [savePicVw addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [savePicVw setTitle:@"Save" forState:UIControlStateNormal];
    [header addSubview:savePicVw];
    
    
    UIButton  *cancelPicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelPicVw.frame = CGRectMake(5*width1/320, 10*height1/480,35*height1/480, 30*height1/480);
    [cancelPicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    cancelPicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [cancelPicVw addTarget:self action:@selector(cancelPicView) forControlEvents:UIControlEventTouchUpInside];
    [cancelPicVw setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];

    //[cancelPicVw setTitle:@"Back" forState:UIControlStateNormal];
    [header addSubview:cancelPicVw];
    
    
    NSString *proPicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
    proPicStr = [proPicStr stringByReplacingOccurrencesOfString:@"small" withString:@"large"];
    proPicStr = [proPicStr stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
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
    
    [self.view addSubview:_picView];
    
    [proPic setImage:Im];
        
   _imageSave=proPic.image;
    _picView.hidden=NO;
    [_picView addSubview:proPic];
    [self.hud hide:YES];
    
}

-(void)handleTapGstur1:(UITapGestureRecognizer*)sender{
    //UIView *v = (UIControl *)sender;
    //UITapGestureRecognizer *tap = (UITapGestureRecognizer*)v;
    self.tabBarController.tabBar.hidden =YES;
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    UIImageView *img = (UIImageView *)sender.view;
    NSDictionary *dict=nil;
    if(selectedTable==1){
        dict= [self.allMessageArray objectAtIndex:img.tag];
    }else{
        dict= [self.searchArray objectAtIndex:img.tag];
    }
    
    _picView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,screenRect.size.width , screenRect.size.height)];
    _picView.backgroundColor=[UIColor blackColor];
    //_picView.backgroundColor=[UIColor whiteColor];
      UIView *header=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 45*height1/480)];
    [header setBackgroundColor:[UIColor colorWithRed:(CGFloat)50/255 green:(CGFloat)50/255 blue:(CGFloat)50/255 alpha:1]];
    [_picView addSubview:header];

    
    UIButton  *savePicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    savePicVw.frame = CGRectMake(250*width1/320, 10*height1/480, 60*width1/320,30*height1/480);
    [savePicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    savePicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [savePicVw addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [savePicVw setTitle:@"Save" forState:UIControlStateNormal];
    [header addSubview:savePicVw];

    
    UIButton  *cancelPicVw = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelPicVw.frame = CGRectMake(5*width1/320, 10*height1/480,35*height1/480,30*height1/480);
    [cancelPicVw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelPicVw setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];

   // cancelPicVw.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [cancelPicVw addTarget:self action:@selector(cancelPicView) forControlEvents:UIControlEventTouchUpInside];
    //[cancelPicVw setTitle:@"Back" forState:UIControlStateNormal];
    [header addSubview:cancelPicVw];
    
    NSString *PicStr = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Picture"]];
    PicStr = [PicStr stringByReplacingOccurrencesOfString:@"small" withString:@"large"];
    PicStr = [PicStr stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:PicStr]];
    UIImage *Im=[UIImage imageWithData:data];
    
   // NSLog(@"%f",Im.size.width);
   // NSLog(@"%f",Im.size.height);
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
    
    [proPic setImage:Im];
    //[proPic setImageWithURL:[NSURL URLWithString:PicStr] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
    [self.view addSubview:_picView];
    
    _imageSave=proPic.image;

    _picView.hidden=NO;
    [_picView addSubview:proPic];
    [self.hud hide:YES];
    
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


- (void)saveImage
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
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"couldntImgSaved"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [alertView show];
        [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
        [self cancelPicView];

        }
}


-(void)cancelPicView{
    self.tabBarController.tabBar.hidden =NO;
    _picView.hidden=YES;
    
}


#pragma mark -
#pragma mark Search Bar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    //set Background View
    if (!self.dimLightView) {
        self.dimLightView = [[UIView alloc] initWithFrame:CGRectMake(0,105, width1, height1)];
        
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
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //[searchBar setShowsCancelButton:NO animated:YES];
    selectedTable=1;
    searchBar.text=@"";
    currentSelection = -1;
    self.dimLightView.hidden = YES;
    [self.AllMessageTableView setContentOffset:CGPointZero animated:NO];
    [self.AllMessageTableView reloadData];
    searchBar.showsCancelButton=NO;
    [self.view addSubview:self.AllMessageTableView];
    self.searchTableView.hidden=YES;
    self.searchTableView = nil;
    [self.searchTableView removeFromSuperview];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"Search Text==%@",searchText);
    [searchBar setShowsCancelButton:YES animated:YES];
    [self filterContentForSearchText:searchText scope:@"All"];
    currentSelection = -1;
    if (self.searchTableView) {
        self.searchTableView = nil;
        [self.searchTableView removeFromSuperview];
    }
    
    CGRect frame = CGRectMake(self.AllMessageTableView.frame.origin.x, self.AllMessageTableView.frame.origin.y+30, self.AllMessageTableView.frame.size.width, self.AllMessageTableView.frame.size.height);
    self.searchTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchTableView.dataSource=self;
    self.searchTableView.delegate=self;
    [self.view addSubview:self.searchTableView];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    selectedTable=2;
    [self.view addSubview:self.searchTableView];
    [searchBar resignFirstResponder];
}

//Filter All Message Array on the basis of entered Keyword on Search Bar
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
	
    // Remove all objects from the filtered search array
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.DisplayMessage contains[c] %@",searchText];
    
	// Filter the array using NSPredicate
    
    NSArray *tempArray = [self.allMessageArray filteredArrayUsingPredicate:predicate];
    
    if(![scope isEqualToString:@"All"]) {
        // Further filter the array with the scope
        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"SELF.category contains[c] %@",scope];
        tempArray = [tempArray filteredArrayUsingPredicate:scopePredicate];
    }
    
    self.searchArray = [NSMutableArray arrayWithArray:tempArray];
    
}

//Add Menu OPtion in Bottom of selected Cell
-(void)addMenuViewToSelectedCell:(MessageCustomCell *)selectedCell{
    
    CGFloat y = selectedCell.contentView.bounds.size.height;
    self.menuCellView = [[UIView alloc] initWithFrame:CGRectMake(0, y, 300, 48)];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(100, 9, 30, 30);
    [moreButton setBackgroundImage:[UIImage imageNamed:@"action-more"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuCellView addSubview:moreButton];
    
    UIButton *taskButton = [UIButton buttonWithType:UIButtonTypeCustom];
    taskButton.frame = CGRectMake(200, 9, 30, 30);
    [taskButton setBackgroundImage:[UIImage imageNamed:@"action-assign-norm"] forState:UIControlStateNormal];
    [taskButton addTarget:self action:@selector(taskButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuCellView addSubview:taskButton];
    
    UIButton *repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
    repostButton.frame = CGRectMake(250, 9, 30, 30);
    [repostButton setBackgroundImage:[UIImage imageNamed:@"action-reply"] forState:UIControlStateNormal];
    [repostButton addTarget:self action:@selector(rePostButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuCellView addSubview:repostButton];
    
}
#pragma mark Cell Menu button Action
/*
  Menu Option(Selected Cell) 
 //More Button Action
 ---------------*/



-(void)menuButtonAction:(UIButton*)button
{
    if(_buttonNum!=(int)button.tag)
    {
        
        currentSelection=(int)button.tag;
        _buttonNum=currentSelection;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
        MessageCustomCell *cell;
        if(selectedTable==1){
            cell = (MessageCustomCell *)[_AllMessageTableView cellForRowAtIndexPath:indexPath];
            [_AllMessageTableView beginUpdates];
        }
        else{
            cell = (MessageCustomCell *)[_searchTableView cellForRowAtIndexPath:indexPath];
            [_searchTableView beginUpdates];
            
        }
        cell.menuView.frame = CGRectMake(0, cell.contentView.bounds.size.height, 320, 48);
        
        menuCellFrame = cell.menuView.frame;
        cell.menuView.hidden=NO;
        [cell.moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.taskButton addTarget:self action:@selector(taskButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
        [cell.repostButton addTarget:self action:@selector(rePostButtonAction1:) forControlEvents:UIControlEventTouchUpInside];
        
        if(selectedTable==1){
            [_AllMessageTableView endUpdates];
            [_AllMessageTableView reloadData];
        }else{
            [_searchTableView endUpdates];
            [_searchTableView reloadData];
        }
    }
    
}




-(void)moreButtonAction:(id)sender{
    
    NSLog(@"More Action Called");
    NSLog(@"Selected Row = %d",currentSelection);
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    NSDictionary *dict = nil;
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        dict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        dict =[self.searchArray objectAtIndex:currentSelection];
    }
    else{
        NSLog(@"Unknown Table");
    }
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    
    
    //Check Selected Messgae (from facebook, twitter or Google Plus)
    if ([accountType isEqualToString:@"Facebook"]) {
        currentSelectedAccountType = @"Facebook";
        //Display Action Sheet
        accType=0;
        [self facebookActionSheetDisplay];
    }
    else if ([accountType isEqualToString:@"Twitter"]){
        accType=1;
        accountTypeNum=2;
        currentSelectedAccountType = @"Twitter";
        _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, height1)];
        _bgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.view addSubview:_bgView];
        
        _moreActionView=[[UIView alloc]initWithFrame:CGRectMake(width1/2-110, height1/2-150, 220, 300)];
        _moreActionView.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:.9];
        _moreActionView.hidden=NO;
        _moreActionView.layer.cornerRadius=4.0f;
        _moreActionView.layer.borderWidth=1.0f;
        _moreActionView.layer.borderColor=[UIColor blackColor].CGColor;
        [self.view addSubview:_moreActionView];
        [_bgView bringSubviewToFront:_moreActionView];
        
        UIButton *FvBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        FvBt.frame=CGRectMake(20, 40, 180, 40);
        FvBt.layer.cornerRadius=7.0f;
        FvBt.layer.borderColor=[UIColor redColor].CGColor;
        FvBt.layer.borderWidth=3.0f;
        FvBt.titleLabel.textColor=[UIColor blackColor];
        FvBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        [FvBt addTarget:self action:@selector(displayAllTwitterOrFacebookAccount) forControlEvents:UIControlEventTouchUpInside];
        FvBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [FvBt setTitle:@"Favorite" forState:UIControlStateNormal];
        FvBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:FvBt];
        
        UIButton *emailBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        emailBt.frame=CGRectMake(20, 110, 180, 40);
        emailBt.layer.cornerRadius=7.0f;
        emailBt.layer.borderColor=[UIColor redColor].CGColor;
        emailBt.layer.borderWidth=3.0f;
        emailBt.titleLabel.textColor=[UIColor blackColor];
        
        emailBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        [emailBt addTarget:self action:@selector(openMailComposer1) forControlEvents:UIControlEventTouchUpInside];
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
            self.twitterActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] destructiveButtonTitle:nil otherButtonTitles:@"Favorite",@"Email", nil];
            self.twitterActionSheet.tag=1;
            self.twitterActionSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
            
        
        //[self.twitterActionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    else if ([accountType isEqualToString:@"GooglePlus"]){
        currentSelectedAccountType = @"GooglePlus";
                   accountTypeNum=3;
            _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            _bgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
            [self.view addSubview:_bgView];
            
            _moreActionView=[[UIView alloc]initWithFrame:CGRectMake(50, 130, 220, 250)];
            _moreActionView.layer.borderWidth=1.0f;
            _moreActionView.layer.borderColor=[UIColor blackColor].CGColor;

        _moreActionView.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:.9];
        _moreActionView.hidden=NO;
        _moreActionView.layer.cornerRadius=4.0f;
            [self.view addSubview:_moreActionView];
            [_bgView bringSubviewToFront:_moreActionView];
            
            
            UIButton *emailBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            emailBt.frame=CGRectMake(20, 50, 180, 40);
            emailBt.layer.cornerRadius=7.0f;
            emailBt.layer.borderColor=[UIColor redColor].CGColor;
            emailBt.layer.borderWidth=3.0f;
            emailBt.titleLabel.textColor=[UIColor blackColor];
            
            emailBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
            [emailBt addTarget:self action:@selector(openMailComposer1) forControlEvents:UIControlEventTouchUpInside];
            emailBt.titleLabel.textAlignment=NSTextAlignmentCenter;
            [emailBt setTitle:@"Email" forState:UIControlStateNormal];
            emailBt.backgroundColor=[UIColor whiteColor];
            [_moreActionView addSubview:emailBt];
            
            
            UIButton *cancelBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            cancelBt.frame=CGRectMake(20, 130, 180, 40);
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
        
        //[self.googleActionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}
//Task Button Action
//Display NewTaskViewController
-(void)taskButtonAction1:(id)sender{
    NSLog(@"Task Action Called");
     NSLog(@"Selected Row = %d",currentSelection);
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    
    NewTaskViewController *newTask = [[NewTaskViewController alloc] initWithNibName:@"NewTaskViewController" bundle:nil];
    
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        newTask.dataDict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        newTask.dataDict =[self.searchArray objectAtIndex:currentSelection];
    }
    else{
        NSLog(@"Unknown Table");
    }
    [self presentViewController:newTask animated:YES completion:nil];
}

//Replay on selected Message
-(IBAction)rePostButtonAction1:(id)sender{
    NSLog(@"RepostButton Action Called");
     NSLog(@"Selected Row = %d",currentSelection);
   // NSMutableDictionary *dict =[self.allMessageArray objectAtIndex:currentSelection];
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    
    NSMutableDictionary *dict = nil;
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        dict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        dict =[self.searchArray objectAtIndex:currentSelection];
    }
    else{
        NSLog(@"Unknown Table");
    }
    NSString *accountType = [NSString stringWithFormat:@"%@",[dict objectForKey:SocialAccountType]];
    
    //NSString *profileImageString=nil;
    if ([accountType isEqualToString:@"Facebook"]) {
        FBCommentPostViewController *repost = [[FBCommentPostViewController alloc] initWithNibName:@"FBCommentPostViewController" bundle:nil];
        repost.accountType = @"Facebook";
        repost.dataDict = dict ;
        [self presentViewController:repost animated:YES completion:nil];
        
    }
    else if ([accountType isEqualToString:@"Twitter"]){
        
        RePostViewController *repost = [[RePostViewController alloc] initWithNibName:@"RePostViewController" bundle:nil];
        repost.accountType = @"Twitter";
        NSString *pro_name = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_Name",[dict objectForKey:@"ProfileId"]]];
        
        NSString *pro_imageStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_ImageUrl",[dict objectForKey:@"ProfileId"]]];
        repost.message = [NSString stringWithFormat:@"@%@",pro_name];
        repost.profileName = [NSString stringWithFormat:@"%@",pro_name];
        repost.profileImage = pro_imageStr;
        
        repost.dataDict = dict;
        [self presentViewController:repost animated:YES completion:nil];
    }
    else if ([accountType isEqualToString:@"GooglePlus"]){
        FBCommentPostViewController *repost = [[FBCommentPostViewController alloc] initWithNibName:@"FBCommentPostViewController" bundle:nil];
        repost.accountType = @"GooglePlus";
        repost.dataDict=dict;
        [self presentViewController:repost animated:YES completion:nil];
    }
    
    
}

//Dicplay ActionSheet for Facebook Selected Message with OPtions
//    Like and Email

-(void)facebookActionSheetDisplay{
     //Like,  Email, From Facebook
    accountTypeNum=1;
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1 , height1)];
    _bgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:_bgView];
    
    _moreActionView=[[UIView alloc]initWithFrame:CGRectMake(width1/2-110, height1/2-150, 220, 300)];
    _moreActionView.backgroundColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:.9];
    _moreActionView.hidden=NO;
    _moreActionView.layer.cornerRadius=4.0f;

    _moreActionView.layer.borderColor=[UIColor blackColor].CGColor;
    _moreActionView.layer.borderWidth=1.0f;
    _moreActionView.layer.shadowColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)250/255 blue:(CGFloat)250/255 alpha:.7].CGColor;
    
        _moreActionView.hidden=NO;
        [self.view addSubview:_moreActionView];
    
    
        UIButton *likeBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        likeBt.frame=CGRectMake(20, 40, 180, 40);
        likeBt.layer.cornerRadius=7.0f;
        likeBt.layer.borderColor=[UIColor redColor].CGColor;
        likeBt.layer.borderWidth=3.0f;
    likeBt.titleLabel.textColor=[UIColor blackColor];
        likeBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
        [likeBt addTarget:self action:@selector(displayAllTwitterOrFacebookAccount) forControlEvents:UIControlEventTouchUpInside];
        likeBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [likeBt setTitle:@"Like" forState:UIControlStateNormal];
        likeBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:likeBt];
        
        UIButton *emailBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        emailBt.frame=CGRectMake(20, 100, 180, 40);
        emailBt.layer.cornerRadius=7.0f;
        emailBt.layer.borderColor=[UIColor redColor].CGColor;
        emailBt.layer.borderWidth=3.0f;
    emailBt.titleLabel.textColor=[UIColor blackColor];

        emailBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
    [emailBt addTarget:self action:@selector(openMailComposer1) forControlEvents:UIControlEventTouchUpInside];
        likeBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [emailBt setTitle:@"Email" forState:UIControlStateNormal];
        emailBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:emailBt];
    
        UIButton *shareBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        shareBt.frame=CGRectMake(20, 160, 180, 40);
        shareBt.layer.cornerRadius=7.0f;
        shareBt.layer.borderColor=[UIColor redColor].CGColor;
        shareBt.layer.borderWidth=3.0f;
        shareBt.titleLabel.font=[UIFont boldSystemFontOfSize:16.0f];
    shareBt.titleLabel.textColor=[UIColor blackColor];
         
    [shareBt addTarget:self action:@selector(openMessageBluetoothView:) forControlEvents:UIControlEventTouchUpInside];
        shareBt.titleLabel.textAlignment=NSTextAlignmentCenter;
        [shareBt setTitle:@"share" forState:UIControlStateNormal];
        shareBt.backgroundColor=[UIColor whiteColor];
        [_moreActionView addSubview:shareBt];
    
        
        UIButton *cancelBt=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelBt.frame=CGRectMake(20, 220, 180, 40);
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
       // self.fbActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Like",@"Email", nil];
        //self.fbActionSheet.tag=2;
        //self.fbActionSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    }
    //[self.fbActionSheet showFromTabBar:self.tabBarController.tabBar];

-(void)cancelView{
    [_bgView removeFromSuperview];
    _moreActionView.hidden=YES;
}



#pragma mark -
#pragma mark Action Sheet Methods



#pragma mark -
-(void) displayAllTwitterOrFacebookAccount{
    
    //Check Account Type
    /*
     if 1 display all connected Twitter Account
     else display all connected Facebook Account
      */
    if (accType==1) {
        NSLog(@"Display Tweeter Account");
        //buttonTitle = @"Proceed";
        //Fetch all Connected Twitter Account
        self.twitterAccountArray = [SingletonClass sharedSingleton].connectedTwitterAccount;
    }
    else{
        NSLog(@"Display Facebook Account");
       // buttonTitle = @"Proceed";
        //Fetch All Connected Facebook Account
        self.twitterAccountArray = [SingletonClass sharedSingleton].connectedFacebookAccount;
    }
    _moreActionView.hidden=YES;
    
    //UI for display Connect Twitter or Facebook Account
    
        self.secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width1, height1)];
    
        self.secondView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:self.secondView];
        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
        bgImageView.frame = CGRectMake(0, 0, width1, height1);
        //[self.secondView  addSubview:bgImageView];

        UIView *sec_header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width1,55*height1/480)];
    
    sec_header.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
        [self.secondView addSubview:sec_header];
//+++++++++++++++++++++++++++++++++
        
        
        
        
        self.can_two_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.can_two_btn.frame = CGRectMake(10, 15*height1/480,35*height1/480, 30*height1/480);
                self.can_two_btn.clipsToBounds = YES;
        [self.can_two_btn addTarget:self action:@selector(hidesecondView:) forControlEvents:UIControlEventTouchUpInside];
    //self.can_two_btn.titleLabel.font=[UIFont systemFontOfSize:width1/16];
    [self.can_two_btn setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
        //[self.can_two_btn setTitle:@"Back" forState:UIControlStateNormal];
        [sec_header addSubview:self.can_two_btn];
        
        UIImageView *logo=[[UIImageView alloc]initWithFrame:CGRectMake(10,34, 30, 40)];
        [logo setImage:[UIImage imageNamed:@"SB.png"]];
       // [self.secondView addSubview:logo];
        UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(47, 35,180, 40)];
        [logoTxt setImage:[UIImage imageNamed:@"logo_txt.png"]];
        //[self.secondView addSubview:logoTxt];

        //----------------------------------------------
        
        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favoriteButton.frame = CGRectMake(width1-(85*width1/320),20*height1/480, 75*width1/320, 30*height1/480);
        [self.favoriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.favoriteButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
        [self.favoriteButton setTitle:@"" forState:UIControlStateNormal];

        self.favoriteButton.backgroundColor=[UIColor clearColor];
        
        [self.favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *proceedImg=[[UIImageView alloc]initWithFrame:CGRectMake(width1-(85*width1/320),20*height1/480, 75*width1/320, 27*height1/480)];
        [proceedImg setImage:[UIImage imageNamed:@"proceed_btn@3x.png"]];
                [self.secondView addSubview:self.favoriteButton];
        [sec_header addSubview:proceedImg];

        //---------------------------------
        
        
        
        self.tweeterAccountTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 55*height1/480, width1-10,height1-(70*height1/480)) style:UITableViewStylePlain];
    self.tweeterAccountTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
   // self.tweeterAccountTableView.backgroundColor=[UIColor whiteColor];
        [self.secondView addSubview:self.tweeterAccountTableView];
        
        self.tweeterAccountTableView.opaque=NO;
        self.tweeterAccountTableView.backgroundColor=[UIColor whiteColor];
        //self.tweeterAccountTableView.backgroundView=nil;
        
        selectedTwitterAccountRow = -1;
        self.tweeterAccountTableView.delegate = self;
        self.tweeterAccountTableView.dataSource = self;

        [self.tweeterAccountTableView reloadData];
    
    //[self.favoriteButton setTitle: buttonTitle forState:UIControlStateNormal];
    [UIView animateWithDuration:.40 animations:^{
        self.secondView.frame = CGRectMake(0, 0, width1, height1);
    }];
}
-(void) hidesecondView:(id)sender{
    
    [UIView animateWithDuration:.10 animations:^{
        self.secondView.frame = CGRectMake(width1, 0, width1,height1);
    }];
    _moreActionView.hidden=NO;
}
//Like on Facebook or Favorite on Twitter on Selected Message
-(void) favoriteButtonAction:(id)sender{
    NSLog(@"Selected rowe = %d", selectedTwitterAccountRow);
    if (selectedTwitterAccountRow <0) {
        return;
    }
    NSDictionary *dict = [self.twitterAccountArray objectAtIndex:selectedTwitterAccountRow];
    NSLog(@"Dict ===%@",dict);

    if ([currentSelectedAccountType isEqualToString: @"Twitter"]) {
        [self getTwitterUserDetails:dict];
    }
    else if ([currentSelectedAccountType isEqualToString: @"Facebook"]){
        [self getFaceBookUserDetails:dict];
    }

    
    [UIView animateWithDuration:.40 animations:^{
        self.secondView.frame = CGRectMake(self.view.frame.size.width, 0, 320, self.view.frame.size.height);
        _moreActionView.hidden=NO;
    }];
}
#pragma mark -
#pragma mark Open share Composer
-(void)openMessageBluetoothView:(int)accType{
    
    NSDictionary *dict = nil;
    
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        dict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        dict =[self.searchArray objectAtIndex:currentSelection];
    }
    else{
        NSLog(@"Unknown Table");
    }
    NSString *message = nil;
    if (accountTypeNum == 2) {
        NSLog(@"Twitter Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterMsg"]];
    }
    else if (accountTypeNum == 1){
        NSLog(@"Facebook Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
    }
    else if (accountTypeNum == 3){
        NSLog(@"Google Plus Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Content"]];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    
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
    NSDictionary *dict = nil;
    
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        dict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        dict =[self.searchArray objectAtIndex:currentSelection];
    }
    else{
        NSLog(@"Unknown Table");
    }
    NSString *message = nil;
    if (accountTypeNum == 2) {
        NSLog(@"Twitter Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterMsg"]];
    }
    else if (accountTypeNum == 1){
        NSLog(@"Facebook Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
    }
    else if (accountTypeNum == 3){
        NSLog(@"Google Plus Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Content"]];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray *objectsToShare = @[message];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter,            UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMail,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;

    [self presentViewController:controller animated:YES completion:nil];
     */
    
    
    
    /*
    mesgBluetoothView=[[UIView alloc] initWithFrame:CGRectMake(30, 180,260, 140)];
    mesgBluetoothView.layer.cornerRadius=5.0f;
    mesgBluetoothView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:mesgBluetoothView];
    
    UIButton *messageBut=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    messageBut.frame=CGRectMake(170,45,70,60);
    [messageBut setBackgroundImage:[UIImage imageNamed:@"message5.jpg"] forState:UIControlStateNormal];
    [messageBut addTarget:self action:@selector(openMessageComposer) forControlEvents:UIControlEventTouchUpInside];
    [mesgBluetoothView addSubview:messageBut];
    
    
    UIButton *blueTooth=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    blueTooth.frame=CGRectMake(30,45,70,60);
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

-(void) openMessageComposer{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    NSDictionary *dict = nil;
    
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        dict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        dict =[self.searchArray objectAtIndex:currentSelection];
    }
    else{
        NSLog(@"Unknown Table");
    }
    NSString *message = nil;
    if (accountTypeNum == 2) {
        NSLog(@"Twitter Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterMsg"]];
    }
    else if (accountTypeNum == 1){
        NSLog(@"Facebook Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
    }
    else if (accountTypeNum == 3){
        NSLog(@"Google Plus Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Content"]];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    [self presentViewController:messageController animated:YES completion:nil];
    
}



-(void)openBluetoothView{
    
    NSDictionary *dict = nil;
    
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        dict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        dict =[self.searchArray objectAtIndex:currentSelection];
    }
    else{
        NSLog(@"Unknown Table");
    }
    NSString *message = nil;
    if (accountTypeNum == 2) {
        NSLog(@"Twitter Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterMsg"]];
    }
    else if (accountTypeNum == 1){
        NSLog(@"Facebook Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
    }
    else if (accountTypeNum == 3){
        NSLog(@"Google Plus Account");
        message = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Content"]];
    }
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    

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
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"msgnoSent"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 3){
        NSLog(@"Failed");
        [[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:@"Please check your bal" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
    }
    
    
}



-(void)cancelPicView1{
    
    mesgBluetoothView.hidden=YES;
    _moreActionView.hidden=NO;
}







#pragma mark -
#pragma mark Open Email Composer



//Open mail Composer for sending Mail
-(void) openMailComposer1{
    
    if([MFMailComposeViewController canSendMail]){
        NSLog(@"Send Mail");
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSDictionary *dict = nil;
        if ([self.currentTable isEqualToString:@"MessageTable"]) {
            dict =[self.allMessageArray objectAtIndex:currentSelection];
        }
        else if([self.currentTable isEqualToString:@"SearchTable"]){
            dict =[self.searchArray objectAtIndex:currentSelection];
        }
        else{
            NSLog(@"Unknown Table");
        }
        NSString *emailBody = nil;
        if (accountTypeNum == 2) {
            NSLog(@"Twitter Account");
            emailBody = [NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterMsg"]];
        }
        else if (accountTypeNum == 1){
            NSLog(@"Facebook Account");
            emailBody = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Message"]];
        }
        else if (accountTypeNum == 3){
            NSLog(@"Google Plus Account");
            emailBody = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Content"]];
        }
        emailBody = [emailBody stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        [mailer setSubject:@"A Message from SOCIOBOARD"];
       // NSString *emailBody = @"Have you seen the MobileTuts+ web site?";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else{
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cantsendmail"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"configMail"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
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
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"savedDraft"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 2){
        NSLog(@"Sent");
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SentMsg"]
                                                        message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (result == 3){
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"failedMsg"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        NSLog(@"Failed");
    }
}
#pragma mark - 
#pragma mark Twitter Favorite
//Get selected Twitter account Info
-(void) getTwitterUserDetails: (NSDictionary *)dataDict{
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    NSString *proID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId =[SingletonClass sharedSingleton].profileID;
    
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
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/TwitterAccount.asmx?op=GetTwitterAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetTwitterAccountDetailsById" forHTTPHeaderField:@"SOAPAction"];
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
       
        NSDictionary *feeddict = nil;
            if ([self.currentTable isEqualToString:@"MessageTable"]) {
            feeddict =[self.allMessageArray objectAtIndex:currentSelection];
            }
            else if([self.currentTable isEqualToString:@"SearchTable"]){
                feeddict =[self.searchArray objectAtIndex:currentSelection];
            }
        
        
        NSString *mesId = [[NSString alloc] initWithFormat:@"%@",[feeddict objectForKey:@"MessageId"]];
       
        returnCode = [[FHSTwitterEngine sharedEngine]markTweet:mesId asFavorite:YES aouthTokenDictionary:dict];
        
        
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (!returnCode) {
            NSLog(@"%@",returnCode);
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"successMsg"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
            [av show];
            [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

        }
        else{
            NSLog(@"Error to Pos Twitter==%ld",(long)returnCode.code );
            //Code == 139 message= You have already favorited this status
            //code == 89  message":"Invalid or expired token.
            
            
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
    [self.hud hide:YES];
}
#pragma mark -
#pragma mark Like on Facebook
//Get selected Facebook Account Info
- (void)getFaceBookUserDetails:(NSDictionary *)dataDict{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    NSString *fbID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    //NSString *strUserid = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"UserId"]];
    NSString *strUserid=[SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Facebook-=-= %@",fbID);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<getFacebookAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<ProfileId>%@</ProfileId>\n"
                             "</getFacebookAccountDetailsById>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserid,fbID];
    
    NSLog(@"soapMessg facebook %@",soapmessage);
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/FacebookAccount.asmx?op=getFacebookAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/getFacebookAccountDetailsById" forHTTPHeaderField:@"SOAPAction"];
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
        NSString *accessToken = [dict objectForKey:@"AccessToken"];
        NSLog(@"Info Dict = %@", dict);
        
        [self likeOnFacebook:accessToken];
    }
    [self.hud hide:YES];
}
//Perform Like operation on Facebook
-(void)likeOnFacebook:(NSString *)accessToken{
    //NSDictionary *dict = [self.allMessageArray objectAtIndex:currentSelection];
    NSDictionary *dict = nil;
    if ([self.currentTable isEqualToString:@"MessageTable"]) {
        dict =[self.allMessageArray objectAtIndex:currentSelection];
    }
    else if([self.currentTable isEqualToString:@"SearchTable"]){
        dict =[self.searchArray objectAtIndex:currentSelection];
    }
    NSString *mesId = [[NSString alloc] initWithFormat:@"%@",[dict objectForKey:@"MessageId"]];
    
    
    NSLog(@"%@",mesId);
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/likes",mesId];
    NSURL *url = [NSURL URLWithString:urlString];

    //NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/124119744888_10151904850279889/likes"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setStringEncoding:NSUTF8StringEncoding];
    [request setPostValue:accessToken forKey:@"access_token"];
    //[request setDidFinishSelector:@selector(likePost:)];
    NSError *error;
    //[request setDelegate:self];
    [request startSynchronous];
    
    error = [request error];
    NSLog(@"%@",error);
    if (error) {
        NSLog(@"error=%@",error);
        //[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your internet connection and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        //[self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:1.0];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
    }
    else{
        
        NSString *response = [request responseString];
        NSLog(@"response = %@",response);
        if ([response rangeOfString:@"error"].location != NSNotFound) {
           
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
        }
        else{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"successMsg"] message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
        }
        NSLog(@"response = %@",response);
    }
}

#pragma mark -

-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


@end

