//
//  MessageCustomCell.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 21/10/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "MessageCustomCell.h"

@implementation MessageCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        screenRect = [[UIScreen mainScreen] bounds];
        width1=screenRect.size.width;
        height1=screenRect.size.height;

        
        UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1-10,4*height1/480)];
        devider.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
        [self.contentView addSubview:devider];

        
        self.profilePicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 40, 40)];
        [self.contentView addSubview:self.profilePicImageView];
        //self.textLabel.frame = CGRectMake(60, 5, 250, 300);
        
        
        self.messageTxtView = [[UITextView alloc] initWithFrame:CGRectMake(5, 60, 200, 30)];
              self.messageTxtView.editable = NO;
        self.messageTxtView.scrollsToTop = NO;
        self.messageTxtView.userInteractionEnabled = NO;
        self.messageTxtView.textAlignment = NSTextAlignmentLeft;
        self.messageTxtView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.messageTxtView];
        
        
        self.nameLable = [[UILabel alloc] init];
        self.nameLable.textColor = [UIColor blackColor];
        self.nameLable.backgroundColor=[UIColor clearColor];
        self.nameLable.font = [UIFont boldSystemFontOfSize:14];
        self.nameLable.frame = CGRectMake(60, 15, 180, 25);
        [self.contentView addSubview:self.nameLable];
        
        self.dateLable = [[UILabel alloc] init];
        self.dateLable.textColor = [UIColor blackColor];
        self.dateLable.backgroundColor=[UIColor clearColor];
        self.dateLable.font = [UIFont systemFontOfSize:12.0f];
        self.dateLable.frame = CGRectMake(width1-95, 15, 65, 25);
        [self.contentView addSubview:self.dateLable];
        
        self.picImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.picImageView];
        
        self.menuView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, width1-10, 50)];
        self.menuView.hidden = YES;
        [self.contentView addSubview:self.menuView];
        
        self.dividerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1,width1, 2)];
        self.dividerImageView.image = [UIImage imageNamed:@"action-divider.png"];
        [self.menuView addSubview:self.dividerImageView];
        
        self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.moreButton.frame = CGRectMake(width1-230, 9, 35, 35);
        [self.moreButton setBackgroundImage:[UIImage imageNamed:@"action-more"] forState:UIControlStateNormal];
        [self.menuView addSubview:self.moreButton];
        
        
        self.taskButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.taskButton.frame = CGRectMake(width1-130, 9, 35, 35);
        [self.taskButton setBackgroundImage:[UIImage imageNamed:@"action-assign-norm"] forState:UIControlStateNormal];
        [self.menuView addSubview:self.taskButton];
        
        
        
       self.repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.repostButton.frame = CGRectMake(width1-80, 9, 35, 35);
        [self.repostButton setBackgroundImage:[UIImage imageNamed:@"action-reply"] forState:UIControlStateNormal];
        [self.menuView addSubview:self.repostButton];
        
        
        _menuButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        _menuButton.backgroundColor=[UIColor whiteColor];
        [_menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.contentView addSubview:_menuButton];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}
@end
