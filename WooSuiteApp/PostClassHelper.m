//
//  PostClassHelper.m
//  WooSuiteApp
//
//  Created by Sumit Ghosh on 15/11/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "PostClassHelper.h"
#import "SingletonClass.h"
#import "SBJson.h"
#import "HelperClass.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "FHSTwitterEngine.h"
#import "JSONKit.h"
#import "OAuthConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"
#import "OATokenManager.h"
#import "OADataFetcher.h"
#import "OAServiceTicket.h"


@interface PostClassHelper(){
    
}
@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, strong) OAToken *LinkedinAccessToken;
@end
@implementation PostClassHelper

#pragma mark-
#pragma mark Get User Details
//Get selected Facebook account details
- (NSMutableDictionary *)getFaceBookUserDetails:(NSMutableDictionary *)dataDict{
    NSString *returnString;
    NSString *fbID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserid = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Facebook-=-= %@",fbID);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<getFacebookAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<ProfileId>%@</ProfileId>\n"
                             "</getFacebookAccountDetailsById>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserid,fbID];
    
    NSLog(@"soapMessg facebook %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/FacebookAccount.asmx?op=getFacebookAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.00];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/getFacebookAccountDetailsById" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
   
    NSLog(@"%@",msglength);
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
   
    if (error) {
        NSLog(@"Error == %@", error);
        //returnString = @"error";
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"Rersponse String = %@", responseString);
        
        NSString *response = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
        //Fetch access token
        NSString *accessToken = [dict objectForKey:@"AccessToken"];
        NSLog(@"Info Dict = %@", dict);
        
        NSString *imageAttached = [dataDict objectForKey:@"ImageAttachValue"];
        NSDictionary *postDict = nil;
        //check if image attached
        if ([imageAttached isEqualToString:@"1"]) {
            //post on facebook with image
            returnString=  [self postOnFacebookWithImage:dataDict withAccessToken:accessToken];
            
            postDict=[returnString JSONValue];
            [dataDict setObject:[postDict objectForKey:@"id"] forKey:@"MessageId"];
            [dataDict setObject:[[postDict objectForKey:@"picture"] stringByReplacingOccurrencesOfString:@"\\" withString:@""] forKey:@"Picture"];
            
        }
        else{
            //post on facebook without image
            returnString =  [self postOnFacebookWithoutImage:dataDict withAccessToken:accessToken];
            if ([returnString isEqualToString:@"error"]) {
                [dataDict setObject:@"error" forKey:@"MessageId"];
            }
            else{
                postDict=[returnString JSONValue];
                [dataDict setObject:[postDict objectForKey:@"id"] forKey:@"MessageId"];
                [dataDict setObject:@"null" forKey:@"Picture"];
            }
            
        }
    }
    return dataDict;
}

#pragma mark-





