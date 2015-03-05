//
//  GroupViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 15/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "GroupViewController.h"
#import "SingletonClass.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "MessageCustomCell.h"
#import "UIImageView+WebCache.h"

#define FacabookWallPostValue @"facebookwallpostValue"
#define SentMessagesValue @"sentmessagesvalue"
#define FacebookCommentsValue @"commentsValue"
#define TwitterPublicMentionsValue @"publicMentionsValue"
#define TwitterMessagesValue @"twitterMessagesValue"
#define TwitterRetweetsValue @"twitterRetwttesValue"
#define GooglePlusActivitiesValue @"GooglePlusActivitiedValue"

@interface GroupViewController (){
    CGRect screenRect;
    
}

@end

@implementation GroupViewController

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
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    groupNo=0;
    noOfLeftShift=1;
    UIImageView * backgroungimg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"normalScreen.png"]];
    backgroungimg.frame=CGRectMake(0, 0, width1, height1);
    [self.view addSubview:backgroungimg];
    
    
    _status=[[UILabel alloc]initWithFrame:CGRectMake(width1/2-75,screenRect.size.height-80 ,150,30)];
    _status.backgroundColor=[UIColor redColor];
    _status.textColor=[UIColor whiteColor];
    _status.font=[UIFont systemFontOfSize:10.0f];
    _status.layer.borderColor=[UIColor blackColor].CGColor;
    _status.textAlignment=NSTextAlignmentCenter;
    _status.layer.borderWidth=4.0f;
    _status.text=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"lgSuccess"];
    [self.view addSubview:_status];
    
    
    
    _downLbl=[[UILabel alloc]initWithFrame:CGRectMake(5,screenRect.size.height-30, 200,30)];
    _downLbl.backgroundColor=[UIColor clearColor];
    _downLbl.textColor=[UIColor whiteColor];
    _downLbl.font=[UIFont systemFontOfSize:12.0f];
    _downLbl.text=@"Free for personal use";
    //downLbl.textAlignment=NSTextAlignmentCenter;
    //downLbl.layer.borderWidth=4.0f;
    [self.view addSubview:_downLbl];
    
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [self.view endEditing:YES];
    HUD.delegate = self;
    //HUD.dimBackground=YES;
    HUD.color = [UIColor colorWithRed:0.50 green:0.30 blue:0.60 alpha:0.60];
    HUD.labelText = @"Loading";
    HUD.square = YES;
    HUD.alpha=1;
    [HUD show:YES];
    
   
    
    
    // Do any additional setup after loading the view from its nib.
    
    
    //[self loadAccountInfo];
    [self fetchGroupIDs];
    //[NSThread detachNewThreadSelector:@selector(fetchGroupIDs) toTarget:self withObject:nil];
    
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark-





-(void) fetchGroupIDs{
    
    NSString *strProfileId = [SingletonClass sharedSingleton].profileID;
    //strProfileId = @"256f9c69-6b6a-4409-a309-b1f6d1f8e43b";
    //
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetGroupDetailsByUserId xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "</GetGroupDetailsByUserId>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strProfileId];
    
    //NSLog(@"soapMessg  %@",soapmessage);
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/Groups.asmx?op=GetGroupDetailsByUserId",WebLink];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetGroupDetailsByUserId" forHTTPHeaderField:@"SOAPAction"];
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
        NSLog(@"XML String = %@",responseString);
        NSString *jsonString = [HelperClass stripTags:responseString startString:@"[{" upToString:@"}]"];
        jsonString = [NSString stringWithFormat:@"%@}]",jsonString];
        NSLog(@"Response String = %@",jsonString);
        NSMutableArray *jsonArray = [jsonString JSONValue];
        tempArray = [[NSMutableArray alloc] init];
        
        
        if (jsonArray.count==0) {
            return;
        }
        for (int i=0; i<jsonArray.count; i++) {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
            tempDict =[jsonArray objectAtIndex:i];
            
            //NSString *SocioboardStr=[tempDict objectForKey:@"GroupName"];
            if([[tempDict objectForKey:@"GroupName"] isEqualToString:@"Socioboard"]){
                [tempArray insertObject:tempDict atIndex:0];
                
            }
            else{
                [tempArray addObject:tempDict];
            }
            
        }
        _allGrpProfile=[[NSMutableArray alloc]init];
        totalTeam=(int)jsonArray.count;
        
        NSLog(@"%@",tempArray);
        [self fetchTeamId];
        [self createUI];

        //[NSThread detachNewThreadSelector:@selector(getFirstTeamData) toTarget:self withObject:nil];
                          //  dispatch_async(dispatch_get_main_queue(),^{
                
           // });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    for(int i=0;i<totalTeam-1;i++)
                    {

                    [self fetchTeamId];
                    }
               }});
           
            
            
       
       
        //[SingletonClass sharedSingleton].groupIDArray = tempArray;
    }//End else block
    
}


    

