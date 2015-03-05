//
//  TabBarView.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 25/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxVC.h"
#import "TaskVC.h"
#import "Feeds.h"
#import "SchedulerVC.h"
#import "SearchVC.h"

extern NSString *const FBSessionStateChangedNotification;

@interface TabBarView : UIViewController<UITabBarControllerDelegate,UITabBarDelegate>{
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
