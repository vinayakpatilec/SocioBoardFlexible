//
//  TabBarView.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 25/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "TabBarView.h"
#import "AppDelegate.h"
@interface TabBarView ()

@end

@implementation TabBarView

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
    
        //CGFloat height = [[UIScreen mainScreen] bounds].size.height;
        //NSLog(@"Height==%f",height);
        //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    // Setting Appearance of TabBarView
    
        //[[UITabBar appearance] setSelectedImageTintColor:[UIColor redColor]];
    /*
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"transparent.png"]];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    
        //[[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor clearColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
        //self.myTabBarController.tabBar.alpha=1;
    
    self.myTabBarController.tabBar.frame = CGRectMake(0,self.view.frame.size.height-100, 320, 50);
    //self.myTabBarController.tabBar.backgroundColor=[UIColor clearColor];
    
    self.myTabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"bottom_tab_new-2.png"];
    //Setting TabBarController as a Root View Controller for Window
    //self.window.rootViewController = self.tabBarController;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:self.myTabBarController];
    
    */
    
    UINavigationController *nc1;
    nc1 = [[UINavigationController alloc] init];
    [nc1.navigationBar setTintColor:[UIColor blackColor]];
    
    
    InboxVC *inbox=[[InboxVC alloc]initWithNibName:@"InboxVC" bundle:nil];
    nc1.viewControllers = [NSArray arrayWithObjects:inbox, nil];
    
    UINavigationController *nc2;
    nc2 = [[UINavigationController alloc] init];
    [nc2.navigationBar setTintColor:[UIColor blackColor]];
   Feeds *feed=[[Feeds alloc]initWithNibName:@"Feeds" bundle:nil];
    nc2.viewControllers = [NSArray arrayWithObjects:feed, nil];
    
    
     TaskVC *task=[[TaskVC alloc]initWithNibName:@"TaskVC" bundle:nil];
    UINavigationController *nc3;
    nc3 = [[UINavigationController alloc] init];
    [nc3.navigationBar setTintColor:[UIColor blackColor]];
    
    nc3.viewControllers = [NSArray arrayWithObjects:task, nil];
    
    SchedulerVC *schdule=[[SchedulerVC alloc]initWithNibName:@"Schediuler" bundle:nil];
    SearchVC *search=[[SearchVC alloc]initWithNibName:@"SearchVC" bundle:nil];
    UINavigationController *nc4;
    nc4 = [[UINavigationController alloc] init];
    [nc4.navigationBar setTintColor:[UIColor blackColor]];
    
    nc4.viewControllers = [NSArray arrayWithObjects:schdule, nil];
    
    
    
    
    UINavigationController *nc5;
    nc5 = [[UINavigationController alloc] init];
    [nc5.navigationBar setTintColor:[UIColor blackColor]];
    
    nc5.viewControllers = [NSArray arrayWithObjects:search, nil];

    
    self.tabBarController = [[UITabBarController alloc] init];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:nc1, nc2,nc3,nc4 ,nil];
    

    
    
    
    self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"bottom_tab_new-2.png"];
    self.tabBarController.tabBar.frame = CGRectMake(0,self.view.frame.size.height-100, 320, 50);

    
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor],
                              UITextAttributeFont:[UIFont boldSystemFontOfSize:16.0f]}
     forState:UIControlStateNormal];
    
        //set the tab bar title appearance for selected state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor blueColor],
                               UITextAttributeFont:[UIFont boldSystemFontOfSize:16.0f]}
     forState:UIControlStateHighlighted];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"transparent.png"]];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    
        // AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        //[appDelegate.window addSubview:self.tabBarController];
    self.tabBarController.delegate=self;
        //[self.view addSubview:self.tabBarController];
    [self presentViewController:self.tabBarController animated:YES completion:nil];

        //[appDelegate.window setRootViewController:self.tabBarController];
    
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end