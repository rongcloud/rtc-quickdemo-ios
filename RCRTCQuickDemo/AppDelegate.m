//
//  AppDelegate.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "AppDelegate.h"
#import <RongIMLib/RongIMLib.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    /**
     未进行任何操作，直接进入 RCRTCLoginViewController 
     */
    return YES;
}

@end
