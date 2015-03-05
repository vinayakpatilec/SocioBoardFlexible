//
//  SearchDisplayViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "SearchDisplayViewController.h"
#import "CustomSearchCell.h"
#import "FHSTwitterEngine.h"
#import "SingletonClass.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "TweetAccountCell.h"
#import "NewTaskViewController.h"
#import "RePostViewController.h"

@interface SearchDisplayViewController () <MBProgressHUDDelegate>
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SearchDisplayViewController

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
    // Do any additional setup after loading the view from its nib.
    
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    //bgImageView.frame = self.view.bounds;
    bgImageView.frame=CGRectMake(0, 0, width1, height1);
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];

    //Creating UI
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 50*height1/480)];
   self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
    
    [self.view addSubview:self.headerView];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    //[self.headerView.layer insertSublayer:gradient atIndex:0];
    
        
    
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(5*width1/320,15*height1/480,35*height1/480, 30*height1/480);
    //[self.cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
   // self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:width1/16];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    //self.cancelButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
    //self.cancelButton.layer.borderWidth=1.0f;
    //self.cancelButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    //self.cancelButton.layer.cornerRadius = 5.0f;
    //self.cancelButton.clipsToBounds = YES;
    
    //[self.cancelButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.cancelButton];

    //---------------------------------
    
   // if(_typeOfSearch==0)
    //[NSThread detachNewThreadSelector:@selector(firstCallMethod) toTarget:self withObject:nil];
    if (_typeOfSearch==1)
        [NSThread detachNewThreadSelector:@selector(facebookPost) toTarget:self withObject:nil];
    else if (_typeOfSearch==2)
        [NSThread detachNewThreadSelector:@selector(facebookContact) toTarget:self withObject:nil];
    else if (_typeOfSearch==3)
        [NSThread detachNewThreadSelector:@selector(twitterContact) toTarget:self withObject:nil];
    else if(_typeOfSearch==0){
        [NSThread detachNewThreadSelector:@selector(TwitterPost) toTarget:self withObject:nil];
    }
}
//First call method for perform search operation
-(void)firstCallMethod{
     [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    NSArray *twitterArray = [SingletonClass sharedSingleton].connectedTwitterAccount ;
    NSDictionary *dataDict = [twitterArray objectAtIndex:0];
    
    [self getTwitterUserDeatails:dataDict addFavorite:@"0"];
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
-(void) cancelButtonClickedAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -


//fetch facebook contacts
-(void)facebookContact{
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    @try {
        
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<contactSearchFacebook xmlns=\"http://tempuri.org/\">\n"
                                 "<keyword>%@</keyword>\n"
                                 "</contactSearchFacebook>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",_searchedString];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/DiscoverySearch.asmx?op=contactSearchFacebook",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/contactSearchFacebook" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse   * response;
        NSError *error = nil;
        NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"Error try Again");
            [self.hud hide:YES];

        }
        else{
            NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
            NSLog(@"respo==%@",responseString);
            NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
            if (response.length<1) {
                //                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something Went Wrong" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                [self.hud hide:YES];
                
                [self noResult];
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSLog(@"respo==%@",jsonArray);
            if(jsonArray.count==0){
                [self.hud hide:YES];
                
                [self noResult];
            }
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
           
            _facebookContacts=[[NSMutableArray alloc]initWithArray:tempArray];
            self.allTweetTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 50*height1/480, width1-10,self.view.frame.size.height-60) style:UITableViewStylePlain];
            self.allTweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.allTweetTableView.delegate = self;
            self.allTweetTableView.backgroundColor=[UIColor clearColor];
            
            self.allTweetTableView.dataSource = self;
            self.allTweetTableView.scrollEnabled=YES;
            [self.view addSubview:self.allTweetTableView];
            currentSelection = -1;

                    }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
           }
    @finally {
            NSLog(@"Finally Block");
    }
    
    return ;
}





