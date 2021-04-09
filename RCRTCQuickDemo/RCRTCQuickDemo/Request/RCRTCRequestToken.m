//
//  RCRTCRequestToken.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import "RCRTCRequestToken.h"
#import "RCRTCConstant.h"
#import "RCRTCSignatureTool.h"

@implementation RCRTCRequestToken


+ (void)requestToken:(NSString *)userId name:(NSString *)name portraitUrl:(NSString * _Nullable)portraitUrl completionHandler:(void (^)(BOOL isSuccess, NSString * _Nullable tokenString))completionHandler{
    
    NSURL *url = [NSURL URLWithString:RequestTokenUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:AppKey forHTTPHeaderField:@"App-Key"];
    NSString *nonce = [RCRTCSignatureTool getNonce];
    [request setValue:nonce forHTTPHeaderField:@"RC-Nonce"];
    NSString *timestamp = [RCRTCSignatureTool getTimestamp];
    [request setValue:timestamp forHTTPHeaderField:@"RC-Timestamp"];
    NSString *signature = [RCRTCSignatureTool getSignature:nonce Timestamp:timestamp];
    [request setValue:signature forHTTPHeaderField:@"Signature"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *bodyStr = [NSString stringWithFormat:@"userId=%@&name=%@&portraitUri=%@",userId,name,portraitUrl];
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            completionHandler(NO,nil);
        } else {
            NSError *__error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&__error];
            NSLog(@"result:%@", result);
            
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
