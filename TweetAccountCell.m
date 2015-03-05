//
//  TweetAccountCell.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 24/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "TweetAccountCell.h"

@implementation TweetAccountCell{
    int width1;
    int height1;
    CGRect screenRect;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        screenRect = [[UIScreen mainScreen] bounds];
        width1=screenRect.size.width;
        height1=screenRect.size.height;
        // Initialization code
        //self.backView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
       // self.backgroundView = self.backView;
       // [self.contentView addSubview:self.backView];
        
        //border_320
        //UIView *devider=[[UIView alloc]initWithFrame:CGRectMake(0,self.contentView.frame.size.height-10 , 300,10)];
        //devider.backgroundColor=[UIColor colorWithRed:(CGFloat)243/255 green:(CGFloat)114/255 blue:(CGFloat)86/255 alpha:1];
       // [self.contentView addSubview:devider];
        self.contentView.backgroundColor=[UIColor whiteColor];
        self.profilePic = [[UIImageView alloc] init];
                           //WithFrame:CGRectMake(2, 5, 50*width1/320, 50*height1/480)];
        [self.contentView addSubview:self.profilePic];
        
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(55*width1/320, 5, 240*width1/320, 30)];
        self.nameLable.textColor = [UIColor blackColor];
        //self.nameLable.frame = CGRectMake(55*width1/320, 5, 260, 25);
        self.nameLable.backgroundColor=[UIColor clearColor];
        self.nameLable.font = [UIFont boldSystemFontOfSize:width1/18];
    
        [self.contentView addSubview:self.nameLable];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