-(void)twitterContact{
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    @try {
        
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<contactSearchTwitter xmlns=\"http://tempuri.org/\">\n"
                                 "<keyword>%@</keyword>\n"
                                 "</contactSearchTwitter>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",_searchedString];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/DiscoverySearch.asmx?op=contactSearchTwitter",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/contactSearchTwitter" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse   * response;
        NSError *error = nil;
        NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"Error try Again");
            [self.hud hide:YES];

            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"reqTimedOut"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
          
        }
        else{
            NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
            NSLog(@"respo==%@",responseString);
            NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
            if (response.length<1) {
                 [self.hud hide:YES];
                    [self noResult];
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSLog(@"respo==%@",jsonArray);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            if(jsonArray.count==0){
                [self.hud hide:YES];
                
                [self noResult];
            }
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                [tempDict setObject:@"Twitter_Feed" forKey:SocialAccountType];
                [tempArray addObject:tempDict];
            }
            NSLog(@"%@",tempArray);
            _twitterContacts=[[NSMutableArray alloc]initWithArray:tempArray];
            self.allTweetTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 50*height1/480, width1-10,height1-60) style:UITableViewStylePlain];
            self.allTweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.allTweetTableView.delegate = self;
            self.allTweetTableView.dataSource = self;
            self.allTweetTableView.scrollEnabled=YES;
            self.allTweetTableView.backgroundColor=[UIColor clearColor];

            [self.view addSubview:self.allTweetTableView];
            currentSelection = -1;
            [self.hud hide:YES];
            
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
    }
    @finally {
        NSLog(@"Finally Block");
    }
    
    return ;
}



-(void)facebookPost{
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    @try {
        NSString *userID=[SingletonClass sharedSingleton].profileID;
        
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<DiscoverySearchFacebook xmlns=\"http://tempuri.org/\">\n"
                                  "<UserId>%@</UserId>\n"
                                 "<keyword>%@</keyword>\n"
                                 "</DiscoverySearchFacebook>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",userID,_searchedString];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/DiscoverySearch.asmx?op=DiscoverySearchFacebook",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/DiscoverySearchFacebook" forHTTPHeaderField:@"SOAPAction"];
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
                [self.hud hide:YES];

                [self noResult];
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSLog(@"respo==%@",jsonArray);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            if(jsonArray.count==0){
                [self.hud hide:YES];
                
                [self noResult];
            }
            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                
                [tempArray addObject:tempDict];
            }
            NSLog(@"Twitter Feed = %@",tempArray);
            _facebookPosts=[[NSMutableArray alloc]initWithArray:tempArray];
            self.allTweetTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 50*height1/480, width1-10,height1-60) style:UITableViewStylePlain];
            self.allTweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.allTweetTableView.delegate = self;
            self.allTweetTableView.dataSource = self;
            self.allTweetTableView.scrollEnabled=YES;
            self.allTweetTableView.backgroundColor=[UIColor clearColor];

            [self.view addSubview:self.allTweetTableView];
            currentSelection = -1;
            
            
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
    }
    @finally {
        NSLog(@"Finally Block");
    }
    
    return ;
}







-(void)TwitterPost{
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    @try {
        NSString *userID=[SingletonClass sharedSingleton].profileID;
        
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<DiscoverySearchTwitter xmlns=\"http://tempuri.org/\">\n"
                                 "<UserId>%@</UserId>\n"
                                 "<keyword>%@</keyword>\n"
                                 "</DiscoverySearchTwitter>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",userID,_searchedString];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *str= [NSString stringWithFormat:@"%@/Services/DiscoverySearch.asmx?op=DiscoverySearchTwitter",WebLink];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/DiscoverySearchTwitter" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSHTTPURLResponse   * response;
        NSError *error = nil;
        NSData *resonseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        if (error) {
            NSLog(@"Error try Again");
            [self.hud hide:YES];

        }
        else{
            NSString *responseString = [[NSString alloc]initWithData:resonseData encoding:NSUTF8StringEncoding];
            NSLog(@"respo==%@",responseString);
            NSString *response = [HelperClass stripTags:responseString startString:@"[" upToString:@"}]"];
            if (response.length<1) {
                [self.hud hide:YES];
 
               [self noResult];
            }
            NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
            NSMutableArray *jsonArray = [jsonString JSONValue];
            NSLog(@"respo==%@",jsonArray);
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            if(jsonArray.count==0){
                [self.hud hide:YES];
                [self noResult];
            }

            for (int i=0; i<jsonArray.count; i++) {
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
                tempDict =[jsonArray objectAtIndex:i];
                
                [tempArray addObject:tempDict];
            }
            NSLog(@"Twitter Feed = %@",tempArray);
            _twitterPosts=[[NSMutableArray alloc]initWithArray:tempArray];
            self.allTweetTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,50*height1/480, width1-10,height1-60) style:UITableViewStylePlain];
            self.allTweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.allTweetTableView.delegate = self;
            self.allTweetTableView.dataSource = self;
            self.allTweetTableView.backgroundColor=[UIColor clearColor];

            self.allTweetTableView.scrollEnabled=YES;
            [self.view addSubview:self.allTweetTableView];
            currentSelection = -1;
            
            
        }
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
    }
    @finally {
        NSLog(@"Finally Block");
    }
    
    return ;
}







