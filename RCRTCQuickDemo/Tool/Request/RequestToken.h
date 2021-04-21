//
//  RCRTCRequestToken.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 此类用于帮助开发者在客户端生成 Token
 *
 * 正式环境请勿在客户端请求 Token，您的客户端代码一旦被反编译，会导致您的 AppSecret 泄露。
 * 请务必确保在服务端获取 Token。 参考文档：https://docs.rongcloud.cn/v4/views/im/server/user/register.html
 */
@interface RequestToken : NSObject

/**
 * 获取 token
 *
 * 注意：获取 Token 逻辑应部署在应用服务器上，客户端不要存储 AppSecret，此函数仅供演示使用。
 */
+ (void)requestToken:(NSString *)userId
                name:(NSString *)name
         portraitUrl:(NSString * _Nullable)portraitUrl
   completionHandler:(void (^)(BOOL isSuccess, NSString * _Nullable tokenString))completionHandler;

@end

NS_ASSUME_NONNULL_END
