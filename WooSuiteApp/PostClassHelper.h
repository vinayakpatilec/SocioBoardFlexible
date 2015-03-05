//
//  PostClassHelper.h
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 15/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface PostClassHelper : NSObject <ASIHTTPRequestDelegate>

- (NSMutableDictionary *)getFaceBookUserDetails:(NSMutableDictionary *)dataDict;
-(NSString *) getTwitterUserDeatails: (NSMutableDictionary *)dataDict;
-(NSString *) getLinkedinUserDetails: (NSMutableDictionary *)dataDict;
-(NSString *) getTumblrUserDeatails: (NSMutableDictionary *)dataDict;
@end
