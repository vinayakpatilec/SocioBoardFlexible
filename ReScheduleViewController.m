//
//  ReScheduleViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 14/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "ReScheduleViewController.h"
#import "SingletonClass.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "HelperClass.h"
#import "HelperClass.h"
#import "MBProgressHUD.h"
#import "NSData+Base64.h"

@interface ReScheduleViewController ()<MBProgressHUDDelegate>{
    int width1;
    int height1;
    CGRect screenRect;

}
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ReScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.messageTextView becomeFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageAttachedValue = @"0";
    isMessagere_Scheduled = NO;
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    
    //Creating UI
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 55*height1/480)];
    //self.TopView.backgroundColor = [UIColor blackColor];
    self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
    [self.view addSubview:self.headerView];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    
    //[self.headerView.layer insertSublayer:gradient atIndex:0];
    //-------------------------------------------------
    self.titlelable = [[UILabel alloc] initWithFrame:CGRectMake(width1/2-110, 20*height1/480, 200, 30)];
    self.titlelable.backgroundColor = [UIColor clearColor];
    self.titlelable.textAlignment = NSTextAlignmentCenter;
    self.titlelable.textColor = [UIColor whiteColor];
    self.titlelable.font=[UIFont systemFontOfSize:width1/20];
    self.titlelable.text = @"Reschedule Message";
    [self.headerView addSubview:self.titlelable];
    
    //-------------------------------------------------
    //Add Cancel Button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(10, 15*height1/480, 35*height1/480, 30*height1/480);
    //[self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //self.cancelButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:width1/20];
    [self.cancelButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //self.cancelButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
    //self.cancelButton.layer.borderWidth=1.0f;
    //self.cancelButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
   // self.cancelButton.layer.cornerRadius = 5.0f;
    self.cancelButton.clipsToBounds = YES;
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    //[self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.headerView addSubview:self.cancelButton];
    
    
    //-----------------------------------------------
    //Add Send Button
    self.scheduleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.scheduleButton.frame = CGRectMake(width1-(80*width1/320), 20*height1/480, 70*width1/320, 25*height1/480);
    [self.scheduleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.scheduleButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:width1/20];
    [self.scheduleButton addTarget:self action:@selector(scheduleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.scheduleButton.layer.backgroundColor=[UIColor whiteColor].CGColor;
    self.scheduleButton.layer.borderWidth=1.0f;
    self.scheduleButton.layer.borderColor = [UIColor redColor].CGColor;
    self.scheduleButton.layer.cornerRadius = 5.0*width1/320;
    self.scheduleButton.clipsToBounds = YES;
    
    [self.scheduleButton setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"scheduleMsg"] forState:UIControlStateNormal];
    [self.headerView addSubview:self.scheduleButton];
    
    count = 0;
    self.allConnectcedAccountArray = [[NSMutableArray alloc] init];
    
    //Fetch All Connect Account
    NSArray *tempArray =[SingletonClass sharedSingleton].connectedprofileInfo;
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"ProfileType" ascending:NO];
    NSArray *descriptors=[NSArray arrayWithObject: descriptor];
    NSArray *sortedArray=(NSMutableArray *)[tempArray sortedArrayUsingDescriptors:descriptors];
    //NSLog(@"Sorted Array==%@",sortedArray);
    
#pragma mark -
    //-------------------------------------------------------
    NSLog(@"%d",height1);
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
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 55*height1/480, width1, hhh)];
    
    [self.view addSubview:self.scrollView];
    
    //------------------------------------------------------
    NSLog(@"Selected Schedule Dict = %@",self.scheduleDict);
    NSString *str = [self.scheduleDict objectForKey:@"ProfileId"];
    for (int i=0; i<sortedArray.count; i++) {
        NSDictionary *dict = [sortedArray objectAtIndex:i];
        NSString *pro = [dict objectForKey:@"ProfileId"];
        NSString *proType = [dict objectForKey:@"ProfileType"];
        //Check Account type for selected account
        if ([pro isEqualToString:str]) {
            [self.allConnectcedAccountArray insertObject:dict atIndex:0];
            self.selectedAccDict = dict;
            NSString *accType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
            if ([accType isEqualToString:@"facebook"] || [accType isEqualToString:@"googleplus"]||[accType isEqualToString:@"tumblr"]||[accType isEqualToString:@"instagram"]){
                messageCharacterCount = 5000;
            }
            else if ([accType isEqualToString:@"linkedin"] || [accType isEqualToString:@"twitter"]){
                messageCharacterCount = 140;
            }
        }
        else if([proType isEqualToString:@"facebook"] || [proType isEqualToString:@"twitter"] || [proType isEqualToString:@"linkedin"]||[proType isEqualToString:@"tumblr"]||[proType isEqualToString:@"instagram"]){
            [self.allConnectcedAccountArray addObject:dict];
        }
    }
    if (messageCharacterCount==0) {
        messageCharacterCount = 140;
    }
    
    //Adding Icon with Account
    for (int i =0; i<self.allConnectcedAccountArray.count; i++) {
        NSDictionary *dict =[self.allConnectcedAccountArray objectAtIndex:i];
        NSString *accType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
        UIImageView *profileImageView= nil;
        NSString *imageName = nil;
        if ([accType isEqualToString:@"facebook"]) {
            imageName = @"facebook1.png";
            
            
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count +1;
        }
        else if ([accType isEqualToString:@"twitter"]){
            imageName = @"twitter1.png";
            
            
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
            
        }
        else if ([accType isEqualToString:@"linkedin"]){
            imageName = @"linkedin1.png";
            
            
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
        }
        else if ([accType isEqualToString:@"tumblr"]){
            imageName = @"tumblr1.png";
            
            
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
        }
        else if ([accType isEqualToString:@"instagram"]){
            imageName = @"instagram1.png";
            
            
            [self displayImageView:profileImageView count:i accountImageName:imageName];
            count = count + 1;
        }
        else if ([accType isEqualToString:@"googleplus"]){
            
            NSLog(@"Google Plus Account");
            
        }
        else{
            NSLog(@"Instagram Account");
            
        }
    }
    
    //--------------------------------------------------
    
    [self.scrollView setContentSize:CGSizeMake(width1, yy)];
    //--------------------
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = CGRectMake(0, 0, width1, yy);
    
    
    UIColor *lastColor2 =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)255/255 blue:(CGFloat)255/255 alpha:1.0];
    gradient2.colors = [NSArray arrayWithObjects:(id)[lastColor2 CGColor], (id)[firstColor CGColor],(id)[lastColor2 CGColor], nil];
    
    [self.scrollView.layer insertSublayer:gradient2 atIndex:0];
    //--------------------
    
    
    //UI For Composer View
    self.composerView = [[UIView alloc] initWithFrame:CGRectMake(65*width1/320, 55*height1/480, 265*width1/320, hhh)];
    
    self.composerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.composerView];
    //-------------------------------------------------------
    self.borderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 5, hhh)];
    self.borderImageView.image = [UIImage imageNamed:@"side_divider.png"];
    [self.composerView addSubview:self.borderImageView];
    //---------------------------------------------------------
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 250*width1/320, hhh-50)];
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.delegate = self;
    self.messageTextView.font = [UIFont systemFontOfSize:width1/20];
    [self.composerView addSubview:self.messageTextView];
    
    self.messageTextView.text = [NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"ShareMessage"]];
    
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
    [self.schedulButton setBackgroundImage:[UIImage imageNamed:@"schedul_icon_done.png"] forState:UIControlStateNormal];
    [self.schedulButton addTarget:self action:@selector(displayDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.composerView addSubview:self.schedulButton];
    //----------------------------------------------------------
    self.characterCountLable = [[UILabel alloc] initWithFrame:CGRectMake(195*width1/320, hhh-40, 50*width1/320, 25*width1/320)];
    self.characterCountLable.textColor = [UIColor blackColor];
    self.characterCountLable.backgroundColor = [UIColor clearColor];
    self.characterCountLable.font=[UIFont systemFontOfSize:width1/16];
    self.characterCountLable.textAlignment = NSTextAlignmentCenter;
    [self.composerView addSubview:self.characterCountLable];
    
    self.characterCountLable.text = [NSString stringWithFormat:@"%lu",(messageCharacterCount - self.messageTextView.text.length)];
    
    [self.messageTextView becomeFirstResponder];
    
    NSString *image_str = [NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"PicUrl"]];
    if (image_str != nil || image_str.length >4) {
        
        self.selectedImageView = [[UIImageView alloc] init];
        self.selectedImageView.frame = self.composerView.bounds;
        self.selectedImageView.alpha=0.24;
        [self.composerView insertSubview:self.selectedImageView atIndex:0];
        [self.selectedImageView setImageWithURL:[NSURL URLWithString:image_str]];
        self.imageAttachedValue = @"1";
    }
    image_selected_new = NO;
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
//Display Activity Indicator
-(void) displayActivityIndicator{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.dimBackground=YES;
    self.hud.delegate=self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}
