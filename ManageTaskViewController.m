//
//  ManageTaskViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 20/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "ManageTaskViewController.h"
#import "SingletonClass.h"
#import "TaskCommentViewController.h"
#import "HelperClass.h"
#import "SBJson.h"
#import "MBProgressHUD.h"
@interface ManageTaskViewController () <TaskCommentViewControllerDetegate, MBProgressHUDDelegate>{
   
}
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation ManageTaskViewController

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
    //commentForTask
    [super viewDidLoad];
    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;

    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, 50*height1/480)];
     self.headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
    [self.view addSubview:self.headerView];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:.7];
    gradient.startPoint=CGPointMake(0.2, 0);
    gradient.endPoint=CGPointMake(0.8, 0);

    
    gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    
    
    //------------------------------------------------------
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cancelButton.frame = CGRectMake(5, 17*height1/480, 35*height1/480, 30*height1/480);
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
   
    self.cancelButton.backgroundColor=[UIColor clearColor];
  
    [self.headerView addSubview:self.cancelButton];
    //------------------------------------------------------
    self.saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.saveButton.frame = CGRectMake(255*width1/320,150*height1/480, 45*height1/480, 45*height1/480);
        [self.saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:@"ok_button.png"] forState:UIControlStateNormal];
    
    

    //---------------------------------
    self.titlelable = [[UILabel alloc] initWithFrame:CGRectMake(width1/2-(90*width1/320), 15*height1/480, 180*width1/320, 30*height1/480)];
    self.titlelable.backgroundColor = [UIColor whiteColor];
    self.titlelable.layer.cornerRadius=5*width1/320;
    self.titlelable.clipsToBounds=YES;
    self.titlelable.layer.borderColor=[UIColor redColor].CGColor;
    self.titlelable.layer.borderWidth=1.0f;
    self.titlelable.textAlignment = NSTextAlignmentCenter;
    self.titlelable.textColor = [UIColor blackColor];
    self.titlelable.font=[UIFont boldSystemFontOfSize:width1/18];
    self.titlelable.text = @"Manage Task";
    [self.headerView addSubview:self.titlelable];
    