#pragma mark -

-(void)createUI{
    /*
     UISwipeGestureRecognizer *swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight)];
     swiperight.direction=UISwipeGestureRecognizerDirectionRight;
     //[self.view addGestureRecognizer:swiperight];
     
     
     UISwipeGestureRecognizer *swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft)];
     swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
     //[self.view addGestureRecognizer:swipeleft];
     */
    
    
   
    
    enterGrp=0;
    UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(30*width1/320, 20*height1/480, 260*width1/320, 40*height1/480)];
    
    [logoTxt setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:logoTxt];

    
    UILabel *userName=[[UILabel alloc]initWithFrame:CGRectMake(0, 80*height1/480,320*width1/320, 40)];
    userName.text= [SingletonClass sharedSingleton].userName;
    userName.font=[UIFont systemFontOfSize:width1/14];
    userName.textAlignment=NSTextAlignmentCenter;
    userName.textColor=[UIColor whiteColor];
    [self.view addSubview:userName];
    
    
    
    NSDictionary *group=[tempArray objectAtIndex:0];
    
    grpLabel=[[UILabel alloc]initWithFrame:CGRectMake(70*width1/320, 300*height1/480,220*width1/320, 40*height1/480)];
    
    
    grpLabel.text=[group objectForKey:@"GroupName"];
    grpLabel.font=[UIFont systemFontOfSize:width1/16];
    grpLabel.textAlignment=NSTextAlignmentLeft;
    grpLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:grpLabel];
    
    
    
    UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(10, 300*height1/480, 300*width1/320, 1*height1/480)];
    devider.backgroundColor=[UIColor whiteColor];
   // [self.view addSubview:devider];
    
    UIView *devider1=[[UIView alloc]initWithFrame:CGRectMake(60*width1/320, 340*height1/480, 200*width1/320, .4*height1/480)];
    devider1.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:devider1];
    
    UIView *devider2=[[UIView alloc]initWithFrame:CGRectMake(10, 380*height1/480, 300*width1/320, 1*height1/480)];
    devider2.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:devider2];
    
    
    
    noOfProf=[[UILabel alloc]initWithFrame:CGRectMake(70*width1/320,340*height1/480,200*width1/320, 40*height1/480)];
    NSString *str=[NSString stringWithFormat:@"%d %@",noOfPofile,[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"Profilemsg"]];
    //[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"Profilemsg"];
    noOfProf.text=str;
    noOfProf.font=[UIFont systemFontOfSize:width1/16];
    noOfProf.textAlignment=NSTextAlignmentLeft;
    noOfProf.textColor=[UIColor whiteColor];
    [self.view addSubview:noOfProf];
    
    
    UIButton *grpChange=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    grpChange.frame=CGRectMake(260*width1/320, 300*height1/480,40*width1/320, 40*width1/320);
    grpChange.backgroundColor=[UIColor clearColor];
    grpChange.layer.cornerRadius=7.0f;
    [self.view addSubview:grpChange];
    [grpChange setBackgroundImage:[UIImage imageNamed:@"plus_icon.png"] forState:UIControlStateNormal];

    [grpChange addTarget:self action:@selector(grpChangeAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *grpImg=[[UIImageView alloc]initWithFrame:CGRectMake(20*width1/320, 310*height1/480, 40*width1/320,30*width1/320)];
    grpImg.image=[UIImage imageNamed:@"group_icon@2x.png"];
    [self.view addSubview:grpImg];
    
    UIImageView *singleImg=[[UIImageView alloc]initWithFrame:CGRectMake(20*width1/320, 350*height1/480, 40*width1/320, 30*width1/320)];
    singleImg.image=[UIImage imageNamed:@"user_icon@2x.png"];
    [self.view addSubview:singleImg];

    
    
    UIButton *info=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    info.frame=CGRectMake(260*width1/320, 340*height1/480,40*width1/320, 40*width1/320);
    info.backgroundColor=[UIColor clearColor];
    info.layer.cornerRadius=7.0f;
    [info setBackgroundImage:[UIImage imageNamed:@"arrow-14.png"] forState:UIControlStateNormal];
    [self.view addSubview:info];
    [info addTarget:self action:@selector(doneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    _logoutButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    _logoutButton.frame=CGRectMake(30*width1/320, height1-(65*height1/480),260*width1/320, 40*height1/480);
    _logoutButton.backgroundColor=[UIColor clearColor];
    _logoutButton.layer.cornerRadius=7.0f;
    [_logoutButton setBackgroundImage:[UIImage imageNamed:@"logout_btn@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:_logoutButton];
    [_logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *imageUrlString1= [NSString stringWithFormat:@"%@",[SingletonClass sharedSingleton].mainProPic];
    NSLog(@"%@",imageUrlString1);
     UIImageView *UserPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(((width1/2)-(75*height1/480)),120*height1/480, 150*height1/480,150*height1/480)];
    if([imageUrlString1 isEqualToString:@""]){
        UserPhoto.image=[UIImage imageNamed:@"profile_icon@3x.png"];
    }
    else{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString1]];
    UIImage *Im=[UIImage imageWithData:data];
   
    UserPhoto.layer.cornerRadius=90*width1/320;
    UserPhoto.clipsToBounds=YES;
    [UserPhoto setImage:Im];
    }
    [self.view addSubview:UserPhoto];
    

    
    
    [self.hud hide:YES];
    [HUD hide:YES];
    
    _status.hidden=YES;
    
    
}







-(void)fetchTeamId{
    
    
    
    
    //strProfileId = @"256f9c69-6b6a-4409-a309-b1f6d1f8e43b";
    NSLog(@"%d",groupNo);
    NSDictionary *grp=[tempArray objectAtIndex:groupNo];
    NSString *strProfileId=[grp objectForKey:@"Id"];
    NSLog(@"%@",strProfileId);
    //
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetTeamByGroupId xmlns=\"http://tempuri.org/\">\n"
                             "<GroupId>%@</GroupId>\n"
                             "</GetTeamByGroupId>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strProfileId];
    
    NSLog(@"soapMessg  %@",soapmessage);
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/Team.asmx?op=GetTeamByGroupId",WebLink];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetTeamByGroupId" forHTTPHeaderField:@"SOAPAction"];
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
        NSLog(@"XML String = %@",responseString);
        NSString *jsonString = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        jsonString = [NSString stringWithFormat:@"%@}",jsonString];
        NSDictionary *dict = [jsonString JSONValue];
        NSLog(@"respo==%@",dict);
        
        
        [self loadAccountInfo:dict];
        
    }
    
}

//Call WEb service for fetching all connected Account Informations
-(void)loadAccountInfo:(NSDictionary*)teamId{
    
    NSString *strProfileId=[teamId objectForKey:@"Id"];
    NSLog(@"%@",strProfileId);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetTeamMemberProfilesByTeamId xmlns=\"http://tempuri.org/\">\n"
                             "<TeamId>%@</TeamId>\n"
                             "</GetTeamMemberProfilesByTeamId>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strProfileId];
    
    NSLog(@"soapMessg  %@",soapmessage);
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/TeamMemberProfile.asmx?op=GetTeamMemberProfilesByTeamId",WebLink];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:150];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetTeamMemberProfilesByTeamId" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
    }
    [_allGrpProfile insertObject:responseData atIndex:groupNo];
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    
    webdata = [[NSMutableData alloc]init];
    [webdata appendData:responseData];
    
    
    NSString *response1 = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
    
    NSString *jsonString = [NSString stringWithFormat:@"%@}]",response1];
    NSMutableArray *jsonArray = [jsonString JSONValue];
    NSLog(@"respo==%@",jsonArray);
    noOfPofile=(int)jsonArray.count;
    NSLog(@"%d",noOfPofile);
    groupNo++;
    if(groupNo==totalTeam){
        downLoadOver=2;
        groupNo=0;
        [SingletonClass sharedSingleton].allGrpProfileArray=_allGrpProfile;
    }
    return;
    
}
/*
 - (void)didReceiveMemoryWarning
 {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }
 -(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
 [webdata appendData:data];
 //    NSString *wdata=[[NSString alloc]initWithData:webdata encoding:NSUTF8StringEncoding];
 //    NSLog(@"string formate= %@",wdata);
 }
 
 -(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
 [HUD hide:YES];
 UIAlertView *myAlert = [[UIAlertView alloc]
 initWithTitle:nil message:@"Please Check your Network Connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
 [myAlert show];
 ViewController *v1=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
 [self presentViewController:v1 animated:YES completion:nil];
 return;
 }
 */
