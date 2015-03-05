//
//  TwitterReplyViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "TwitterReplyViewController.h"
#import "SingletonClass.h"
#import "UIImageView+WebCache.h"
#import "FHSTwitterEngine.h"
#import "HelperClass.h"
#import "SBJson.h"


@interface TwitterReplyViewController ()

@end

@implementation TwitterReplyViewController

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
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 55)];
    //self.TopView.backgroundColor = [UIColor blackColor];
    self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)40/255 green:(CGFloat)40/255 blue:(CGFloat)40/255 alpha:1.0];

    [self.view addSubview:self.headerView];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    
    //[self.headerView.layer insertSublayer:gradient atIndex:0];
    //-------------------------------------------------
    self.titlelable = [[UILabel alloc] initWithFrame:CGRectMake(70, 17, 180, 30)];
    self.titlelable.backgroundColor = [UIColor clearColor];
    self.titlelable.textAlignment = NSTextAlignmentCenter;
    self.titlelable.textColor = [UIColor whiteColor];
    self.titlelable.text = @"Compose Message";
    [self.headerView addSubview:self.titlelable];
    //-------------------------------------------------
    //Add Cancel Button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(10, 20, 60, 27);
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
    self.cancelButton.layer.borderWidth=1.0f;
    self.cancelButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.cancelButton.clipsToBounds = YES;
    
    [self.cancelButton setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] forState:UIControlStateNormal];
    [self.headerView addSubview:self.cancelButton];
    
    
    //-----------------------------------------------
    //Add Send Button
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(260, 20, 50, 27);
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
    [self.sendButton addTarget:self action:@selector(sendButtobclickedAction:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
    self.sendButton.layer.borderWidth=1.0f;
    self.sendButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.clipsToBounds = YES;
    
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.headerView addSubview:self.sendButton];
    //======================================================
    CGFloat hhh=0;
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        hhh = 300;
    }
    else{
        hhh = 200;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 54, self.view.bounds.size.width, hhh)];
    [self.view addSubview:self.scrollView];
    
    self.allTwitterAccount = [SingletonClass sharedSingleton].connectedTwitterAccount;
    for (int i=0; i<self.allTwitterAccount.count; i++) {
        UIImageView *profileImageView= nil;
        NSString *imageName = nil;
        imageName = @"twticon.png";
        [self displayImageView:profileImageView count:i accountImageName:imageName];
        count = count + 1;
    }
     CAGradientLayer *gradient2 = [CAGradientLayer layer];
    if(yy>hhh){
        [self.scrollView setContentSize:CGSizeMake(320, yy)];
        gradient2.frame = CGRectMake(0, 0, 320, yy);

    }
    else{
        [self.scrollView setContentSize:CGSizeMake(320, hhh)];
        gradient2.frame = CGRectMake(0, 0, 320, hhh);

    }
    
    
    UIColor *lastColor2 =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1.0];
    gradient2.colors = [NSArray arrayWithObjects:(id)[lastColor2 CGColor], (id)[firstColor CGColor],(id)[lastColor2 CGColor], nil];
    
    [self.scrollView.layer insertSublayer:gradient2 atIndex:0];
    //--------------------
    self.composerView = [[UIView alloc] initWithFrame:CGRectMake(55, 54, 265, hhh)];
    
    self.composerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.composerView];
    //-------------------------------------------------------
    self.borderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 5, hhh)];
    self.borderImageView.image = [UIImage imageNamed:@"side_divider.png"];
    [self.composerView addSubview:self.borderImageView];
    //---------------------------------------------------------
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 250, hhh-40)];
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.delegate = self;
    self.messageTextView.font = [UIFont systemFontOfSize:15.0f];
    [self.composerView addSubview:self.messageTextView];
    
    //----------------------------------------------------
    self.sliderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sliderButton.frame = CGRectMake(55, 125, 13, 30);
    [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"right_slide.png"] forState:UIControlStateNormal];
    [self.sliderButton addTarget:self action:@selector(sliderButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sliderButton];
    
//    //------------------------------------------------------
//    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.cameraButton.frame = CGRectMake(25, 176, 20, 20);
//    [self.cameraButton setBackgroundImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
//    [self.cameraButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.composerView addSubview:self.cameraButton];
    //----------------------------------------------------
    
    //----------------------------------------------------------
    self.characterCountLable = [[UILabel alloc] initWithFrame:CGRectMake(195, hhh-36, 50, 20)];
    self.characterCountLable.textColor = [UIColor blackColor];
    self.characterCountLable.backgroundColor = [UIColor clearColor];
    self.characterCountLable.textAlignment = NSTextAlignmentCenter;
    [self.composerView addSubview:self.characterCountLable];
    self.characterCountLable.text = @"140";
    messageCharacterCount = 140;
    [self.messageTextView becomeFirstResponder];
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
-(void)cancelButtonClickedAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) sendButtobclickedAction:(id)sender{
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        return;
    }
    //==============================================
    
   // int a= (int)self.previousSelectedImageView.tag;
