//
//  WebView1.h
//  Socioboard
//
//  Created by GBS-ios on 1/8/15.
//  Copyright (c) 2015 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SingletonClass.h"
@interface WebView1 : UIViewController<UIWebViewDelegate,MBProgressHUDDelegate>
@property(nonatomic,assign)int typeOfsearch;
@property(nonatomic,strong)NSString *url;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@end
