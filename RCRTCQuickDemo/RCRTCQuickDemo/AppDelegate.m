//
//  AppDelegate.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/7.
//

#import "AppDelegate.h"
#import "RCRTCConstant.h"
#import <RongIMKit/RCIM.h>


#import "RCRTCSignatureTool.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    [[RCIM sharedRCIM] initWithAppKey:AppKey];
    
    return YES;
}


@end
