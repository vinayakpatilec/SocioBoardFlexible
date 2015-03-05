//
//  FBCommentPostViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 22/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBCommentPostViewController : UIViewController<UITextViewDelegate>{
    int width1;
    int height1;
CGRect screenRect;
}

@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) UILabel *placeHolder;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *titlelable;

@property (nonatomic, strong) NSString *accountType;
@property (nonatomic, strong) NSDictionary *dataDict;

-(IBAction)postButtonClicked:(id)sender;
//-(IBAction)cancelButtonClicked:(id)sender;
@end
