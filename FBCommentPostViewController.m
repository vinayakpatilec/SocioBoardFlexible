//
//  FBCommentPostViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 22/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "FBCommentPostViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "SingletonClass.h"
#import "HelperClass.h"

#import "MBProgressHUD.h"
@interface FBCommentPostViewController ()<MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;
@end

@implementation FBCommentPostViewController

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

    self.view.backgroundColor=[UIColor whiteColor];
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 50*height1/480)];
     self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];    [self.view addSubview:self.headerView];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)111/255 blue:(CGFloat)5/255 alpha:1.0];
    UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)211/255 blue:(CGFloat)150/255 alpha:1.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    gradient.startPoint=CGPointMake(0.2, 0);
    gradient.endPoint=CGPointMake(0.8, 0);
    //[self.headerView.layer insertSublayer:gradient atIndex:0];
   
    //-------------------------------------------------
    
    
    self.titlelable = [[UILabel alloc] initWithFrame:CGRectMake(60*width1/320,15*height1/480, 200*width1/320, 27*height1/480)];
    self.titlelable.backgroundColor = [UIColor whiteColor];
    self.titlelable.clipsToBounds=YES;
    self.titlelable.backgroundColor=[UIColor whiteColor];
    self.titlelable.layer.borderColor=[UIColor redColor].CGColor;
    self.titlelable.layer.borderWidth=1.0;
    self.titlelable.layer.cornerRadius=5.0f;
    self.titlelable.textAlignment = NSTextAlignmentCenter;
    self.titlelable.font=[UIFont boldSystemFontOfSize:18.0f];
    self.titlelable.textColor = [UIColor blackColor];
    [self.headerView addSubview:self.titlelable];
    //-------------------------------------------------
    //Add Cancel Button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cancelButton.frame = CGRectMake(5*width1/320, 15*height1/480, 35*width1/320, 30*height1/480);
    //[self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:width1/20];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];

    self.cancelButton.backgroundColor=[UIColor clearColor];
   // [self.cancelButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.headerView addSubview:self.cancelButton];
    
    //-----------------------------------------------
    //Add Send Button
    
    //-----------------------------------------------
    //Add Send Button
    self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.sendButton.frame = CGRectMake(10*width1/320,200*height1/480,width1*300/320,40*height1/480);
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"title_bar@3x.png"] forState:UIControlStateNormal];
    [self.sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //self.sendButton.titleLabel.text=@"SEND";
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
    [self.sendButton addTarget:self action:@selector(postButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.clipsToBounds = YES;
    self.sendButton.titleLabel.font=[UIFont boldSystemFontOfSize:width1/16];
    
    [self.view addSubview:self.sendButton];
    
    
    
    
    self.commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10*width1/320,80*height1/480, 300*width1/320, 100*height1/480)];
    self.commentTextView.delegate = self;
    self.commentTextView.backgroundColor=[UIColor whiteColor];
    self.commentTextView.layer.cornerRadius=7.0f;
    self.commentTextView.layer.borderColor=[UIColor blackColor].CGColor;
    self.commentTextView.layer.shadowColor=[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)126/255 blue:(CGFloat)83/255 alpha:.6].CGColor;
    
    self.commentTextView.layer.borderWidth=.7f;
    
    [self.commentTextView becomeFirstResponder];
    self.commentTextView.font = [UIFont fontWithName:@"Arial" size:width1/20] ;
    [self.view addSubview:self.commentTextView];
    
  
//display comment(leave comment only viewable by team)
    self.placeHolder = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 320, 30)];
    self.placeHolder.backgroundColor=[UIColor clearColor];
    self.placeHolder.adjustsFontSizeToFitWidth=YES;
    self.placeHolder.textAlignment = NSTextAlignmentLeft;
    self.placeHolder.font=[UIFont fontWithName:@"Arial" size:width1/22];
    self.placeHolder.alpha=0.8;
    self.placeHolder.textColor = [UIColor darkGrayColor];
    
    [self.commentTextView addSubview:self.placeHolder];
    
    if ([self.accountType isEqualToString:@"Facebook"]) {
        self.titlelable.text = @"Facebook Comment";
        self.placeHolder.text = @"Comment here...";
    }
    else if ([self.accountType isEqualToString:@"GooglePlus"]){
        self.titlelable.text = @"Google+ Comment";
        self.placeHolder.text = @"Comment on Google+ Post";
        
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
-(void) displayActivityIndicator{
    self.HUD = [[MBProgressHUD alloc] init];
    self.HUD.dimBackground = YES;
    self.HUD.delegate = self;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
}
-(void) hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}
#pragma mark -

