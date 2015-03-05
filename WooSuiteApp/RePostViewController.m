//
//  RePostViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 09/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "RePostViewController.h"
#import "UIImageView+WebCache.h"
#import "FHSTwitterEngine.h"
#import "SingletonClass.h"
#import "HelperClass.h"
#import "SBJson.h"
#import "MBProgressHUD.h"

#import "JSONKit.h"
#import "OAuthConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"
#import "OATokenManager.h"
#import "OADataFetcher.h"
#import "OAServiceTicket.h"

@interface RePostViewController ()<MBProgressHUDDelegate>
@property (nonatomic, strong) MBProgressHUD *HUD;
@end

@implementation RePostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
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
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.messageTextView becomeFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //------------------------------------------------------
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    isMessageScheduled = NO;
    
    //Creating UI
    self.view.backgroundColor=[UIColor whiteColor];
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 50*height1/480)];
    self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)40/255 green:(CGFloat)40/255 blue:(CGFloat)40/255 alpha:1.0];

          [self.view addSubview:self.headerView];
   //---------------------------------------------------------------
       self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cancelButton.frame = CGRectMake(5*width1/320,15*height1/480, 50*width1/320, 30*height1/480);
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
      self.cancelButton.backgroundColor=[UIColor clearColor];
      [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];

[self.headerView addSubview:self.cancelButton];
    
    //-----------------------------------------------
    //Add Send Button
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(230*width1/320, 187*height1/480,80*width1/320, 25*height1/480);
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
    [self.sendButton addTarget:self action:@selector(postButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.layer.backgroundColor=[UIColor redColor].CGColor;;
    self.sendButton.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1];
    self.sendButton.layer.borderWidth=1.0f;
    self.sendButton.layer.borderColor = [UIColor redColor].CGColor;
    //self.sendButton.layer.cornerRadius = 2.0f;
    self.sendButton.clipsToBounds = YES;
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"proceed_btn@3x.png"] forState:UIControlStateNormal];
    
    [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    [self.view addSubview:self.sendButton];
    
    
    //------------------------------------------------------
    //Display selected account name and profile pic
    

//[self.headerView addSubview:self.profileImageView];
//--------------------------------------------------------
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90*width1/320,15*height1/480,140*height1/480, 27*height1/480)];
    self.nameLabel.backgroundColor = [UIColor whiteColor];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:width1/20];
    
    self.nameLabel.layer.borderWidth=2.0f;
    self.nameLabel.layer.cornerRadius=2.0f;
    self.nameLabel.layer.borderColor = [UIColor redColor].CGColor;
    //[self.view addSubview:self.nameLabel];
    self.nameLabel.text =@"Reply";
    self.nameLabel.backgroundColor=[UIColor whiteColor];
    
    CALayer * layer = [self.nameLabel layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:7.0];
    [layer setBorderWidth:1.0];
    
    [self.headerView addSubview:_nameLabel];
//----------------------------------------------------------
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(10*width1/320,80*height1/480, width1*300/320,100*height1/480)];
    self.messageTextView.backgroundColor = [UIColor whiteColor];
    //self.messageTextView.text = self.message;
    self.messageTextView.layer.cornerRadius=5.0f;
    self.messageTextView.layer.borderColor=[UIColor blackColor].CGColor;
    self.messageTextView.layer.borderWidth=2.0f;
    self.messageTextView.delegate = self;
    self.messageTextView.font = [UIFont systemFontOfSize:width1/20];
    [self.view addSubview:self.messageTextView];
    [self.messageTextView becomeFirstResponder];
    
    
    self.characterCountLable = [[UILabel alloc] initWithFrame:CGRectMake(width1/2, 190*height1/480, 50*width1/320, 20*height1/480)];
    self.characterCountLable.textColor = [UIColor blackColor];
    self.characterCountLable.backgroundColor = [UIColor clearColor];
    self.characterCountLable.textAlignment = NSTextAlignmentCenter;
    self.characterCountLable.font=[UIFont systemFontOfSize:width1/16];
    [self.view addSubview:self.characterCountLable];
    
    characterCount = (int)(140 - self.message.length);
    self.characterCountLable.text = [NSString stringWithFormat:@"%d",characterCount];
    
    //----------------------------------------------------
    
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

