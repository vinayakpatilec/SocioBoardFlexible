//
//  SingletonClass.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 12/07/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupViewController.h"
@class GroupViewController;

@interface SingletonClass : NSObject{
    
}
@property(nonatomic,strong)NSString *mainProPic;
@property (nonatomic, assign) int teamNo;
@property (nonatomic, assign) int totalTeam;
@property(nonatomic,assign)int typeofTable;
@property(nonatomic,assign)BOOL typeOfCell;
@property (nonatomic, strong) NSString *emailID;
@property (nonatomic, strong) NSString *password;
@property(nonatomic, retain) NSString *profileID;
@property(nonatomic, retain) NSString *teamID;
@property(nonatomic, retain) NSString *groupID;
@property(nonatomic, retain) NSString *userName;
//@property(nonatomic, retain) NSMutableArray *arrTotalAccount;
//@property(nonatomic, retain) NSMutableArray *arrIds;
//@property(nonatomic, retain) NSMutableArray *arrProfileIds;
//@property(nonatomic, retain) NSMutableArray *arrProfileTypes;
//==========================================================
@property (nonatomic, strong)NSMutableArray *connectedprofileInfo;
@property (nonatomic, strong)NSMutableArray *messagePageAccountArray;
@property (nonatomic, strong)NSMutableArray *feedPageAccountArray;
@property (nonatomic, strong) NSMutableArray *messageTypeArray;
@property (nonatomic, strong) NSMutableArray *teamArray;

@property (nonatomic, assign) BOOL accountLoaded;
@property (nonatomic, assign) int feedSelAcc;
@property (nonatomic, assign) int schedulePreSelected;
@property (nonatomic, assign) BOOL haveTwitterAccount;
@property (nonatomic,strong) NSArray *connectedTwitterAccount;
@property (nonatomic, strong) NSArray *connectedFacebookAccount;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++
@property (nonatomic, strong) NSArray *connectedLinkedinAccount;
@property (nonatomic, strong) NSArray *connectedUtubeAccount;
@property (nonatomic, strong) NSArray *connectedInstagramAccount;
@property (nonatomic, strong) NSArray *connectedTumblerAccount;
//---------------------------------------------
@property (nonatomic, strong) NSMutableArray *messageSelectedAccounts;

//----------------------------------------------
@property (nonatomic, strong) NSArray *groupIDArray;

@property (nonatomic, assign) NSInteger remainDays;
@property(nonatomic,strong)NSMutableArray *allGrpProfileArray;
//==========
+(SingletonClass*)sharedSingleton;
-(CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font;
-(NSString*) languageSelectedStringForKey:(NSString*) key;
@end