//Fetch all response
-(void)saveInfo{
    [SingletonClass sharedSingleton].teamNo=enterGrp;
    [SingletonClass sharedSingleton].teamArray=tempArray;
    [SingletonClass sharedSingleton].totalTeam=totalTeam;
    [SingletonClass sharedSingleton].typeOfCell=NO;
    NSDictionary *grp=[tempArray objectAtIndex:enterGrp];
    
    [SingletonClass sharedSingleton].groupID=[grp objectForKey:@"Id"];
    webdata = [[NSMutableData alloc]init];
    [webdata appendData:[_allGrpProfile objectAtIndex:enterGrp]];
    
    NSString *wdata=[[NSString alloc]initWithData:webdata encoding:NSUTF8StringEncoding];
    NSLog(@"string formate= %@",wdata);
    
    if ([wdata rangeOfString:@"Please Try Again"].location != NSNotFound) {
        buttonenable = 1;
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"Error" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        ViewController *v1=[[ViewController alloc]initWithNibName:@"ViewController" bundle:nil];
        [self presentViewController:v1 animated:YES completion:nil];
        
    }
    else{
        //-----------------------------------------
        // Parse JSON String from Response String
        
        NSString *response = [HelperClass stripTags:wdata startString:@"[" upToString:@"]"];
        NSString *jsonString = [NSString stringWithFormat:@"%@]",response];
        NSArray *jsonArray = [jsonString JSONValue];
        
        [SingletonClass sharedSingleton].connectedprofileInfo=(NSMutableArray*)jsonArray;
        [SingletonClass sharedSingleton].accountLoaded = YES;
        NSLog(@"JsonArray==%@",jsonArray);
        
        //----------------------
        /*
         fetch all Twitter, Facebook, Google Plus and Linkedin Account
         and stroe these account info to Singleton Class
         -------------------------------------------------*/
        NSMutableArray *accArray=[[NSMutableArray alloc]init];
        NSMutableArray *messageArray = [[NSMutableArray alloc] init];
        NSMutableArray *feedAccount = [[NSMutableArray alloc] init];
        NSMutableArray *twitterAcount = [[NSMutableArray alloc] init];
        NSMutableArray *facebookAccount = [[NSMutableArray alloc] init];
        NSMutableArray *linkedinAccount = [[NSMutableArray alloc] init];
        NSMutableArray *instagramAccount = [[NSMutableArray alloc] init];
        NSMutableArray *tumblerAccount = [[NSMutableArray alloc] init];
        NSMutableArray *utubeAccount = [[NSMutableArray alloc] init];
        if (jsonArray.count<=0) {
            buttonenable = 1;
            //nomemberMsg
            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"nomemberMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
                [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
            [HUD hide:YES];
            isTeamEmpty=2;
            return;
            
        }
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        for (int i =0; i<jsonArray.count; i++) {
            
            NSMutableDictionary *dict =[jsonArray objectAtIndex:i];
            [SingletonClass sharedSingleton].teamID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"Id"]];
            NSString *proType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
            
            [userDefault setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]] forKey:[NSString stringWithFormat:@"%@_Name",[dict objectForKey:@"ProfileId"]]];
            if ([proType isEqualToString:@"tumblr"]) {
                
                [userDefault setObject:[NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@.tumblr.com/avatar",[dict objectForKey:@"ProfilePicUrl"]] forKey:[NSString stringWithFormat:@"%@_ImageUrl",[dict objectForKey:@"ProfileId"]]];
            }
            else{
                [userDefault setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfilePicUrl"]] forKey:[NSString stringWithFormat:@"%@_ImageUrl",[dict objectForKey:@"ProfileId"]]];
            }
            
            if ([proType isEqualToString:@"facebook"]) {
                [accArray addObject:dict];
                [feedAccount insertObject:dict atIndex:0];
                [facebookAccount addObject:dict];
                if (![messageArray containsObject:@"Wall Posts"]) {
                    
                    [messageArray addObject:@"Wall Posts"];
                    //[messageArray addObject:@"Comments"];
                }
            }//End facebook check
            else if ([proType isEqualToString:@"twitter"]) {
                
                [accArray insertObject:dict atIndex:0];
                [feedAccount insertObject:dict atIndex:0];
                [twitterAcount addObject:dict];
                [SingletonClass sharedSingleton].haveTwitterAccount=YES;
                if (![messageArray containsObject:@"Messages"]) {
                    
                    [messageArray insertObject:@"Retweets" atIndex:0];
                    [messageArray insertObject:@"Messages" atIndex:0];
                    [messageArray insertObject:@"Public Mentions" atIndex:0];
                }
            }//End Twitter check
            else if ([proType isEqualToString:@"googleplus"]) {
                
                [accArray insertObject:dict atIndex:accArray.count];
                if (![messageArray containsObject:@"Activities"]) {
                    
                    [messageArray insertObject:@"Activities" atIndex:messageArray.count];
                }
                
            }//End GooglePlus check
            else if ([proType isEqualToString:@"instagram"]) {
                
                [feedAccount insertObject:dict atIndex:feedAccount.count];
                [instagramAccount addObject:dict];
                
            }//End instagram check
            else if ([proType isEqualToString:@"linkedin"]) {
                [feedAccount addObject:dict];
                [linkedinAccount addObject:dict];
                
            }//End linkedin check
            
            else if ([proType isEqualToString:@"tumblr"]){
                [feedAccount addObject:dict];
                [tumblerAccount addObject:dict];
            }
            else if ([proType isEqualToString:@"youtube"]){
                [feedAccount addObject:dict];
                [utubeAccount addObject:dict];
            }
            
        }//End For Loop
        NSLog(@"Account Array = %@",accArray);
        NSLog(@"Message Array = %@",messageArray);
        
        // Store All fetched information to Singleton Class
        [SingletonClass sharedSingleton].messagePageAccountArray=accArray;
        [SingletonClass sharedSingleton].messageTypeArray = messageArray;
        [SingletonClass sharedSingleton].feedPageAccountArray =  feedAccount;
        [SingletonClass sharedSingleton].connectedTwitterAccount = twitterAcount;
        [SingletonClass sharedSingleton].connectedFacebookAccount = facebookAccount;
        [SingletonClass sharedSingleton].connectedLinkedinAccount = linkedinAccount;
        [SingletonClass sharedSingleton].connectedTumblerAccount = tumblerAccount;
        [SingletonClass sharedSingleton].connectedInstagramAccount = instagramAccount;
        [SingletonClass sharedSingleton].connectedUtubeAccount = utubeAccount;
        
        [userDefault setObject:@"1" forKey:@"WoosuiteFirstRun"];
        NSMutableArray *accountValueArray = [[NSMutableArray alloc] initWithCapacity:accArray.count];
        for (int i=0; i<accArray.count; i++) {
            [accountValueArray addObject:@"0"];
        }
        [userDefault setObject:accountValueArray forKey:@"WoosuiteAccountValue"];
        
        NSMutableArray *messageTypeValueArray = [[NSMutableArray alloc] initWithCapacity:messageArray.count];
        for (int i=0; i<messageArray.count; i++) {
            [messageTypeValueArray addObject:@"1"];
        }
        [messageTypeValueArray insertObject:@"0" atIndex:messageTypeValueArray.count];
        [userDefault setObject:messageTypeValueArray forKey:@"WoosuiteMessageTypevale"];
        
        //Set default Value for Message Type(Display in InboxSetingViewController)
        [userDefault setObject:@"1" forKey:FacabookWallPostValue];
        [userDefault setObject:@"0" forKey:SentMessagesValue];
        [userDefault setObject:@"1" forKey:TwitterPublicMentionsValue];
        [userDefault setObject:@"1" forKey:TwitterMessagesValue];
        [userDefault setObject:@"1" forKey:TwitterRetweetsValue];
        [userDefault setObject:@"1" forKey:GooglePlusActivitiesValue];
        //---------------------------------
        [SingletonClass sharedSingleton].feedSelAcc = -1;
        [SingletonClass sharedSingleton].schedulePreSelected = -1;
        [userDefault synchronize];
    }
    [_bgView removeFromSuperview];
    [HUD hide:YES];
    
    
    
}