-(void)hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}
//Add Social network Icon to Profile Image View
-(void)displayImageView:(UIImageView *)profileImageView count:(int)i accountImageName:(NSString *)imageName{
    
    NSDictionary *dict =[self.allConnectcedAccountArray objectAtIndex:count];
    NSString *imageUrlString;
    NSString *proType = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
    if([proType isEqualToString:@"tumblr"]){
        imageUrlString = [NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@.tumblr.com/avatar",[dict objectForKey:@"ProfilePicUrl"]];
        NSLog(@"%@",imageUrlString);
    }
    else{
        imageUrlString= [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfilePicUrl"]];
    }
    
    
    NSString *profileName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileName"]];
    // CGFloat y = count*53;
    profileImageView = [[UIImageView alloc] init];
    profileImageView.frame = CGRectMake(0, yy,65*width1/320,65*width1/320);
    profileImageView.tag=count;
    profileImageView.userInteractionEnabled = YES;
    [profileImageView setImageWithURL:[NSURL URLWithString:imageUrlString]];
    if (count==0) {
        profileImageView.alpha = .4f;
        //preSelectedImageTag = profileImageView.tag;
        self.selectedProImageView = profileImageView;
        self.selectedProImageView.tag = count;
    }
    else{
        profileImageView.alpha = 1.0f;
    }
    
    [self.scrollView addSubview:profileImageView];
    
    UIImageView *accView=[[UIImageView alloc] initWithFrame:CGRectMake(48*width1/320, 40*height1/480, 16*width1/320, 16*width1/320)];
    accView.image = [UIImage imageNamed:imageName];
    [profileImageView addSubview:accView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTapsRequired = 1;
    [profileImageView addGestureRecognizer:tap];
    
    //y = y+10;
    UILabel *profileNameLabel = [[UILabel alloc] init];
    profileNameLabel.backgroundColor = [UIColor clearColor];
    profileNameLabel.textColor = [UIColor blackColor];
    profileNameLabel.frame = CGRectMake(74*width1/320, yy+10, 250, 30);
    profileNameLabel.textAlignment = NSTextAlignmentLeft;
    profileNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    profileNameLabel.text = profileName;
    [self.scrollView addSubview:profileNameLabel];
     yy=yy+63*width1/320;
}

//handle Tao Gesture Recogniser on Profile Image
// if alpha value == 1 than reduce to 0.4
//if alpha value == 0.4 than increase to 1
-(void) handleTapGesture:(id)sender{
    
    UIView *v = (UIControl *)sender;
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)v;
    UIImageView *img = (UIImageView *)tap.view;
    
    if (img.tag==self.selectedProImageView.tag) {
        return;
    }
    img.alpha = .4f;
    self.selectedProImageView.alpha = 1.0f;
    self.selectedProImageView = img;
    
    NSDictionary *dict = [self.allConnectcedAccountArray objectAtIndex:img.tag];
    self.selectedAccDict = dict;
    NSString *accType2 = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileType"]];
    //--------------------------------------------
    //set limit for message
    // if any twitter/linkedin account is selected Character count must be 140 either facebook account selected too
    //if only facebook account selected(not any twitter and linkedin account character count limit will be 5000)
    //-----------------------------------------
    
    if ([accType2 isEqualToString:@"twitter"] || [accType2 isEqualToString:@"linkedin"]) {
        messageCharacterCount = (int)(140-self.messageTextView.text.length);
    }
    else{
        messageCharacterCount = (int)(5000-self.messageTextView.text.length);
    }
    self.characterCountLable.text = [NSString stringWithFormat:@"%d",messageCharacterCount];
}
//back Button Action
-(void) backButtonClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
//Schedule button Action
-(void) scheduleButtonClicked{
    NSLog(@"Selected==%@",self.selectedAccDict);
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    
    //Check message
    if (self.messageTextView.text.length<1) {
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:@"Compose your message" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        return;
    }
    
    
    BOOL isUpdate=NO;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //check if new image selected
    if (image_selected_new == YES) {
        isUpdate = YES;
        NSLog(@"Upload new Image");
        NSString *uploaded_url = [self scheduleImageUpload];
        if ([uploaded_url isEqualToString:@"error"]) {
            NSLog(@"Error to upload image");
            return;
        }
        [dict setObject:uploaded_url forKey:@"PicUrl"];
        
    }
    else{
        [dict setObject:[NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"PicUrl"]] forKey:@"PicUrl"];
    }
    
    //check if  message reschedule
    if (isMessagere_Scheduled==YES) {
        isUpdate = YES;
        NSLog(@"New Date");
        [dict setObject:self.datePIckerDate forKey:@"ReScheduleDate"];
        [dict setObject:self.formattedDate forKey:@"ScheduleDate"];
        
    }
    else{
        NSString *scheduleDate = [NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"ScheduleDate"]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+5.30"]];
        [formatter setDateFormat:@"yyyy/MM/dd hh:mm a"];
        NSDate *date  = [formatter dateFromString:scheduleDate];
        NSLog(@"Date == %@",date);
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        scheduleDate = [formatter stringFromDate:date];
        
        [dict setObject:[self.scheduleDict objectForKey:@"ScheduleDate"] forKey:@"ScheduleDate"];
        
        [dict setObject:scheduleDate forKey:@"ReScheduleDate"];
        
        
    }
    
    NSString *preMes = [NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"ShareMessage"]];
    if ([preMes isEqualToString:self.messageTextView.text]) {
        NSLog(@"Message not change");
        [dict setObject:preMes forKey:@"ShareMessage"];
    }
    else{
        NSLog(@"Message  Change");
        [dict setObject:self.messageTextView.text forKey:@"ShareMessage"];
        isUpdate = YES;
    }
    
    NSString *preAccID=[NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"ProfileId"]];
    NSString *currAccID = [NSString stringWithFormat:@"%@",[self.selectedAccDict objectForKey:@"ProfileId"]];
    
    if ([preAccID isEqualToString:currAccID]) {
        NSLog(@"Previous Account Selected");
        [dict setObject:[NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"ProfileId"]] forKey:@"ProfileId"];
        [dict setObject:[NSString stringWithFormat:@"%@",[self.scheduleDict objectForKey:@"ProfileType"]] forKey:@"ProfileType"];
        
    }
    else{
        NSLog(@"Account changed");
        [dict setObject:[NSString stringWithFormat:@"%@",[self.selectedAccDict objectForKey:@"ProfileId"]] forKey:@"ProfileId"];
        [dict setObject:[NSString stringWithFormat:@"%@",[self.selectedAccDict objectForKey:@"ProfileType"]] forKey:@"ProfileType"];
        isUpdate = YES;
    }
    
    //if message update(any change found than re-schedule message)
    if (isUpdate==YES) {
        [self reScheduleMessage:dict];
        NSLog(@"Dict==%@",dict);
    }
    else{
        NSLog(@"No changes");
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"No Changes" message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
    }
}