//Post Button Clicked Action
-(IBAction)postButtonClicked:(id)sender{
    //Check Expiry Date
    [self.commentTextView resignFirstResponder];
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
       [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        return;
    }
    //Comment Text Field Authentication
    if ([self.commentTextView.text isEqualToString:@""]) {
        UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"plzComposeMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
       [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
    }
    else{
        NSLog(@"Post Comment");
        [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
        //for Facebook message perform Comment operation and for Google Plus save comment to DataBase
        if ([self.accountType isEqualToString:@"Facebook"]) {
            [self getFacebookUserDetails];
        }
        else if ([self.accountType isEqualToString:@"GooglePlus"]){
           
            [self saveReplyToDataBase];
        }
    }
}
-(void)cancelButtonClicked{
    [self.commentTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
//Save Google Plus Comment to Database
-(void) saveReplyToDataBase{
     NSLog(@"Sae To DB");
    NSString *pro_name = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_Name",[self.dataDict objectForKey:@"GpUserId"]]];
    
    NSString *fromUserId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"GpUserId"]];
    NSString *name =pro_name;
    NSString *userId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"UserId"]];
    NSString *messageId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Id"]];;
    NSString *message = self.commentTextView.text;
    NSString *type = @"GooglePlus";
    
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                             <soap:Body>\
                             <AddReplyMessage xmlns=\"http://tempuri.org/\">\
                             <FromUserId>%@</FromUserId>\
                             <Name>%@</Name>\
                             <UserId>%@</UserId>\
                             <MessageId>%@</MessageId>\
                             <Message>%@</Message>\
                             <type>%@</type>\
                             </AddReplyMessage>\
                             </soap:Body>\
                             </soap:Envelope>",fromUserId,name,userId,messageId,message,type];
    
    NSLog(@"Soap Message = = %@",soapMessage);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/Messages.asmx?op=AddReplyMessage",WebLink];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/AddReplyMessage" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    
    [self.HUD hide:YES];
    
    if (error) {
        NSLog(@"Error == %@", error);
        NSString *errorString = [NSString stringWithFormat:@"%@",error];
        
        if ([errorString rangeOfString:@"The request timed out"].location != NSNotFound) {
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:@"Eror" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
           [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
            
        }
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String =%@", responseString);
        if ([responseString rangeOfString:@"faultstring"].location != NSNotFound) {
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"plzTryAfterAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
           [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
            [self cancelButtonClicked];
            
            NSLog(@"Error==%@", responseString);
            return;
        }
        else{
            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"successMsg"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
           [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
            [self cancelButtonClicked];
            //[self.commentTextView resignFirstResponder];
            //[self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }//End else Block
}

#pragma mark -
//Fet Selected Facebook Account Details
-(void) getFacebookUserDetails{
    
    NSString *fbID = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"ProfileId"]];
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Facebook-=-= %@",strUserid);
    
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
    //http://graph.facebook.com/jansharkhan/picture
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Rersponse String = %@", responseString);
        
        NSString *response = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
        NSString *accessToken = [dict objectForKey:@"AccessToken"];
        NSLog(@"Info Dict = %@", accessToken);
        
        if(!accessToken){
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
           [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
            NSLog(@"error=%@",error);
            [self cancelButtonClicked];
            
        }
        else
        [self CommentToFacebook:accessToken];
    }
}
//Cooment on Facebook
-(void) CommentToFacebook:(NSString *)accessToken{
    NSString *mesId = [[NSString alloc] initWithFormat:@"%@",[self.dataDict objectForKey:@"MessageId"]];
    NSLog(@"%@",mesId);
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/comments",mesId];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setStringEncoding:NSUTF8StringEncoding];
    [request setPostValue:accessToken forKey:@"access_token"];
    
    [request setPostValue:self.commentTextView.text forKey:@"message"];
    //[request setDidFinishSelector:@selector(commentPost:)];
    NSError *error;
    //[request setDelegate:self];
    [request startSynchronous];
    
    error = [request error];
    [self.HUD hide:YES];
    if (error) {
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        NSLog(@"error=%@",error);
        [self cancelButtonClicked];
    }
    else{
       NSString *response = [request responseString];
       NSLog(@"response = %@",response);
        NSLog(@"Comment Posted");
        UIAlertView *Msg=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"successMsg"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
                          Msg.backgroundColor=[UIColor blackColor];
                          Msg.tintColor=[UIColor whiteColor];
                          [Msg show];
        [self performSelector:@selector(dismissAlertView1:) withObject:Msg afterDelay:2.0];
        [self cancelButtonClicked];
    }
    
}

-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark -
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
   // if([text isEqualToString:@"\n"]) {
        //[textView resignFirstResponder];
       // return NO;
   // }

    //NSLog(@"New Text = %@",text);
    if ([textView.text isEqualToString:@""]){
        if (![text isEqualToString:@""]) {
            self.placeHolder.hidden=YES;
        }
        else{
           self.placeHolder.hidden=NO; 
        }
        
    }
    else{
        if (textView.text.length==1) {
            if ([text isEqualToString:@""]) {
                self.placeHolder.hidden=NO;
            }
        }
        else{
            self.placeHolder.hidden=YES;
        }
        
    }
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //NSLog(@"End Editing");
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self commentTextView] resignFirstResponder];
}



@end
