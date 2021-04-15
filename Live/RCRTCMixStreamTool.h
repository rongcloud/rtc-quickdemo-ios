//
//  RCRTCMixStreamTool.h
//  RCRTCQuickDemo
//
//  Created by apple on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCRTCMixStreamTool : NSObject
// 设置合流布局
+ (RCRTCMixConfig *)setOutputConfig:(RCRTCMixLayoutMode)mode;

@end

NS_ASSUME_NONNULL_END
