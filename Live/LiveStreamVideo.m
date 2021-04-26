//
//  LiveStreamVideo.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LiveStreamVideo.h"

static NSString *zero  = @"0";

@implementation LiveStreamVideo

// 根据 streamId 创建并设置远端视频预览视图
- (instancetype)initWithStreamId:(nonnull NSString *)stream{
    if (self = [super init]) {
        self.streamId = stream;
        self.canvesView = [[RCRTCRemoteVideoView alloc] init];
        self.canvesView.translatesAutoresizingMaskIntoConstraints = NO;
        self.canvesView.fillMode = RCRTCVideoFillModeAspectFill;
    }
    return self;
}

+ (instancetype)LocalStreamVideo{
    LiveStreamVideo *localStreamVideo = [[LiveStreamVideo alloc] init];
    // 初始化 这里的 streamId 推荐 0
    localStreamVideo.streamId = zero;
    localStreamVideo.canvesView = [[RCRTCLocalVideoView alloc] init];
    localStreamVideo.canvesView.translatesAutoresizingMaskIntoConstraints = NO;
    localStreamVideo.canvesView.fillMode = RCRTCVideoFillModeAspectFill;
    return localStreamVideo;
}

@end
