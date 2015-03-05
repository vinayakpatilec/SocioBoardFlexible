//
//  CustomSearchCell.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 21/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "CustomSearchCell.h"

@implementation CustomSearchCell{
    int width1;
    int height1;
    CGRect screenRect;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        screenRect = [[UIScreen mainScreen] bounds];
        width1=screenRect.size.width;
        height1=screenRect.size.height;
        UIImageView *dividerImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"action-divider"]];
        dividerImageView1.frame = CGRectMake(0, 1, 320, 2);
        [self.contentView addSubview:dividerImageView1];
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,10,50*width1/320,50*width1/320)];
        [self.contentView addSubview:self.profileImageView];
        
        self.messageLable = [[UILabel alloc]init];
        self.messageLable.backgroundColor = [UIColor clearColor];
        self.messageLable.textColor = [UIColor darkGrayColor];
        self.messageLable.numberOfLines=0;
        [self.contentView addSubview:self.messageLable];
        
        self.nameLable = [[UILabel alloc] init];
        self.nameLable.textColor = [UIColor blackColor];
        self.nameLable.frame = CGRectMake(62*width1/320, 15, 240*width1/320, 25);
        self.nameLable.backgroundColor=[UIColor clearColor];
        self.nameLable.font = [UIFont boldSystemFontOfSize:width1/20];
        [self.contentView addSubview:self.nameLable];
        
        //---------------------
        self.menuView = [[UIView alloc]init];
        self.menuView.hidden = YES;
        [self.contentView addSubview:self.menuView];
        
        //self.dividerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 320, 2)];
       // self.dividerImageView.image = [UIImage imageNamed:@"action-divider.png"];
        //[self.menuView addSubview:self.dividerImageView];
        
        self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.moreButton.frame = CGRectMake(100, 9, 35, 35);
        [self.moreButton setBackgroundImage:[UIImage imageNamed:@"action-more"] forState:UIControlStateNormal];
        
        [self.menuView addSubview:self.moreButton];
        
        self.taskButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.taskButton.frame = CGRectMake(200, 9, 35, 35);
        [self.taskButton setBackgroundImage:[UIImage imageNamed:@"action-assign-norm"] forState:UIControlStateNormal];
        
        [self.menuView addSubview:self.taskButton];
        
        self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.replyButton.frame = CGRectMake(250, 9, 35, 35);
        [self.replyButton setBackgroundImage:[UIImage imageNamed:@"action-reply"] forState:UIControlStateNormal];
        
        [self.menuView addSubview:self.replyButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