//Fetch twitter user account details
-(void) getTwitterUserDeatails:(NSDictionary *)dataDict addFavorite:(NSString *)addFavorite{
    
   
    NSString *keyword = self.searchedString;
    NSString *proID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Twitter-=-= %@",proID);
    //Preapre Soap message for fetching user details
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
        [self.hud hide:YES];
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"Rersponse String = %@", responseString);
        
        NSString *response = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
        /*------------------------------
        //Check request type
         if addfavorite Value is 1 add to favorite or perform search operation
         ------------------------------*/
        /*if ([addFavorite isEqualToString:@"1"]) {
            
            //set Twitter Consumer key and Secret Key
            [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TwitterConsumerKey  andSecret:TwitterSecretKey];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSError *returnCode = nil;
            NSDictionary *dictA = [self.allTweetArray objectAtIndex:currentSelection];
            
            NSString *mesId = [[NSString alloc] initWithFormat:@"%@",[dictA objectForKey:@"messageid"]];
           
            //Perform Favorite Operation
            returnCode = [[FHSTwitterEngine sharedEngine]markTweet:mesId asFavorite:YES aouthTokenDictionary:dict];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.hud hide:YES];
            
            if (!returnCode) {
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Success" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
            else{
                NSLog(@"Error to Pos Twitter==%ld",(long)returnCode.code );
                if (returnCode.code == 139) {
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:@"You have already favorited this status." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                else if (returnCode.code == 89){
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid or expired token." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                else if (returnCode.code==32){
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:@"Could not authenticate you" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                else{
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }
                
            }
        }
        else{*/
        if(_typeOfSearch==0)
            [self searchOnTwitter:dict enteredKey:keyword];
        else{
            [self searchContactTwitter:dict enteredKey:keyword];
        }
        
        
        
    }
}

//perform Search Operation
-(void) searchOnTwitter:(NSDictionary *)dict enteredKey:(NSString *)keyword{
    
    @try {
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TwitterConsumerKey  andSecret:TwitterSecretKey];
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TwitterConsumerKey andSecret:TwitterSecretKey];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        //Send message with Keywork to search Tweet and get all resultant tweet
        NSString *response = [[FHSTwitterEngine sharedEngine] newTweitterFeedSearch:keyword withCount:100 aouthTokenDictionary:dict];
        //NSString *r1=[[FHSTwitterEngine sharedEngine] searchUsersWithQuery:<#(NSString *)#> andCount:<#(int)#> aouthTokenDictionary:<#(NSDictionary *)#>]
        
        NSDictionary *newDict = nil;
        if ([response isEqualToString:@"error"]) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.hud hide: YES];
            
            [[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"operationCouldntCompleted"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
            return;
        }
        else{
            newDict = [response JSONValue];
        }
        
        NSArray *tempArray = [newDict objectForKey:@"statuses"];
        
        
        
        self.allTweetArray = [[NSMutableArray alloc]init];
        
        for (NSDictionary *item in tempArray) {
            
            NSDictionary *secDict =[item objectForKey:@"user"];
            
            //Parse require Value from resultant Value
            NSDictionary *adict = [NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"text"],@"Feed",[secDict objectForKey:@"name"],@"ScreenName",[secDict objectForKey:@"screen_name"],@"screen_name",[secDict objectForKey:@"profile_image_url_https"],@"FromProfileUrl",[secDict objectForKey:@"id"],@"messageid",@"Twitter_Feed",SocialAccountType, nil];
            NSLog(@"Create at = %@",[item objectForKey:@"created_at"]);
            NSLog(@"Dict==%@",adict);
            [self.allTweetArray addObject:adict];
        }
        //display All tweet on table View
        self.allTweetTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 60, width1-10,height1-60) style:UITableViewStylePlain];
        self.allTweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allTweetTableView.delegate = self;
        self.allTweetTableView.dataSource = self;
        self.allTweetTableView.scrollEnabled=YES;
        [self.view addSubview:self.allTweetTableView];
        currentSelection = -1;
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
//        NSString *exc = [NSString stringWithFormat:@"%@",exception];
//        NSLog(@"exc==%@",exc);
    }
    @finally {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.hud hide:YES];
         NSLog(@"Finally Block");
    }
    
    
    
    
    
    
}





