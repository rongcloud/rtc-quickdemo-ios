//
//  RCRTCStreamVideo.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCRTCStreamVideo.h"

@implementation RCRTCStreamVideo

//根据 uid 创建并设置远端视频预览视图
- (instancetype)initWithUid:(NSString *)uid {
    if (self = [super init]) {
        self.userId = uid;
        self.canvesView = [[RCRTCRemoteVideoView alloc] init];
        self.canvesView.translatesAutoresizingMaskIntoConstraints = NO;
        self.canvesView.fillMode = RCRTCVideoFillModeAspectFill;
    }
    return self;
}

+ (instancetype)LocalStreamVideo{
    RCRTCStreamVideo *localStreamVideo = [[RCRTCStreamVideo alloc] init];
    //初始化 这里的 userId 推荐 0
    localStreamVideo.userId = @"0";
    localStreamVideo.canvesView = [[RCRTCLocalVideoView alloc] init];
    localStreamVideo.canvesView.translatesAutoresizingMaskIntoConstraints = NO;
    localStreamVideo.canvesView.fillMode = RCRTCVideoFillModeAspectFill;
    return localStreamVideo;
}

@end