#pragma mark-
-(void)swipeleft
{
    if(groupNo<(totalTeam-1)){
        groupNo++;
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        
        [self.view endEditing:YES];
        HUD.delegate = self;
        HUD.color = [UIColor colorWithRed:0.50 green:0.30 blue:0.60 alpha:0.60];
        HUD.labelText = @"Loading";
        HUD.square = YES;
        HUD.alpha=1;
        [HUD show:YES];
        NSLog(@"%@",[_allGrpProfile objectAtIndex:(groupNo-1)]);
        
        
        
        if(noOfLeftShift<=groupNo){
            [self.view addSubview:HUD];
            noOfLeftShift++;
            [self fetchTeamId];
        }
        else{
            NSData *responseData=[_allGrpProfile objectAtIndex:groupNo];
            NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"respo==%@",responseString);
            webdata = [[NSMutableData alloc]init];
            [webdata appendData:responseData];
            NSString *response1 = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
            
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response1];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            noOfPofile=(int)jsonArray.count;
        }
        NSLog(@"%@",tempArray);
        NSDictionary *group=[tempArray objectAtIndex:groupNo];
        NSLog(@"%@",group);
        grpLabel.text=[group objectForKey:@"GroupName"];
        NSString *str=[NSString stringWithFormat:@"%d Profiles",noOfPofile];
        noOfProf.text=str;
        [HUD hide:YES];
    }
    
    
}

