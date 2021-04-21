//
//  LiveMixStreamTool.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>

/**
 *  合流布局配置类
 */
NS_ASSUME_NONNULL_BEGIN

@interface LiveMixStreamTool : NSObject

/**
 * 设置合流布局
 */
+ (RCRTCMixConfig *)setOutputConfig:(RCRTCMixLayoutMode)mode;

@end

NS_ASSUME_NONNULL_END
