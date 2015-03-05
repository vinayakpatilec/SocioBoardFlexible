//
//  ManageTaskViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 20/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

@protocol ManageTaskViewControllerDelegate <NSObject>

-(void)taskUpdated:(NSDictionary *)updatedDict;

@end
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ManageTaskViewController : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    CGFloat yy;
    UITableView *commentsTable;
    NSArray *commentArray;
    int heightText;
    int width1;
    int height1;
    CGRect screenRect;

}
@property (nonatomic, weak) id <ManageTaskViewControllerDelegate> delegate;
@property (nonatomic, strong)  UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titlelable;
@property(nonatomic,strong)UITextView *comment;
@property (nonatomic, strong) NSDictionary *dataDict;
@property (strong, nonatomic)UILabel *status;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UILabel *placeHolder;
@property (nonatomic,strong)UITextView *diplayAllComments;


@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *messageLable;
@property (nonatomic, strong) UIView *secondView;

@property (nonatomic, strong) UILabel *assignLable;
@property (nonatomic, strong) UILabel *statusLable;
@property (nonatomic, strong) UISegmentedControl *statusSegmentControl;
@property (nonatomic, strong) NSString *statusValue;


@property (nonatomic, strong) UILabel *commentLabel;

@end
