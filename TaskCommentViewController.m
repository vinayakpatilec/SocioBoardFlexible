//
//  TaskCommentViewController.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 20/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "TaskCommentViewController.h"

@interface TaskCommentViewController ()

@end

@implementation TaskCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Creating UI
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 55)];
    [self.view addSubview:self.headerView];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    UIColor *firstColor = [UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    UIColor *lastColor =[UIColor colorWithRed:(CGFloat)255/255 green:(CGFloat)106/255 blue:(CGFloat)63/255 alpha:1.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[firstColor CGColor], (id)[lastColor CGColor],(id)[firstColor CGColor], nil];
    
    [self.headerView.layer insertSublayer:gradient atIndex:0];
    
    
    //------------------------------------------------------
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(10, 20, 50, 27);
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
    self.cancelButton.layer.borderWidth=1.0f;
    self.cancelButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.cancelButton.clipsToBounds = YES;
    
    [self.cancelButton setTitle:[[SingletonClass sharedSingleton] languageSelectedStringForKey:@"cancelMsg"] forState:UIControlStateNormal];
    [self.headerView addSubview:self.cancelButton];
    //------------------------------------------------------
    self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.previewButton.frame = CGRectMake(260, 20, 50, 27);
    [self.previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.previewButton.titleLabel.font = [UIFont fontWithName:@"Bodoni 72 Oldstyle" size:14.0f];
    [self.previewButton addTarget:self action:@selector(previewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.previewButton.layer.backgroundColor=[UIColor colorWithRed:(CGFloat)250/255 green:(CGFloat)174/255 blue:(CGFloat)220/255 alpha:.1].CGColor;;
    self.previewButton.layer.borderWidth=1.0f;
    self.previewButton.layer.borderColor = [UIColor colorWithRed:(CGFloat)218/255 green:(CGFloat)63/255 blue:(CGFloat)27/255 alpha:1].CGColor;
    self.previewButton.layer.cornerRadius = 5.0f;
    self.previewButton.clipsToBounds = YES;
    
    [self.previewButton setTitle:@"Preview" forState:UIControlStateNormal];
    [self.headerView addSubview:self.previewButton];
    
    //---------------------------------
    self.titlelable = [[UILabel alloc] initWithFrame:CGRectMake(70, 17, 180, 30)];
    self.titlelable.backgroundColor = [UIColor clearColor];
    self.titlelable.textAlignment = NSTextAlignmentCenter;
    self.titlelable.textColor = [UIColor whiteColor];
    self.titlelable.text = @"Task Comment";
    [self.headerView addSubview:self.titlelable];
    
//**********************************************************
    self.commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 55, 320, 200)];
    self.commentTextView.font = [UIFont systemFontOfSize:17];
    self.commentTextView.backgroundColor = [UIColor whiteColor];
    self.commentTextView.text = self.composedMessage;
    [self.commentTextView becomeFirstResponder];
    
    [self.view addSubview:self.commentTextView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - 
//Cancel Button Action
-(void) cancelButtonClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//Preview Button Action
//Pass added comment as a message to delegate method defined in Owner Class(Previous Class)
-(void) previewButtonClicked:(id) sender{
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(commentForTask:)]) {
        [self.delegate commentForTask:self.commentTextView.text];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