//Get selected Twitter account details
-(NSString *) getTwitterUserDeatails: (NSMutableDictionary *)dataDict{
    
    NSString *returnString = nil;
    
    NSString *proID = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Twitter-=-= %@",proID);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetTwitterAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<ProfileId>%@</ProfileId>\n"
                             "</GetTwitterAccountDetailsById>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserId,proID];
    
    NSLog(@"soapMessg twitter  %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/TwitterAccount.asmx?op=GetTwitterAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetTwitterAccountDetailsById" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString = @"error";
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"Rersponse String = %@", responseString);
        
        NSString *response = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        
        NSDictionary *dict = [jsonString JSONValue];
        NSLog(@"Info Dict = %@", dict);
        
//        NSString *aOthToken = [NSString stringWithFormat:@"%@",[dict objectForKey:@"OAuthToken"]];
//        NSString *aOthSecrate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"OAuthSecret"]];
       // NSLog(@"aOthToken = %@",aOthToken);
        //NSLog(@"aothSecrate = %@",aOthSecrate);
        
        NSString *imageAttached = [dataDict objectForKey:@"ImageAttachValue"];
        
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TwitterConsumerKey  andSecret:TwitterSecretKey];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        // NSError *returnCode = nil;
        NSString *twitterResponseStr = nil;
        NSString *messageText = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ComposedMessage"]];
        
        NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
        NSDictionary *respoDict= nil;
        
        //Check image attach or not
        if ([imageAttached isEqualToString:@"1"]) {
            UIImage *originalImage = [dataDict objectForKey:@"SelectedImage"];
            //convert selected image in NSData
            NSData *data = UIImageJPEGRepresentation(originalImage, .5);
            //POst on twitter with image
            twitterResponseStr = [[FHSTwitterEngine sharedEngine] newPostTweet:messageText withImageData:data aouthTokenDictionary:dict];
        }
        else{
            //post on twitter without image
            twitterResponseStr = [[FHSTwitterEngine sharedEngine] newPostTweet:messageText aouthTokenDictionary:dict];
            }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (![twitterResponseStr isEqualToString:@"error"]) {
            respoDict = [twitterResponseStr JSONValue];
            NSLog(@"%@",twitterResponseStr);
            //Fetch require data after twitter post
            [returnDict setObject:@"Twitter" forKey:SocialAccountType];
            [returnDict setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileImageUrl"]] forKey:@"FromProfileUrl"];
            [returnDict setObject:messageText forKey:@"TwitterMsg"];
            [returnDict setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterScreenName"]] forKey:@"FromScreenName"];
            [returnDict setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"TwitterUserId"]] forKey:@"ProfileId"];
            [returnDict setObject:[NSString stringWithFormat:@"%@",[respoDict objectForKey:@"id"]] forKey:@"MessageId"];
            [returnDict setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"NewDate"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Update Message Table" object:returnDict];
            
            returnString = @"success";
        }
        else{
            NSLog(@"Error to Pos Twitter==");
            returnString = @"error";
            
        }
    }
    return returnString;
    
}
#pragma mark -
//Get selected Linkedin account details
-(NSString *) getLinkedinUserDetails: (NSMutableDictionary *)dataDict{
    
    NSString *returnString = nil;
    
    NSString *proId = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Linkedin-=-= %@",proId);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetLinkedinAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<LinkedinId>%@</LinkedinId>\n"
                             "</GetLinkedinAccountDetailsById>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserId,proId];
    
    NSLog(@"soapMessg twitter  %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/LinkedinAccount.asmx?op=GetLinkedinAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetLinkedinAccountDetailsById" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString = @"error";
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"Rersponse String = %@", responseString);
        
        NSString *response = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
        NSLog(@"Info Dict = %@", dict);
        
        NSString *message = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ComposedMessage"]];
        //post on Linkedin
       returnString =  [self postToLinkedin:dict composedMessage:message];
    }
    return returnString;
}

#pragma mark-


//Get selected Twitter account details
-(NSString *) getTumblrUserDeatails: (NSMutableDictionary *)dataDict{

    NSString *returnString = nil;
    
    NSString *proId = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileId"]];
    NSString *strUserId = [SingletonClass sharedSingleton].profileID;
    NSLog(@"profile id Linkedin-=-= %@",proId);
    NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<GetTumblrAccountDetailsById xmlns=\"http://tempuri.org/\">\n"
                             "<UserId>%@</UserId>\n"
                             "<ProfileId>%@</ProfileId>\n"
                             "</GetTumblrAccountDetailsById>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n",strUserId,proId];
    
    NSLog(@"soapMessg Tumblr  %@",soapmessage);
    NSString *str= [NSString stringWithFormat:@"%@/Services/TumblrAccount.asmx?op=GetTumblrAccountDetailsById",WebLink];
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"http://tempuri.org/GetTumblrAccountDetailsById" forHTTPHeaderField:@"SOAPAction"];
    [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSLog(@"%@",msglength);
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error == %@", error);
        returnString = @"error";
    }
    else{
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"Rersponse String = %@", responseString);
        
        NSString *response = [HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
        NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
        NSLog(@"Json String= %@",jsonString);
        NSDictionary *dict = [jsonString JSONValue];
        NSLog(@"Info Dict = %@", dict);
        
        NSString *message = [NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ComposedMessage"]];
        //post on Linkedin
       
    }
    return returnString;

}




