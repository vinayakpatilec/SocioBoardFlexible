//
//  NewTaskViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 22/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface NewTaskViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

{
    CGFloat yy;
    int width1;
    int height1;
    CGRect screenRect;
}

@property (nonatomic, assign) CGRect frame;

@property (nonatomic, strong)  UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titlelable;
@property (nonatomic) UIButton *groupButton;
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) UITextView *comment;
@property (nonatomic, strong) UILabel *placeHolder;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *messageLable;
@property (nonatomic, strong) UIView *secondView;

@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UIButton *saveButton;
//---------------
@property (nonatomic, strong) NSString *selectedGroupID;
@property (nonatomic, strong) NSArray *groupIDArray;

@property (nonatomic) UITableView *groupTableView;

-(IBAction)cancelButtonClicked:(id)sender;
@end
