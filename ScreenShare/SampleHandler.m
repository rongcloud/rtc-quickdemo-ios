//
//  SampleHandler.m
//  ScreenShare
//
//  Created by wangyanxu on 2021/4/28.
//


#import "SampleHandler.h"
#import "RongRTCClientSocket.h"

@interface SampleHandler () 
@property(nonatomic , strong)RongRTCClientSocket *clientSocket;
@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    self.clientSocket = [[RongRTCClientSocket alloc] init];
       [self.clientSocket createCliectSocket];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self sendData:sampleBuffer];

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
- (void)sendData:(CMSampleBufferRef)sampleBuffer{
     
    [self.clientSocket encodeBuffer:sampleBuffer];
 
}
@end
