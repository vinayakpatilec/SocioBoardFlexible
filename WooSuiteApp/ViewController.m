//
//  ViewController.m
//  WooSuiteApp
//
//  Created by Globussoft 1 on 4/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "ViewController.h"
//#import "TabBarView.h"
#import "InboxVC.h"
#import "SingletonClass.h"
#import "HelperClass.h"
#import "SBJson.h"
#import "GroupViewController.h"

#import "ASIFormDataRequest.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize login = _login;
@synthesize txtpwd = _txtpwd;
@synthesize txtemail = _txtemail;


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
// Do any additional setup after loading the view, typically from a nib.
    [self createUI];
      
    self.txtemail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtemail.autocorrectionType = UITextAutocorrectionTypeNo;
    self.txtpwd.delegate = self;
    self.txtpwd.secureTextEntry = YES;
    self.txtemail.delegate = self;
    
}

-(void)createUI{
    
    
   // NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
   // NSLog(@"%@",language);

    
    //http://sugartin.info/2012/03/14/standard-image-and-icon-sizes-for-ios-apps/
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    UIImageView *BackImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width,screenRect.size.height)];
    [BackImg setImage:[UIImage imageNamed:@"LoginScreen.png"]];
    [self.view addSubview:BackImg];
    
   

    UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(30*width1/320, 100*height1/480, 260*width1/320, 40*height1/480)];
   
    [logoTxt setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:logoTxt];
   
    
    UIImageView *pswdImg;
    UIImageView *usernameImg;
           usernameImg=[[UIImageView alloc]initWithFrame:CGRectMake(35*width1/320,180*height1/480,250*width1/320,32*height1/480)];
         pswdImg=[[UIImageView alloc]initWithFrame:CGRectMake(35*width1/320,218*height1/480,250*width1/320,32*height1/480)];
        _txtemail=[[UITextField alloc]initWithFrame:CGRectMake(40*width1/320,180*height1/480,240*width1/320,32*height1/480)];
        _txtpwd=[[UITextField alloc]initWithFrame:CGRectMake(40*width1/320,218*height1/480,240*width1/320,32*height1/480)];

        

       
    

   
    [usernameImg setImage:[UIImage imageNamed:@"text_fill.png"]];
    [self.view addSubview:usernameImg];
    [self.view addSubview:pswdImg];
    _txtemail.font=[UIFont systemFontOfSize:width1/20];
    _txtemail.layer.cornerRadius=5.0f;
    _txtemail.placeholder=@"Email";
    _txtemail.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_txtemail];
    
    
   
    [pswdImg setImage:[UIImage imageNamed:@"text_fill.png"]];
    _txtpwd.font=[UIFont systemFontOfSize:width1/20];
       _txtpwd.layer.cornerRadius=5.0f;
    _txtpwd.placeholder=@"Password";
    _txtpwd.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_txtpwd];
    
    
    
    _login=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            _login.frame=CGRectMake(35*width1/320, 285*height1/480,250*width1/320, 35*height1/480);
   
   
    _login.backgroundColor=[UIColor clearColor];
    _login.layer.cornerRadius=7.0f;
    [_login setBackgroundImage:[UIImage imageNamed:@"login_btn.png"] forState:UIControlStateNormal];
    [_login addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_login];
    
    
 //status label
    _status=[[UILabel alloc]initWithFrame:CGRectMake(width1/2-75,screenRect.size.height-75 ,150,30)];
    _status.backgroundColor=[UIColor redColor];
    _status.textColor=[UIColor whiteColor];
    _status.font=[UIFont systemFontOfSize:10.0f];
    _status.layer.borderColor=[UIColor blackColor].CGColor;
    _status.textAlignment=NSTextAlignmentCenter;
    _status.layer.borderWidth=3.0f;
    [self.view addSubview:_status];
    _status.hidden=YES;
    
    
 //label to indicate tagline
    UILabel *downLbl=[[UILabel alloc]initWithFrame:CGRectMake(5,screenRect.size.height-30,200,30)];
    downLbl.backgroundColor=[UIColor clearColor];
    downLbl.textColor=[UIColor whiteColor];
    downLbl.font=[UIFont systemFontOfSize:12.0f];
    downLbl.text=@"Free for personal use";
    [self.view addSubview:downLbl];
    
    
    
    UIButton *signUp=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    signUp.frame=CGRectMake(35*width1/320, 330*height1/480,250*width1/320, 35*height1/480);
    signUp.backgroundColor=[UIColor clearColor];
    signUp.clipsToBounds=YES;
    signUp.layer.cornerRadius=5*width1/320;
    [signUp setTitle:@"Sign up" forState:UIControlStateNormal];
    [signUp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    signUp.titleLabel.font=[UIFont systemFontOfSize:width1/18];
    [signUp addTarget:self action:@selector(SignUpMeth) forControlEvents:UIControlEventTouchUpInside];
    [signUp setBackgroundImage:[UIImage imageNamed:@"divider@2x.png"] forState:UIControlStateNormal];
    [self.view addSubview:signUp];
    
    LanguageSelect=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    LanguageSelect.frame=CGRectMake(150*width1/320, 20*height1/480,160*width1/320, 30*height1/480);
    LanguageSelect.backgroundColor=[UIColor clearColor];
    LanguageSelect.clipsToBounds=YES;
    LanguageSelect.layer.cornerRadius=5*width1/320;
   
    [LanguageSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    LanguageSelect.titleLabel.font=[UIFont systemFontOfSize:width1/18];
    LanguageSelect.titleLabel.textAlignment=NSTextAlignmentLeft;
    [LanguageSelect addTarget:self action:@selector(languageSelectAction) forControlEvents:UIControlEventTouchUpInside];
    [LanguageSelect setBackgroundImage:[UIImage imageNamed:@"divider.png"] forState:UIControlStateNormal];
    [self.view addSubview:LanguageSelect];
    UIImageView *dropDown=[[UIImageView alloc]initWithFrame:CGRectMake(130*width1/320, 8*height1/480, 20*width1/320, 15*width1/320)];
    dropDown.image=[UIImage imageNamed:@"drop_down_inbox@3x.png"];
    [LanguageSelect addSubview:dropDown];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *strLan = [userDefault objectForKey:@"language"];
    
   // if([strLan isEqualToString:@"English"])
       
    
        if([strLan isEqualToString:@"Italic"]){
             [LanguageSelect setTitle:@"Italiano" forState:UIControlStateNormal];
                }
           else{
                [LanguageSelect setTitle:@"English" forState:UIControlStateNormal];
                }

    
    
    
    UILabel *forgetPswLbl=[[UILabel alloc]initWithFrame:CGRectMake(35,350,200,30)];
    forgetPswLbl.backgroundColor=[UIColor clearColor];
    forgetPswLbl.textColor=[UIColor whiteColor];
    forgetPswLbl.font=[UIFont systemFontOfSize:12.0f];
    forgetPswLbl.text=@"Forgot your password?";
        

    
//get saved username and password
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedStr=[defaults objectForKey:@"user"];
    _saveData=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    
            _saveData.frame=CGRectMake(35*width1/320,258*height1/480,23*width1/320,20*height1/480);
   
       //_saveData.frame=CGRectMake(205,282,115,22);
    UILabel *saveText=[[UILabel alloc]initWithFrame:CGRectMake(62*width1/320, 260*height1/480, 100*width1/320, 20*height1/480)];
    saveText.text=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"rememberMsg"];
    saveText.font=[UIFont systemFontOfSize:width1/22];
    saveText.backgroundColor=[UIColor clearColor];
    saveText.textColor=[UIColor whiteColor];
    [self.view addSubview:saveText];
    
    if([savedStr isEqualToString:@"YES"]){
        imgType=YES;
        _txtemail.text=[defaults objectForKey:@"username"];
        _txtpwd.text=[defaults objectForKey:@"password"];
        [_saveData setBackgroundImage:[UIImage imageNamed:@"checkbox_clicked@3x.png"] forState:UIControlStateNormal];
    }
    else{
        imgType=NO;
        _txtemail.text=@"";
        _txtpwd.text=@"";
        [_saveData setBackgroundImage:[UIImage imageNamed:@"checkbox@3x.png"] forState:UIControlStateNormal];
    }
       [_saveData addTarget:self action:@selector(rememberMeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveData];
    
    self.txtpwd.secureTextEntry = YES;
    
}



-(void)selectPhoneLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language isEqualToString:@"en"]){
         [[NSUserDefaults standardUserDefaults]setObject:@"English" forKey:@"language"];
    }
    else if ([language isEqualToString:@"it"]){
        [[NSUserDefaults standardUserDefaults]setObject:@"Italic" forKey:@"language"];

    }
    else{
         [[NSUserDefaults standardUserDefaults]setObject:@"English" forKey:@"language"];
    }
    
    
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
#pragma mark rememberme button actoion

