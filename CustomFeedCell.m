//
//  CustomFeedCell.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 08/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "CustomFeedCell.h"

@implementation CustomFeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //UIImageView *dividerImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"action-divider"]];
       // dividerImageView1.frame = CGRectMake(0, 1, 320, 2);
        //[self.contentView addSubview:dividerImageView1];
        
        screenRect = [[UIScreen mainScreen] bounds];
        width1=screenRect.size.width;
        height1=screenRect.size.height;

        
        UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width1,4*height1/480)];
        devider.backgroundColor=[UIColor colorWithRed:(CGFloat)RColor/255 green:(CGFloat)Gcolor/255 blue:(CGFloat)Bcolor/255 alpha:1];
        [self.contentView addSubview:devider];
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, 30*width1/320, 30*width1/320)];
        [self.contentView addSubview:self.profileImageView];
        
        
        self.messageTxtView = [[UITextView alloc] init];//WithFrame:CGRectMake(5, 5, 200, 50)];
        //self.jokeTxtView.layer.backgroundColor = [UIColor redColor].CGColor;
        self.messageTxtView.editable = NO;
        self.messageTxtView.scrollsToTop = NO;
        self.messageTxtView.userInteractionEnabled = NO;
        self.messageTxtView.textAlignment = NSTextAlignmentLeft;
        self.messageTxtView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.messageTxtView];
        
        self.nameLable = [[UILabel alloc] init];
        self.nameLable.frame = CGRectMake(50*width1/320, 13, 180*width1/320, 25);
        self.nameLable.textColor = [UIColor blackColor];
        self.nameLable.font = [UIFont boldSystemFontOfSize:width1/22];
        self.nameLable.backgroundColor=[UIColor clearColor];
        //self.nameLable.font = [UIFont fontWithName:@"Arials" size:14];
        [self.contentView addSubview:self.nameLable];
        
        self.dateLable = [[UILabel alloc] init];
        self.dateLable.textColor = [UIColor blackColor];
        self.dateLable.backgroundColor=[UIColor clearColor];
        self.dateLable.font = [UIFont systemFontOfSize:width1/30];
        self.dateLable.frame = CGRectMake(width1-(95*width1/320), 13, (70*width1/320), 25);
        [self.contentView addSubview:self.dateLable];
        
        
        
        self.like1=[[UILabel alloc]init];
        [self.contentView addSubview:self.like1];

        //---------------------
        self.menuView = [[UIView alloc]init];
        self.menuView.hidden = YES;
        [self.contentView addSubview:self.menuView];
        
        self.dividerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, width1, 2)];
        self.dividerImageView.image = [UIImage imageNamed:@"action-divider.png"];
        [self.menuView addSubview:self.dividerImageView];
        
        self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.moreButton.frame = CGRectMake(width1-230, 9, 35, 35);
        //40, 9, 35, 35
        [self.moreButton setBackgroundImage:[UIImage imageNamed:@"action-more"] forState:UIControlStateNormal];
       
        
        
        
        self.taskButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.taskButton.frame = CGRectMake(width1-130, 9, 35, 35);
        //135, 9, 35, 35
        [self.taskButton setBackgroundImage:[UIImage imageNamed:@"action-assign-norm"] forState:UIControlStateNormal];
        

        
        self.repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.repostButton.frame = CGRectMake(width1-80, 9, 35, 35);
        [self.repostButton setBackgroundImage:[UIImage imageNamed:@"action-reply"] forState:UIControlStateNormal];
        
        self.picView=[[UIImageView alloc]init];
        [self.contentView addSubview:self.picView];
        
        
        
        //[self.menuView addSubview:self.repostButton];
        _menuButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[_menuButton setTitle:@":" forState:UIControlStateNormal];
        [_menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
       

       // _menuButton.backgroundColor=[UIColor blackColor];
        

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