//--------------------------------------------------------------
#pragma mark -
#pragma mark facebook Post Method
//Post on facebook with image
//Post selected image
- (NSString *) postOnFacebookWithImage :(NSMutableDictionary *)dict withAccessToken:(NSString *)accessToken{
    NSString *returnString=nil;
    NSString *strText = [dict objectForKey:@"ComposedMessage"];
    UIImage *originalImage = [dict objectForKey:@"SelectedImage"];
    
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setStringEncoding:NSUTF8StringEncoding];
    [request setFile:UIImageJPEGRepresentation(originalImage, 100.0f) withFileName:[NSString stringWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSinceNow]] andContentType:@"image/jpg" forKey:@"imageFile"];
    
    [request setPostValue:strText forKey:@"message"];
    [request setPostValue:accessToken forKey:@"access_token"];
    NSError *error;
    [request startSynchronous];
    
    error = [request error];
    if (error) {
        NSLog(@"error=%@",error);
        returnString = @"error";
    }
    else{
        NSString *response = [request responseString];
        NSLog(@"response with image method= %@",response);
        
        if ([response rangeOfString:@"error"].location != NSNotFound) {
            returnString = @"error";
        }
        else{
            returnString = [self sendToPhotosFinished:request withAccessToken:accessToken];
            return returnString;

        }
    }
    return returnString;
}
#pragma mark-
//post on wall with imaege
- (NSString *)sendToPhotosFinished:(ASIHTTPRequest *)request withAccessToken:(NSString *)accessToken
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    NSMutableDictionary *responseJSON = [responseString JSONValue];
    NSString *photoId = [responseJSON objectForKey:@"id"];
    NSLog(@"Photo id is: %@", photoId);
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@", photoId,accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *newRequest = [ASIHTTPRequest requestWithURL:url];
    NSError *error;
    [newRequest startSynchronous];
    error = [newRequest error];
    NSString *response = nil;
    if (error) {
        NSLog(@"error=%@",error);
        response =  @"error";
    }
    else{
        response = [newRequest responseString];
        NSLog(@"response photo finished= %@",response);
        if ([response rangeOfString:@"error"].location != NSNotFound) {
            return @"error";
        }
        else{
            return response;
        }
        
        
    }
    return response;
}
#pragma mark without Image
//Post on facebook without image
-(NSString *)postOnFacebookWithoutImage: (NSMutableDictionary *)dict withAccessToken:(NSString *)accessToken{
    NSString *returnString = nil;
    NSString *strText = [dict objectForKey:@"ComposedMessage"];;
    NSString *proId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ProfileId"]];
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/feed",proId];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:strText forKey:@"message"];
    [request setPostValue:accessToken forKey:@"access_token"];
    NSError *error;
    [request startSynchronous];
    error = [request error];
    if (error) {
        NSLog(@"error=%@",error);
        returnString = @"error";
    }
    else{

        NSString *response = [request responseString];
        NSLog(@"response = %@",response);
        if ([response rangeOfString:@"error"].location != NSNotFound) {
            returnString = @"error";
        }
        else{
            returnString = response;
        }
        
    }
    return returnString;
}

- (void)postToWallFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    NSMutableDictionary *responseJSON = [responseString JSONValue];
    NSString *postId = [responseJSON objectForKey:@"id"];
    NSLog(@"Post id is: %@", postId);
    
    if (postId) {
        //        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sucessfully posted to wall!" message:@"Check out your Facebook to see!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [av show];
        NSLog(@"Facebook Post Completed");
    }
}
#pragma mark-

