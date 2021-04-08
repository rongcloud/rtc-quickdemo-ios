//
//  RCRTCRequestToken.h
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCRequestToken : NSObject

+ (void)requestToken:(NSString *)userId name:(NSString *)name portraitUrl:(NSString *)portraitUrl completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
