//
//  WebView1.m
//  Socioboard
//
//  Created by GBS-ios on 1/8/15.
//  Copyright (c) 2015 Globussoft 1. All rights reserved.
//

#import "WebView1.h"

@interface WebView1 ()

@end

@implementation WebView1

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
  self.view.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
    CGRect screenRect= [[UIScreen mainScreen] bounds];
    UIWebView *webVw=[[UIWebView alloc]initWithFrame:CGRectMake(0, 50*screenRect.size.height/480, screenRect.size.width, screenRect.size.height-(50*screenRect.size.height/480))];
   // NSString *url=@"http://www.google.com";
    webVw.delegate=self;
    NSURL *nsurl=[NSURL URLWithString:_url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webVw loadRequest:nsrequest];
    [self.view addSubview:webVw];
    
    
    
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(3, 15*screenRect.size.height/480, 35*screenRect.size.height/480, 30*screenRect.size.height/480);
    //[self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:screenRect.size.width/20];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    //self.cancelButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
    //self.cancelButton.layer.borderWidth=1.0f;
    //self.cancelButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    //self.cancelButton.layer.cornerRadius = 5.0f;
    //self.cancelButton.clipsToBounds = YES;
    
    //[self.cancelButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"back_icon@3x.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.cancelButton];
    

    // Do any additional setup after loading the view from its nib.
}


-(void)webViewDidStartLoad:(UIWebView *)webView
{
    self.hud = [[MBProgressHUD alloc] init];
    self.hud.dimBackground = YES;
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    [self.hud show:YES];

    
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  
    [self.hud hide:YES];
    

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",errorMsg] message:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"failedtoLoadPage"] delegate:nil cancelButtonTitle:[NSString stringWithFormat:@"%@",okMsg] otherButtonTitles:nil, nil];
    [alertView show];
    [self performSelector:@selector(dismissAlertView1:) withObject:alertView afterDelay:2.0];
    [self.hud hide:YES];

    
}


-(void) dismissAlertView1:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


-(void) cancelButtonClickedAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
