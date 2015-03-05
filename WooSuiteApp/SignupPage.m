//
//  SignupPage.m
//  Socioboard
//
//  Created by GBS-ios on 3/2/15.
//  Copyright (c) 2015 Globussoft 1. All rights reserved.
//

#import "SignupPage.h"

@interface SignupPage ()

@end

@implementation SignupPage

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedAcc=-1;

    screenRect = [[UIScreen mainScreen] bounds];
    width1=screenRect.size.width;
    height1=screenRect.size.height;
    [self createUI];
    // Do any additional setup after loading the view from its nib.
}


-(void)createUI{
    
    UIImageView *BackImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width,screenRect.size.height)];
    [BackImg setImage:[UIImage imageNamed:@"LoginScreen.png"]];
    [self.view addSubview:BackImg];
    accTypearray=[[NSArray alloc]initWithObjects:@"Basic(Free)",@"Standard",@"Premium",@"Deluxe",@"SocioBasic",@"SocioStandard",@"SocioPremium",@"SocioDeluxe",nil];
    
    
    mediumChars = [[NSCharacterSet letterCharacterSet] mutableCopy];
    [mediumChars addCharactersInString:@"1234567890"];
    allChars = [[NSCharacterSet letterCharacterSet] mutableCopy];
    [allChars addCharactersInString:@"?!.$@%^&*(){}[]<>"];

    
    UIImageView *logoTxt=[[UIImageView alloc]initWithFrame:CGRectMake(30*width1/320, 60*height1/480, 260*width1/320, 40*height1/480)];
    [logoTxt setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:logoTxt];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
   cancelButton.frame = CGRectMake(5, 15*height1/480, 35*height1/480, 30*height1/480);
    [cancelButton addTarget:self action:@selector(overActivate) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    cancelButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:cancelButton];
    
    
    
   UIScrollView *scrolview=[[UIScrollView alloc]initWithFrame:CGRectMake(30*width1/320, 110*height1/480, width1-(60*width1/320), height1-(100*height1/480))];
    scrolview.contentSize = CGSizeMake(300,600*height1/480);
    scrolview.delegate = self;
    [self.view addSubview:scrolview];
    scrolview.accessibilityActivationPoint = CGPointMake(100, 100);
    scrolview.showsVerticalScrollIndicator = NO;

    
    
    
    accountType=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    accountType=[[UIButton alloc]initWithFrame:CGRectMake(0,0*height1/480,260*width1/320,30*height1/480)];
    accountType.backgroundColor=[UIColor whiteColor];
    accountType.layer.borderColor=[UIColor blackColor].CGColor;
    accountType.titleLabel.textAlignment=NSTextAlignmentLeft;
    accountType.layer.borderWidth=1.0;
    accountType.layer.cornerRadius=5.0*width1/320;
    [accountType setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [accountType setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"AccountTypesignMsg"] forState:UIControlStateNormal];
    selectedAccType=@"Account Type";
    [accountType addTarget:self action:@selector(acctypeMethod) forControlEvents:UIControlEventTouchUpInside];
    [scrolview addSubview:accountType];
    UIImageView *dropDown=[[UIImageView alloc]initWithFrame:CGRectMake(230*width1/320, 5*height1/480, 30*width1/320, 20*width1/320)];
    dropDown.image=[UIImage imageNamed:@"drop_down_inbox@3x.png"];
    
    [accountType addSubview:dropDown];
       userName=[[UITextField alloc]initWithFrame:CGRectMake(0,45*height1/480,260*width1/320,32*height1/480)];
    userName.backgroundColor=[UIColor whiteColor];
    userName.layer.borderColor=[UIColor blackColor].CGColor;
    userName.layer.borderWidth=1.0;
    userName.textAlignment=NSTextAlignmentCenter;
    userName.placeholder=@"First Name";
    userName.layer.cornerRadius=5.0*width1/320;
    [userName resignFirstResponder];

    [scrolview addSubview:userName];
    
    lastName=[[UITextField alloc]initWithFrame:CGRectMake(0,90*height1/480,260*width1/320,32*height1/480)];
    lastName.backgroundColor=[UIColor whiteColor];
    lastName.layer.borderColor=[UIColor blackColor].CGColor;
    lastName.layer.borderWidth=1.0;
    lastName.placeholder=@"Last Name";
    lastName.textAlignment=NSTextAlignmentCenter;
   [lastName resignFirstResponder];
     lastName.layer.cornerRadius=5.0*width1/320;
    [scrolview addSubview:lastName];
    
    emailId=[[UITextField alloc]initWithFrame:CGRectMake(0,135*height1/480,260*width1/320,32*height1/480)];
    emailId.backgroundColor=[UIColor whiteColor];
    emailId.layer.borderColor=[UIColor blackColor].CGColor;
    emailId.layer.cornerRadius=5.0*width1/320;
    emailId.layer.borderWidth=1.0;
    emailId.textAlignment=NSTextAlignmentCenter;
   [emailId resignFirstResponder];
    emailId.placeholder=@"Email ID";
    [scrolview addSubview:emailId];
    
    passWordText=[[UITextField alloc]initWithFrame:CGRectMake(0,180*height1/480,260*width1/320,32*height1/480)];
    passWordText.backgroundColor=[UIColor whiteColor];
    passWordText.layer.borderColor=[UIColor blackColor].CGColor;
    passWordText.layer.borderWidth=1.0;
   passWordText.layer.cornerRadius=5.0*width1/320;
    passWordText.placeholder=@"Password";
    passWordText.delegate=self;
    [passWordText addTarget:self
                    action:@selector(textFieldValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    passWordText.textAlignment=NSTextAlignmentCenter;
   [passWordText resignFirstResponder];
    [scrolview addSubview:passWordText];
    
    repeatPasword=[[UITextField alloc]initWithFrame:CGRectMake(0,225*height1/480,260*width1/320,32*height1/480)];
    repeatPasword.backgroundColor=[UIColor whiteColor];
    repeatPasword.layer.borderColor=[UIColor blackColor].CGColor;
    repeatPasword.layer.borderWidth=1.0;
      repeatPasword.placeholder=@"Conform Password";
     repeatPasword.layer.cornerRadius=5.0*width1/320;
    repeatPasword.textAlignment=NSTextAlignmentCenter;
   [repeatPasword resignFirstResponder];
    [scrolview addSubview:repeatPasword];
    
    
    coupenCode=[[UITextField alloc]initWithFrame:CGRectMake(0,270*height1/480,260*width1/320,32*height1/480)];
    coupenCode.backgroundColor=[UIColor whiteColor];
    coupenCode.layer.borderColor=[UIColor blackColor].CGColor;
    coupenCode.layer.borderWidth=1.0;
    coupenCode.placeholder=@"Coupen Code(optional)";
     coupenCode.layer.cornerRadius=5.0*width1/320;
    coupenCode.textAlignment=NSTextAlignmentCenter;
    [coupenCode resignFirstResponder];
    [scrolview addSubview:coupenCode];
    
    
    
    
   UIButton *createAcc=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    createAcc.frame=CGRectMake(0, 345*height1/480,130*width1/320, 35*height1/480);
    createAcc.backgroundColor=[UIColor clearColor];
    createAcc.layer.cornerRadius=7.0f;
    [createAcc setBackgroundImage:[UIImage imageNamed:@"create_btn.png"] forState:UIControlStateNormal];
    [createAcc addTarget:self action:@selector(createAcc) forControlEvents:UIControlEventTouchUpInside];
    [scrolview addSubview:createAcc];
    
    
    UIButton *resetBut=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    resetBut.frame=CGRectMake(130*width1/320, 345*height1/480,130*width1/320, 35*height1/480);
    resetBut.backgroundColor=[UIColor clearColor];
    resetBut.layer.cornerRadius=7.0f;
    [resetBut setBackgroundImage:[UIImage imageNamed:@"reset_btn.png"] forState:UIControlStateNormal];
    [resetBut addTarget:self action:@selector(resetAll) forControlEvents:UIControlEventTouchUpInside];
    [scrolview addSubview:resetBut];

    passwordLabel=[[UILabel alloc]initWithFrame:CGRectMake(30*width1/320, 315*height1/480, 200*width1/320, 20*height1/480)];
    passwordLabel.text=@"";
    
    passwordLabel.backgroundColor=[UIColor redColor];
    passwordLabel.textColor=[UIColor whiteColor];
    passwordLabel.textAlignment=NSTextAlignmentCenter;
    passwordLabel.font=[UIFont systemFontOfSize:width1/24];
    [scrolview addSubview:passwordLabel];
    passwordLabel.hidden=YES;

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (void)textFieldDidBeginEditing:(UITextField *)textField{
   

}
-(void)textFieldDidEndEditing:(UITextField *)textField{
     passwordCorrect=0;
    if([passWordText.text length ]<6){
        passwordLabel.text=@"password length:weak";
        passwordLabel.hidden=NO;
    }
    if([passWordText.text length ]>=6){
        if ([passWordText.text containsString:@"0"]||[passWordText.text containsString:@"1"]||[passWordText.text containsString:@"2"]||[passWordText.text containsString:@"3"]||[passWordText.text containsString:@"4"]||[passWordText.text containsString:@"5"]||[passWordText.text containsString:@"6"]||[passWordText.text containsString:@"7"]||[passWordText.text containsString:@"8"]||[passWordText.text containsString:@"9"])
            {
            if([passWordText.text containsString:@"!"]||[passWordText.text containsString:@"@"]||[passWordText.text containsString:@"#"]||[passWordText.text containsString:@"$"]||[passWordText.text containsString:@"%"]||[passWordText.text containsString:@"&"]||[passWordText.text containsString:@"*"]||[passWordText.text containsString:@"?"]||[passWordText.text containsString:@"."]||[passWordText.text containsString:@"0)"]||[passWordText.text containsString:@"("]||[passWordText.text containsString:@"^"])
            {
                //passwordLabel.text=@"password length:Strong";
                passwordLabel.hidden=YES;
                passwordCorrect=2;
                
            }
            
            else{
            passwordLabel.text=@"password length:medium";
            passwordLabel.hidden=NO;
                 passwordCorrect=2;
            }
            
        }
        else{
            passwordCorrect=0;
            passwordLabel.text=@"password length:weak";
            passwordLabel.hidden=NO;
        }
    }
    
}

#pragma mark-
#pragma mark button method


-(void)createAcc{
    if([[userName text] isEqualToString:@""]&&[[lastName text]isEqualToString:@""]&&[[emailId text ]isEqual:@""]){
        passwordLabel.text=@"enter all field";
        passwordLabel.hidden=NO;
        return;
    }
    if([selectedAccType isEqual:@"Account Type"]){
        passwordLabel.text=@"select Account Type";
        passwordLabel.hidden=NO;
        return;
        
    }
    if(!([emailId.text containsString:@"@"]&&[emailId.text containsString:@"."])){
        passwordLabel.text=@"email id is invalid";
        passwordLabel.hidden=NO;
    }

    if(passwordCorrect==2){
        if(![passWordText.text isEqualToString:[repeatPasword text]]){
            passwordLabel.text=@"Password did't match";
            passwordLabel.hidden=NO;
            return;
        }
        
       
        
  else{
      passwordLabel.hidden=YES;
      NSLog(@"success");
      [self resisterAcc];
  }
    }
        else{
            
            passwordLabel.text=@"Password length:weak";
            passwordLabel.hidden=NO;
            return;
        }
    
   

    
}
/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [userName resignFirstResponder];
    [lastName resignFirstResponder];
    [emailId resignFirstResponder];
    [passWordText resignFirstResponder];
    [repeatPasword resignFirstResponder];
    [coupenCode resignFirstResponder];
}
*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    passwordLabel.hidden=YES;
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

-(void)resetAll{
    userName.text=@"";
    lastName.text=@"";
    emailId.text=@"";
    passWordText.text=@"";
    repeatPasword.text=@"";
    coupenCode.text=@"";
    [accountType setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
   [accountType setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"AccountTypesignMsg"] forState:UIControlStateNormal];
    selectedAcc=-1;
    
    
}




-(void)acctypeMethod{
    
    
    
    BgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1, height1)];
    BgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
    BgView.hidden=NO;
    [self.view addSubview:BgView];
    

    
    acctypeTable = [[UITableView alloc]initWithFrame:CGRectMake(35*width1/320, 120*height1/480, 250*width1/320, 300*height1/480) style:UITableViewStyleGrouped];
    [acctypeTable registerClass:[UITableViewCell class]
      forCellReuseIdentifier:@"SimpleTableIdentifier"];
    
    acctypeTable.layer.cornerRadius=5.0;
    acctypeTable.layer.borderColor=[UIColor blackColor].CGColor;
    acctypeTable.layer.borderWidth=1.5;
    acctypeTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    acctypeTable.opaque=NO;
    acctypeTable.backgroundColor=[UIColor whiteColor];
    acctypeTable.backgroundView=nil;
    [acctypeTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    acctypeTable.hidden=NO;
    acctypeTable.delegate = self;
    acctypeTable.dataSource = self;
    acctypeTable.scrollEnabled=YES;
    [BgView addSubview:acctypeTable];
    
    
    
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}