//    NSDictionary *dict = [self.allTwitterAccount objectAtIndex:a];
//    NSLog(@"Dict==%@",dict);
    
    if (self.messageTextView.text.length <1) {
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:@"Please compose message" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        return;
    }
    
}
#pragma mark - 
-(void)displayImageView:(UIImageView *)profileImageView count:(int)i accountImageName:(NSString *)imageName{
    
    NSDictionary *dict =[self.allTwitterAccount objectAtIndex:i];
    NSString *imageUrlString = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfilePicUrl"]];
    NSString *profileName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]];
    //CGFloat y = count*53;
    profileImageView = [[UIImageView alloc] init];
    profileImageView.frame = CGRectMake(0, yy, 53, 53);
    profileImageView.tag=count;
    profileImageView.userInteractionEnabled = YES;
    [profileImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
    if (count==0) {
        profileImageView.alpha = 1.0f;
        self.previousSelectedImageView = profileImageView;
    }
    else{
        profileImageView.alpha = .4f;
    }
    
    [self.scrollView addSubview:profileImageView];
    
    UIImageView *accView=[[UIImageView alloc] initWithFrame:CGRectMake(38, 37, 16, 16)];
    accView.image = [UIImage imageNamed:imageName];
    [profileImageView addSubview:accView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTapsRequired = 1;
    [profileImageView addGestureRecognizer:tap];
    
    //y = y+10;
    UILabel *profileNameLabel = [[UILabel alloc] init];
    profileNameLabel.backgroundColor = [UIColor clearColor];
    profileNameLabel.textColor = [UIColor whiteColor];
    profileNameLabel.frame = CGRectMake(64, yy+10, 250, 30);
    profileNameLabel.textAlignment = NSTextAlignmentLeft;
    profileNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    profileNameLabel.text = profileName;
    [self.scrollView addSubview:profileNameLabel];
    yy=yy+53;
}
-(void) handleTapGesture:(id)sender{
    UIView *v = (UIControl *)sender;
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)v;
    UIImageView *img = (UIImageView *)tap.view;
    
    if (img.alpha==1.0) {
        return;
    }
    else{
        self.previousSelectedImageView.alpha = 0.4;
        img.alpha = 1;
        self.previousSelectedImageView = img;
    }
}
-(void) sliderButtonClickedAction:(id)sender{
    CGFloat x = self.composerView.frame.origin.x;
    // NSLog(@"x==%f",x);
    if (x==55 || x<150) {
        [UIView animateWithDuration:.50 animations:^{
            self.composerView.frame = CGRectMake(316, 54, 265, self.composerView.frame.size.height);
            self.sliderButton.frame = CGRectMake(307, 125, 13, 30);
            [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"left_slide.png"] forState:UIControlStateNormal];
        }];
    }
    else{
        [UIView animateWithDuration:.50 animations:^{
            self.composerView.frame = CGRectMake(55, 54, 265, self.composerView.frame.size.height);
            self.sliderButton.frame = CGRectMake(55, 125, 13, 30);
            [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"right_slide.png"] forState:UIControlStateNormal];
        }];
    }
 
}

#pragma mark -
#pragma mark Twitter Reply

-(void) getTwitterUserDtails:(NSDictionary *)dataDict{
    NSString *proID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Twitter-=-= %@",proID);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetTwitterAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<TwitterId>%@</TwitterId>\n"
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
        
        
        //        dispatch_async(GCDBackgroundThread, ^{
        //            @autoreleasepool {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSError *returnCode = nil;
        NSString *messageText = self.messageTextView.text;
       // NSString *messageId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"MessageId"]];
        
        NSString *messageId = self.messageIDString;
            
            returnCode =  [[FHSTwitterEngine sharedEngine] postTweet:messageText inReplyTo:messageId aouthTokenDictionary:dict];
    
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"%@",returnCode);
        if (!returnCode) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"commentedTwitter"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
            [av show];
             [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];
        }
        else{
            NSLog(@"Error to Pos Twitter==%ld",(long)returnCode.code );
            
        }
        
        
    }
}
-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (text.length == 0) {
        if (messageCharacterCount<140) {
           // messageCharacterCount = messageCharacterCount+1;
            messageCharacterCount = (int)(140 - range.location);
        }
        
    }
    else{
        messageCharacterCount = (int)(messageCharacterCount - text.length);
    }
    if (messageCharacterCount<0) {
        self.characterCountLable.textColor = [UIColor redColor];
    }
    else{
        self.characterCountLable.textColor = [UIColor blackColor];
    }
    self.characterCountLable.text = [NSString stringWithFormat:@"%d",messageCharacterCount];
    return YES;
}
@end