-(void)swiperight
{   if(groupNo>0){
    groupNo--;
    //if(![_allGrpProfile objectAtIndex:groupNo]){
    // [self fetchTeamId];
    //}
    // else{
    NSData *responseData=[_allGrpProfile objectAtIndex:groupNo];
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"respo==%@",responseString);
    webdata = [[NSMutableData alloc]init];
    [webdata appendData:responseData];
    NSString *response1 = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
    
    NSString *jsonString = [NSString stringWithFormat:@"%@}]",response1];
    NSMutableArray *jsonArray = [jsonString JSONValue];
    noOfPofile=(int)jsonArray.count;
    //}
    /*
     HUD = [[MBProgressHUD alloc] initWithView:self.view];
     [self.view addSubview:HUD];
     [self.view endEditing:YES];
     HUD.delegate = self;
     //HUD.dimBackground=YES;
     HUD.color = [UIColor colorWithRed:0.50 green:0.30 blue:0.60 alpha:0.60];
     HUD.labelText = @"Loading";
     HUD.square = YES;
     HUD.alpha=1;
     [HUD show:YES];
     */
    NSLog(@"%@",tempArray);
    NSDictionary *group=[tempArray objectAtIndex:groupNo];
    NSLog(@"%@",group);
    grpLabel.text=[group objectForKey:@"GroupName"];
    NSString *str=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"Profilemsg"];
    noOfProf.text=str;
    //[HUD hide:YES];
    
}
}
#pragma mark -

