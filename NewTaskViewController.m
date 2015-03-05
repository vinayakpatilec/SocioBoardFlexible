//
//  NewTaskViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 22/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "NewTaskViewController.h"
#import "UIImageView+WebCache.h"
#import "SingletonClass.h"
#import "TaskCommentViewController.h"
#import "MBProgressHUD.h"


#define SocialAccountType @"SocileAccountType"
#define RefreshTask @"woosuiterefreshtask"
@interface NewTaskViewController ()<TaskCommentViewControllerDetegate, MBProgressHUDDelegate>
@property (nonatomic, strong) MBProgressHUD *HUD;
@end

@implementation NewTaskViewController

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"normalScreen.png"]];
    bgImageView.frame = CGRectMake(0, 0, width1, height1);
    //[self.view addSubview:bgImageView];
    //[self.view sendSubviewToBack:bgImageView];
    
    yy=0;
    
    //Get All Group IDs for logged in account
    
    
    self.view.backgroundColor=[UIColor whiteColor];

    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 50*height1/480)];
    self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
    [self.view addSubview:self.headerView];
    
    
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cancelButton.frame = CGRectMake(5, 15*height1/480, 35*height1/480, 30*height1/480);
    //[self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:width1/20];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor=[UIColor clearColor];
    //[self.cancelButton setBackgroundImage:self.profileImageView forState:UIControlStateNormal];
    //[self.cancelButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.headerView addSubview:self.cancelButton];
    //---------------------------------
    //Adding Title Label
    self.titlelable = [[UILabel alloc] initWithFrame:CGRectMake(60*width1/320,15*height1/480,200*width1/320, 27*height1/480)];
    self.titlelable.backgroundColor = [UIColor whiteColor];
    self.titlelable.textAlignment = NSTextAlignmentCenter;
    self.titlelable.clipsToBounds=YES;
    self.titlelable.layer.cornerRadius=5.0f;
    self.titlelable.layer.borderWidth=1.0f;
    self.titlelable.layer.borderColor=[UIColor redColor].CGColor;
    //self.titlelable.textColor = [UIColor colorWithRed:(CGFloat)160/255 green:(CGFloat)70/255 blue:(CGFloat)7/255 alpha:1];
    self.titlelable.textColor=[UIColor blackColor];
    self.titlelable.font=[UIFont boldSystemFontOfSize:width1/18];
    self.titlelable.text = @"New Task";
    [self.headerView addSubview:self.titlelable];
    //====================
    
    
    self.secondView = [[UIView alloc] initWithFrame:CGRectMake(10*width1/320, 65*height1/480,300*width1/320, 100*height1/480)];
    self.secondView.layer.backgroundColor = [UIColor clearColor].CGColor;
    [self.view addSubview:self.secondView];
    self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5*width1/320, 5*width1/320, 50*width1/320, 50*width1/320)];
    [self.secondView addSubview:self.profileImageView];
    
    self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(60*width1/320, 5*height1/480, 250*width1/320, 20*height1/480)];
    self.nameLable.textAlignment = NSTextAlignmentLeft;
    self.nameLable.backgroundColor = [UIColor clearColor];
    self.nameLable.font=[UIFont systemFontOfSize:width1/20];
    self.nameLable.textColor = [UIColor blackColor];
    [self.secondView addSubview:self.nameLable];
    
    self.messageLable = [[UILabel alloc] initWithFrame:CGRectMake(60*width1/320, 25*height1/480,250*width1/320, 50*height1/480)];
    self.messageLable.backgroundColor = [UIColor clearColor];
    self.messageLable.textColor = [UIColor blackColor];
    //self.messageLable.textAlignment = NSTextAlignmentLeft;
    self.messageLable.numberOfLines = 0;
    self.messageLable.font = [UIFont systemFontOfSize:width1/22];
    self.messageLable.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.secondView addSubview:self.messageLable];
    NSString *message = nil;
    NSString *urlString = nil;
    NSString *accTypeString = nil;
    //------------------------------------------------------
    NSString *accType = [[NSString alloc] initWithFormat:@"%@",[self.dataDict objectForKey:SocialAccountType]];
    
    if ([accType isEqualToString:@"Facebook"]) {
        message = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Message"]];
        self.nameLable.text  =[NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromName"]];
        urlString = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromProfileUrl"]];
        accTypeString = @"facebook_icon.png";
    }
    if ([accType isEqualToString:@"facebook"]) {
        message = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FeedDescription"]];
        self.nameLable.text  =[NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromName"]];
        urlString = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromProfileUrl"]];
        accTypeString = @"facebook_icon.png";
    }

    else if ([accType isEqualToString:@"Twitter"]){
        message = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"TwitterMsg"]];
        self.nameLable.text = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"ScreenName"]];
        urlString = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromProfileUrl"]];
        accTypeString = @"twitter_icon.png";
    }
    else if ([accType isEqualToString:@"Twitter_Feed"]){
        message = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Feed"]];
        self.nameLable.text = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"ScreenName"]];
        urlString = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromProfileUrl"]];
        accTypeString = @"twitter_icon.png";
    }
    else if ([accType isEqualToString:@"Linkedin"]){
        message = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Feeds"]];
        self.nameLable.text = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromName"]];
        urlString = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromPicUrl"]];
        //accTypeString = @"linkedin_icon.png";
    }
    else if ([accType isEqualToString:@"Google Plus"]){
        message = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Content"]];
        self.nameLable.text = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromUserName"]];
        urlString = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromProfileImage"]];
        accTypeString = @"google_plus.png";
          }
    else if([accType isEqualToString:@"Tumblr"]){
        self.nameLable.text = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromUserName"]];
        urlString = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"FromProfileImage"]];
        accTypeString=@"tumblr_icon.png";

        
    }
    [self.profileImageView setImageWithURL:[NSURL URLWithString:urlString]];
    UIImageView *accTypeImage = [[UIImageView alloc] initWithFrame:CGRectMake(25*width1/320,25*height1/480, 15*width1/320, 15*height1/480)];
    accTypeImage.image = [UIImage imageNamed:accTypeString];
    [self.profileImageView addSubview:accTypeImage];
    
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    //CGSize lblSize = [message sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(250,1000)];
    //self.messageLable.frame = CGRectMake(60, 25, 250, lblSize.height+5);
    self.messageLable.text = message;
    //NSLog(@"hhh===%f",lblSize.height);

 
    //------------------------------------------------
   
    _comment=[[UITextView alloc]initWithFrame:CGRectMake(10*width1/320, 180*height1/480, 300*width1/320, 70*height1/480)];
    _comment.backgroundColor=[UIColor whiteColor];
    _comment.textColor=[UIColor blackColor];
    _comment.layer.borderWidth=2.0f;
    _comment.layer.borderColor=[UIColor blackColor].CGColor;
    _comment.layer.shadowColor=[UIColor colorWithRed:(CGFloat)248/255 green:(CGFloat)197/255 blue:(CGFloat)127/255 alpha:1.0].CGColor;
    //_comment.layer.borderColor=[UIColor blackColor].CGColor;
    _comment.font=[UIFont systemFontOfSize:width1/20];
    _comment.delegate = self;
    _comment.layer.cornerRadius=7.0f;
    [_comment becomeFirstResponder];
    [self.view addSubview:_comment];
    
    
    self.placeHolder = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320, 30)];
    self.placeHolder.backgroundColor=[UIColor clearColor];
    self.placeHolder.adjustsFontSizeToFitWidth=YES;
    self.placeHolder.textAlignment = NSTextAlignmentCenter;
    self.placeHolder.font=[UIFont fontWithName:@"Arial" size:width1/22];
    self.placeHolder.alpha=0.8;
    self.placeHolder.textColor = [UIColor darkGrayColor];
    self.placeHolder.text=@"Leave comment(only viewable by team)";
    [self.comment addSubview:self.placeHolder];

    
   /*
    self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,170, 270, 64)];
    self.commentLabel.backgroundColor = [UIColor whiteColor];
    self.commentLabel.textColor = [UIColor darkGrayColor];
    self.commentLabel.font = [UIFont systemFontOfSize:13];
    self.commentLabel.numberOfLines=3;
    //self.commentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.commentLabel.userInteractionEnabled = YES;
    
    [_secondView addSubview:self.commentLabel];
    self.commentLabel.text = @"Leave comment(only viewable by team)";
    */
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentTapGesture:)];
    //[_comment addGestureRecognizer:tap];
   
    
    //--------------------------------
    
    //-----------------------------------------------------
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.frame = CGRectMake(10*width1/320,270*height1/480,width1*300/320, 40*height1/480);
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //UIImageView *butImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"save_button_dark.png"]];
    //butImg.frame = CGRectMake(5,300, 315, 40);
    //[self.scrollView addSubview:butImg];
    self.saveButton.titleLabel.font=[UIFont boldSystemFontOfSize:width1/18];
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveNewTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:@"title_bar@3x.png"] forState:UIControlStateNormal];
    
    //CAGradientLayer *gradient1 = [CAGradientLayer layer];
    //gradient1.frame = self.headerView.bounds;
   // gradient1.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    //gradient1.startPoint=CGPointMake(0.2, 0);
    //gradient1.endPoint=CGPointMake(0.8, 0);
    //[self.saveButton.layer insertSublayer:gradient1 atIndex:0];

   
    //self.saveButton.layer.borderWidth=1.0f;
   // self.saveButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
   // self.saveButton.layer.cornerRadius = 5.0f;
    self.saveButton.clipsToBounds = YES;
    //[self.view addSubview:butImg];
    [self.view addSubview:self.saveButton];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotate{
    return NO;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //if([text isEqualToString:@"\n"]) {
       // [textView resignFirstResponder];
       /// return NO;
        
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




- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark -


-(void) saveNewTask:(id)sender{
    [_comment resignFirstResponder];
    NSLog(@"Save Task");
    
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    NSString *userId= [SingletonClass sharedSingleton].profileID;
    NSString *task_message = self.messageLable.text;
    
    
    NSDate *curentDate = [NSDate date];
    NSDate *newDate = [curentDate laterDate:curentDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd'T'hh:mm:ss.000"];
    
    NSString *assignDate = [dateFormatter stringFromDate:curentDate];
    NSString *comDate = [dateFormatter stringFromDate:newDate];
    
    NSLog(@"Assigned Date = %@",assignDate);
    NSLog(@"task Message = %@",task_message);
    NSLog(@"user id = %@",userId);
    NSLog(@"Comment = %@",_comment);
    NSLog(@"Com  date=  %@",comDate);
    
    [dateFormatter setDateFormat:@"dd/MM/YY hh:mm a"];
    NSLog(@"Current Data = %@",[dateFormatter stringFromDate:[NSDate date]]);
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    [dataDict setObject:self.messageLable.text forKey:@"TaskMessage"];
    [dataDict setObject:@"false" forKey:@"TaskStatus"];
    [dataDict setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"AssignDate"];
    [dataDict setObject:userId forKey:@"UserId"];
    [dataDict setObject:userId forKey:@"AssignTaskTo"];
    NSLog(@"Task New Dictionary = %@",dataDict);
    self.selectedGroupID=[SingletonClass sharedSingleton].groupID;
    
    //Prepare SOAP Body Message for adding new Task
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                             <soap:Body>\
                             <AddNewTaskWithGroup xmlns=\"http://tempuri.org/\">\
                             <description>%@</description>\
                             <messagedate>%@</messagedate>\
                             <userid>%@</userid>\
                             <task>\
                             <Id>%@</Id>\
                             <GroupId>%@</GroupId>\
                             <TaskMessage>%@</TaskMessage>\
                             <UserId>%@</UserId>\
                             <AssignTaskTo>%@</AssignTaskTo>\
                             <TaskStatus>false</TaskStatus>\
                             <AssignDate>%@</AssignDate>\
                             <CompletionDate>%@</CompletionDate>\
                             <ReadStatus>0</ReadStatus>\
                             <TaskMessageDate>%@</TaskMessageDate>\
                             </task>\
                             <assigntoId>%@</assigntoId>\
                             <comment>%@</comment>\
                             <AssignDate>%@</AssignDate>\
                             <groupid>%@</groupid>\
                             </AddNewTaskWithGroup>\
                             </soap:Body>\
                             </soap:Envelope>",task_message,comDate,userId,userId,self.selectedGroupID,task_message,userId,userId,assignDate,comDate,assignDate,userId,_comment.text,assignDate,self.selectedGroupID];
    NSLog(@"Soap Mesage = %@",soapMessage);
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/Tasks.asmx?op=AddNewTaskWithGroup",WebLink];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/AddNewTaskWithGroup" forHTTPHeaderField:@"SOAPAction"];
    [request addValue:[NSString stringWithFormat:@"%@",soapMessage] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *httpResponse=nil;
    NSError *error = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    if (error) {
        NSLog(@"Error to Create new Task=%@",error);
        UIAlertView *myAlert=[[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; [myAlert show];
         [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
        //[self cancelButtonClicked];
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String to Create new Task = %@",responseString);
        if([responseString rangeOfString:@"faultstring"].location != NSNotFound){
            NSLog(@"Task Not Save");

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"taskNtSaved"] message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];

            [self cancelButtonClicked];
        }
        else{
            NSLog(@"Task Saved");
            [[NSNotificationCenter defaultCenter] postNotificationName:RefreshTask object:nil];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"newTaskadded"] message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
            
            [self cancelButtonClicked];
        }
    }
    
    [self.HUD hide:YES];
    
}



//Cancel Button Action
-(void)cancelButtonClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark NewTask Delegate
//Delegate method of TaskCommentViewController
-(void)commentForTask:(NSString *)composedmessage{
    if (composedmessage.length<=0) {
        self.commentLabel.text = @"Leave comment(only viewable by team)";
    }
    else{
        self.commentLabel.text = composedmessage;
    }
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self comment] resignFirstResponder];
}




-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