//**********************************************************
    
    
    
    self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5*width1/320, 70*height1/480, 40*width1/320, 40*width1/320)];
    [self.view addSubview:self.profileImageView];
    
    self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(60*width1/320, 70*height1/480, width1-70, 20*height1/480)];
    self.nameLable.font = [UIFont boldSystemFontOfSize:width1/20];
    self.nameLable.textAlignment = NSTextAlignmentLeft;
    self.nameLable.backgroundColor = [UIColor clearColor];
    self.nameLable.textColor = [UIColor blackColor];
    [self.view addSubview:self.nameLable];
    
    self.messageLable = [[UILabel alloc] initWithFrame:CGRectMake(60*width1/320, 95*height1/480,250*width1/320, 20*height1/480)];
    self.messageLable.backgroundColor = [UIColor clearColor];
    self.messageLable.textColor = [UIColor darkTextColor];
    //self.messageLable.textAlignment = NSTextAlignmentLeft;
    self.messageLable.numberOfLines = 0;
    self.messageLable.font = [UIFont fontWithName:@"Arial" size:width1/20];
    self.messageLable.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:self.messageLable];
    
    //=======================================================
    self.nameLable.text = [SingletonClass sharedSingleton].userName;
    self.profileImageView.image = [UIImage imageNamed:@"task_pin.png"];
    NSString *message = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"TaskMessage"]];
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.messageLable.text = message;
    
    yy = self.secondView.frame.size.height;
    
    self.assignLable = [[UILabel alloc]initWithFrame:CGRectMake(10, 110*height1/480, width1, 30*height1/480)];
    self.assignLable.backgroundColor = [UIColor clearColor];
    self.assignLable.textColor = [UIColor darkTextColor];
    [self.view addSubview:self.assignLable];
    self.assignLable.font = [UIFont systemFontOfSize:width1/22];
    self.assignLable.text = [NSString stringWithFormat:@"Assigned date - %@",[self.dataDict objectForKey:@"AssignDate"]];
    
    //------------------------------------
     //yy = yy+self.assignLable.frame.size.height;
    
    _comment=[[UITextView alloc]initWithFrame:CGRectMake(15*width1/320,150*height1/480,230*width1/320, 45*height1/480)];
    _comment.backgroundColor=[UIColor whiteColor];
    _comment.layer.borderColor=[UIColor blackColor].CGColor;
    _comment.font=[UIFont systemFontOfSize:width1/20];
    _comment.layer.borderWidth=1.0f;
    _comment.textColor=[UIColor blackColor];
    _comment.delegate=self;
    [self.view addSubview:_comment];
    
    yy = yy +50;
    
    
    
    self.placeHolder = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 230, 25)];
    self.placeHolder.backgroundColor=[UIColor clearColor];
    self.placeHolder.adjustsFontSizeToFitWidth=YES;
    self.placeHolder.textAlignment = NSTextAlignmentCenter;
    self.placeHolder.font=[UIFont fontWithName:@"Arial" size:width1/20];
    self.placeHolder.alpha=0.8;
    self.placeHolder.textColor = [UIColor darkGrayColor];
    self.placeHolder.text=@"Leave comment(only viewable by team)";
    [self.comment addSubview:self.placeHolder];

    
    
    
    yy=200*height1/480;
   
    self.statusLable = [[UILabel alloc] initWithFrame:CGRectMake(20,230*height1/480, 150, 30*height1/480)];
    self.statusLable.backgroundColor = [UIColor clearColor];
    self.statusLable.textColor = [UIColor blackColor];
    self.statusLable.font = [UIFont boldSystemFontOfSize:width1/18];
    self.statusLable.textAlignment = NSTextAlignmentLeft;
    self.statusLable.text = @"Priority";
    self.statusLable.userInteractionEnabled = YES;
    [self.view addSubview:self.statusLable];

    //---------------------------------------------
    
    
    
    
    
    
    
    self.statusSegmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Open",@"Completed", nil]];     self.statusSegmentControl.layer.borderWidth=2.0;
    self.statusSegmentControl.layer.cornerRadius=5*width1/320;
    self.statusSegmentControl.layer.borderColor=[UIColor blackColor].CGColor;
    //UIFont *font = [UIFont boldSystemFontOfSize:width1/22];
   //NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                          // forKey:UITextAttributeFont];
    //[self.statusSegmentControl setTitleTextAttributes:attributes
                                       //forState:UIControlStateNormal];
    
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont systemFontOfSize:width1/22],NSFontAttributeName,nil];
    
   
    [self.statusSegmentControl setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    self.statusSegmentControl.frame = CGRectMake(120*width1/320,230*height1/480, 180*width1/320, 30*height1/480);
    self.statusSegmentControl.tintColor = [UIColor redColor];
    self.statusSegmentControl.userInteractionEnabled=YES;
    [self.statusSegmentControl addTarget:self action:@selector(statusSegmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} forState:UIControlStateNormal];
  
    [self.view addSubview:self.statusSegmentControl];
    self.statusValue = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"TaskStatus"]];
    if ([self.statusValue isEqualToString:@"false"]) {
        self.statusSegmentControl.selectedSegmentIndex=0;
    }
    else if ([self.statusValue isEqualToString:@"true"]){
        self.statusSegmentControl.selectedSegmentIndex=1;
    }
    [self getAllComments];
    
    /* segEditorial= [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"New Content", @"Staff Picks", @"Popular", nil]];
     segEditorial.selectedSegmentIndex=0;
     segEditorial.tag=100;
     //segEditorial.layer.cornerRadius=5;
     
     segEditorial.layer.borderWidth=1.0;
     segEditorial.layer.borderColor=[UIColor colorWithRed:(CGFloat)198/255 green:(CGFloat)230/255 blue:(CGFloat)245/255 alpha:1.0].CGColor;
     // segEditorial.segmentedControlStyle  = UISegmentedControlStyleBar;
     segEditorial.frame= CGRectMake(20, 50, self.view.frame.size.width-40, 30);
     [segEditorial addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
     
     segEditorial.tintColor= [UIColor blackColor];
     
     [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
     segEditorial.backgroundColor=[UIColor colorWithRed:71.0f/255.0f green:165.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
     [self.thirdSectionHeaderView addSubview:segEditorial];
     }
     [segEditorial setTitle:[ViewController languageSelectedStringForKey:@"New Content"] forSegmentAtIndex:0];
     [segEditorial setTitle:@"추천" forSegmentAtIndex:1];
     [segEditorial setTitle:[ViewController languageSelectedStringForKey:@"Popular"] forSegmentAtIndex:2];
     self.sectionThirdTitle.textColor=[UIColor blackColor];
     self.sectionThirdTitle.text =@"간편보기";//[ViewController languageSelectedStringForKey:@"Editorial"];
     return self.thirdSectionHeaderView;
     */
    
    
}

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {
    return YES;
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
//segment Controller Action
-(void) statusSegmentControlValueChanged:(id)sender{
    if (self.statusSegmentControl.selectedSegmentIndex==0) {
        self.statusValue = @"false";
    }
    else{
        self.statusValue = @"true";
    }
}
//Display Activity Indicator
-(void) displayActivityIndicator{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
}
-(void)hudWasHidden:(MBProgressHUD *)hud{
    hud = nil;
    [hud removeFromSuperview];
}

//Cancel Button Action
-(void) cancelButtonAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Get All Comment for selected Task
-(void) getAllComments{
    NSString *userID = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"UserId"]];
    NSString *taskID = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Id"]];
    
    //Prepare SOAP message for Update Task
    NSString *soapMessage = [[NSString alloc] initWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                             <soap:Body>\
                             <GetAllTaskCommentByUserIdTaskId xmlns=\"http://tempuri.org/\">\
                              <taskId>%@</taskId>\
                              <userId>%@</userId>\
                             </GetAllTaskCommentByUserIdTaskId>\
                             </soap:Body>\
                             </soap:Envelope>",taskID,userID];
    
    //NSLog(@"soapMessg facebook %@",soapMessage);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/TaskComment.asmx?op=GetAllTaskCommentByUserIdTaskId",WebLink];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/GetAllTaskCommentByUserIdTaskId" forHTTPHeaderField:@"SOAPAction"];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *httpResponse = nil;
    NSError *error = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    if (error) {
        NSLog(@"Error to Update Task");
        [self.hud hide:YES];

    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String == %@",responseString);
        
       NSString *jsonString = [HelperClass stripTags:responseString startString:@"<GetAllTaskCommentByUserIdTaskIdResult>" upToString:@"</GetAllTaskCommentByUserIdTaskIdResult>"];
        if ([jsonString rangeOfString:@"Data Not Found"].location != NSNotFound) {
             NSLog(@"No Comment added yet");
            [self.hud hide:YES];
            
        }
        else{
           
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"<GetAllTaskCommentByUserIdTaskIdResult>" withString:@""];
           // NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            //id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            commentArray = [jsonString JSONValue];
                NSLog(@"%@",commentArray);
            [self.hud hide:YES];

            [self createTable];
                        }

        
        }
    }