-(void)grpChangeAction{
    while (downLoadOver<1) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        
        [self.view endEditing:YES];
        HUD.delegate = self;
        HUD.color = [UIColor colorWithRed:0.50 green:0.30 blue:0.60 alpha:0.60];
        HUD.labelText = @"Loading";
        HUD.square = YES;
        HUD.alpha=1;
        [HUD show:YES];

    }
    [HUD hide:YES];
    UIView *grpDisplayView=[[UIView alloc]initWithFrame:CGRectMake(100*width1/320, 320*height1/480, 170*width1/320, 150*height1/480)];
    [self.view addSubview:grpDisplayView];
    UIImageView *grpImgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width1, height1)];
    grpImgView.image=[UIImage imageNamed:@"darshan.jpg"];
    //[grpImgView addSubview:grpImgView];
    
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,10,170*width1/320, 140*height1/480) style:UITableViewStyleGrouped];
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:@"SimpleTableIdentifier"];
    
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    tableView.opaque=NO;
    tableView.backgroundColor=[UIColor whiteColor];
    tableView.backgroundView=nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled=YES;
    [grpDisplayView addSubview:tableView];
    
    
    
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return totalTeam;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *header=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"groupMsg"];
    //groupMsg
    return header;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.contentView.backgroundColor=[UIColor whiteColor];
    header.textLabel.textColor = [UIColor blackColor];
    header.textLabel.font=[UIFont boldSystemFontOfSize:width1/18];
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font=[UIFont systemFontOfSize:width1/18];
    cell.textLabel.backgroundColor =[UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)0/255 blue:(CGFloat)0/255 alpha:0.3];
    
    cell.backgroundColor = [UIColor colorWithRed:(CGFloat)254/255 green:(CGFloat)250/255 blue:(CGFloat)254/255 alpha:1];
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
    cell.backgroundColor=[UIColor whiteColor];
    NSDictionary *grp=[tempArray objectAtIndex:indexPath.row];
    NSString *strProfileId=[grp objectForKey:@"GroupName"];
    cell.textLabel.text=strProfileId;
    
    
    return cell;
}



