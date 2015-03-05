//
//  SingletonClass.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 12/07/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "SingletonClass.h"
static SingletonClass *sharedSingleton;

@implementation SingletonClass
@synthesize profileID,userName;
@synthesize messagePageAccountArray,messageTypeArray,feedPageAccountArray;
@synthesize accountLoaded;
@synthesize feedSelAcc;
@synthesize haveTwitterAccount;
@synthesize connectedTwitterAccount;
@synthesize connectedFacebookAccount;

+(SingletonClass*)sharedSingleton{
    @synchronized(self){
        
        if(!sharedSingleton){
            sharedSingleton=[[SingletonClass alloc]init];
        }
    }return sharedSingleton;
}
-(CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGFloat result = font.pointSize + 4;
    if (text)
    {
        CGSize textSize = { widthValue, CGFLOAT_MAX };       //Width and height of text area
        CGSize size;
        
            //iOS 7
            CGRect frame = [text boundingRectWithSize:textSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName:font }
                                              context:nil];
            size = CGSizeMake(frame.size.width, frame.size.height+1);
        result = MAX(size.height, result); //At least one row

    }
            return result;
}


-(NSString*) languageSelectedStringForKey:(NSString*) key
{
    NSString *path;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *strLan = [userDefault objectForKey:@"language"];
    
    if([strLan isEqualToString:@"English"])
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
    
    else if([strLan isEqualToString:@"Italic"])
        path = [[NSBundle mainBundle] pathForResource:@"it" ofType:@"lproj"];
    else{
        
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSLog(@"path for resource %@",path);
    }
    NSBundle* languageBundle = [NSBundle bundleWithPath:path];
    NSString* str=[languageBundle localizedStringForKey:key value:@"" table:nil];
    return str;
}


@end
