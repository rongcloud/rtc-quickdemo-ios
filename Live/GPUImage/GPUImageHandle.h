//
//  GPUImageHandle.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageBeautyFilter.h"
#import "GPUImageOutputCamera.h"
#import <RongRTCLib/RongRTCLib.h>


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
- (void)rotateWaterMark:(BOOL)isAdd;

// 切换美颜滤镜
-(void)onlyBeauty;

// 添加水印
-(void)onlyWaterMark;

// 添加水印的美颜
-(void)beautyAndWaterMark;
@end

NS_ASSUME_NONNULL_END
