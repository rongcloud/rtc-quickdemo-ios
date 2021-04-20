//
//  RCRTCMixStreamTool.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

/**
 * RCRTCMixStreamTool.m
 *
 * 12
 * 2
 * 2
 * 2
 * 2
 * 2
 * 2
 * 2
 */
#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCRTCMixStreamTool : NSObject
// 设置合流布局
+ (RCRTCMixConfig *)setOutputConfig:(RCRTCMixLayoutMode)mode;

@end

NS_ASSUME_NONNULL_END
