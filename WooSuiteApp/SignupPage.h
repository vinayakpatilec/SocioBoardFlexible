//
//  SignupPage.h
//  Socioboard
//
//  Created by GBS-ios on 3/2/15.
//  Copyright (c) 2015 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SingletonClass.h"
#import "HelperClass.h"
#import "SBJson.h"

@interface SignupPage : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIScrollViewAccessibilityDelegate, UITextFieldDelegate,MBProgressHUDDelegate>{
  CGRect screenRect;
    int width1;
    int height1;
    UIButton *accountType;
    UITextField *userName;
    UITextField *lastName;
    UITextField *emailId;
    UITextField *passWordText;
    UITextField *repeatPasword;
    UITextField *coupenCode;
    UITableView *acctypeTable;
    UIView *BgView;
    NSArray *accTypearray;
    MBProgressHUD *HUD;
    NSMutableData *webdata;
    UILabel *passwordLabel;
    NSMutableCharacterSet *mediumChars;
    NSMutableCharacterSet *allChars;
    int passwordCorrect;
    NSString *selectedAccType;
    UIImageView *accessoryImageView;
    int selectedAcc;
    

}
@end
