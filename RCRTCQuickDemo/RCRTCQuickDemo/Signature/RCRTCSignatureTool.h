//
//  RCRTCSignatureTool.h
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCSignatureTool : NSObject



/**
 获取签名数据
 
 Signature (数据签名)计算方法：
 将系统分配的 App Secret、Nonce (随机数)、Timestamp (时间戳)三个字符串按先后顺序拼接成一个字符串并进行 SHA1 哈希计算。
 
 如果调用的数据签名验证失败，接口调用会返回 HTTP 状态码 401
 */
+ (NSString *)getSignature:(NSString *)nonce Timestamp:(NSString *)timestamp;

+ (NSString *)getNonce;

+ (NSString *)getTimestamp;

@end

NS_ASSUME_NONNULL_END