//Displaing All Task


/*
-(void) displayComments{
     NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    if ([parse isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Dictionary kind class");
        NSDictionary *commentDict = [jsonString JSONValue];
        
        NSString *comments = [commentDict objectForKey:@"Comment"];
        NSLog(@"%@-------------------------",comments);
        comments = [comments stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        CGSize lblSize = [comments sizeWithFont:[UIFont fontWithName:@"Arial" size:12] constrainedToSize:CGSizeMake(260,1000)];
        
        
        
        
        UILabel *commentLable = [[UILabel alloc] initWithFrame:CGRectMake(400, 350, 320, 60)];
        commentLable.backgroundColor = [UIColor clearColor];
        commentLable.layer.borderColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)55/255 blue:(CGFloat)136/255 alpha:1].CGColor;
        commentLable.layer.borderWidth = .3f;
        commentLable.textColor = [UIColor blackColor];
        [self.view addSubview:commentLable];
        commentLable.font = [UIFont systemFontOfSize:10];
        commentLable.text = [NSString stringWithFormat:@"     %@",comments];
        yy = yy+lblSize.height;
    }
    else if ([parse isKindOfClass:[NSArray class]]){
        NSLog(@"Array kind Class");
        
        NSArray *commentArray = [jsonString JSONValue];
        for (int i = 0; i<commentArray.count; i++) {
            NSDictionary *commentDict = [commentArray objectAtIndex:i];
            
            NSString *comments = [commentDict objectForKey:@"Comments"];
            comments = [comments stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            CGSize lblSize = [comments sizeWithFont:[UIFont fontWithName:@"Arial" size:12] constrainedToSize:CGSizeMake(260,1000)];
           
            
//---------------
            UILabel *commentLable = [[UILabel alloc] initWithFrame:CGRectMake(0, yy, 320, lblSize.height)];
            commentLable.backgroundColor = [UIColor colorWithRed:(CGFloat)114/255 green:(CGFloat)200/255 blue:(CGFloat)236/255 alpha:.1];
            commentLable.layer.borderColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)55/255 blue:(CGFloat)136/255 alpha:1].CGColor;
            commentLable.layer.borderWidth = .3f;
            commentLable.textColor = [UIColor blackColor];
            [self.view addSubview:commentLable];
            commentLable.font = [UIFont systemFontOfSize:10];
            commentLable.text = [NSString stringWithFormat:@"     %@",commentLable];
            yy = yy+lblSize.height;
            
        }
    }
}
*/
//Save Button Action

