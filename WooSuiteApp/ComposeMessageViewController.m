//
//  ComposeMessageViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 09/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "ComposeMessageViewController.h"
#import "SingletonClass.h"
#import "UIImageView+WebCache.h"
#import <UIKit/UITextInput.h>
#import "PostClassHelper.h"
#import "MBProgressHUD.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "NSData+Base64.h"

@interface ComposeMessageViewController ()<MBProgressHUDDelegate>{
    int width1;
    int height1;
    CGRect screenRect;
}
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation ComposeMessageViewController

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
    [self createUI];
}
-(void) createUI{
    
    self.imageAttachedValue = @"0";
    isMessageScheduled = NO;
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    //Creating UI
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,width1, 55*height1/480)];
    
        self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];

    [self.view addSubview:self.headerView];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    
    //[self.headerView.layer insertSublayer:gradient atIndex:0];
    //-------------------------------------------------
    self.titlelable = [[UILabel alloc] initWithFrame:CGRectMake(width1/2-90, 20*height1/480, 180, 30)];
    self.titlelable.backgroundColor = [UIColor clearColor];
    self.titlelable.textAlignment = NSTextAlignmentCenter;
    self.titlelable.textColor = [UIColor whiteColor];
    self.titlelable.font=[UIFont systemFontOfSize:width1/19];
    self.titlelable.text = @"Compose Message";
    [self.headerView addSubview:self.titlelable];
    //-------------------------------------------------
    //Add Cancel Button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(10, 15*height1/480, 35*height1/480, 30*height1/480);
      [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    self.cancelButton.clipsToBounds = YES;
    [self.headerView addSubview:self.cancelButton];
    
    
    //-----------------------------------------------
    //Add Send Button
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(width1-(70*width1/320), 20*height1/480, 60*width1/320, 25*height1/480);
    [self.sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:width1/16];
    [self.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.layer.backgroundColor=[UIColor whiteColor].CGColor;
    self.sendButton.layer.borderWidth=1.0f;
    self.sendButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    self.sendButton.layer.cornerRadius = 5.0f;
    self.sendButton.clipsToBounds = YES;
    
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.headerView addSubview:self.sendButton];
    
    selectionCount = 1;
    count = 0;
    
    //Fetch all Connect Account
    self.allConnectcedAccountArray = [[NSMutableArray alloc] init];
    self.selectedAccount = [[NSMutableArray alloc]init];
    
    NSArray *tempArray =[SingletonClass sharedSingleton].connectedprofileInfo;
    //Sort All account on the basis of Account Type
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"ProfileType" ascending:NO];
    NSArray *descriptors=[NSArray arrayWithObject: descriptor];
    NSArray *sortedArray=(NSMutableArray *)[tempArray sortedArrayUsingDescriptors:descriptors];
    //-------------------------------------------------------

        if(height1==480){
        hhh =180*height1/480;
    }
    else if(height1==568){
        hhh =220*height1/480;
        
    }
    else if(height1==667){
        hhh =240*height1/480;
        
    }
    else {
        hhh =250*height1/480;
    }


    /*
    if ([UIScreen mainScreen].bounds.size.height>500) {
        hhh = 310;
    }
    else{
        hhh = 210;
    }
     */
    //---------------------------------------------------------
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 55*height1/480, width1, hhh)];
    
    
    [self.view addSubview:self.scrollView];
    
    //----------------------------------------------------------
    selectedTwitterAccCount = 0;
    
    //Add logo image with Profile Image
    for (int i =0; i<sortedArray.count; i++) {
        NSDictionary *dict =[sortedArray objectAtIndex:i];
        NSString *accType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
        UIImageView *profileImageView= nil;
        NSString *imageName = nil;
        if ([accType isEqualToString:@"facebook"]) {
            imageName = @"facebook1.png";
            
            [self.allConnectcedAccountArray addObject:[sortedArray objectAtIndex:i]];
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count +1;
            if (selectedTwitterAccCount==0) {
                
                messageCharacterCount = 5000;
            }
        }
        else if ([accType isEqualToString:@"twitter"]){
            imageName = @"twitter1.png";
            
            [self.allConnectcedAccountArray addObject:[sortedArray objectAtIndex:i]];
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
            if (selectedTwitterAccCount==0) {
                selectedTwitterAccCount = 1;
                messageCharacterCount = 140;
            }
        }
        else if ([accType isEqualToString:@"linkedin"]){
            imageName = @"linkedin1.png";
            
            [self.allConnectcedAccountArray addObject:[sortedArray objectAtIndex:i]];
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
            if (selectedTwitterAccCount==0) {
                selectedTwitterAccCount = 1;
                messageCharacterCount = 140;
            }
        }
        else if ([accType isEqualToString:@"googleplus"]){
            //imageName = @"google_plus.png";
            NSLog(@"Google Plus Account");
            //            [self.allConnectcedAccountArray addObject:[sortedArray objectAtIndex:i]];
            //            [self displayImageView:profileImageView count:i accountImageName:imageName];
            //            count = count + 1;
        }
        else if ([accType isEqualToString:@"tumblr"]){
            imageName = @"tumblr1.png";
            
            [self.allConnectcedAccountArray addObject:[sortedArray objectAtIndex:i]];
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
            if (selectedTwitterAccCount==0) {
                messageCharacterCount = 5000;
            }
        }
        else if ([accType isEqualToString:@"instagram"]){
            imageName = @"instagram1.png";
            
            [self.allConnectcedAccountArray addObject:[sortedArray objectAtIndex:i]];
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
            if (selectedTwitterAccCount==0) {
                selectedTwitterAccCount = 1;
                messageCharacterCount = 5000;
            }
            
        }
        
    }

    // NSLog(@"All Connected account = %@\n\n\n\n",self.allConnectcedAccountArray);
    //--------------------------------------------------
    
    if (self.allConnectcedAccountArray>0) {
        [self.selectedAccount addObject:[self.allConnectcedAccountArray objectAtIndex:0]];
    }
    
    [self.scrollView setContentSize:CGSizeMake(width1, yy)];
    //--------------------
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = CGRectMake(0, 0, width1, yy);
    
    
    UIColor *lastColor2 =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1.0];
    gradient2.colors = [NSArray arrayWithObjects:(id)[lastColor2 CGColor], (id)[firstColor CGColor],(id)[lastColor2 CGColor], nil];
    
    [self.scrollView.layer insertSublayer:gradient2 atIndex:0];
    //--------------------
    
    
    //UI for Composer View
    self.composerView = [[UIView alloc] initWithFrame:CGRectMake(65*width1/320, 55*height1/480, 265*width1/320, hhh)];
    
    self.composerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.composerView];
    //-------------------------------------------------------
    self.borderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 5, hhh)];
    self.borderImageView.image = [UIImage imageNamed:@"side_divider.png"];
    [self.composerView addSubview:self.borderImageView];
    //---------------------------------------------------------
   
    
    //--------------------------------------------------------
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 250*width1/320, hhh-50)];
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.delegate = self;
    self.messageTextView.font = [UIFont systemFontOfSize:width1/18];
    [self.composerView addSubview:self.messageTextView];
    
    //----------------------------------------------------
    self.sliderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sliderButton.frame = CGRectMake(65*width1/320, 160*height1/480, 13, 30);
    [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"right_slide.png"] forState:UIControlStateNormal];
    [self.sliderButton addTarget:self action:@selector(sliderButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sliderButton];
    
    //------------------------------------------------------
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraButton.frame = CGRectMake(35*width1/320, hhh-40, 27*width1/320, 25*width1/320);
    [self.cameraButton setBackgroundImage:[UIImage imageNamed:@"action-photo.png"] forState:UIControlStateNormal];
    [self.cameraButton addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.composerView addSubview:self.cameraButton];
    //----------------------------------------------------
    self.schedulButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.schedulButton.frame = CGRectMake(120*width1/320, hhh-40, 25*width1/320, 25*width1/320);
    [self.schedulButton setBackgroundImage:[UIImage imageNamed:@"schedul_icon.png"] forState:UIControlStateNormal];
    [self.schedulButton addTarget:self action:@selector(displayDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.composerView addSubview:self.schedulButton];
    //----------------------------------------------------------
    self.characterCountLable = [[UILabel alloc] initWithFrame:CGRectMake(192*width1/320, hhh-40, 60,25)];
    self.characterCountLable.textColor = [UIColor blackColor];
    self.characterCountLable.font=[UIFont systemFontOfSize:width1/16];
    self.characterCountLable.backgroundColor = [UIColor clearColor];
    self.characterCountLable.textAlignment = NSTextAlignmentCenter;
    [self.composerView addSubview:self.characterCountLable];
    
    
    if (self.isDraftMessages==YES) {
        self.messageTextView.text = [NSString stringWithFormat:@"%@",[self.draftDict objectForKey:@"Message"]];
        messageCharacterCount = (int)(messageCharacterCount - self.messageTextView.text.length);
    }
    self.characterCountLable.text = [NSString stringWithFormat:@"%d",messageCharacterCount];
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
//Adding logo image with Profile image View
-(void)displayImageView:(UIImageView *)profileImageView count:(int)i accountImageName:(NSString *)imageName{
    
    NSDictionary *dict =[self.allConnectcedAccountArray objectAtIndex:count];
   
    NSString *profileName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]];
    //CGFloat y = count*53;
    NSString *imageUrlString;
    NSString *proType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
    if([proType isEqualToString:@"tumblr"]){
        imageUrlString = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@.tumblr.com/avatar",[dict objectForKey:@"ProfilePicUrl"]];
        NSLog(@"%@",imageUrlString);
       }
    else{
         imageUrlString= [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfilePicUrl"]];
    }
       
    profileImageView = [[UIImageView alloc] init];
    profileImageView.frame = CGRectMake(0, yy,65*width1/320,65*width1/320);
    profileImageView.tag=count;
    profileImageView.backgroundColor = [UIColor whiteColor];
    profileImageView.userInteractionEnabled = YES;
    [profileImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
    if (count==0) {
        profileImageView.alpha = .4f;
    }
    else{
        profileImageView.alpha = 1.0f;
    }
    
    [self.scrollView addSubview:profileImageView];
    
    UIImageView *accView=[[UIImageView alloc] initWithFrame:CGRectMake(47*width1/320, 39*height1/480, 16*width1/320, 16*width1/320)];
    accView.image = [UIImage imageNamed:imageName];
    [profileImageView addSubview:accView];
    
    //Add Gesture Recognizer on Profile imageview
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTapsRequired = 1;
    [profileImageView addGestureRecognizer:tap];
    
    //y = y+10;
    UILabel *profileNameLabel = [[UILabel alloc] init];
    profileNameLabel.backgroundColor = [UIColor clearColor];
    profileNameLabel.textColor = [UIColor blackColor];
    profileNameLabel.frame = CGRectMake(74*width1/320, yy+10, 250, 30);
    profileNameLabel.textAlignment = NSTextAlignmentLeft;
    profileNameLabel.font = [UIFont boldSystemFontOfSize:width1/17];
    profileNameLabel.text = profileName;
    [self.scrollView addSubview:profileNameLabel];
    yy=yy+65*width1/320;
}
//Slider button Action
-(void)sliderButtonClicked{
    CGFloat x = self.composerView.frame.origin.x;
    // NSLog(@"x==%f",x);
    if (x==55 || x<150) {
        [UIView animateWithDuration:.50 animations:^{
            self.composerView.frame = CGRectMake(width1-4, 55*height1/480, 265*width1/320, self.composerView.bounds.size.height);
            self.sliderButton.frame = CGRectMake(width1-13, 160*height1/480, 13, 30);
            [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"left_slide.png"] forState:UIControlStateNormal];
        }];
    }
    else{
        [UIView animateWithDuration:.50 animations:^{
            self.composerView.frame = CGRectMake(65*width1/320, 55*height1/480, 265*width1/320, self.composerView.bounds.size.height);
            self.sliderButton.frame = CGRectMake(65*width1/320, 160*height1/480, 13, 30);
            [self.sliderButton setBackgroundImage:[UIImage imageNamed:@"right_slide.png"] forState:UIControlStateNormal];
        }];
    }
}
//Gesture Recognizer method for handle touch on Prodile image view
// if tapped imageview alpha value in 1 than reduce to 0.4
//and alpha value is 0.4 increase to 1
-(void) handleTapGesture:(id)sender{
    UIView *v = (UIControl *)sender;
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)v;
    UIImageView *img = (UIImageView *)tap.view;
    NSDictionary *dict = [self.allConnectcedAccountArray objectAtIndex:img.tag];
    ///-----------------------------------------
    // if alpha value 1 reduce to 0.4 and revoce from selected Account array and increase alpha value to 1 and add to selected Account array
    //------------------------------------------
    if (img.alpha==.4f) {
        if (selectionCount!=1) {
            img.alpha = 1.0f;
            selectionCount = selectionCount -1;
            if ([self.selectedAccount containsObject:dict]) {
                [self.selectedAccount removeObject:dict];
                NSString *accType2 = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
                if ([accType2 isEqualToString:@"twitter"] || [accType2 isEqualToString:@"linkedin"]) {
                    selectedTwitterAccCount = selectedTwitterAccCount-1;
                }
            }
        }
    }
    else{
        img.alpha = .4f;
        selectionCount = selectionCount+1;
        NSDictionary *dict = [self.allConnectcedAccountArray objectAtIndex:img.tag];
        [self.selectedAccount addObject:dict];
        
        NSString *accType2 = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
        if ([accType2 isEqualToString:@"twitter"] || [accType2 isEqualToString:@"linkedin"]) {
            selectedTwitterAccCount = selectedTwitterAccCount+1;
        }
    }
    //--------------------------------------------
    //set limit for message
    // if any twitter/linkedin account is selected Character count must be 140 either facebook account selected too
    //if only facebook account selected(not any twitter and linkedin account character count limit will be 5000)
    //-----------------------------------------
    if (selectedTwitterAccCount==0) {
        messageCharacterCount = (int)(5000-self.messageTextView.text.length);
    }
    else{
        messageCharacterCount = (int)(140-self.messageTextView.text.length);
    }
    self.characterCountLable.text = [NSString stringWithFormat:@"%d",messageCharacterCount];
}
#pragma mark -
//Cancel button Action
- (IBAction) cancelButtonAction: (id) sender{
    
    if ([self.messageTextView.text isEqualToString:@""]) {
        [self.messageTextView resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        NSLog(@"Display Action Sheet");
        
        if (!self.actionSheet) {
            //cancelMsg
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] destructiveButtonTitle:nil otherButtonTitles:@"Save Draft",@"Delete Message", nil];
            self.actionSheet.tag = 1;
            self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        }
        
        [self.actionSheet showInView:self.view];
        
    }
}
//Send Button Action
- (IBAction) sendButtonAction :(id) sender{
    NSLog(@"Message Character = %d",messageCharacterCount);
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        //NSString *msg1=[NSString stringWithFormat:@"%@",accExpiremsg];
        
       UIAlertView *myalert= [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myalert show];
         [self performSelector:@selector(dismissAlertView2:) withObject:myalert afterDelay:2.0];
        return;
    }
    //----------------------------------
    
    if ((messageCharacterCount==140)&&([self.imageAttachedValue isEqualToString:@"0"])) {
        UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"plzComposeMsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
        [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];

    }
    else if (messageCharacterCount <0){
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"tooManyChars"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
        [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];

    }
    //message schedule save message as a scheduled message
    else if (isMessageScheduled==YES){
        NSLog(@"Message Schedule");
        [self saveScheduleMessage];
    }
    else{
        NSLog(@"Selected Account = %d",selectionCount);
        NSLog(@"Selected Account Info = %@",self.selectedAccount);
        //Post message on selected account
        [self postMessages];
        
    }
    return;
}
#pragma mark -
-(void) postMessages{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    NSMutableString *messageString = [[NSMutableString alloc] init];
    BOOL status = YES;
    int acc_count = 0;
    
    @try {
        //Fetch Selected Account
        for (int i=0; i<self.selectedAccount.count; i++) {
            
            NSMutableDictionary *dict = [self.selectedAccount objectAtIndex:i];
            NSString *acctype =[NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
            
            [dict setObject:self.imageAttachedValue forKey:@"ImageAttachValue"];
            [dict setObject:self.messageTextView.text forKey:@"ComposedMessage"];
            //if image atached add image to Data dict
            if ([self.imageAttachedValue isEqualToString:@"1"]) {
                [dict setObject:self.selectedImageView.image forKey:@"SelectedImage"];
            }
            NSMutableDictionary *postResponse = nil;
            
            //PostClassHelper *post = [[PostClassHelper alloc]init];
            // pass datadict to PostClassHelper for post to Social site
            if ([acctype isEqualToString:@"facebook"]) {
                NSLog(@"Get facebook details");
                //pass datadict for facebook post
                //postResponse = [post getFaceBookUserDetails:dict];
                NSLog(@"Post Dic==%@",postResponse);
                NSString *check=[self composeFacebookMessage:dict];
                // NSString *check = [NSString stringWithFormat:@" %@",[postResponse objectForKey:@"MessageId"]];
                //Check response after facebook post
                
                if ([check isEqualToString:@"success"]) {
                    NSLog(@" post on facebook");
                }
                else{
                    status = NO;
                    acc_count = acc_count + 1;
                    [messageString appendString:[NSString stringWithFormat:@" %@",[dict objectForKey:@"ProfileName"]]];
                }

                
                
            }//End block of check facebook account
            else if ([acctype isEqualToString:@"twitter"]){
                NSLog(@"Get Twitter Details");
                //pass datadict for twitter post
                //NSString *check = [post getTwitterUserDeatails:dict];
                NSString *check=[self composeTwitterMessage:dict];
                //Check response after twitter post
                if ([check isEqualToString:@"success"]) {
                    NSLog(@" post on twitter");
                }
                else{
                    status = NO;
                    acc_count = acc_count + 1;
                    [messageString appendString:[NSString stringWithFormat:@" %@",[dict objectForKey:@"ProfileName"]]];
                }
                
            }
            else if ([acctype isEqualToString:@"linkedin"]){
                NSLog(@"Get Linkdin Details");
                //pass datadict for Linkedin post
                NSString *check =  [self composeLinkedinMessage:dict];
                //Check response after Linkedin post
                if ([check isEqualToString:@"success"]) {
                    NSLog(@"Error to post on Linkedin");
                }
                else{
                    status = NO;
                    acc_count = acc_count + 1;
                    [messageString appendString:[NSString stringWithFormat:@" %@",[dict objectForKey:@"ProfileName"]]];
                }
            }
            else if ([acctype isEqualToString:@"tumblr"]){
                // NSLog(@"Get Linkdin Details");
                //pass datadict for Linkedin post
                NSString *check =[self composeTumblrMessage:dict];
                //Check response after Linkedin post
                if ([check isEqualToString:@"success"]) {
                    // NSLog(@"Error to post on Linkedin");
                }
                else{
                    status = NO;
                    acc_count = acc_count + 1;
                    [messageString appendString:[NSString stringWithFormat:@" %@",[dict objectForKey:@"ProfileName"]]];
                }
            }
            
            else{
                //[[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"unknown account"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"unknownAcc"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
                [alertView show];
                [self performSelector:@selector(dismissAlertView2:) withObject:alertView afterDelay:2.0];
                
                [self.HUD hide:YES];
                
                return;
            }
        }//End of For Loop
        
        
        
        if (status==NO) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"SorryMsg"] message:[NSString stringWithFormat:@"%@ %d %@ %@",[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"yourMsgNotPosted"],acc_count,[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accountsMsg"],messageString] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView2:) withObject:alertView afterDelay:2.0];
        }
        else{
            //
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"successMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"msgPosted"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView2:) withObject:alertView afterDelay:2.0];
        }
        //if message is in draft than delete after post
        if (self.isDraftMessages==YES) {
            [self deleteDraftMessage];
        }
        //Reset Compose message view
        messageCharacterCount = (int)(messageCharacterCount + self.messageTextView.text.length);
        self.messageTextView.text = @"";
        if ([self.imageAttachedValue isEqualToString:@"1"]) {
            self.imageAttachedValue = @"0";
            self.selectedImageView.image=nil;
        }
        self.characterCountLable.text = [NSString stringWithFormat:@"%d",messageCharacterCount];
        
        [self.HUD hide:YES];
        return;
    }
    @catch (NSException *exception) {
        [self.HUD hide:YES];
        NSString *str  = [NSString stringWithFormat:@"%@",exception];
        NSLog(@"Str == %@",str);
    }
    @finally {
        //[self.HUD hide:YES];
        NSLog(@"Finally Block");
    }
    
    
}



#pragma mark-
#pragma mark  compose message

-(NSString*)composeTumblrMessage:(NSMutableDictionary *)dataDict{
    NSString *returnString;
    NSString *TumblrID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSLog(@"%@",TumblrID);
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"%@",strUserid);
    NSString *masg=[dataDict objectForKey:@"ComposedMessage"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@",currentDate);
    
    NSString *picUrl = @"";
    if ([self.imageAttachedValue isEqualToString:@"1"]) {
        picUrl = [self scheduleImageUpload];
        if ([picUrl isEqualToString:@"error"]) {
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [myAlert show];
             [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];
        }
    }
    NSLog(@"%@",picUrl);
    NSString *strSoapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                "<soap:Body>\n"
                                "<TumblrComposeMessage xmlns=\"http://tempuri.org/\">\n"
                                "<message>%@</message>\n"
                                "<profileid>%@</profileid>\n"
                                "<userid>%@</userid>\n"
                                "<currentdatetime>%@</currentdatetime>\n"
                                "<picurl>%@</picurl>\n"
                                "</TumblrComposeMessage>\n"
                                "</soap:Body>\n"
                                "</soap:Envelope>\n",masg,TumblrID,strUserid,currentDate,picUrl];
    
    NSLog(@"Soap Mesage = %@",strSoapMessage);
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/Services/Tumblr.asmx?op=TumblrComposeMessage",WebLink];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[strSoapMessage length]];
    [urlReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlReq addValue:@"http://tempuri.org/TumblrComposeMessage" forHTTPHeaderField:@"SOAPAction"];
    [urlReq addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[strSoapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSLog(@"%@",msglength);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString=@"error";
    }
    else{
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response string tumbler %@",responseString);
        NSString *response=[HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        returnString=@"success";
        NSLog(@"=========================================================%@",response);
        //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Message " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
    }
    return returnString;
    
}
#pragma mark -

-(NSString*)composeTwitterMessage:(NSMutableDictionary *)dataDict{
    NSString *returnString;
    NSString *TumblrID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSLog(@"%@",TumblrID);
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"%@",strUserid);
    NSString *masg=[dataDict objectForKey:@"ComposedMessage"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@",currentDate);
    
    NSString *picUrl = @"";
    if ([self.imageAttachedValue isEqualToString:@"1"]) {
        picUrl = [self scheduleImageUpload];
        if ([picUrl isEqualToString:@"error"]) {
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [ myAlert show];
             [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];
        }
    }
    NSString *strSoapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                "<soap:Body>\n"
                                "<TwitterComposeMessage xmlns=\"http://tempuri.org/\">\n"
                                "<message>%@</message>\n"
                                "<profileid>%@</profileid>\n"
                                "<userid>%@</userid>\n"
                                "<currentdatetime>%@</currentdatetime>\n"
                                "<picurl>%@</picurl>\n"
                                "</TwitterComposeMessage>\n"
                                "</soap:Body>\n"
                                "</soap:Envelope>\n",masg,TumblrID,strUserid,currentDate,picUrl];
    
    // NSLog(@"Soap Mesage = %@",strSoapMessage);
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/Services/Twitter.asmx?op=TwitterComposeMessage",WebLink];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[strSoapMessage length]];
    [urlReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlReq addValue:@"http://tempuri.org/TwitterComposeMessage" forHTTPHeaderField:@"SOAPAction"];
    [urlReq addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[strSoapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSLog(@"%@",msglength);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString=@"error";
    }
    else{
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response string twitter %@",responseString);
        NSString *response=[HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        returnString=@"success";
        NSLog(@"=========================================================%@",response);
        //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Message " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
    }
    return returnString;
    
}



-(NSString*)composeFacebookMessage:(NSMutableDictionary *)dataDict{
    NSString *returnString;
    NSString *FacebookID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSLog(@"%@",FacebookID);
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"%@",strUserid);
    NSString *masg=[dataDict objectForKey:@"ComposedMessage"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@",currentDate);
    
    NSString *picUrl = @"";
    if ([self.imageAttachedValue isEqualToString:@"1"]) {
        picUrl = [self scheduleImageUpload];
        if ([picUrl isEqualToString:@"error"]) {
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [myAlert show];
             [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];
        }
    }
    NSLog(@"%@",picUrl);
    NSString *strSoapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                "<soap:Body>\n"
                                "<FacebookComposeMessage xmlns=\"http://tempuri.org/\">\n"
                                "<message>%@</message>\n"
                                "<profileid>%@</profileid>\n"
                                "<userid>%@</userid>\n"
                                "<currentdatetime>%@</currentdatetime>\n"
                                "<picurl>%@</picurl>\n"
                                "</FacebookComposeMessage>\n"
                                "</soap:Body>\n"
                                "</soap:Envelope>\n",masg,FacebookID,strUserid,currentDate,picUrl];
    
    // NSLog(@"Soap Mesage = %@",strSoapMessage);
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/Services/Facebook.asmx?op=FacebookComposeMessage",WebLink];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[strSoapMessage length]];
    [urlReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlReq addValue:@"http://tempuri.org/FacebookComposeMessage" forHTTPHeaderField:@"SOAPAction"];
    [urlReq addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[strSoapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSLog(@"%@",msglength);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString=@"error";
    }
    else{
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response string Facebook %@",responseString);
        NSString *response=[HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        returnString=@"success";
        NSLog(@"=========================================================%@",response);
        //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Message " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
    }
    return returnString;
    
}




-(NSString*)composeLinkedinMessage:(NSMutableDictionary *)dataDict{
    NSString *returnString;
    NSString *LinkedinID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSLog(@"%@",LinkedinID);
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"%@",strUserid);
    NSString *masg=[dataDict objectForKey:@"ComposedMessage"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@",currentDate);
    
    NSString *picUrl = @"";
    if ([self.imageAttachedValue isEqualToString:@"1"]) {
        picUrl = [self scheduleImageUpload];
        if ([picUrl isEqualToString:@"error"]) {
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [myAlert show];
             [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];
        }
    }
    NSString *strSoapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                "<soap:Body>\n"
                                "<LinkedinComposeMessage xmlns=\"http://tempuri.org/\">\n"
                                "<message>%@</message>\n"
                                "<profileid>%@</profileid>\n"
                                "<userid>%@</userid>\n"
                                "<currentdatetime>%@</currentdatetime>\n"
                                "<picurl>%@</picurl>\n"
                                "</LinkedinComposeMessage>\n"
                                "</soap:Body>\n"
                                "</soap:Envelope>\n",masg,LinkedinID,strUserid,currentDate,picUrl];
    
    // NSLog(@"Soap Mesage = %@",strSoapMessage);
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/Services/Linkedin.asmx?op=LinkedinComposeMessage",WebLink];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[strSoapMessage length]];
    [urlReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlReq addValue:@"http://tempuri.org/LinkedinComposeMessage" forHTTPHeaderField:@"SOAPAction"];
    [urlReq addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[strSoapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSLog(@"%@",msglength);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString=@"error";
    }
    else{
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response string Linkedin %@",responseString);
        NSString *response=[HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSLog(@"---->%@",response);
        
        returnString=@"success";
        //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Message " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
    }
    return returnString;
    
}






#pragma mark -
#pragma mark Buttons Action
//Camera button Action
//Display Photo Album
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
    //get selected image
    UIImage *selImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.selectedImageView) {
        self.selectedImageView.image =selImage ;
    }
    else{
        self.selectedImageView = [[UIImageView alloc] initWithImage:selImage];
        self.selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.selectedImageView.frame = self.composerView.bounds;
        self.selectedImageView.alpha=0.24;
        [self.composerView insertSubview:self.selectedImageView atIndex:0];
    }
    self.selectedImageView.backgroundColor = [UIColor colorWithPatternImage:selImage];
    self.imageAttachedValue = @"1";
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark Actionsheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag==1) {
        if (buttonIndex==0) {
            NSLog(@"Save Draft");
            
            //Check is message already in draft
            if (self.isDraftMessages==YES) {
                NSString *preMessage = [NSString stringWithFormat:@"%@",[self.draftDict objectForKey:@"Message"]];
                //update draft message
                if (![preMessage isEqualToString:self.messageTextView.text]) {
                    [self updateDraftMessage];
                }// End if block update call
                
            }// End if block check draft message
            else{
                //add message to draft
                [self addToDraft];
            }//Else block Add to Draft
            [self dismissViewControllerAnimated:YES completion:nil];
        }//End if block button index 0
        else if(buttonIndex==1){
            NSLog(@"Delete Message");
            if (self.isDraftMessages==YES) {
                //if message is in draft after post delete that message from draft
                [self deleteDraftMessage];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }//Button index 1
        else{
            NSLog(@"Cancel");
        }
    }
}
-(void) dismissAlertView2:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark -
//Add new method to draft
-(void) addToDraft{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    NSString *mes = self.messageTextView.text;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    NSString *userID = [SingletonClass sharedSingleton].profileID;
    
    @try {
        //Prepare SOAP body message
        NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                                  <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><AddDraft xmlns=\"http://tempuri.org/\"><UserId>%@</UserId><CreatedDate>%@</CreatedDate><ModifiedDate>%@</ModifiedDate><Message>%@</Message></AddDraft></soap:Body></soap:Envelope>",userID,currentDate,currentDate,mes];
        NSLog(@"Soap Message ==%@",soapmessages);
        
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/Drafts.asmx?op=AddDraft",WebLink];
        //Prepare a request
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        [req addValue:@"http://tempuri.org/AddDraft" forHTTPHeaderField:@"SOAPAction"];
        
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"%@",msglength);
        
        //send request
        BOOL check = [self sendRequest:req];
        //check status
        if (check==YES) {
            //if yes, update draft message
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Update Draft Message" object:nil];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"msgSavedtoDraft"] delegate:nil cancelButtonTitle:@" " otherButtonTitles:nil, nil] ;
            [alertView show];
            [self performSelector:@selector(dismissAlertView2:) withObject:alertView afterDelay:2.0];
            
        }
        else{
            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [myAlert show];
            [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];

        }
        [self.HUD hide:YES];
    }
    @catch (NSException *exception) {
        [self.HUD hide:YES];
        NSString *ecx = [NSString stringWithFormat:@"%@",exception];
        NSLog(@"Exc == %@",ecx);
    }
    @finally {
        //[self.HUD hide:YES];
        NSLog(@"Finally Block");
    }
    
    
    
}
//Update draft message and also update selected draft data dict
-(void) updateDraftMessage{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    NSString *mesId = [NSString stringWithFormat:@"%@",[self.draftDict objectForKey:@"Id"]];
    NSString *mes = self.messageTextView.text;
    
    @try {
        NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                                  <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                                  <soap:Body>\
                                  <UpdateDrafts xmlns=\"http://tempuri.org/\">\
                                  <Id>%@</Id>\
                                  <message>%@</message>\
                                  </UpdateDrafts>\
                                  </soap:Body>\
                                  </soap:Envelope>",mesId,mes];
        NSLog(@"Soap Message ==%@",soapmessages);
        
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/Drafts.asmx?op=UpdateDrafts",WebLink];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/UpdateDrafts" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"%@",msglength);
        
        BOOL check = [self sendRequest:req];
        
        if (check==YES) {
            //Updated selected draft data dict
            [self.draftDict setObject:self.messageTextView.text forKey:@"Message"];
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateSelectedDraftMessage:)]) {
                [self.delegate updateSelectedDraftMessage:self.draftDict];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"msgSavedtoDraft"] delegate:nil cancelButtonTitle:@" " otherButtonTitles:nil, nil] ;
            [alertView show];
            [self performSelector:@selector(dismissAlertView2:) withObject:alertView afterDelay:2.0];
        }
        else{
            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
           [myAlert show];
             [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];
        }
        [self.HUD hide:YES];
    }
    @catch (NSException *exception) {
        [self.HUD hide:YES];
        NSString *str = [NSString stringWithFormat:@"%@",exception];
        NSLog(@"Exception = %@",str);
    }
    @finally {
        //[self.HUD hide:YES];
        NSLog(@"Finally Block");
    }
    
    
}
//Delete draft message
-(void)deleteDraftMessage{
    NSString *mesID = [NSString stringWithFormat:@"%@",[self.draftDict objectForKey:@"Id"]];
    
    @try {
        NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                                  <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                                  <soap:Body>\
                                  <DeleteDrafts xmlns=\"http://tempuri.org/\">\
                                  <Id>%@</Id>\
                                  </DeleteDrafts>\
                                  </soap:Body>\
                                  </soap:Envelope>",mesID];
        NSLog(@"Soap Message ==%@",soapmessages);
        
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/Drafts.asmx?op=DeleteDrafts",WebLink];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/DeleteDrafts" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"%@",msglength);
        
        BOOL check = [self sendRequest:req];
        if (check==YES) {
            //remove selected message from draft message
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(removeDeletedDraftMessage:)]) {
                [self.delegate removeDeletedDraftMessage:self.draftDict];
            }
            
        }
        
        [self.HUD hide:YES];
    }
    @catch (NSException *exception) {
        [self.HUD hide:YES];
        NSString * str = [NSString stringWithFormat:@"%@",exception];
        NSLog(@"Exception = %@",str);
    }
    @finally {
        //[self.HUD hide:YES];
        NSLog(@"Finally Block");
    }
    
    
}
//Make url connected with received url request
-(BOOL) sendRequest:(NSMutableURLRequest *)request{
    BOOL returnValue = NO;
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    @try {
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
            NSLog(@"Error == %@", error);
            
            returnValue = NO;
        }
        else{
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"Response String =%@", responseString);
            if([responseString rangeOfString:@"Success"].location != NSNotFound || [responseString rangeOfString:@"<UpdateDraftsResult>1</UpdateDraftsResult>"].location != NSNotFound){
                returnValue = YES;
            }
            else if ([responseString rangeOfString:@"Failed"].location != NSNotFound || [responseString rangeOfString:@"<UpdateDraftsResult>0</UpdateDraftsResult>"].location != NSNotFound){
                returnValue = NO;
            }
        }
        return returnValue;
    }
    @catch (NSException *exception) {
        [self.HUD hide:YES];
        NSString *str= [NSString stringWithFormat:@"%@",exception];
        NSLog(@"Exception=%@",str);
    }
    @finally {
        //[self.HUD hide:YES];
        NSLog(@"Finally Block");
    }
    
}



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
            self.pickerView.frame = CGRectMake(0, hhh+(55*height1/480), width1,(height1-hhh-(55*height1/480)));
        }
        else{
            //ui for date picker
            self.pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, hhh+(55*height1/480), width1,(height1-hhh-(55*height1/480)))];
            [self.view addSubview:self.pickerView];
            self.pickerView.backgroundColor = [UIColor whiteColor];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = CGRectMake(0, 0, width1, 40);
            UIColor *firstColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)49/255 blue:(CGFloat)129/255 alpha:1.0];
            UIColor *lastColor =[UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)157/255 blue:(CGFloat)219/255 alpha:0.5];
            
            gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
            [self.pickerView.layer insertSublayer:gradient atIndex:0];
            
            self.pickerView.frame = CGRectMake(0,  hhh+(55*height1/480), width1,(height1-hhh-(55*height1/480)));
            //-----------------------------------------------
            //Add Send Button
            UIButton *setTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            setTimeButton.frame = CGRectMake(250*width1/320, 7, 60*width1/320, 27);
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
            
            
            //----------------------------------------------
            //Add Cancel Button
            UIButton *cancelTimer = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelTimer.frame = CGRectMake(10, 7, 60*width1/320, 27);
            [cancelTimer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cancelTimer.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
            [cancelTimer addTarget:self action:@selector(hidePickerView:) forControlEvents:UIControlEventTouchUpInside];
            cancelTimer.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
            cancelTimer.layer.borderWidth=1.0f;
            cancelTimer.layer.borderColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)55/255 blue:(CGFloat)136/255 alpha:1].CGColor;
            cancelTimer.layer.cornerRadius = 5.0f;
            cancelTimer.clipsToBounds = YES;
            
            [cancelTimer setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] forState:UIControlStateNormal];
            [self.pickerView addSubview:cancelTimer];
            
            
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40,width1,(195*height1/480)-40)];
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            self.datePicker.minimumDate = [NSDate date];
            
            [self.pickerView addSubview:self.datePicker];
            
        }
    }];
    
    
}
//selecte date
-(void) selectedDate: (id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
    
    isMessageScheduled = YES;
    
    self.scheduledDate = [formatter stringFromDate:[self.datePicker date]];
    NSLog(@"Picked the date %@",self.scheduledDate);
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
#pragma mark TextView Delegate
-(void) textViewDidBeginEditing:(UITextView *)textView{
    if (self.pickerView) {
        [self hidePickerView:nil];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
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



#pragma mark -
#pragma mark Schedule Message
//upload image if selected
-(NSString *)scheduleImageUpload{
    
    NSString *returnString = nil;
    // NSString *randomString = [self dateString];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy MM dd hh mm"];
    
    
    NSString *fileN = [NSString stringWithFormat:@"%@.jpeg",[formatter stringFromDate:[NSDate date]]];
    fileN = [fileN stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    UIImage *sel_image = self.selectedImageView.image;
    NSData *imageData = UIImageJPEGRepresentation(sel_image, .5);
    NSUInteger len = [imageData length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [imageData bytes], len);
    
    NSString *byteArray  = [imageData base64EncodedString];
    
    NSString *strSoapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                "<soap:Body>\n"
                                "<UploadFile xmlns=\"http://tempuri.org/\">\n"
                                "<f>%@</f>\n"
                                "<fileName>%@</fileName>\n"
                                "</UploadFile>\n"
                                "</soap:Body>\n"
                                "</soap:Envelope>\n",byteArray,fileN];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/Services/ScheduledMessage.asmx?op=UploadFile",WebLink];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[strSoapMessage length]];
    [urlReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlReq addValue:@"http://tempuri.org/UploadFile" forHTTPHeaderField:@"SOAPAction"];
    [urlReq addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[strSoapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSLog(@"%@",msglength);
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString = @"error";
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Response String send to schedule =--= %@",responseString);
        NSString *strUrl = [HelperClass stripTags:responseString startString:@"<UploadFileResult>" upToString:@"</UploadFileResult>"];
        
        strUrl = [strUrl substringWithRange:NSMakeRange(18, [strUrl length]-18)];
        returnString = strUrl;
        
        
    }
    return returnString;
}
//Save message as Schedule message
-(void) saveScheduleMessage{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    NSString *picUrl = @"";
    //check if image selected
    if ([self.imageAttachedValue isEqualToString:@"1"]) {
        picUrl = [self scheduleImageUpload];
        if ([picUrl isEqualToString:@"error"]) {
            UIAlertView *myAlert= [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
           [myAlert show];
             [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];
        }
    }
    
    NSString *message = self.messageTextView.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    NSMutableString *detailsStr = [[NSMutableString alloc] init];
    for(int i=0; i<self.selectedAccount.count;i++){
        NSDictionary *dict = [self.selectedAccount objectAtIndex:i];
        NSString *acctype =[NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
        NSString *accID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileId"]];
        if (i==self.selectedAccount.count-1) {
            [detailsStr appendString:[NSString stringWithFormat:@"%@,%@",acctype,accID]];
        }
        else{
            [detailsStr appendString:[NSString stringWithFormat:@"%@,%@,",acctype,accID]];
        }
    }
    BOOL boolValue = FALSE;
    NSString *proId = [SingletonClass sharedSingleton].profileID;
    //prepare soap message for
    NSString *strSoapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                "<soap:Body>\n"
                                "<ADDScheduledMessage xmlns=\"http://tempuri.org/\">\n"
                                "<typeandid>%@</typeandid>\n"
                                "<ShareMessage>%@</ShareMessage>\n"
                                "<ClientTime>%@</ClientTime>\n"
                                "<ScheduleTime>%@</ScheduleTime>\n"
                                "<Status>%hhd</Status>\n"
                                "<UserId>%@</UserId>\n"
                                "<PicUrl>%@</PicUrl>\n"
                                "<CreateTime>%@</CreateTime>\n"
                                "</ADDScheduledMessage>\n"
                                "</soap:Body>\n"
                                "</soap:Envelope>\n",detailsStr,message,currentDate,self.scheduledDate,boolValue,proId,picUrl,currentDate];
    NSLog(@"Soap Mesage = %@",strSoapMessage);
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/Services/ScheduledMessage.asmx?op=ADDScheduledMessage",WebLink];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[strSoapMessage length]];
    [urlReq addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlReq addValue:@"http://tempuri.org/ADDScheduledMessage" forHTTPHeaderField:@"SOAPAction"];
    [urlReq addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[strSoapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSLog(@"%@",msglength);
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:urlReq returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Response String send to schedule =--= %@",responseString);
        //if message is in draft deleted from Draft message
        if (self.isDraftMessages == YES) {
            [self deleteDraftMessage];
        }
        //reset composer view
        messageCharacterCount = (int)(messageCharacterCount + self.messageTextView.text.length);
        self.messageTextView.text = @"";
        if ([self.imageAttachedValue isEqualToString:@"1"]) {
            self.imageAttachedValue = @"0";
            self.selectedImageView.image=nil;
        }
        isMessageScheduled = NO;
        self.characterCountLable.text = [NSString stringWithFormat:@"%d",messageCharacterCount];
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"urMsgRescheduled"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
       [myAlert show];
         [self performSelector:@selector(dismissAlertView2:) withObject:myAlert afterDelay:2.0];
        //pass notification for add new scheduled message
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddNewScheduleMessage" object:nil];
    }
    
    [self.HUD hide:YES];
}
@end