-(void) searchContactTwitter:(NSDictionary *)dict enteredKey:(NSString *)keyword{
    
    @try {
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TwitterConsumerKey  andSecret:TwitterSecretKey];
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TwitterConsumerKey andSecret:TwitterSecretKey];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        //Send message with Keywork to search Tweet and get all resultant tweet
        //NSString *response = [[FHSTwitterEngine sharedEngine] newTweitterFeedSearch:keyword withCount:100 aouthTokenDictionary:dict];
        NSLog(@"%@",keyword);
        NSString *response=(NSString*)[[FHSTwitterEngine sharedEngine] searchUsersWithQuery:keyword andCount:10 aouthTokenDictionary:dict];
        
        NSDictionary *newDict = nil;
       // if (![response isEqualToString:@"error"]) {
            //
                   // }
       // else{
        NSLog(@"%@",response);
        // NSString *response1 = [HelperClass stripTags:response startString:@"[" upToString:@"}]"];
        
        NSString *jsonString = [NSString stringWithFormat:@"%@}]",response];
        NSMutableArray *jsonArray = [jsonString JSONValue];
        NSLog(@"respo==%@",jsonArray);
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if(jsonArray.count==0){
            [self.hud hide:YES];
            [self noResult];
        }

        for (int i=0; i<jsonArray.count; i++) {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
            tempDict =[jsonArray objectAtIndex:i];
            
            [tempArray addObject:tempDict];
        }
        NSLog(@"Twitter Feed = %@",tempArray);
        _twitterContacts=[[NSMutableArray alloc]initWithArray:tempArray];
        self.allTweetTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 60, width1-10,height1-60) style:UITableViewStylePlain];
        self.allTweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allTweetTableView.delegate = self;
        self.allTweetTableView.dataSource = self;
        self.allTweetTableView.scrollEnabled=YES;
        [self.view addSubview:self.allTweetTableView];
        currentSelection = -1;

       
        
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.hud hide: YES];
            
            //[[[UIAlertView alloc] initWithTitle:@"Error" message:@"The operation couldn’t be completed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            //return;

        
        
       // NSArray *tempArray = [newDict objectForKey:@"statuses"];
        
        
        
        self.allTweetArray = [[NSMutableArray alloc]init];
        
        for (NSDictionary *item in tempArray) {
            
            NSDictionary *secDict =[item objectForKey:@"user"];
            
            //Parse require Value from resultant Value
            NSDictionary *adict = [NSDictionary dictionaryWithObjectsAndKeys:[item objectForKey:@"text"],@"Feed",[secDict objectForKey:@"name"],@"ScreenName",[secDict objectForKey:@"screen_name"],@"screen_name",[secDict objectForKey:@"profile_image_url_https"],@"FromProfileUrl",[secDict objectForKey:@"id"],@"messageid",@"Twitter_Feed",SocialAccountType, nil];
            NSLog(@"Create at = %@",[item objectForKey:@"created_at"]);
            NSLog(@"Dict==%@",adict);
            [self.allTweetArray addObject:adict];
        }
        //display All tweet on table View
        self.allTweetTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 60, width1-10,height1-60) style:UITableViewStylePlain];
        self.allTweetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allTweetTableView.delegate = self;
        self.allTweetTableView.dataSource = self;
        self.allTweetTableView.scrollEnabled=YES;
        [self.view addSubview:self.allTweetTableView];
        currentSelection = -1;
    }
    @catch (NSException *exception) {
        [self.hud hide:YES];
        //        NSString *exc = [NSString stringWithFormat:@"%@",exception];
        //        NSLog(@"exc==%@",exc);
    }
    @finally {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.hud hide:YES];
        NSLog(@"Finally Block");
    }
}


