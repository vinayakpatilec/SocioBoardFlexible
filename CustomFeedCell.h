//
//  CustomFeedCell.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 08/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomFeedCell : UITableViewCell{
    int width1;
    int height1;
    CGRect screenRect;
}

@property (nonatomic) UITextView *messageTxtView;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *dateLable;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic ,strong) UIButton *menuButton;
@property(nonatomic,strong) UIImageView *picView;
@property(nonatomic,strong) UILabel *like1;

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic ,strong) UIButton *moreButton;
@property (nonatomic ,strong) UIButton *taskButton;
@property (nonatomic ,strong) UIButton *repostButton;
@property (nonatomic, strong) UIImageView *dividerImageView;
@end
