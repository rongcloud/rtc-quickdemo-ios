//
//  RCRTCRequestToken.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 Token 请由客户服务端生成后在登录页输入，客户端不再提供请求 Token 的能力。
 */
@interface RequestToken : NSObject

/*!
 已禁用。请不要在客户端请求 Token。
 */
+ (void)requestToken:(NSString *)userId
                name:(NSString *)name
         portraitUrl:(NSString *_Nullable)portraitUrl
   completionHandler:(void (^)(BOOL isSuccess, NSString *_Nullable tokenString))completionHandler;

@end

NS_ASSUME_NONNULL_END
