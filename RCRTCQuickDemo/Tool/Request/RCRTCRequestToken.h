//
//  RCRTCRequestToken.h
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCRequestToken : NSObject

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
