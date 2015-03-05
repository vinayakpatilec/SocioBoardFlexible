//
//  TwitterReplyViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterReplyViewController : UIViewController<UITextViewDelegate>{
    CGFloat yy;
    int count;
    
    int messageCharacterCount;
}
@property (nonatomic, strong) UIImageView *previousSelectedImageView;

@property (nonatomic, strong) NSString *messageIDString;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *titlelable;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView *composerView;
@property (nonatomic, strong) UIImageView *borderImageView;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIButton *sliderButton;

@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UILabel *characterCountLable;

@property (nonatomic, strong) NSArray *allTwitterAccount;
@end
