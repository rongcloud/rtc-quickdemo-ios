//
//  RCRTCStreamVideo.m
//  RCRTCQuickDemo
//
//  Created by apple on 2021/4/15.
//

#import "RCRTCStreamVideo.h"

@implementation RCRTCStreamVideo

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
    localStreamVideo.userId = @"0";
    localStreamVideo.canvesView = [[RCRTCLocalVideoView alloc] init];
    localStreamVideo.canvesView.translatesAutoresizingMaskIntoConstraints = NO;
    localStreamVideo.canvesView.fillMode = RCRTCVideoFillModeAspectFill;
    return localStreamVideo;
}

@end