#pragma  mark -
//cancel button action
//switch to previous view
-(void)cancelButtonClicked{
    [self.HUD hide:YES];
    [self.messageTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//Post button Action
- (IBAction) postButtonClicked: (id)sender{
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //----------------------------------
    if (self.messageTextView.text.length <=0) {
        UIAlertView *av =[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"plzComposeMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
       [av show];
        [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

    }
    else if(characterCount<0){
        UIAlertView *av =[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"tooManyChars"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
       [av show];
        [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

    }

    else
    {
        [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
        
        @try {
            NSLog(@"Send Reply");
            //check account type
            if ([self.accountType isEqualToString:@"Twitter"]) {
                NSLog(@"Twitter Reply");
                [self getTwitterUserDtails];
            }
            else if ([self.accountType isEqualToString:@"Linkedin"]){
                NSLog(@"Linkedin Reply");
                NSLog(@"Save Reply to DB");
                [self saveReplyToDatabase];
               
            }
            else if ([self.accountType isEqualToString:@"Twitter_Feed"]){
                [self getTwitterUserDtails];
            }
            else{
                NSLog(@"Unknown Account");
            }
        }
        @catch (NSException *exception) {
            [self.HUD hide:YES];

        }
        @finally {
            //[self.HUD hide:YES];
             NSLog(@"Finally Block");
        }
        
    }
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}



#pragma mark -
//Save Linkedin reply to database
-(void) saveReplyToDatabase{
    
    NSString *fromUserId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"ProfileId"]];
    NSString *name = self.nameLabel.text;
    NSString *userId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"UserId"]];
    NSString *messageId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Id"]];
    NSString *message = self.messageTextView.text;
    NSString *type = @"Linkedin";
    
    //Prepare soap message
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@/API/Messages.asmx?op=AddReplyMessage",WebLink];
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
    if (error) {
        NSLog(@"Error == %@", error);
        NSString *errorString = [NSString stringWithFormat:@"%@",error];
        
        if ([errorString rangeOfString:@"The request timed out"].location != NSNotFound) {
            UIAlertView *av =[[UIAlertView alloc] initWithTitle:@"Eror" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [av show];
            [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

           // [self cancelButtonClicked];

        }
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String =%@", responseString);
        if ([responseString rangeOfString:@"faultstring"].location != NSNotFound) {
            UIAlertView *av= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"plzTryAfterAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [av show];
            [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

            NSLog(@"Error==%@", responseString);
            
           // [self cancelButtonClicked];

            //return;
        }
        else{
            self.messageTextView.text = self.message;
            UIAlertView *av =[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"successMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [av show];
            [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

            [self cancelButtonClicked];

        }
        
    }//End else Block
    [self.HUD hide:YES];
}

#pragma mark -
//Slider button action
-(void)sliderButtonClicked{
    CGFloat x = self.composerView.frame.origin.x;
   // NSLog(@"x==%f",x);
    if (x==55 || x<150) {
        [UIView animateWithDuration:.50 animations:^{
            self.composerView.frame = CGRectMake(316, 55, 265, self.composerView.frame.size.height);
            self.sliderButton.frame = CGRectMake(307, 125, 13, 30);
            [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"left_slide.png"] forState:UIControlStateNormal];
        }];
    }
    else{
        [UIView animateWithDuration:.50 animations:^{
            self.composerView.frame = CGRectMake(55, 55, 265, self.composerView.frame.size.height);
            self.sliderButton.frame = CGRectMake(55, 110, 13, 30);
            [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"right_slide.png"] forState:UIControlStateNormal];
        }];
    }
}


#pragma mark -
#pragma mark Buttons Action
-(void) cameraButtonAction: (id)sender{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark Image Picker Delegate

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *selImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.selectedImageView) {
        self.selectedImageView.image =selImage ;
    }
    else{
        self.selectedImageView = [[UIImageView alloc] initWithImage:selImage];
        self.selectedImageView.frame = CGRectMake(0, 0, 265, 200);
        self.selectedImageView.alpha=0.24;
        [self.composerView insertSubview:self.selectedImageView atIndex:0];
        //[self.composerView addSubview:self.selectedImageView];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Twitter Reply
//Get selected Twitter account details
-(void) getTwitterUserDtails{
    NSLog(@"Self DataDict== %@", self.dataDict);
    NSString *proID = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [SingletonClass sharedSingleton].profileID;
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
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
        [av show];
        
        [self cancelButtonClicked];
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"Rersponse String = %@", responseString);
        if ([responseString rangeOfString:@"faultstring"].location != NSNotFound) {
            [[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"plzTryAfterAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
            
            NSLog(@"Error==%@", responseString);
            [self cancelButtonClicked];
            //return;
        }
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
        NSString *messageText = self.messageTextView.text;
        NSString *messageId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"MessageId"]];
       
        //check image attach or not
        if ([self.imageAttached isEqualToString:@"1"]) {
            UIImage *originalImage = self.selectedImageView.image;
            NSData *data = UIImageJPEGRepresentation(originalImage, .5);
            
            // add reply on twitter with image
            returnCode = [[FHSTwitterEngine sharedEngine] postTweet:messageText withImageData:data inReplyTo:messageId aouthTokenDictionary:dict];
        }
        else{
            // add reply on twitter with out image
            returnCode =  [[FHSTwitterEngine sharedEngine] postTweet:messageText inReplyTo:messageId aouthTokenDictionary:dict];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (!returnCode) {
            NSLog(@"---------%@",returnCode);
            self.messageTextView.text =  self.message;
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"repliedonTwitter"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
            [av show];
            [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

            [self cancelButtonClicked];
        }
        else{
            NSLog(@"Error to Pos Twitter==%ld",(long)returnCode.code );
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
            [av show];
            [self performSelector:@selector(dismissAlertView1:) withObject:av afterDelay:2.0];

            [self cancelButtonClicked];
        }
    }
    
    [self.HUD hide:YES];
}
#pragma mark -
#pragma mark TextView Delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (text.length == 0) {
        
        if (characterCount<140) {
            
            characterCount = (int)(140 - range.location);
        }
        
    }
    else{
        characterCount = (int)(characterCount - text.length);
    }
    
    if (characterCount<0) {
        self.characterCountLable.textColor = [UIColor redColor];
    }
    else{
        self.characterCountLable.textColor = [UIColor blackColor];
    }
    self.characterCountLable.text = [NSString stringWithFormat:@"%d",characterCount];
    
    return YES;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self messageTextView] resignFirstResponder];
}


-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}



@end










/*
#pragma mark -
#pragma mark Display Date Picker
//Display date Picker
-(void) displayDatePicker:(id)sender{
    if (isMessageScheduled==YES) {
        [self.schedulButton setBackgroundImage:[UIImage imageNamed:@"schedul_icon.png"] forState:UIControlStateNormal];
        isMessageScheduled = NO;
        return;
    }
    
    [UIView animateWithDuration:.5 animations:^{
        [self.messageTextView resignFirstResponder];
        if (self.datePicker) {
            self.datePicker.date = [NSDate date];
            self.pickerView.frame = CGRectMake(0, self.view.bounds.size.height-245, self.view.bounds.size.width, 245);
        }
        else{
            self.pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-245, self.view.bounds.size.width, 245)];
            [self.view addSubview:self.pickerView];
            self.pickerView.backgroundColor = [UIColor whiteColor];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = CGRectMake(0, 0, 320, 40);
            UIColor *firstColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)49/255 blue:(CGFloat)129/255 alpha:1.0];
            UIColor *lastColor =[UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)157/255 blue:(CGFloat)219/255 alpha:0.5];
            
            gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
            [self.pickerView.layer insertSublayer:gradient atIndex:0];
            
            self.pickerView.frame = CGRectMake(0, self.view.bounds.size.height-245, self.view.bounds.size.width, 245);
            //-----------------------------------------------
            //Add Send Button
            UIButton *setTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            setTimeButton.frame = CGRectMake(250, 7, 60, 27);
            [setTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            setTimeButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
            [setTimeButton addTarget:self action:@selector(selectedDate:) forControlEvents:UIControlEventTouchUpInside];
            setTimeButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
            setTimeButton.layer.borderWidth=1.0f;
            setTimeButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)55/255 blue:(CGFloat)136/255 alpha:1].CGColor;
            setTimeButton.layer.cornerRadius = 5.0f;
            setTimeButton.clipsToBounds = YES;
            
            [setTimeButton setTitle:@"Set Time" forState:UIControlStateNormal];
            [self.pickerView addSubview:setTimeButton];
            
            
            //-------------------------------------------------
            //Add Cancel Button
            UIButton *cancelTimer = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelTimer.frame = CGRectMake(10, 7, 60, 27);
            [cancelTimer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cancelTimer.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
            [cancelTimer addTarget:self action:@selector(hidePickerView:) forControlEvents:UIControlEventTouchUpInside];
            cancelTimer.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
            cancelTimer.layer.borderWidth=1.0f;
            cancelTimer.layer.borderColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)55/255 blue:(CGFloat)136/255 alpha:1].CGColor;
            cancelTimer.layer.cornerRadius = 5.0f;
            cancelTimer.clipsToBounds = YES;
            
            [cancelTimer setTitle:@"Cancel" forState:UIControlStateNormal];
            [self.pickerView addSubview:cancelTimer];
            
            
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 200)];
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            self.datePicker.minimumDate = [NSDate date];
            
            [self.pickerView addSubview:self.datePicker];
            
        }
    }];
    
    
}
-(void) selectedDate: (id)sender{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    isMessageScheduled = YES;
    //self.myLabel.text = [dateFormatter stringFromDate:[dueDatePickerView date]];
    NSLog(@"Picked the date %@", [dateFormatter stringFromDate:[self.datePicker date]]);
    [self.schedulButton setBackgroundImage:[UIImage imageNamed:@"schedul_icon_done.png"] forState:UIControlStateNormal];
    [UIView animateWithDuration:.5 animations:^{
        [self.messageTextView becomeFirstResponder];
        
        self.pickerView.frame = CGRectMake(0, self.view.frame.size.height, 320, 0);
    }];
    
}
-(void) hidePickerView: (id)sender{
    //self.pickerView.hidden = YES;
    [UIView animateWithDuration:.5 animations:^{
        [self.messageTextView becomeFirstResponder];
        
        self.pickerView.frame = CGRectMake(0, self.view.frame.size.height, 320, 0);
    }];
    
}

#pragma mark - 
#pragma mark Linkedin Post
-(void) getLinkedinUserDetails{
    NSString *proID = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [SingletonClass sharedSingleton].profileID;
    
    NSLog(@"profile id Linkedin-=-= %@",proID);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetLinkedinAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<LinkedinId>%@</LinkedinId>\n"
                             "</GetLinkedinAccountDetailsById>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserId,proID];
    
    NSLog(@"soapMessg twitter  %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/LinkedinAccount.asmx?op=GetLinkedinAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetLinkedinAccountDetailsById" forHTTPHeaderField:@"SOAPAction"];
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
        
        [self addCommentOnLinkedin:@"new comment iOS" withOAuthToken:dict];
        
    }
    
}

-(void) addCommentOnLinkedin:(NSString *)comment withOAuthToken:(NSDictionary *)authDict{
    
    NSString *gotkeyValue = [[NSString alloc] initWithFormat:@"%@",[authDict objectForKey:@"OAuthToken"]];
    NSString *gotSecretKayValue = [[NSString alloc] initWithFormat:@"%@",[authDict objectForKey:@"OAuthSecret"]];
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:LinkedinAPIKey secret:LinkedinSecretKey realm:RealMLink];
    OAToken *token = [[OAToken alloc] initWithKey:gotkeyValue secret:gotSecretKayValue];
    
//    NSString *strUrl = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~/network/updates/key=%@/update-comments",[self.dataDict objectForKey:@"FeedId"]];
    // 	https://api.linkedin.com/v1/people/~/network/updates/key={NETWORK UPDATE KEY}/update-comments
   NSString *strUrl = [NSString stringWithFormat:@"http://api.linkedin.com/v1/people/~/network/updates/key=UPDATE-310121522-5926240257379942400/update-comments"];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:consumer
                                       token:token
                                    callback:nil
                           signatureProvider:nil];
    
    NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:
                            comment, @"comment", nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *updateString = [update JSONString];
    [request setHTTPBodyWithString:updateString];
	[request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *httpResponse = nil;
    NSError *error = nil;
    [request prepare];
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    if (error) {
        NSLog(@"Error in Linkedin Post== %@", error);
    }
    else{
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"Response = %@",responseString);
    }
    [self.HUD hide:YES];
}
*/
