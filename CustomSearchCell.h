//
//  CustomSearchCell.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 21/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSearchCell : UITableViewCell
@property (nonatomic, strong) UILabel *messageLable;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UIImageView *profileImageView;

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *taskButton;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UIImageView *dividerImageView;
@end
