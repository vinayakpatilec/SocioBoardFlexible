//
//  SchedulerVC.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchedulerVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSInteger messageType;
    int width1;
    int height1;
    CGRect screenRect;
}

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIButton *settingBtn;
@property (nonatomic, strong) UITableView *scheduleTableView;

@property (nonatomic, strong) NSMutableArray *allScheduleMesgArray;

@property (nonatomic, strong) UISearchBar *scheduleSearchBar;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSString *currentTable;

@property (nonatomic, strong) UIView *dimLightView;
- (IBAction) goToComposerMessage:(id)sender;
- (IBAction) gotTOScheduleSetting:(id) sender;
@end