#pragma mark
-(void) saveButtonAction : (id)sender{
    NSLog(@"Save Button Clicked");
    //Checking Expiry Date
    NSInteger remainDay = [SingletonClass sharedSingleton].remainDays;
    if (remainDay<=0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"accExpiremsg"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil] show];
        return;
    }
    //==============================================
    
    
    NSString *previousStatus = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"TaskStatus"]];
    
    BOOL check = NO;
    if((![self.comment.text isEqualToString:@""])||(![previousStatus isEqualToString:self.statusValue]))
    {
    [NSThread detachNewThreadSelector:@selector(displayActivityIndicator) toTarget:self withObject:nil];
    //Check if new comment added
        //comapre with Previous Status
        if (![previousStatus isEqualToString:self.statusValue]) {
            NSLog(@"Update Task");
            [self updateTask];
            [self cancelButtonAction];
        }

   else if (![self.comment.text isEqualToString:@""]) {
        // if comment added call service and add new comment for selected Task
        check = [self addNewComments];
        if (check == NO) {
            [self.hud hide:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [alertView show];
             [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];

            
           
            [self.hud hide:YES];
            [self cancelButtonAction];
            //return;
        }
    
    
       
        [self.hud hide:YES];
        if (check == YES) {
            
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"commentAdded"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [alertView show];
             [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
           // [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
           
            //[self getAllComments];
            [self cancelButtonAction];
             return;

    }
    }
    

}
}

//call service and Update Task
-(void) updateTask{
    
    //2015-01-08T04:40:39.000
    //29/12/2014 17:14:09
    NSString *userId = [SingletonClass sharedSingleton].profileID;
    NSString *taskId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Id"]];
    NSLog(@"%@",taskId);
    NSString *taskMessage = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"TaskMessage"]];
    NSString *assignDate = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"AssignDate"]];
    
    
    
    NSLog(@"%@",assignDate);
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+5.30"]];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *date  = [formatter dateFromString:assignDate];
    NSLog(@"Date == %@",date);
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    assignDate = [formatter stringFromDate:date];
    
    NSLog(@"%@",assignDate);
    //Prepare Soap Body Message for update Task
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                             <soap:Body>\
                             <UpdateTasksByUserIdTaskId xmlns=\"http://tempuri.org/\">\
                            <taskMessage>%@</taskMessage>\
                            <assignTaskTo>%@</assignTaskTo>\
                            <taskStatus>%@</taskStatus>\
                             <assignDate>%@</assignDate>\
                             <taskId>%@</taskId>\
                             <userId>%@</userId>\
                             </UpdateTasksByUserIdTaskId>\
                             </soap:Body>\
                             </soap:Envelope>",taskMessage,userId,self.statusValue,assignDate,taskId,userId];
    
    NSLog(@"%@",soapMessage);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/Tasks.asmx?op=UpdateTasksByUserIdTaskId",WebLink];
   
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
     [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/UpdateTasksByUserIdTaskId" forHTTPHeaderField:@"SOAPAction"];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *httpResponse = nil;
    NSError *error = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    if (error) {
        NSLog(@"Error to Update Task");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [alertView show];
        [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
         [self.hud hide:YES];
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String == %@",responseString);
        
        if ([responseString rangeOfString:@"is not a valid AllXsd value"].location != NSNotFound) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
             [self.hud hide:YES];
            return;
        }
        else if ([responseString rangeOfString:@"faultstring"].location != NSNotFound){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"errorMsg"] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"PlztryAgain"] delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
            [alertView show];
            [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
            return;
        }
        
        [self.dataDict setValue:self.statusValue forKey:@"TaskStatus"];
        
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(taskUpdated:)]){
            [self.delegate taskUpdated:self.dataDict];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"taskUpdated1"] message:@"" delegate:nil cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil, nil];
        [alertView show];
        [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
        [self.hud hide:YES];
       // _status.hidden=NO;
    }
}

