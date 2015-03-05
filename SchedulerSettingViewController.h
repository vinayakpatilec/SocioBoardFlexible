//
//  SchedulerSettingViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 02/01/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SchedulerSettingViewControllerDelegate <NSObject>

-(void) selectedMessageRow:(NSInteger)selectedRow;

@end

@interface SchedulerSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger selectedRow;
    int width1;
    int height1;
    CGRect screenRect;

}

@property (nonatomic, strong) id <SchedulerSettingViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *settingTableView;
@property (nonatomic, strong) NSArray *allLisrArray;
@end
