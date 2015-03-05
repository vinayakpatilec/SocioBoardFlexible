//
//  RePostViewController.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 09/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RePostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
{
    int characterCount;
    
    BOOL isMessageScheduled;
    int width1;
    int height1;
    CGRect screenRect;
    
    //NSInteger rangeCharacter;
}
@property (nonatomic, strong) NSString *selected_acc_Id;

@property (nonatomic, strong)  UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong)  UILabel *titleLable;

@property (nonatomic, strong) UIView *composerView;
@property (nonatomic, strong) UIImageView *borderImageView;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIButton *sliderButton;

@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *schedulButton;
@property (nonatomic, strong) UILabel *characterCountLable;

@property (nonatomic, strong) NSString *profileImage;
@property (nonatomic, strong) NSString *accountType;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@property (nonatomic, strong) NSString *imageAttached;

@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;

- (IBAction) cancelButtonClicked;
- (IBAction) postButtonClicked : (id)sender;
@end