-(void)languageSelectAction{
    
    BgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, height1)];
    BgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
    BgView.hidden=NO;
    [self.view addSubview:BgView];
    
    UIView *languageView=[[UIView alloc]initWithFrame:CGRectMake(15*width1/320,180*height1/480, 290*width1/320,75*height1/480)];
    languageView.backgroundColor=[UIColor whiteColor];
    languageView.layer.borderWidth=1.5;
    languageView.layer.borderColor=[UIColor blackColor].CGColor;
    [BgView addSubview:languageView];
    
    
    
    UIButton *englisgSelect=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    englisgSelect.frame=CGRectMake(2*width1/320, 3*height1/480,286*width1/320, 35*height1/480);
    englisgSelect.backgroundColor=[UIColor clearColor];
    englisgSelect.clipsToBounds=YES;
    englisgSelect.layer.cornerRadius=5*width1/320;
    [englisgSelect setTitle:@"English" forState:UIControlStateNormal];
    [englisgSelect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    englisgSelect.titleLabel.font=[UIFont systemFontOfSize:width1/18];
    [englisgSelect addTarget:self action:@selector(selectEnglisgLan) forControlEvents:UIControlEventTouchUpInside];
    [englisgSelect setBackgroundImage:[UIImage imageNamed:@"divider.png"] forState:UIControlStateNormal];
    [languageView addSubview:englisgSelect];

    
    UIButton *italic=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    italic.frame=CGRectMake(2*width1/320, 39*height1/480,286*width1/320, 35*height1/480);
    italic.backgroundColor=[UIColor clearColor];
    italic.clipsToBounds=YES;
    italic.layer.cornerRadius=5*width1/320;
    [italic setTitle:@"Italiano" forState:UIControlStateNormal];
    [italic setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    italic.titleLabel.font=[UIFont systemFontOfSize:width1/18];
    [italic addTarget:self action:@selector(selectItalicLan) forControlEvents:UIControlEventTouchUpInside];
    [italic setBackgroundImage:[UIImage imageNamed:@"divider.png"] forState:UIControlStateNormal];
    [languageView addSubview:italic];

    
    
    
    
}


-(void)selectEnglisgLan{
    [[NSUserDefaults standardUserDefaults]setObject:@"English" forKey:@"language"];
    BgView.hidden=YES;
    [self createUI];
    
    
}
-(void)selectItalicLan{
    [[NSUserDefaults standardUserDefaults]setObject:@"Italic" forKey:@"language"];
    BgView.hidden=YES;
    [self createUI];
    
    
}



-(void)rememberMeAction{
    if(imgType==YES){
         [_saveData setBackgroundImage:[UIImage imageNamed:@"checkbox@3x.png"] forState:UIControlStateNormal];
        imgType=NO;
            }
    else{
        [_saveData setBackgroundImage:[UIImage imageNamed:@"checkbox_clicked@3x.png"] forState:UIControlStateNormal];
        imgType=YES;
        }
    
}



-(void)SignUpMeth{
    
    SignupPage *crtAcc=[[SignupPage alloc]initWithNibName:@"SignupPage" bundle:nil];
    crtAcc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self  presentViewController:crtAcc animated:YES completion:nil];
    
    
    
    
}