-(void) tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    groupNo=indexPath.row;
    enterGrp=groupNo;
    [self.view endEditing:YES];
    HUD.delegate = self;
    //HUD.dimBackground=YES;
    HUD.color = [UIColor colorWithRed:0.50 green:0.30 blue:0.60 alpha:0.60];
    HUD.labelText = @"Loading";
    HUD.square = YES;
    HUD.alpha=1;
    [HUD show:YES];
    //NSLog(@"%@",[_allGrpProfile objectAtIndex:(groupNo-1)]);
    
    
    
    
    NSData *responseData=[_allGrpProfile objectAtIndex:groupNo];
    NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"respo==%@",responseString);
    webdata = [[NSMutableData alloc]init];
    [webdata appendData:responseData];
    NSString *response1 = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
    
    NSString *jsonString = [NSString stringWithFormat:@"%@}]",response1];
    NSMutableArray *jsonArray = [jsonString JSONValue];
    noOfPofile=(int)jsonArray.count;
    
    NSLog(@"%@",tempArray);
    NSDictionary *group=[tempArray objectAtIndex:groupNo];
    NSLog(@"%@",group);
    grpLabel.text=[group objectForKey:@"GroupName"];
   NSString *str=[NSString stringWithFormat:@"%d %@",noOfPofile,[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"Profilemsg"]];
    noOfProf.text=str;
    [HUD hide:YES];
    tableView.hidden=YES;
    
    
    
}








#pragma mark -


-(void)doneButtonClicked{
    isTeamEmpty=0;
    [self saveInfo];
        if(isTeamEmpty==0)
        [self createTabbar];
    
    
    
}

