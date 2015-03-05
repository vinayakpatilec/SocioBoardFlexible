//
//  InboxSettingViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 16/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@protocol UserConnectedAccountDelegate <NSObject>
    

-(void)passSelectedVlue:(NSMutableArray *)selAccounts;
//-(void)passTwitterId:(NSString*)twitterId;
//-(void)passFacebookId:(NSString*)facebookId;
//@optional
//-(void)passLinkedinId:(NSString*)linkedinId;
@end

@interface InboxSettingViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,NSXMLParserDelegate>{
    int width1;
    int height1;
    CGRect screenRect;
    
    UITableView *tableView;
//    NSMutableData *webdata;
//    NSXMLParser *xmlParser;
//    BOOL itmselected;
//    BOOL checkTwitter;
    
    
//    NSString *strTwitterId;
//    NSString *strFacebookId;
//    NSString *strLinkedinId;
    
//    NSMutableArray *arrOauthToken;
//    NSMutableArray *arrOauthSecret;
//    NSMutableArray *arrTwitterUserIds;
    
//    NSMutableArray *arrFbUserId;
//    NSMutableArray *arrEmailId;
//    NSMutableArray *arrAccessToken;
//    NSMutableArray *arrType;
    
//    NSMutableArray *instaAccessToken;
//    NSMutableArray *instaFollowers;
//    NSMutableArray *instaFollowedBy;
//    NSMutableArray *instaTotalImages;
    
//    NSMutableArray *arrTotalUserName;
//    NSMutableArray *arrTotalProfileImage;
//    NSMutableArray *arrUserIds;
    
//    NSMutableDictionary *dictFacebookAccountType;
//    NSMutableArray *arrAccountType;
//    NSIndexPath *lastIndexPath;
//    BOOL checkMark;
//    NSMutableArray *arrCheckmark;
//    NSMutableArray *mark;
    UIImageView *accessoryImageView;
    NSUserDefaults *userDefault;
}

@property (nonatomic, weak) id <UserConnectedAccountDelegate> myDelegate;
//@property(nonatomic, retain) NSMutableArray *profileType;
//@property (nonatomic,retain) NSDictionary *tableContents;
//@property (nonatomic,retain) NSArray *sortedKeys;
//@property (nonatomic,retain) NSMutableArray *arrAccounts;


//=====================================
@property (nonatomic, strong)NSMutableArray *allProfileInfoArray;
@property (nonatomic,retain) NSMutableArray *arrKeywords;
@property (nonatomic,retain) NSMutableArray *arrMessageTypes;

@property (nonatomic, strong) NSMutableArray *accountValueArray;
@property (nonatomic, strong) NSMutableArray *messageTypeValueArray;



@end
