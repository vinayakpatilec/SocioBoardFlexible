//
//  ComposeMessageViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 09/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ComposeMessageViewControllerDelegate <NSObject>

-(void) updateSelectedDraftMessage:(NSDictionary *)dict;
-(void) removeDeletedDraftMessage:(NSDictionary *)dict;

@end

@interface ComposeMessageViewController : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CGFloat yy;
    int selectionCount;
    int count;
    int messageCharacterCount;
    UIImageView *accessoryImageView;
    int selectedTwitterAccCount;
    UITableView *frdList;
    BOOL isMessageScheduled;
    CGFloat hhh;

       
}
@property (nonatomic,weak) id <ComposeMessageViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UILabel *titlelable;
@property (nonatomic, strong) UILabel *placeHolder;


@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *composerView;
@property (nonatomic, strong) UIImageView *borderImageView;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIButton *sliderButton;
@property (nonatomic, strong) UIActionSheet *actionSheet;

@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *schedulButton;
@property (nonatomic, strong) UILabel *characterCountLable;

@property (nonatomic, strong) UIImageView *selectedImageView;

@property (nonatomic, assign) BOOL isDraftMessages;
@property (nonatomic, strong) NSMutableDictionary *draftDict;

@property (nonatomic, strong) NSString *scheduledDate;
@property (nonatomic, strong) NSMutableArray *allConnectcedAccountArray;
@property (nonatomic, strong) NSMutableArray *selectedAccount;
@property (nonatomic, strong) NSMutableArray *accountValueArray;

//-------
@property (nonatomic, strong) NSString *imageAttachedValue;
@property(nonatomic, strong)UIView *accList;


@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;
//---------
- (IBAction) cancelButtonAction: (id) sender;
- (IBAction) sendButtonAction :(id) sender;
@end