-(void)createTabbar{
    
    UINavigationController *nc1;
    nc1 = [[UINavigationController alloc] init];
    [nc1.navigationBar setTintColor:[UIColor blackColor]];
    nc1.navigationBarHidden = YES;
    
    InboxVC *inbox=[[InboxVC alloc]initWithNibName:@"InboxVC" bundle:nil];
    nc1.viewControllers = [NSArray arrayWithObjects:inbox, nil];
    
    UINavigationController *nc2;
    nc2 = [[UINavigationController alloc] init];
    [nc2.navigationBar setTintColor:[UIColor blackColor]];
    nc2.navigationBarHidden = YES;
    
    Feeds *feed=[[Feeds alloc]initWithNibName:@"Feeds" bundle:nil];
    nc2.viewControllers = [NSArray arrayWithObjects:feed, nil];
    
    
    TaskVC *task=[[TaskVC alloc]initWithNibName:@"TaskVC" bundle:nil];
    UINavigationController *nc3;
    nc3 = [[UINavigationController alloc] init];
    [nc3.navigationBar setTintColor:[UIColor blackColor]];
    nc3.navigationBarHidden = YES;
    
    
    nc3.viewControllers = [NSArray arrayWithObjects:task, nil];
    
    
    
    SchedulerVC *schdule=[[SchedulerVC alloc]initWithNibName:@"SchedulerVC" bundle:nil];
    
    UINavigationController *nc4;
    nc4 = [[UINavigationController alloc] init];
    [nc4.navigationBar setTintColor:[UIColor blackColor]];
    nc4.navigationBarHidden = YES;
    
    
    nc4.viewControllers = [NSArray arrayWithObjects:schdule, nil];
    
    
    
    SearchVC *search=[[SearchVC alloc]initWithNibName:@"SearchVC" bundle:nil];
    UINavigationController *nc5;
    nc5 = [[UINavigationController alloc] init];
    [nc5.navigationBar setTintColor:[UIColor blackColor]];
    nc5.navigationBarHidden = YES;
    
    nc5.viewControllers = [NSArray arrayWithObjects:search, nil];
    
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:nc1, nc2,nc3,nc4,nc5 ,nil];
    
    
    //[[UITabBarItem appearance]setTitleTextAttribut forState:<#(UIControlState)#>
    
    
    
    
    //[[UITabBarItem appearance]
    // setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor],
    //                            UITextAttributeFont:[UIFont systemFontOfSize:12.0f]}
    //   forState:UIControlStateNormal];
    
    //set the tab bar title appearance for selected state
    
    
    
    
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    NSLog(@"Height==%f",height);
    
    //self.tabBarController.tabBar.frame = CGRectMake(0,height1-50, width1, 50);
    
   // UIImageView *v1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 55, 47)];
    //v1.image=[UIImage imageNamed:@"active_tab_bg@3x.png"];
    NSLog(@"%d",height1);
    if(height1<569){
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"SelectedFriendFooter2.png"]];
    }
    else if (height1<690){
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"SelectedFriendFooter1.png"]];
    }
    else{
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"SelectedFriendFooter.png"]];

    }
    //[[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"active_tab_bg@3x.png"]];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UITabBar appearance] setTintColor:[UIColor blueColor]];
    [[UITabBar appearance] setBarStyle:UIBlurEffectStyleLight];
    
    UIImage *selectedImage0     = [UIImage imageNamed:@"message_icon@3x.png"];
    
    UIImage *selectedImage1     = [UIImage imageNamed:@"feeds_icon@3x.png"];
    UIImage *selectedImage2     = [UIImage imageNamed:@"task_icon@3x.png"];
    UIImage *selectedImage3     = [UIImage imageNamed:@"scheduler_icon@3x.png"];
    UIImage *selectedImage4     = [UIImage imageNamed:@"search_icon@3x.png"];
    
    UITabBar     *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0  = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1  = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2  = [tabBar.items objectAtIndex:2];
    UITabBarItem *item3  = [tabBar.items objectAtIndex:3];
    UITabBarItem *item4  = [tabBar.items objectAtIndex:4];
    
    item0.image = selectedImage0;
    //inbosMsg
    item0.title=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"inbosMsg"];
    item1.image = selectedImage1;
    item1.title=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"feedsMsg"];
    item2.image = selectedImage2;
    item2.title=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"taskMsg"];
    item3.image = selectedImage3;
    item3.title=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"scheduleMsg"];
    item4.image = selectedImage4;
    item4.title=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"searchMsg"];
    
    
    
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:self.tabBarController];
    
    
    
    
}



//Logout from App
-(void)logoutButtonClicked{
    
    if (self.logoutSheet) {
        [self.logoutSheet showInView:self.view];
    }
    else{
        //logoutMsg
        self.logoutSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] destructiveButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"logoutMsg"] otherButtonTitles:nil, nil];
        [self.logoutSheet showInView:self.view];
    }
}

//Action Sheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Clicked Button index = %ld",(long)buttonIndex);
    
    // Perform LogoutAction
    if (buttonIndex==0) {
        NSLog(@"logout button Clicked");
        ViewController *viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        viewController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
        NSLog(@"Cancel Button Clicked");
    }
    
}


- (void)drawLine {
    
    CGMutablePathRef straightLinePath = CGPathCreateMutable();
    CGPathMoveToPoint(straightLinePath, NULL, 50, 50);
    CGPathAddLineToPoint(straightLinePath, NULL,40 , 60);
    CGPathAddLineToPoint(straightLinePath, NULL,50 , 70);
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = straightLinePath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    shapeLayer.lineWidth = 2.0f;
    shapeLayer.fillRule = kCAFillRuleNonZero;
    [self.view.layer addSublayer:shapeLayer];
}


- (void)drawLineright {
    
    CGMutablePathRef straightLinePath = CGPathCreateMutable();
    CGPathMoveToPoint(straightLinePath, NULL, 260, 50);
    CGPathAddLineToPoint(straightLinePath, NULL,270 , 60);
    CGPathAddLineToPoint(straightLinePath, NULL,260 , 70);
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = straightLinePath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    shapeLayer.lineWidth = 2.0f;
    shapeLayer.fillRule = kCAFillRuleNonZero;
    [self.view.layer addSublayer:shapeLayer];
}



@end
