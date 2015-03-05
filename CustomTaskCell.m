//
//  CustomTaskCell.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 18/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "CustomTaskCell.h"

@implementation CustomTaskCell{
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

        UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(0,0, self.contentView.frame.size.width,5)];
        devider.backgroundColor=[UIColor colorWithRed:(CGFloat)243/255 green:(CGFloat)114/255 blue:(CGFloat)86/255 alpha:1];

        //[self.contentView addSubview:devider];
        
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5*width1/320, 10*height1/480, 35*width1/320, 35*width1/320)];
        [self.contentView addSubview:self.profileImageView];
        
        self.messageLable = [[UILabel alloc]init];
        self.messageLable.backgroundColor = [UIColor clearColor];
        self.messageLable.textColor = [UIColor blackColor];
        self.messageLable.numberOfLines=0;
        [self.contentView addSubview:self.messageLable];
        
        self.nameLable = [[UILabel alloc] init];
        self.nameLable.textColor = [UIColor blackColor];
        self.nameLable.backgroundColor=[UIColor clearColor];
        self.nameLable.frame = CGRectMake(55, 15, 260, 25);
        self.nameLable.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:self.nameLable];
        
        self.dataLable = [[UILabel alloc] init];
        self.dataLable.textColor = [UIColor redColor];
        self.dataLable.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:self.dataLable];
        
        self.statusLable = [[UILabel alloc] init];
        self.statusLable.textColor = [UIColor darkGrayColor];
        self.statusLable.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:self.statusLable];
        
        self.assigedBy = [[UILabel alloc] init];
        self.assigedBy.textColor = [UIColor colorWithRed:(CGFloat)93/255 green:(CGFloat)145/255 blue:(CGFloat)230/255 alpha:1];
        self.assigedBy.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:self.assigedBy];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
