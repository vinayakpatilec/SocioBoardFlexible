//
//  AppDelegate.m
//  WooSuiteApp
//
//  Created by Globussoft 1 on 4/12/13.
//  Copyright (c) 2013 Globussoft 1. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HelperClass.h"
#import "SBJson.h"
#import "InboxVC.h"
#import "Feeds.h"

@implementation AppDelegate
@synthesize viewController = _viewController;
@synthesize window = _window;

- (void)dealloc
{
}

-(void) createTabBar{
    //Home controller
    InboxVC *homeVC = [[InboxVC alloc]initWithNibName:@"InboxVC" bundle:nil];
    homeVC.tabBarItem.title = @"Home";
    //Settings controller
    Feeds *settingsVC = [[Feeds alloc]initWithNibName:@"Feeds" bundle:nil];
    settingsVC.tabBarItem.title = @"Settings";
    
    //init the UITabBarController
    
    self.tabBarController = [[UITabBarController alloc]init];
    self.tabBarController.viewControllers = @[homeVC,settingsVC];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   // CGRect frame = [UIScreen mainScreen].bounds;
    //NSLog(@"Height==%f",frame.size.height);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    [app setNewsstandIconImage:[UIImage imageNamed:@"SB.png"]];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    UIApplication *app = [UIApplication sharedApplication];
    [app setNewsstandIconImage:[UIImage imageNamed:@"SB.png"]];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RefresAfterResign" object:nil];
    [self getLoggedinuserDetails];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
     // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark -
-(void) getLoggedinuserDetails{
    NSString *profileID = [SingletonClass sharedSingleton].profileID;
    if (profileID.length>1) {
        NSLog(@"Refresh Method Call");
        NSString *soapmessage = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                 "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                 "<soap:Body>\n"
                                 "<getUsersById xmlns=\"http://tempuri.org/\">\n"
                                 "<UserId>%@</UserId>\n"
                                 "</getUsersById>\n"
                                 "</soap:Body>\n"
                                 "</soap:Envelope>\n",profileID];
        
        NSLog(@"soapMessg  %@",soapmessage);
        NSString *urlString = [NSString stringWithFormat:@"%@/Services/User.asmx?op=Login",WebLink];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
        
        NSString *msglength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapmessage length]];
        [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [req addValue:@"http://tempuri.org/getUsersById" forHTTPHeaderField:@"SOAPAction"];
        [req addValue:msglength forHTTPHeaderField:@"Content-Length"];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:[soapmessage dataUsingEncoding:NSUTF8StringEncoding]];
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        
        NSLog(@"%@",msglength);
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        if (error) {
            NSLog(@"Error == %@", error);
        }
        else{
            @try {
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSString *response=[HelperClass stripTags:responseString startString:@"{" upToString:@"}"];
                NSString *jsonString = [NSString stringWithFormat:@"%@}",response];
                NSLog(@"Json String= %@",jsonString);
                NSDictionary *dict = [jsonString JSONValue];
                NSString *expiryDate = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ExpiryDate"]];
                [self compareDatewithExpiryDate:expiryDate];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception = %@",exception.name);
            }
            @finally {
                NSLog(@"Finally Block");
            }
            
        }
        
    }//End if block ProdileID Check
}
-(void)compareDatewithExpiryDate:(NSString *)expiryDate{
    
    //expiryDate = @"/Date(1409127101000)";
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    //[_formatter setDateFormat:@"MMM dd,yy hh:mm:ss a"];
    //[_formatter setDateFormat:@"yyyy MM dd hh:mm:ss"];
    [_formatter setDateFormat:@"yyyy MM dd"];
    //=====================
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@"/" withString:@""];
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@"Date" withString:@""];
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@"(" withString:@""];
    expiryDate = [expiryDate stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    double creation_number = [expiryDate doubleValue];
    double unixTimeStamp = creation_number/1000;
    NSDate *to_date = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
    NSLog(@"To_date = %@", to_date);
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"Current date = %@",currentDate);
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:currentDate toDate:to_date options:0];
    
    NSLog(@"Day count = %d",(int)components.day);
    [SingletonClass sharedSingleton].remainDays = components.day;
    //====================
}












@end