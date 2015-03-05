//
//  GroupViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 15/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TabBarView.h"
#import "InboxVC.h"
@class TabBarView;
@interface GroupViewController : UIViewController<NSXMLParserDelegate, UIActionSheetDelegate,MBProgressHUDDelegate,UITableViewDelegate,UITableViewDataSource>{
    
     MBProgressHUD *HUD;
    NSMutableData *webdata;
    int buttonenable;
    int groupNo;
    int totalTeam;
    int enterGrp;
    int noOfPofile;
    UILabel *noOfProf;
    UILabel *grpLabel;
    int noOfLeftShift;
    NSMutableArray *tempArray;
    int width1;
    int height1;
    int isTeamEmpty;
    UITableView *tableView;
    int downLoadOver;
    
}

@property (nonatomic, strong) IBOutlet UITabBarController *myTabBarController;

@property (nonatomic, strong) UIView *TopView;

@property (nonatomic, strong)NSMutableArray *allGrpProfile;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) UIActionSheet *logoutSheet;
@property (nonatomic, strong)  UIView *bgView;
@property (nonatomic, strong) UIButton *displayButton;
@property (nonatomic, strong) TabBarView *tabBarVC;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic)UILabel *status;
@property (strong, nonatomic)UILabel *downLbl;
@property (strong, nonatomic) UITabBarController *tabBarController;


-(void)loadAccountInfo:(NSDictionary*)teamId;
-(void)fetchGroupIDs;
@end
