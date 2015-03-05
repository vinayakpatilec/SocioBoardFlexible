//
//  TaskVC.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface TaskVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    int alertDisplay;
    int width1;
    int height1;
    CGRect screenRect;

}

@property (nonatomic, strong) NSMutableArray *allTaskArray;
@property (nonatomic, strong) NSMutableArray *allTaskArray1;

@property (nonatomic, strong) UITableView *taskTableView;

@property (nonatomic, strong) UISearchBar *taskSearchBar;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) UIView *dimLightView;

- (IBAction) goToComposerMessage:(id)sender;
@end
