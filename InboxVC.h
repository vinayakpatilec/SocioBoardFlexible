//
//  InboxVC.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/04/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "SingletonClass.h"
#import "GroupViewController.h"
#import "InboxSettingViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FBCommentPostViewController.h"
#import "NewTaskViewController.h"

#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
@interface InboxVC : UIViewController<UISearchBarDelegate,UISearchDisplayDelegate,UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, MBProgressHUDDelegate, UserConnectedAccountDelegate, UITableViewDataSource, UITableViewDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate,UIScrollViewAccessibilityDelegate>{
    
    MBProgressHUD *HUD;
  int accType;
    IBOutlet UILabel *labelHeading;
    UIView *mesgBluetoothView;
    CGFloat heightOfRow;
    CGFloat heightofText;
    CGFloat heightofPic;
    //=====================================
    //NSString *find;
    int currentSelection;
     int accountTypeNum;
    CGRect menuCellFrame;
    int selectedTable;
    int isImage;
    //--------
    int selectedTwitterAccountRow;
    NSString *currentSelectedAccountType;
    
    int width1;
    int height1;

}
@property (nonatomic, strong)  UITableView *AllMessageTableView;
//@property (nonatomic, strong) UIActionSheet *actionSheet;
//@property (nonatomic, assign, getter = isPicVisible) BOOL picVisible;

//@property(nonatomic, retain) NSMutableArray *arrProfileType;
//@property(nonatomic, retain) NSMutableArray *arrProfileIds;
//@property(nonatomic, retain) NSMutableArray *arrIds;

//==========================================

@property (nonatomic, strong) UIButton *inboxSettingBtn;
@property (nonatomic, strong) NSMutableArray *allMessageArray;
@property (nonatomic, strong) UIView *menuCellView;
@property (nonatomic,strong) UIView *accInfoVw;
@property (nonatomic,strong) UIImage *imageSave;
@property (nonatomic,assign) int imageNum;


@property (nonatomic, strong) UIActionSheet *fbActionSheet;
@property (nonatomic, strong) UIActionSheet *twitterActionSheet;
@property (nonatomic, strong) UIActionSheet *googleActionSheet;

@property (nonatomic, strong)IBOutlet UISearchBar *messageSearchBar;
@property (nonatomic, strong) UIView *dimLightView;
@property (nonatomic, strong) UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSString *currentTable;
@property(nonatomic,assign)int buttonNum;


//============================================
//--------------------------------
@property (nonatomic, strong)  UIView *secondView;
@property (nonatomic, strong)  UIView *moreActionView;
@property (nonatomic, strong)  UIView *bgView;
@property (nonatomic, strong)UIView *picView;
@property (nonatomic, strong) UITableView *tweeterAccountTableView;
@property (nonatomic, strong) NSArray *twitterAccountArray;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *can_two_btn;
//============================================
- (IBAction)composeMessage:(id)sender;
-(IBAction)webserviceConnectedAccount;
-(IBAction)actionInbox:(id)sender;
-(IBAction)rePostButtonAction1:(id)sender;
@end