- (IBAction)loginAction:(id)sender {
    NSLog(@"%@",_txtpwd.text);
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	[self.view endEditing:YES];
	HUD.delegate = self;
    HUD.dimBackground=YES;
    // Set the hud to display with a color
    HUD.color = [UIColor colorWithRed:0.50 green:0.30 blue:0.60 alpha:0.60];
	HUD.labelText = @"Loading";
	//HUD.detailsLabelText = @"updating data";
	HUD.square = YES;
    HUD.alpha=0.7;
	[HUD show:YES];
    // Validate Email and password TextField
    if ((! [_txtemail.text isEqualToString:@""]) && (![_txtpwd.text isEqualToString:@""])) {
        
        //Prepare SOAP message Body data
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<Login xmlns=\"http://tempuri.org/\">\n"
                                 "<EmailId>%@</EmailId>\n"
                                 "<Password>%@</Password>\n"
                                 "</Login>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",[_txtemail text],[_txtpwd text]];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/User.asmx?op=Login",WebLink];
        NSURL *url = [NSURL URLWithString:urlString];
        
        // Creating a Request for Login authentication
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/Login" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Create URLConnection
        [NSURLConnection connectionWithRequest:req delegate:self];
        NSLog(@"%@",msglength);
        webdata = [[NSMutableData alloc]init];
    }
    else{
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops !" message:@"Please enter all field" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //enterFieldMsg
        _status.text=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"enterFieldMsg"];
        _status.hidden=NO;
        [HUD hide:YES];
        //[alert show];
    }
}



