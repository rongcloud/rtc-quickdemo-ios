//
//  RCRTCConstant.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "Constant.h"

/**
 *  填写信息之后可删除 #error
 */
@implementation Constant

// #error 请填写 App Key
/**
 * 获取地址: https://developer.rongcloud.cn/app/appkey/
 */
NSString * const AppKey = @"cpj2xarlctx9n";

// #error 请填写 App Secret
/**
 * 获取Token 需要提供 App Key 和 App Secret
 *
 * 正式环境请勿在客户端请求 Token，您的客户端代码一旦被反编译，会导致您的 AppSecret 泄露。
 * 请务必确保在服务端获取 Token。 参考文档：https://docs.rongcloud.cn/v4/views/im/server/user/register.html
 */
NSString * const AppSecret = @"fIjvrkQC77qow";

@end
