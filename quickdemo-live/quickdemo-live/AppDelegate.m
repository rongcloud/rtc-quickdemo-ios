//
//  AppDelegate.m
//  ios-live-quick-start
//
//  Created by huan xu on 2020/10/29.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConfig.h"
#import <RongIMLib/RongIMLib.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 前置条件,需要建立IM连接
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppID];
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    [[RCIMClient sharedRCIMClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
    } success:^(NSString *userId) {
        NSLog(@"IM 连接成功 userId: %@",userId);
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"IM 连接失败 errorCode: %ld",errorCode);
    }];
    return YES;
}


@end
