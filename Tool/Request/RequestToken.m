//
//  RCRTCRequestToken.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RequestToken.h"

@implementation RequestToken

+ (void)requestToken:(NSString *)userId
                name:(NSString *)name
         portraitUrl:(NSString *_Nullable)portraitUrl
   completionHandler:(void (^)(BOOL isSuccess, NSString *_Nullable tokenString))completionHandler {
    NSLog(@"RequestToken is disabled. Please generate token on your server and input it on the login page.");
    if (completionHandler) {
        completionHandler(NO, nil);
    }
}

@end
