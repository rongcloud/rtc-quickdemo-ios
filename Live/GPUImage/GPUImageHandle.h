//
//  GPUImageHandle.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageBeautyFilter.h"
#import "GPUImageOutputCamera.h"

/**
 * GPUImage 的封装类
 *
 * - 在该类可以实现自己的美颜效果,返回 CMSampleBufferRef 对象
 */

NS_ASSUME_NONNULL_BEGIN
// typedef void(^HitSampleBuffer)(CMSampleBufferRef originBuffer, CMSampleBufferRef newBuffer);

@interface GPUImageHandle : NSObject
// @property (nonatomic, copy) HitSampleBuffer __nullable sampleBufferCallBack;

- (CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
