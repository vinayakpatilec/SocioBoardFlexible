//
//  ViewController.h
//  WooSuiteApp
//
//  Created by Globussoft 1 on 4/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabBarView.h"
#import "InboxVC.h"
#import "MBProgressHUD.h"
#import "SignupPage.h"

@interface ViewController : UIViewController<NSXMLParserDelegate,UITextFieldDelegate, MBProgressHUDDelegate>
{
    //NSUserDefaults *defaults;
    NSMutableData *webdata;
    MBProgressHUD *HUD;
    UIImage *checkImg;
    BOOL imgType;
    int width1;
    int height1;
     UIView *BgView;
    UIButton *LanguageSelect;
}

@property (strong, nonatomic) IBOutlet UITextField *txtpwd;
@property (strong, nonatomic) IBOutlet UITextField *txtemail;
@property (strong, nonatomic) IBOutlet UIButton *login;
@property (strong, nonatomic) IBOutlet UIButton *saveData;
@property (strong, nonatomic)UILabel *status;

- (IBAction)loginAction:(id)sender;

@end