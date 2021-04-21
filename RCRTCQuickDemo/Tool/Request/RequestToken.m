//
//  RCRTCRequestToken.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RequestToken.h"
#import "Constant.h"
#import <CommonCrypto/CommonDigest.h>


static NSString * const RequestTokenURL = @"http://api-cn.ronghub.com/user/getToken.json";

@implementation RequestToken

+ (NSString *)getNonce{
    int randomNum = arc4random_uniform(RAND_MAX);
    NSLog(@"randomNum : %d",randomNum);
    return [NSString stringWithFormat:@"%d",randomNum];
}

+ (NSString *)getTimestamp{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = interval;
    NSString *timestamp = [NSString stringWithFormat:@"%zd",time];
    NSLog(@"timestamp : %@",timestamp);
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

+ (void)requestToken:(NSString *)userId
                name:(NSString *)name
         portraitUrl:(NSString * _Nullable)portraitUrl
   completionHandler:(void (^)(BOOL isSuccess, NSString * _Nullable tokenString))completionHandler{
    
    NSURL *url = [NSURL URLWithString:RequestTokenURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:AppKey forHTTPHeaderField:@"App-Key"];
    NSString *nonce = [self getNonce];
    [request setValue:nonce forHTTPHeaderField:@"RC-Nonce"];
    NSString *timestamp = [self getTimestamp];
    [request setValue:timestamp forHTTPHeaderField:@"RC-Timestamp"];
    NSString *signature = [self getSignature:nonce Timestamp:timestamp];
    [request setValue:signature forHTTPHeaderField:@"Signature"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *bodyStr = [NSString stringWithFormat:@"userId=%@&name=%@&portraitUri=%@",userId,name,portraitUrl];
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"request completed,Error: \n%@", error);
            completionHandler(NO,nil);
        } else {
            NSError *__error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&__error];
            NSLog(@"request completed,Result: \n%@", result);
            
            if (result && result[@"token"]) {
                completionHandler(YES,result[@"token"]);
            }else{
                completionHandler(NO,nil);
            }
        }
    }];
    [sessionDataTask resume];
}

@end
