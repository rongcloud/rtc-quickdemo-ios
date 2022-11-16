//
//  SampleHandler.m
//  ScreenShare
//
//  Copyright © 2021 RongCloud. All rights reserved.
//


#import "SampleHandler.h"
#import <RongRTCReplayKitExt/RongRTCReplayKitExt.h>
static NSString *const ScreenShareGroupID = @"group.cn.rongcloud.rtcquickdemo.screenshare";

@interface SampleHandler () <RongRTCReplayKitExtDelegate>


@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *, NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [[RCRTCReplayKitEngine sharedInstance] setupWithAppGroup:ScreenShareGroupID delegate:self];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [[RCRTCReplayKitEngine sharedInstance] broadcastFinished];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType  API_AVAILABLE(ios(10.0)) {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [[RCRTCReplayKitEngine sharedInstance] sendSampleBuffer:sampleBuffer
                                                           withType:RPSampleBufferTypeVideo];

            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;

        default:
            break;
    }
}

#pragma mark - RongRTCReplayKitExtDelegate

- (void)broadcastFinished:(RCRTCReplayKitEngine *)broadcast
                   reason:(RCRTCReplayKitExtReason)reason {
    NSString *tip = @"";
    switch (reason) {
        case RCRTCReplayKitExtReasonRequestedByMain:
            tip = @"屏幕共享已结束";
            break;
        case RCRTCReplayKitExtReasonDisconnected:
            tip = @"应用断开";
            break;
        case RCRTCReplayKitExtReasonVersionMismatch:
            tip = @"集成错误（SDK 版本号不相符合）";
            break;
    }
    
    if (tip.length) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                             code:0
                                         userInfo:@{
            NSLocalizedFailureReasonErrorKey:tip
        }];
        [self finishBroadcastWithError:error];
    }
}
@end
