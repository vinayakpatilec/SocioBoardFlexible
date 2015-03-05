//
//  ReScheduleViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 14/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReScheduleViewControllerDelegate <NSObject>
-(void) updateScheduleTable:(NSDictionary *)dict;

@end

@interface ReScheduleViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UITableViewDelegate,UINavigationControllerDelegate,UITableViewDataSource>
{
    CGFloat yy;
    int count;
    int messageCharacterCount;
    BOOL isMessagere_Scheduled;
    int selFeedAcc;
   // NSInteger preSelectedImageTag;
    CGFloat hhh;

    BOOL image_selected_new;
    
   
}
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *scheduleButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *titlelable;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *composerView;
@property (nonatomic, strong) UIImageView *borderImageView;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIButton *sliderButton;

@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *schedulButton;
@property (nonatomic, strong) UILabel *characterCountLable;
@property (nonatomic, strong) NSString *datePIckerDate;
@property (nonatomic, strong) NSString *formattedDate; //12 hours format Date
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, weak) id <ReScheduleViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *allConnectcedAccountArray;
@property (nonatomic, strong) NSString *imageAttachedValue;
@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property(nonatomic, strong)UIView *accList;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIImageView *selectedProImageView;

@property (nonatomic, strong) NSDictionary *scheduleDict;
@property (nonatomic, strong) NSDictionary *selectedAccDict;
-(void)doneAction1;
//-------
@end