//Call service for re-schedule message
-(void) reScheduleMessage:(NSMutableDictionary *)dataDict{
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    NSString *message  =[dataDict objectForKey:@"ShareMessage"];
    NSString *picUrl =  [dataDict objectForKey:@"PicUrl"];
    NSString *scheduledDate = [dataDict objectForKey:@"ReScheduleDate"];
    NSString *selectedAccID = [dataDict objectForKey:@"ProfileId"];
    NSString *accType = [dataDict objectForKey:@"ProfileType"];
    
    NSString *resultString = [NSString stringWithFormat:@"%@,%@,%@",accType,selectedAccID,[self.scheduleDict objectForKey:@"Id"]];
    
    
    //prepare shop message
    NSString *soapmessages = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                              <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                              <soap:Body>\
                              <UpdateScheduledMessage xmlns=\"http://tempuri.org/\">\
                              <typeidandmsgid>%@</typeidandmsgid>\
                              <ShareMessage>%@</ShareMessage>\
                              <scheduledTime>%@</scheduledTime>\
                              <picurl>%@</picurl>\
                              </UpdateScheduledMessage>\
                              </soap:Body>\
                              </soap:Envelope>",resultString,message,scheduledDate,picUrl];
    
    NSLog(@"Soap Message = %@", soapmessages);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/ScheduledMessage.asmx?op=UpdateScheduledMessage",WebLink];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessages length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/UpdateScheduledMessage" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessages dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        NSString *errorString = [NSString stringWithFormat:@"%@",error];
        if ([errorString rangeOfString:@"The request timed out"].location != NSNotFound) {
            UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"Eror" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"chectConnectionntry"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [myAlert show];
             [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        }
    }
    else{
        
        NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Reschedule Response = %@",str);
        str = nil;
        [dataDict setObject:[self.scheduleDict objectForKey:@"Id"] forKey:@"Id"];
        [dataDict setObject:[self.scheduleDict objectForKey:@"UserId"] forKey:@"UserId"];
        [dataDict setObject:self.selectedIndexPath forKey:@"SelectedIndexPath"];
        
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(updateScheduleTable:)]) {
            [self.delegate updateScheduleTable:dataDict];
        }
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"urMsgRescheduled"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"Update Schedule Table" object:nil];
    }
    [self.hud hide:YES];
    
}