-(void)noResult{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"noresultMsg"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
    [alertView show];
    [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
    [self cancelButtonClickedAction:nil];
   
}

-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark -
#pragma TableView Delegate and Datasource

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.tweeterAccountTableView) {
        return 55;
    }
    if(_typeOfSearch==5){
    NSDictionary *adict = [self.allTweetArray objectAtIndex:indexPath.row];
    NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Feed"]];
        CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/18]];

  
        return textHeight+60;
    
    }
    else if (_typeOfSearch==1){
        NSDictionary *adict = [self.facebookPosts objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
        CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
        
        return textHeight+80;

    }
    else if (_typeOfSearch==2){
        NSDictionary *adict = [self.facebookContacts objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
       CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
        return textHeight+80;
        
    }
    else if (_typeOfSearch==3){
        NSDictionary *adict = [self.twitterContacts objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
       CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
        return textHeight+70;
        
    }
    else if (_typeOfSearch==0){
        NSDictionary *adict = [self.twitterPosts objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
        CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
        return textHeight+70;
        
    }

    
    return 0;
    
}
    



-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView==self.tweeterAccountTableView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width1-20, 45)];
        UIImageView *backView = [[UIImageView alloc] initWithFrame:headerView.frame];
        backView.image = [UIImage imageNamed:@"320_strip.png"];
        [headerView insertSubview:backView atIndex:0];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"twticon.png"];
        [headerView addSubview:imageView];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 2, 200, 30)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.font = [UIFont boldSystemFontOfSize:15];
        lbl.text = @"Favorite Via";
        [headerView addSubview:lbl];
        return headerView;
    }
    return nil;
}
-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (tableView==self.tweeterAccountTableView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width1-20, 60)];
        UIImageView *img = [[UIImageView alloc] initWithFrame:footerView.frame];
        img.image = [UIImage imageNamed:@"320_strip.png"];
        [footerView insertSubview:img atIndex:0];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(90, 10, 120, 45);
        [btn setBackgroundImage:[UIImage imageNamed:@"favorite_btn.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btn];
        return footerView;
    }
    return nil;
}
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView==self.tweeterAccountTableView) {
        return 0;
    }
    return 0;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView==self.tweeterAccountTableView) {
        return 0;
    }
    return 0;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [self.hud hide:YES];
    if (tableView==self.tweeterAccountTableView) {
        return self.twitterAccountArray.count;
    }
    if(_typeOfSearch==5)
        return  self.allTweetArray.count;

    else if(_typeOfSearch==1)
        return _facebookPosts.count;
    else if(_typeOfSearch==2)
        return _facebookContacts.count;
    else if(_typeOfSearch==3)
        return _twitterContacts.count;
    else if(_typeOfSearch==0)
        return _twitterPosts.count;
    else
        return 0;
    }
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    
    if (tableView==self.tweeterAccountTableView) {
        TweetAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil) {
            cell = [[TweetAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
//
        cell.backView.image = [UIImage imageNamed:@"unselect.png"];
        NSDictionary *dict = [self.twitterAccountArray objectAtIndex:indexPath.row];
       // cell.profilePic.frame=CGRectMake(2, 5, 50*width1/320, 50*height1/480);
        NSString *imageUrl = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfilePicUrl"]];
        NSString *nameString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]];
        [cell.profilePic setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Placeholder.png"]];
        cell.nameLable.textColor = [UIColor blackColor];
        cell.nameLable.text = nameString;
        cell.nameLable.font=[UIFont boldSystemFontOfSize:width1/18];
        return cell;
    }
    CustomSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        
        cell = [[CustomSearchCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.messageLable.font = [UIFont fontWithName:@"Arial" size:width1/20];
        
        cell.messageLable.numberOfLines=0;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
// cell.profileImageView.frame=CGRectMake(2, 5, 50*width1/320, 50*height1/480);
    if(_typeOfSearch==5){
    
    
    NSDictionary *adict = [self.allTweetArray objectAtIndex:indexPath.row];
    NSString *proImageUrl = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromProfileUrl"]];
    [cell.profileImageView setImageWithURL:[NSURL URLWithString:proImageUrl]];
    NSString *name = [NSString stringWithFormat:@"%@",[adict objectForKey:@"ScreenName"]];
    cell.nameLable.text = name;
    
    NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Feed"]];
    
     CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];
    cell.messageLable.frame = CGRectMake(55, 40, width1-(80*width1/320), textHeight);
    cell.messageLable.text = message;
    }
    
    else if (_typeOfSearch==1){
        NSDictionary *adict = [self.facebookPosts objectAtIndex:indexPath.row];
        NSString *proImageUrl = [NSString stringWithFormat:@"%@",[adict objectForKey:@"ProfileImageUrl"]];
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:proImageUrl]];
        NSString *name = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromName"]];
        cell.nameLable.text = name;
        NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
        message=[message stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
        
        CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];

        cell.messageLable.frame = CGRectMake(62*width1/320, 40, 240*width1/320, textHeight);
        cell.messageLable.text = message;

        
        
    }
    
    
    else if (_typeOfSearch==2){
        NSDictionary *adict = [self.facebookContacts objectAtIndex:indexPath.row];
        NSString *fbID = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromId"]];
        NSString *proImageUrl=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small",fbID];
        
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:proImageUrl]];
        NSString *name = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromName"]];
        cell.nameLable.text = name;
         NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
        message=[message stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
        
        CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];

        cell.messageLable.frame = CGRectMake(62*width1/320, 40, 240*width1/320, textHeight);
        cell.messageLable.text = message;
        


        
    }
    
    else if (_typeOfSearch==3){
        NSDictionary *adict = [self.twitterContacts objectAtIndex:indexPath.row];
        NSString *TwitterID = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromName"]];
        NSString *proImageUrl=[NSString stringWithFormat:@"http://res.cloudinary.com/demo/image/twitter_name/w_100/%@.jpg",TwitterID];
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:proImageUrl]];
        NSString *name = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromName"]];
        cell.nameLable.text = name;
        NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
        message=[message stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
        
        CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];

        cell.messageLable.frame = CGRectMake(62*width1/320, 40, 240*width1/320, textHeight);
        cell.messageLable.text = message;
        
        
        
        
    }
    else if (_typeOfSearch==0){
        NSDictionary *adict = [self.twitterPosts objectAtIndex:indexPath.row];
        NSString *proImageUrl = [NSString stringWithFormat:@"%@",[adict objectForKey:@"ProfileImageUrl"]];
        [cell.profileImageView setImageWithURL:[NSURL URLWithString:proImageUrl]];
        NSString *name = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromName"]];
        cell.nameLable.text = name;
        NSString *message = [NSString stringWithFormat:@"%@",[adict objectForKey:@"Message"]];
        message=[message stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
        
        CGFloat textHeight=[[SingletonClass sharedSingleton] findHeightForText:message havingWidth:240*width1/320 andFont:[UIFont fontWithName:@"Arial" size:width1/20]];

        cell.messageLable.frame = CGRectMake(62*width1/320, 40, 240*width1/320, textHeight);
        cell.messageLable.text = message;
        
        
        
        
    }


    
    UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(0,0, width1-10,4*height1/480)];
    devider.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
    

    [cell addSubview:devider];

    
       return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    
    if(_typeOfSearch==2){
        NSDictionary *adict = [self.facebookContacts objectAtIndex:indexPath.row];
        NSString *fbID = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromId"]];
        WebView1 *webBrowser=[[WebView1 alloc]initWithNibName:@"WebView1" bundle:nil];
        NSString *profileURL=[NSString stringWithFormat:@"https://www.facebook.com/profile.php?id=%@",fbID];
        webBrowser.url=profileURL;
               [self presentViewController:webBrowser animated:YES completion:nil];
       
        //https://www.facebook.com/profile.php?id=%@
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:profileURL]];
    }
    else if (_typeOfSearch==3){
        NSDictionary *adict = [self.twitterContacts objectAtIndex:indexPath.row];
        NSString *twitterID = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromId"]];
        WebView1 *webBrowser=[[WebView1 alloc]initWithNibName:@"WebView1" bundle:nil];
         NSString *profileURL=[NSString stringWithFormat:@"https://twitter.com/%@",twitterID];
         webBrowser.url=profileURL;
        [self presentViewController:webBrowser animated:YES completion:nil];
       
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:profileURL]];
    }
    
    else if (_typeOfSearch==0){
        NSDictionary *adict = [self.twitterPosts objectAtIndex:indexPath.row];
        NSString *twitterID = [NSString stringWithFormat:@"%@",[adict objectForKey:@"FromName"]];
        WebView1 *webBrowser=[[WebView1 alloc]initWithNibName:@"WebView1" bundle:nil];
        NSString *profileURL=[NSString stringWithFormat:@"https://twitter.com/%@",twitterID];
        webBrowser.url=profileURL;
        [self presentViewController:webBrowser animated:YES completion:nil];
        
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:profileURL]];
    }

    
    /*
     https://twitter.com/NarendraModiMth
    if (tableView==self.tweeterAccountTableView) {
        selectedTwitterAccountRow = indexPath.row;
        [tableView reloadData];
        return;
    }
    
    if (currentSelection == indexPath.row) {
        return;
    }
    int row = indexPath.row;
    currentSelection = row;
    
    CustomSearchCell *cell = (CustomSearchCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [tableView beginUpdates];
    cell.menuView.frame = CGRectMake(0, cell.contentView.bounds.size.height, 320, 48);
    menuViewFrame = cell.menuView.frame;
    cell.menuView.hidden=NO;
    [cell.moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.taskButton addTarget:self action:@selector(taskButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.replyButton addTarget:self action:@selector(replayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [tableView endUpdates];
    [tableView reloadData];
     */
}
#pragma mark -
//Display Activity Indicator
-(void) displayActivityIndicator{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.dimBackground=YES;
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}
-(void) hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}
@end


