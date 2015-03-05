//
//  MessageCustomCell.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 21/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCustomCell : UITableViewCell{
    int width1;
    int height1;
    CGRect screenRect;

}

@property (nonatomic, strong) UIImageView *profilePicImageView;
@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UILabel *dateLable;
@property (nonatomic, strong) UIImageView *picImageView;

@property (nonatomic) UITextView *messageTxtView;

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic ,strong) UIButton *menuButton;
@property (nonatomic ,strong) UIButton *moreButton;
@property (nonatomic ,strong) UIButton *taskButton;
@property (nonatomic ,strong) UIButton *repostButton;
@property (nonatomic, strong) UIImageView *dividerImageView;
@property(nonatomic ,strong)UIButton *openHiddenViewBut;


@end
