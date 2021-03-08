//
//  RCRTCMixStreamTool.h
//  quickdemo-live-broadcaster
//
//  Created by RongCloud on 2020/10/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCMixStreamTool : NSObject

// 设置合流布局
+ (RCRTCMixConfig *)setOutputConfig:(RCRTCMixLayoutMode)mode;

@end

NS_ASSUME_NONNULL_END
