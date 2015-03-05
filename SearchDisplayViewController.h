//
//  SearchDisplayViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WebView1.h"

@interface SearchDisplayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    int currentSelection;
    int width1;
    int height1;
    CGRect screenRect;

    //CGRect menuViewFrame;
    //CGFloat Height;
    
    //int previousSelectedIndexPathrow;
    //int selectedTwitterAccountRow;
}
@property (nonatomic, assign)int typeOfSearch;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) NSMutableArray *allTweetArray;
@property (nonatomic, strong) NSMutableArray *facebookContacts;
@property (nonatomic, strong) NSMutableArray *twitterContacts;
@property (nonatomic, strong) NSMutableArray *facebookPosts;
@property (nonatomic, strong) NSMutableArray *twitterPosts;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) NSString *searchedString;

@property (nonatomic, strong) IBOutlet UITableView *allTweetTableView;

//--------------------------------
@property (nonatomic, strong)  UIView *secondView;
@property (nonatomic, strong) UITableView *tweeterAccountTableView;
@property (nonatomic, strong) NSArray *twitterAccountArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *can_two_btn;
@end
