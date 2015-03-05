//
//  AppDelegate.h
//  WooSuiteApp
//
//  Created by Globussoft 1 on 4/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    UIActivityIndicatorView *activity;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property(nonatomic,strong)UITabBarController *tabBarController;

-(void) createTabBar;
@end
