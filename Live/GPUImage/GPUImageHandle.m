//
//  GPUImageHandle.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "GPUImageHandle.h"


@interface GPUImageHandle ()
@property (nonatomic, strong) GPUImageBeautyFilter *beautyFilter;
@property (nonatomic, strong) GPUImageOutputCamera *outputCamera;
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageFilter *filter;
@end

@implementation GPUImageHandle

-(instancetype)init {
    if (self = [super init]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initBeautyFilter];
        });
    }
    return self;
}

#pragma mark- GPUImage
- (void)initBeautyFilter {
    [self.outputCamera addTarget:self.beautyFilter];
    [self.beautyFilter addTarget:self.imageView];
    self.filter = self.beautyFilter;
}

- (CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer
{
    
    
    if (!self.filter || !sampleBuffer)
        return nil;
    
    if (!CMSampleBufferIsValid(sampleBuffer))
        return nil;
    
    //    CMSampleBufferRef originBuffer = sampleBuffer;
    
    [self.filter useNextFrameForImageCapture];
    CFRetain(sampleBuffer);
    [self.outputCamera processVideoSampleBuffer:sampleBuffer];
    
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CFRelease(sampleBuffer);
    
    GPUImageFramebuffer *framebuff = [self.filter framebufferForOutput];
    CVPixelBufferRef pixelBuff = [framebuff pixelBuffer];
    CVPixelBufferLockBaseAddress(pixelBuff, 0);
    
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuff, &videoInfo);
    
    CMSampleTimingInfo timing = {currentTime, currentTime, kCMTimeInvalid};
    
    CMSampleBufferRef processedSampleBuffer = NULL;
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuff, YES, NULL, NULL, videoInfo, &timing, &processedSampleBuffer);
    // CMSampleBufferRef newBuffer = processedSampleBuffer;
    if (videoInfo == NULL)
        return nil;
    
    // if (self.sampleBufferCallBack) {
    //      self.sampleBufferCallBack(originBuffer, newBuffer);
    // }
    
    CFRelease(videoInfo);
    CVPixelBufferUnlockBaseAddress(pixelBuff, 0);
    return processedSampleBuffer;
}

#pragma mark- getter
- (GPUImageBeautyFilter *)beautyFilter
{
    if (!_beautyFilter) {
        _beautyFilter = [[GPUImageBeautyFilter alloc] init];
    }
    return _beautyFilter;
}

- (GPUImageOutputCamera *)outputCamera
{
    if (!_outputCamera) {
        _outputCamera = [[GPUImageOutputCamera alloc] init];
    }
    return _outputCamera;
}

- (GPUImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    }
    return _imageView;
}

@end