#pragma mark Linkedin Post
- (NSString *) postToLinkedin:(NSDictionary *)dataDict composedMessage:(NSString *)message{
    
    NSString *returnString = nil;
    // get OAuthToke and OAuthSecret
    
    NSString *gotkeyValue = [[NSString alloc] initWithFormat:@"%@",[dataDict objectForKey:@"OAuthToken"]];
    NSString *gotSecretKayValue = [[NSString alloc] initWithFormat:@"%@",[dataDict objectForKey:@"OAuthSecret"]];
    
    self.consumer = [[OAConsumer alloc] initWithKey:LinkedinAPIKey secret:LinkedinSecretKey realm:RealMLink];
    self.LinkedinAccessToken = [[OAToken alloc] initWithKey:gotkeyValue secret:gotSecretKayValue];
    
    //url for Linkedin post
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/shares"];
    
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:self.consumer
                                       token:self.LinkedinAccessToken
                                    callback:nil
                           signatureProvider:nil];
    
    NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[NSDictionary alloc]
                             initWithObjectsAndKeys:
                             @"anyone",@"code",nil], @"visibility",
                            message, @"comment", nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    
    NSString *updateString = [update JSONString];
    [request setHTTPBodyWithString:updateString];
	[request setHTTPMethod:@"POST"];

    NSHTTPURLResponse *httpResponse = nil;
    NSError *error = nil;
    [request prepare];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
   
    //Check Error
    if (error) {
        NSLog(@"Error in Linkedin Post== %@", error);
        returnString = @"error";
        
    }
    else{
        
        NSMutableDictionary *dict= [[NSMutableDictionary alloc]init];
        [dict setObject:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"LinkedinUserId"]] forKey:@"ProfileId"];
        [dict setObject:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"ProfileImageUrl"]] forKey:@"FromPicUrl"];
        [dict setObject:message forKey:@"Feeds"];
        [dict setObject:[NSString stringWithFormat:@"%@",[dataDict objectForKey:@"LinkedinUserName"]] forKey:@"FromName"];
        [dict setObject:@"" forKey:@"MessageId"];
        [dict setObject:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"NewDate"];
        [dict setObject:@"Linkedin" forKey:SocialAccountType];
        //Pass notification after Linkedin POst
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Update Linkedin Table" object:dict];
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        responseString = nil;
        NSLog(@"RResponse String = %@", responseString);
        returnString = @"success";
    }
    return returnString;
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    // The next thing we want to do is call the network updates
    //[self networkApiCall];
    //NSLog(@"Result Data -  =%@",data);
}

- (void)postUpdateApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}
- (void)networkApiCall
{
    NSURL *url = [NSURL URLWithString:@"http://api.linkedin.com/v1/people/~/network/updates?scope=self&count=1&type=STAT"];
    OAMutableURLRequest *request =
    [[OAMutableURLRequest alloc] initWithURL:url
                                    consumer:self.consumer
                                       token:self.LinkedinAccessToken
                                    callback:nil
                           signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];
    
    // OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    //    [fetcher fetchDataWithRequest:request
    //                         delegate:self
    //                didFinishSelector:@selector(networkApiCallResult:didFinish:)
    //                  didFailSelector:@selector(networkApiCallResult:didFail:)];
    
    NSHTTPURLResponse *httpResponse = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    if (error) {
        NSLog(@"Error in Linkedin Post== %@", error);
        [self networkApiCallResult:nil didFail:responseData];
    }
    else{
//        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"RResponse String = %@", responseString);
        [self networkApiCallResult:nil didFinish:responseData];
    }
}
- (void)networkApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    NSDictionary *person = [[[[[responseBody objectFromJSONString]
                               objectForKey:@"values"]
                              objectAtIndex:0]
                             objectForKey:@"updateContent"]
                            objectForKey:@"person"];
    NSLog(@"Dictionary Detail -== %@",person);
    
}

- (void)networkApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

@end
