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
@property (nonatomic, strong) GPUImageFilter *filter, *defaultFilter;
@property (nonatomic, weak) GPUImageFilter *gpuFilter;
@property (nonatomic, strong) GPUImageUIElement *uiElement;
@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;
@property (nonatomic, strong) UIImageView *watermarkImageView;
@property (nonatomic, assign) CGFloat videoWidth, videoHeight;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL isTransform, isBackCamera;

@end

@implementation GPUImageHandle

-(instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark- GPUImage
- (void)rotateWaterMark:(BOOL)isAdd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.watermarkImageView.frame = CGRectMake(20, 20, 80, 80);
        self.watermarkImageView.hidden = isAdd ? YES : NO;
    });
}

- (void)reloadGPUFilter {
    [self uiElement];
    __weak typeof(self) weakSelf = self;
    [self.gpuFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        if (weakSelf.uiElement) {
            [weakSelf.uiElement updateWithTimestamp:time];
        }
    }];
}

- (CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer {
    
    if (!self.filter || !sampleBuffer)
        return nil;
    
    if (!CMSampleBufferIsValid(sampleBuffer))
        return nil;
    
    
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
    if (videoInfo == NULL)
        return nil;
    
    CFRelease(videoInfo);
    CVPixelBufferUnlockBaseAddress(pixelBuff, 0);
    return processedSampleBuffer;
}

#pragma mark- getter
- (GPUImageFilter *)defaultFilter {
    if (!_defaultFilter)  {
        _defaultFilter = [[GPUImageFilter alloc] init];
    }
    return _defaultFilter;
}

- (GPUImageBeautyFilter *)beautyFilter {
    if (!_beautyFilter) {
        _beautyFilter = [[GPUImageBeautyFilter alloc] init];
    }
    return _beautyFilter;
}

- (GPUImageOutputCamera *)outputCamera {
    if (!_outputCamera) {
        _outputCamera = [[GPUImageOutputCamera alloc] init];
    }
    return _outputCamera;
}

- (GPUImageView *)imageView {
    if (!_imageView) {
        _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    }
    return _imageView;
}

- (UIView *)contentView {
    if (!_contentView) {
        
        self.videoHeight = 640;
        self.videoWidth = 360;
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.videoWidth, self.videoHeight)];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIImageView *)watermarkImageView {
    if (!_watermarkImageView) {
        _watermarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
        _watermarkImageView.image = [UIImage imageNamed:@"chat_water_mark"];
    }
    return _watermarkImageView;
}

- (GPUImageUIElement *)uiElement {
    if (!_uiElement) {
        [self.contentView addSubview:self.watermarkImageView];
        _uiElement = [[GPUImageUIElement alloc] initWithView:self.contentView];
    }
    return _uiElement;
}

- (GPUImageAlphaBlendFilter *)blendFilter {
    if (!_blendFilter) {
        _blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
        _blendFilter.mix = 1.0;
    }
    return _blendFilter;
}

- (void)onlyBeauty {
    [self cleanAllFilter];
    self.gpuFilter = self.beautyFilter;
    [self.outputCamera addTarget:self.gpuFilter];
    [self.gpuFilter addTarget:self.imageView];
    self.filter = self.gpuFilter;
    
}

- (void)beautyAndWaterMark {
    [self cleanAllFilter];
    self.gpuFilter = self.beautyFilter;
    [self.outputCamera addTarget:self.gpuFilter];
    [self reloadGPUFilter];
    [self.gpuFilter addTarget:self.blendFilter];
    [self.uiElement addTarget:self.blendFilter];
    [self.blendFilter addTarget:self.imageView];
    self.filter = self.blendFilter;
}

- (void)onlyWaterMark {
    
    [self cleanAllFilter];
    self.gpuFilter = self.defaultFilter;
    [self.outputCamera addTarget:self.gpuFilter];
    [self reloadGPUFilter];
    [self.gpuFilter addTarget:self.blendFilter];
    [self.uiElement addTarget:self.blendFilter];
    [self.blendFilter addTarget:self.imageView];
    self.filter = self.blendFilter;
}
- (void)cleanAllFilter {
    
    [_gpuFilter setFrameProcessingCompletionBlock:nil];
    [self.outputCamera removeTarget:self.gpuFilter];
    [self.uiElement removeTarget:self.blendFilter];
    [self.gpuFilter removeTarget:self.blendFilter];
    [self.blendFilter removeTarget:self.imageView];
    [self.gpuFilter removeTarget:self.imageView];
    self.uiElement = nil;
}

@end
