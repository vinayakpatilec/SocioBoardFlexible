//
//  CustomScheduleCell.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 05/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "CustomScheduleCell.h"

@implementation CustomScheduleCell{
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

        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, 35*width1/320, 35*width1/320)];
        [self.contentView addSubview:self.profileImageView];
        
        self.nameLable = [[UILabel alloc] init];
        self.nameLable.textColor = [UIColor blackColor];
        self.nameLable.backgroundColor=[UIColor clearColor];
        self.nameLable.font=[UIFont systemFontOfSize:width1/20];
        self.nameLable.frame = CGRectMake(45*width1/320, 13, 165*width1/320, 25*height1/480);
        self.nameLable.font = [UIFont boldSystemFontOfSize:width1/20];
        [self.contentView addSubview:self.nameLable];
        
        self.messageLable = [[UILabel alloc]init];
        self.messageLable.backgroundColor = [UIColor clearColor];
        self.messageLable.textColor = [UIColor blackColor];
        self.messageLable.numberOfLines=0;
        [self.contentView addSubview:self.messageLable];
        
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.textColor = [UIColor redColor];
        self.dateLabel.backgroundColor=[UIColor clearColor];
        self.dateLabel.frame = CGRectMake(180*width1/320, 13, 110*width1/320, 25*height1/480);
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.font = [UIFont fontWithName:@"Arial" size:width1/20];
        [self.contentView addSubview:self.dateLabel];
        
        self.statusLable = [[UILabel alloc] init];
        self.statusLable.textColor = [UIColor redColor];
        self.statusLable.backgroundColor=[UIColor clearColor];
        self.statusLable.frame = CGRectMake(210*width1/320, 35*height1/480, 80*width1/320, 25*height1/480);
        self.statusLable.textAlignment = NSTextAlignmentRight;
        self.statusLable.font = [UIFont fontWithName:@"Arial" size:10];
        [self.contentView addSubview:self.statusLable];
        
        
        
        
        self.byScheduleLable = [[UILabel alloc]init];
        self.byScheduleLable.backgroundColor = [UIColor clearColor];
        self.byScheduleLable.textColor = [UIColor darkGrayColor];
        self.byScheduleLable.numberOfLines=0;
        self.byScheduleLable.font = [UIFont fontWithName:@"Arial" size:width1/22];
        [self.contentView addSubview:self.byScheduleLable];
        
        self.usernameLable = [[UILabel alloc]init];
        self.usernameLable.backgroundColor = [UIColor clearColor];
        self.usernameLable.textColor = [UIColor colorWithRed:(CGFloat)0 green:(CGFloat)49/255 blue:(CGFloat)129/255 alpha:1];
        self.usernameLable.numberOfLines=0;
        self.usernameLable.font = [UIFont fontWithName:@"Arial" size:width1/20];
        //[self.contentView addSubview:self.usernameLable];
        UIImageView *picView=[[UIImageView alloc]init];
        [self.contentView addSubview:picView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