//Upload image if selected
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
    
    NSString *strUrl = [NSString stringWithFormat:@"%@Services/ScheduledMessage.asmx?op=UploadFile",WebLink];
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
//convert unix timestamp to normal date formate
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
#pragma mark -
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

#pragma mark -
#pragma mark Buttons Action
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
    image_selected_new = YES;
    self.imageAttachedValue = @"1";
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Display Date Picker
//Display Date Picker
-(void) displayDatePicker:(id)sender{
    
    [UIView animateWithDuration:.5 animations:^{
        [self.messageTextView resignFirstResponder];
        if (self.datePicker) {
            self.datePicker.date = [NSDate date];
            self.pickerView.frame = CGRectMake(0, hhh+(55*height1/480), width1,height1-(hhh+(55*height1/480)));
        }
        else{
            //UI code for date Picker View
            self.pickerView = self.pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, hhh+(55*height1/480), width1,height1-(hhh+(55*height1/480)))];
            [self.view addSubview:self.pickerView];
            [self.view addSubview:self.pickerView];
            self.pickerView.backgroundColor = [UIColor whiteColor];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = CGRectMake(0, 0, width1, 40);
            UIColor *firstColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)49/255 blue:(CGFloat)129/255 alpha:1.0];
            UIColor *lastColor =[UIColor colorWithRed:(CGFloat)0/255 green:(CGFloat)157/255 blue:(CGFloat)219/255 alpha:0.5];
            
            gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
            [self.pickerView.layer insertSublayer:gradient atIndex:0];
            
            self.pickerView.frame = CGRectMake(0, hhh+(55*height1/480), width1,height1-(hhh+(55*height1/480)));
            //-----------------------------------------------
            //Add Send Button
            UIButton *setTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            setTimeButton.frame = CGRectMake(250*width1/320, 7, 60*width1/320, 27);
            [setTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            setTimeButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:width1/20];
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
            cancelTimer.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:width1/20];
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
-(void) selectedDate: (id)sender{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    isMessagere_Scheduled = YES;
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+5.30"]];
    //self.myLabel.text = [dateFormatter stringFromDate:[dueDatePickerView date]];
    self.datePIckerDate = [dateFormatter stringFromDate:[self.datePicker date]];
    NSLog(@"Picked the date %@",self.datePIckerDate);
    //[_formatter setDateFormat:@"MMM dd,yy hh:mm:ss a"];
    [dateFormatter setDateFormat:@"dd/MM/yy hh:mm a"];
    
    self.formattedDate = [dateFormatter stringFromDate:[self.datePicker date]];
    NSLog(@"Str==%@",self.formattedDate);
    
    
    
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
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (text.length == 0) {
        if (messageCharacterCount<140) {
            //messageCharacterCount = messageCharacterCount+1;
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
-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