#pragma mark-

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [webdata appendData:data];
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //checkNW
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:nil message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"checkNW"] delegate:self cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
    [myAlert show];
    [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
    [HUD hide:YES];
    
}
//Fetched Login Response
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *xmlString = [[NSString alloc] initWithData:webdata encoding:NSUTF8StringEncoding];
    //Check Successfull Login
    if ([xmlString rangeOfString:@"Invalid user name or password"].location != NSNotFound) {
        [HUD hide:YES];
        _status.text=[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"invalidmsg"];
        _status.hidden=NO;
       
    }
    else{
        
        NSString *response=[HelperClass stripTags:xmlString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
        if (dict ==nil || dict == NULL) {
            [HUD hide:YES];
            NSLog(@"nil");
            //[[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
            _status.text=@"incorrect userid or password";
            _status.hidden=NO;
            return;
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if(imgType==YES){
            [defaults setObject:_txtemail.text forKey:@"username"];
            [defaults setObject:_txtpwd.text forKey:@"password"];
            [defaults setObject:@"YES" forKey:@"user"];
        }
        else
            [defaults setObject:@"NO" forKey:@"user"];

        
       
        NSLog(@"Login Dict =%@",dict);
        NSString *profileID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"Id"]];
        NSString *mainProfilePic=[NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileUrl"]];
        mainProfilePic=[mainProfilePic stringByReplacingOccurrencesOfString:@"C:/inetpub/socioboard.com/wwwroot"
                                                            withString:@"http://www.socioboard.com"];
        [SingletonClass sharedSingleton].mainProPic=mainProfilePic;
        [SingletonClass sharedSingleton].emailID = _txtemail.text;
        [SingletonClass sharedSingleton].password = _txtpwd.text;
        
        [SingletonClass sharedSingleton].profileID = profileID;
        NSString *username = [NSString stringWithFormat:@"%@",[dict objectForKey:@"UserName"]];
        [SingletonClass sharedSingleton].userName = username;
        NSString *expiryDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ExpiryDate"]];
        
        //Check Expiry Data for User
        NSInteger remainDay = [self compareDatewithExpiryDate:expiryDate];
        
        //--------------------------------------------
        //if account has expired display a alert otherwise gor to GroupViewController
        
        if (remainDay<=0) {
            [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
            [HUD hide:YES];
        }
        else{
                        
            
            GroupViewController *tabBarObj = [[GroupViewController alloc] initWithNibName:@"GroupViewController" bundle:nil];
            tabBarObj.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:tabBarObj animated:YES completion:nil];
        }
        
    }
}




//Compare currentdate with Expiry Date
-(NSInteger)compareDatewithExpiryDate:(NSString *)expiryDate{
    
    //expiryDate = @"/Date(1409127101000)";
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [_formatter setDateFormat:@"yyyy MM dd"];
    //=====================
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@"/" withString:@""];
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@"Date" withString:@""];
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@"(" withString:@""];
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    double creation_number = [expiryDate doubleValue];
    double unixTimeStamp = creation_number/1000;
    NSDate *to_date = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    NSLog(@"To_date = %@", to_date);
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"Current date = %@",currentDate);
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:currentDate toDate:to_date options:0];
    
    NSLog(@"Day count = %d",(int)components.day);
    [SingletonClass sharedSingleton].remainDays = components.day;
    //====================
    return components.day;
}

#pragma mark-
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( textField == self.txtemail ) {
        [textField resignFirstResponder];
    }
    if (textField == self.txtpwd) {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField: textField up: YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self animateTextField: textField up: NO];
}
- (void) animateTextField: (UITextField*) textField up: (BOOL) up{
    const int movementDistance = 25; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)viewDidUnload {
    [self setLogin:nil];
    [self setTxtemail:nil];
    [self setTxtpwd:nil];
    [super viewDidUnload];
}
-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
@end
