//
//  RCRTCSignatureTool.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import "RCRTCSignatureTool.h"
#import <CommonCrypto/CommonDigest.h>
#import "RCRTCConstant.h"

@implementation RCRTCSignatureTool

+ (NSString *)getNonce{
    int randomNum = arc4random_uniform(RAND_MAX);
    NSLog(@"生成的随机数为 %d",randomNum);
    return [NSString stringWithFormat:@"%d",randomNum];
}

+ (NSString *)getTimestamp{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = interval;
    NSString *timestamp = [NSString stringWithFormat:@"%zd",time];
    NSLog(@"生成的时间戳为 %@",timestamp);
    return timestamp;
}

+ (NSString *)getSignature:(NSString *)nonce Timestamp:(NSString *)timestamp{
    
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@%@",AppSecret,nonce,timestamp];
    return [self sha1:signatureStr];
}

+ (NSString *)sha1:(NSString *)str{
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}
@end
