//
//  GPUImageHandle.h
//  quickdemo-meeting-beauty
//
//  Created by Zafer.Lee on 2021/1/5.
//

#import <Foundation/Foundation.h>
#import "GPUImageBeautyFilter.h"
#import "GPUImageOutputCamera.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^HitSampleBuffer)(CMSampleBufferRef originBuffer, CMSampleBufferRef newBuffer);

@interface GPUImageHandle : NSObject
@property (nonatomic, copy) HitSampleBuffer __nullable sampleBufferCallBack;

- (CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