/*
#pragma mark =
-(void)moreButtonClicked:(id)sender{
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Your account has been expired. Please visit to http://socioboard.com and renew your account." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    NSLog(@"More Button Action");
    if (!self.actionSheet) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Favorite",@"Email", nil];
        self.actionSheet.tag = 1;
        self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    }
    
    [self.tweeterAccountTableView reloadData];
    //[self.actionSheet showFromTabBar:self.tabBarController.tabBar];
    [self.actionSheet showInView:self.view];
}
-(void) taskButtonAction:(id)sender{
    NSLog(@"Task Button Action");
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Your account has been expired. Please visit to http://socioboard.com and renew your account." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    
    NSMutableDictionary *dict = [self.allTweetArray objectAtIndex:currentSelection];
    
    NewTaskViewController *newTask = [[NewTaskViewController alloc] initWithNibName:@"NewTaskViewController" bundle:nil];
    newTask.dataDict = dict;
    [self presentViewController:newTask animated:YES completion:nil];
}
-(void) replayButtonAction:(id)sender{
    NSLog(@"Replay Button Action");
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Your account has been expired. Please visit to http://socioboard.com and renew your account." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    NSDictionary *dict = [self.allTweetArray objectAtIndex:currentSelection];
    NSLog(@"Dict==%@",dict);
    
    TwitterReplyViewController *repost = [[TwitterReplyViewController alloc] initWithNibName:@"TwitterReplyViewController" bundle:nil];
    repost.messageIDString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"messageid"]];
    //NSString *profileImageString=nil;
//    profileImageString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"FromProfileUrl"]];
//    repost.accountType = @"Twitter_Feed";
//    repost.profileName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ScreenName"]];
//    repost.message = [NSString stringWithFormat:@"@%@",[dict objectForKey:@"ScreenName"]];
//    repost.profileImage = profileImageString;
    [self presentViewController:repost animated:YES completion:nil];
}
#pragma mark -
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag==1) {
        
        if (buttonIndex==0) {
            NSLog(@"Display Tweeter Account");
            [self displayAllTwitterAccount];
        }
        else if(buttonIndex==1){
            NSLog(@"Open Mail Composer");
            [self openMailComposer];
        }
        else{
            NSLog(@"Hide Action sheet");
        }
        
    }
}

#pragma mark -
#pragma mark Open mail Composer
-(void)openMailComposer{
    if([MFMailComposeViewController canSendMail]){
        NSLog(@"Send Mail");
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSDictionary *dict = [self.allTweetArray objectAtIndex:currentSelection];
        
        NSString *emailBody = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Feed"]];
        [mailer setSubject:@"A Message from SOCIOBOARD"];
        // NSString *emailBody = @"Have you seen the MobileTuts+ web site?";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Can't send mail" message:@"Please configure mail account first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    }
}
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
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
    }
}

#pragma mark -
-(void) displayAllTwitterAccount{
    if (!self.secondView) {
        self.secondView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 310, self.view.frame.size.height)];
        [self.view addSubview:self.secondView];
        UIView *sec_header = [[UIView alloc] initWithFrame:self.headerView.frame];
        sec_header.backgroundColor = [UIColor whiteColor];
        [self.secondView addSubview:sec_header];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.headerView.bounds;
        UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
        UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
        
        gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
        [sec_header.layer insertSublayer:gradient atIndex:0];
        
        self.can_two_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.can_two_btn.frame = CGRectMake(0, 10, 50, 27);
        [self.can_two_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.can_two_btn.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
        
        self.can_two_btn.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
        self.can_two_btn.layer.borderWidth=1.0f;
        self.can_two_btn.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
        self.can_two_btn.layer.cornerRadius = 5.0f;
        self.can_two_btn.clipsToBounds = YES;
        [self.can_two_btn addTarget:self action:@selector(hidesecondView:) forControlEvents:UIControlEventTouchUpInside];
        [self.can_two_btn setTitle:@"Cancel" forState:UIControlStateNormal];
        [sec_header addSubview:self.can_two_btn];
        //---------------------------------

        self.favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favoriteButton.frame = CGRectMake(240, 10, 60, 27);
        [self.favoriteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.favoriteButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
        
        self.favoriteButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
        self.favoriteButton.layer.borderWidth=1.0f;
        self.favoriteButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
        self.favoriteButton.layer.cornerRadius = 5.0f;
        self.favoriteButton.clipsToBounds = YES;
        [self.favoriteButton addTarget:self action:@selector(favoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.favoriteButton setTitle:@"Favorite" forState:UIControlStateNormal];
        [sec_header addSubview:self.favoriteButton];
        //---------------------------------
        
        self.twitterAccountArray = [SingletonClass sharedSingleton].connectedTwitterAccount;
        self.tweeterAccountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, sec_header.frame.size.height, 310, self.secondView.frame.size.height) style:UITableViewStylePlain];
        self.tweeterAccountTableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
        [self.secondView addSubview:self.tweeterAccountTableView];
        
        CAGradientLayer *gradient2 = [CAGradientLayer layer];
        gradient2.frame = CGRectMake(0, sec_header.frame.size.height, 310, self.view.frame.size.height);
        UIColor *lastColor2 =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1.0];
        gradient2.colors = [NSArray arrayWithObjects:(id)[lastColor2 CGColor], (id)[firstColor CGColor],(id)[lastColor2 CGColor], nil];
        //[self.tweeterAccountTableView.layer insertSublayer:gradient atIndex:0];
       // [self.tweeterAccountTableView.layer insertSublayer:gradient2 atIndex:-1];
        [self.secondView.layer insertSublayer:gradient2 atIndex:0];
        self.tweeterAccountTableView.opaque=NO;
        self.tweeterAccountTableView.backgroundColor=[UIColor clearColor];
        self.tweeterAccountTableView.backgroundView=nil;

        selectedTwitterAccountRow = -1;
        self.tweeterAccountTableView.delegate = self;
        self.tweeterAccountTableView.dataSource = self;
    }
    else{
        selectedTwitterAccountRow = -1;
        [self.tweeterAccountTableView reloadData];
    }

    [UIView animateWithDuration:.40 animations:^{
        self.secondView.frame = CGRectMake(10, 0, 310, self.view.frame.size.height);
    }];
}

-(void) hidesecondView:(id)sender{
    [UIView animateWithDuration:.40 animations:^{
        self.secondView.frame = CGRectMake(self.view.frame.size.width, 0, 310, self.view.frame.size.height);
    }];
}

-(void) favoriteButtonAction:(id)sender{
    if (selectedTwitterAccountRow == -1) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select account first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    [UIView animateWithDuration:.40 animations:^{
        self.secondView.frame = CGRectMake(self.view.frame.size.width, 0, 310, self.view.frame.size.height);
    }];
    [self performSelector:@selector(addtoFavorite) withObject:nil afterDelay:.20];
}
-(void) addtoFavorite{
    NSLog(@"Favorite Button Clicked");
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    NSDictionary *dict = [self.twitterAccountArray objectAtIndex:selectedTwitterAccountRow];
        [self getTwitterUserDeatails:dict addFavorite:@"1"];
        //NSLog(@"Selected Twitter Account = %@",dict);
    
}*/

