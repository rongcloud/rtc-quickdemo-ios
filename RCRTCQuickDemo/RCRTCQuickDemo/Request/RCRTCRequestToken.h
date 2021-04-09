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
 * 请求 token
 *
 * 此方法只用于测试环境使用，正式环境需要使用 server 进行处理。
 */
+ (void)requestToken:(NSString *)userId name:(NSString *)name portraitUrl:(NSString * _Nullable)portraitUrl completionHandler:(void (^)(BOOL isSuccess, NSString * _Nullable tokenString))completionHandler;

@end

NS_ASSUME_NONNULL_END
