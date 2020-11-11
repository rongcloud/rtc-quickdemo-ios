//
//  VideoLayout.m
//  ios-live-quick-start
//
//  Created by huan xu on 2020/11/2.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import "StreamVideo.h"

@implementation StreamVideo

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
    StreamVideo *localStreamVideo = [[StreamVideo alloc] init];
    localStreamVideo.userId = @"0";
    localStreamVideo.canvesView = [[RCRTCLocalVideoView alloc] init];
    localStreamVideo.canvesView.translatesAutoresizingMaskIntoConstraints = NO;
    localStreamVideo.canvesView.fillMode = RCRTCVideoFillModeAspectFill;
    return localStreamVideo;
}
@end
