//
//  AppDelegate.m
//  Openlab
//
//  Created by admin on 16/4/7.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "ElApiService.h"
#import <UIView+Toast.h>
#import "JPUSHService.h"
#import <objc/runtime.h>
#import <LGAlertView/LGAlertView.h>
static NSString *appKey = @"f79244db2e97099819ee707c";
static NSString *channel = @"Publish channel";
static BOOL isProduction = YES;
@interface AppDelegate ()
{
    UINavigationController *navigationVC;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    navigationVC=[storyBoard instantiateViewControllerWithIdentifier:@"navigationVC"];
    
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController=navigationVC;
    
    [self.window makeKeyAndVisible];
    
    
    
    [[ElApiService shareElApiService] setIWSErrorCodeListenerBlock:^(NSString *errorCode, NSString *errorMsg) {
       
        if([errorCode isEqualToString:@"1006"]||[errorCode isEqualToString:@"1007"]){
           [[[LGAlertView alloc] initWithTitle:@"提示" message:errorMsg style:LGAlertViewStyleAlert buttonTitles:@[@"确定"] cancelButtonTitle:@"取消" destructiveButtonTitle:nil actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
               [navigationVC popToRootViewControllerAnimated:YES];
           } cancelHandler:^(LGAlertView *alertView) {
               
           } destructiveHandler:^(LGAlertView *alertView) {
               
           }] showAnimated:YES completionHandler:^{
               
           }];
        }else if(![errorCode isEqualToString:@"0"]){
             [self.window makeToast:errorMsg];
        }
        
    }];
    
    
    
    /*
     *JPUSH Server
     */
    
    
    
    /*
     *JPUSH config
     */
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    
    
        
    return YES;
}


-(void)getAllClass{
    int numClasses;
    Class *classes=(__unsafe_unretained Class *)malloc(sizeof(Class)*numClasses);
    numClasses=objc_getClassList(classes, numClasses);
    for (int i=0;i<numClasses;i++) {
        Class c=classes[i];
        NSLog(@"%s",class_getName(c));
    }
    free(classes);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
 *推送通知处理
 */

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}
#endif

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"收到通知0:%@", [self logDic:userInfo]);
    NSString *alertMessage=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    [self popupMessage:alertMessage];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"收到通知1:%@", [self logDic:userInfo]);
    NSString *alertMessage=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    [self popupMessage:alertMessage];
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)popupMessage:(NSString *)alertMessage{
    
    
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"新消息" message:alertMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alertView show];
    
    [JPUSHService resetBadge];
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

@end
