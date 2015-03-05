//
//  TaskCommentViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 20/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

@protocol TaskCommentViewControllerDetegate <NSObject>

-(void) commentForTask :(NSString *)composedMessage;

@end
#import <UIKit/UIKit.h>
#import "SingletonClass.h"
@interface TaskCommentViewController : UIViewController
@property (nonatomic, weak) id <TaskCommentViewControllerDetegate> delegate;
@property (nonatomic, strong)  UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UILabel *titlelable;
@property (nonatomic, strong) UITextView *commentTextView;

@property (nonatomic, strong) NSString *composedMessage;
@end
