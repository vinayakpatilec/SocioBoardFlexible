//
//  FeedInboxViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 26/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeedInboxViewVontrollerDelegate <NSObject>

- (void)  selectedAccountInfo:(NSDictionary *)accInfo;

@end

@interface FeedInboxViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int selFeedAcc;
    int width1;
    int height1;
    CGRect screenRect;

   
}
@property (nonatomic, weak) id <FeedInboxViewVontrollerDelegate> delegate;
@property (nonatomic, strong) UITableView *accountTableView;
@property (nonatomic, strong) NSMutableArray *feedAccountArray;
@end