-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font=[UIFont systemFontOfSize:width1/16];
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
    accessoryImageView = [[UIImageView alloc] init];
    accessoryImageView.frame = CGRectMake(width1-(100*width1/320), 5*height1/480, 25*width1/320, 25*width1/320);
    
    accessoryImageView.userInteractionEnabled=YES;
    [cell addSubview:accessoryImageView];
    
    
        if (indexPath.row== selectedAcc)
        {
        accessoryImageView.image = [UIImage imageNamed:@"radiobtn_clicked@3x.png"];
        }
        else{
            accessoryImageView.image = [UIImage imageNamed:@"radiobtn@3x.png"];
        }

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor whiteColor];
    cell.textLabel.text=[accTypearray objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:width1/18];
    return cell;
}



-(void) tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [accountType setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [accountType setTitle:[accTypearray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    selectedAccType=[accTypearray objectAtIndex:indexPath.row];
    for(UITableView *view in BgView.subviews){
        if ([view isKindOfClass:[UITableView class]]) {
            [view removeFromSuperview];
        }
    }
    selectedAcc=(int)indexPath.row;
    BgView.hidden=YES;
    
    
}


#pragma mark-
#pragma mark resister

-(void)resisterAcc {
  
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [self.view endEditing:YES];
    HUD.delegate = self;
    HUD.dimBackground=YES;
    HUD.color = [UIColor colorWithRed:0.50 green:0.30 blue:0.60 alpha:0.60];
    HUD.labelText = @"Loading";
    HUD.square = YES;
    HUD.alpha=0.7;
    [HUD show:YES];
    NSString *userNm=[NSString stringWithFormat:@"%@ %@",[userName text],[lastName text]];
    
          NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<Pass_x0020_Username xmlns=\"http://tempuri.org/\">\n"
                                 "<EmailId>%@</EmailId>\n"
                                 "<Password>%@</Password>\n"
                                 "<AccountType>%@</AccountType>\n"
                                 "<Username>%@</Username>\n"
                                 "<ActivationStatus>%@</ActivationStatus>\n"
                                 "</Pass_x0020_Username>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",[emailId text],[passWordText text],accountType.titleLabel.text,userNm,@"0"];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/User.asmx?op=Pass_x0020_Username",WebLink];
        NSURL *url = [NSURL URLWithString:urlString];
        
        // Creating a Request for Login authentication
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/Pass Username" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Create URLConnection
        [NSURLConnection connectionWithRequest:req delegate:self];
        NSLog(@"%@",msglength);
        webdata = [[NSMutableData alloc]init];
}



#pragma mark-

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [webdata appendData:data];
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *myAlert = [[UIAlertView alloc]
                            initWithTitle:nil message:@"Error" delegate:self cancelButtonTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"okMsg"] otherButtonTitles:nil];
    [myAlert show];
    [self performSelector:@selector(dismissAlertView1:) withObject:myAlert afterDelay:2.0];
    [HUD hide:YES];
}
//Fetched Login Response
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *xmlString = [[NSString alloc] initWithData:webdata encoding:NSUTF8StringEncoding];
        NSString *response=[HelperClass stripTags:xmlString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
    
        NSLog(@"Login Dict =%@",dict);
    if([jsonString isEqual:@"}"]){
        passwordLabel.text=@"Something went wrong";
        passwordLabel.hidden=NO;
        [HUD hide:YES];
        
    }
    else{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Account activation mail has been sent to your email id, go to link to confirm your mail" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
    [HUD hide:YES];
    [self resetAll];
    }
}

-(void)overActivate{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}





@end
