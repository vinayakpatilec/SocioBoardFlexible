//
//  Feeds.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 30/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface Feeds : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISearchBarDelegate,MFMessageComposeViewControllerDelegate> {
    int currentSelection;
    CGRect menuCellFrame;
    int accountTypeNum;
    CGFloat heightofText;
    int containPic;
    UIView *mesgBluetoothView;
    NSString *searchWord;
    //--------
    int indexTwitterCell;
    int feedCount;
    long myIndexPath;
    int selectedTable;
    int selectedTwitterAccountRow;
    NSDictionary *conDict;
}
@property(nonatomic,assign)int buttonNum;
@property (nonatomic, strong) IBOutlet UILabel *titleLable;
@property (nonatomic, strong) IBOutlet UIButton *feedSettingBtn;
@property (nonatomic, strong) NSMutableArray *allFeedArray;
@property (nonatomic, strong) NSString *selectedAccTypeStr;
@property (nonatomic, strong) UITableView *feedTableView;
@property (nonatomic, strong)  UIView *moreActionView;
@property (nonatomic, strong)  UIView *bgView;
@property (nonatomic, strong) UIActionSheet *linkedinActionSheet;
@property (nonatomic, strong) UIActionSheet *twitterActionSheet;
@property (nonatomic,strong)UIImage *imageSave;
@property (nonatomic, strong) NSDictionary *selectedAcc1;

@property (nonatomic, strong)IBOutlet UISearchBar *tweetSearchBar;

@property (nonatomic, strong) NSMutableArray *searchArray;

@property (nonatomic, strong)UIView *picView;
@property (nonatomic, strong) UIView *dimlightView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSString *currentSelectedTable;

@property (nonatomic, strong) NSDictionary *selectedAccountDict;

//============================================
//--------------------------------

@property (nonatomic, strong)  UIView *secondView;
@property (nonatomic, strong) UITableView *tweeterAccountTableView;
@property (nonatomic, strong) NSArray *twitterAccountArray;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *can_two_btn;
//============================================

-(IBAction)inboxSettingButtonClicked:(id)sender;
- (IBAction) goToComposerMessage:(id)sender;
- (IBAction)goToConnectedAccountInfo:(id) sender;
-(void)openMessageBluetoothView1;
-(void)moreButtonAction1:(id)sender;
@end