//Add new comment for selected Task
-(BOOL) addNewComments{
    
    BOOL returnValue = NO;
    
    NSString *comment = self.comment.text;
    NSString *userID = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"UserId"]];
    NSString *taskId = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"Id"]];
    
    NSString *assignDate = [NSString stringWithFormat:@"%@",[self.dataDict objectForKey:@"AssignDate"]];
    
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+5.30"]];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *date  = [formatter dateFromString:assignDate];
    NSLog(@"Date == %@",date);
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    assignDate = [formatter stringFromDate:date];

    
       
    [formatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    //NSString *newAssignDate = [formatter stringFromDate:assignDate];
    NSLog(@"Assign date = %@",assignDate);
    
    NSLog(@"Current Date = %@",currentDate);
    
    //Prepare Soap message for Adding new comment
    NSString *soapMessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\
                             <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\
                             <soap:Body>\
                             <AddTaskComment xmlns=\"http://tempuri.org/\">\
                             <comment>%@</comment>\
                             <userId>%@</userId>\
                             <taskId>%@</taskId>\
                             <commentDate>%@</commentDate>\
                             <entryDate>%@</entryDate>\
                             </AddTaskComment>\
                             </soap:Body>\
                             </soap:Envelope>",comment,userID,taskId,currentDate,assignDate];
    
    NSLog(@"Soap Message = %@",soapMessage);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/Services/TaskComment.asmx?op=AddTaskComment",WebLink];

    //Prepare a Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
     [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"http://tempuri.org/AddTaskComment" forHTTPHeaderField:@"SOAPAction"];
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapMessage length]];
    [request addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSHTTPURLResponse *httpResponse = nil;
    NSError *error = nil;
    //Make a urlconnection and get response
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    if (error) {
        NSLog(@"Error to Update Task");
        
        returnValue = NO;
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"Response String == %@",responseString);
        if ([responseString rangeOfString:@"Success"].location == NSNotFound) {
            returnValue = NO;
        }
        else{
            returnValue = YES;
        }
    }
    return returnValue;
}
#pragma mark -
#pragma mark NewTask Delegate
//Delegate method of TaskCommentViewController


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self comment] resignFirstResponder];
}


#pragma mark
-(void)createTable{
    commentsTable=[[UITableView alloc]initWithFrame:CGRectMake(10, 300*height1/480, width1-20,180*height1/480)];
    commentsTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    commentsTable.backgroundColor=[UIColor clearColor];
    commentsTable.delegate=self;
    commentsTable.dataSource=self;
    [self.view addSubview:commentsTable];
}


- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    //heightofText=size.height;
    return size.height;
}


-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *commentDict = [commentArray objectAtIndex:((int)commentArray.count- (int)indexPath.row-1)];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *conDict = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    NSString *comments = [commentDict objectForKey:@"Comment"];
    NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:comments attributes:conDict];
    heightText =(int)[self textViewHeightForAttributedText:messtr andWidth:240*width1/320];
    if(heightText<30){
        heightText=30;
    }
    return heightText+20;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return  40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (int)commentArray.count;
   }


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    }



- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return @"comments:";
}




-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font=[UIFont systemFontOfSize:width1/18];
    cell.textLabel.backgroundColor =[UIColor clearColor];
    
    cell.backgroundColor = [UIColor clearColor];
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //header.backgroundColor=[UIColor clearColor];
    header.contentView.backgroundColor=[UIColor clearColor];
    header.textLabel.backgroundColor=[UIColor clearColor];
    header.textLabel.textColor = [UIColor blackColor];
    header.textLabel.font=[UIFont boldSystemFontOfSize:width1/18];
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    
    if(cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }

    cell.backgroundColor=[UIColor clearColor];
    NSDictionary *commentDict = [commentArray objectAtIndex:((int)commentArray.count- (int)indexPath.row-1)];
    NSString *comments = [commentDict objectForKey:@"Comment"];
    
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSDictionary *conDict = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    NSAttributedString *messtr = [[NSAttributedString alloc] initWithString:comments attributes:conDict];
    int h =(int)[self textViewHeightForAttributedText:messtr andWidth:250*width1/320];
    if(h<30){
        h=30;
    }
    for(UITextView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UITextView class]]) {
            [view removeFromSuperview];
        }
    }
    UITextView *textComment=[[UITextView alloc]initWithFrame:CGRectMake(10, 5, 270*width1/320, h)];
    textComment.text=comments;
    textComment.font=[UIFont systemFontOfSize:width1/20];
    textComment.backgroundColor=[UIColor clearColor];
    textComment.editable=NO;
    //cell.textLabel.text=[NSString stringWithFormat:@"   %@",comments];
    [cell.contentView addSubview:textComment];
    return cell;
}


-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


@end
