//
//  MenuViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 22/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelperClass.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import "TabBarView.h"
@interface MenuViewController : UIViewController <UIActionSheetDelegate,MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate>{
    MBProgressHUD *HUD;
    NSMutableData *webdata;
    int noOfPofile;
    int groupNo;
    int totalTeam;
     NSMutableArray *tempArray;
    UILabel *grpLabel;
    UILabel *noOfProf;
     BOOL isTeamchanged;
    int noOfLeftShift;
    
    int width1;
    int height1;
    CGRect screenRect;

    int isTeamEmpty;
    UITableView *tableView;

}
@property (nonatomic, strong) UIView *TopView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIButton *displayButton;
@property (nonatomic, strong) UIActionSheet *logoutSheet;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) TabBarView *tabBarVC;
@property (nonatomic, strong)NSMutableArray *allGrpProfile;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
