//
//  SampleHandler.m
//  ScreenShare
//
//  Created by wangyanxu on 2021/4/28.
//


#import "SampleHandler.h"
#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLib/RongIMLib.h>
#import "RequestToken.h"
#import <RongIMKit/RCIM.h>
#import "Constant.h"

static NSString * const ScreenShareGroupID = @"group.cn.rongcloud.rtcquickdemo.screenshare";

@interface SampleHandler () <RCRTCRoomEventDelegate>

@property (nonatomic, strong) RCRTCRoom *room;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) RCRTCVideoOutputStream *videoOutputStream;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *roomId;

@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    [self getByAppGroup];
    [self requestToken];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    
    [self exitRoom];
    
    // User has requested to finish the broadcast.
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self.videoOutputStream write:sampleBuffer error:nil];
            
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
#pragma mark - Private
- (void)requestToken {
    [RequestToken requestToken:[NSString stringWithFormat:@"%@RTC",self.userId]
                          name:[NSString stringWithFormat:@"%@RTC",self.userId]
                   portraitUrl:nil
             completionHandler:^(BOOL isSuccess, NSString * _Nonnull tokenString) {
        
        if (!isSuccess) return;
        [self connectRongCloud:tokenString];
    }];
}

- (void)connectRongCloud:(NSString *)token {
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppKey];
    // 连接 IM
    [[RCIMClient sharedRCIMClient] connectWithToken:token
                                           dbOpened:^(RCDBErrorCode code) {
        NSLog(@"dbOpened: %zd", code);
    } success:^(NSString *userId) {
        NSLog(@"connectWithToken success userId: %@", userId);
        // 加入房间
        [self joinRoom];
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"ERROR status: %zd", errorCode);
    }];
    
    
}

- (void)getByAppGroup {
    //此处 id 要与开发者中心创建时一致
    NSUserDefaults *rongCloudDefaults = [[NSUserDefaults alloc]initWithSuiteName:ScreenShareGroupID];
    self.roomId =  [rongCloudDefaults objectForKey:@"roomId"];
    self.userId = [rongCloudDefaults objectForKey:@"userId"];
}



- (void)joinRoom {
    [[RCRTCEngine sharedInstance] joinRoom:self.roomId
                                completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        self.room = room;
        self.room.delegate = self;
        [self publishScreenStream];
    }];
}


- (void)publishScreenStream {
    self.videoOutputStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:@"RCRTCScreenVideo"];
    RCRTCVideoStreamConfig *videoConfig = self.videoOutputStream.videoConfig;
    videoConfig.videoSizePreset = RCRTCVideoSizePreset1920x1080;
    videoConfig.videoFps = RCRTCVideoFPS24;
    [self.videoOutputStream setVideoConfig:videoConfig];
    [self.room.localUser publishStream:self.videoOutputStream completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess){
            NSLog(@"发布自定义流成功");}
        else{
            NSLog(@"发布自定义流失败%@",[NSString stringWithFormat:@"订阅远端流失败:%ld",(long)desc]);}
    }];
}

- (void)exitRoom {
    [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        self.videoOutputStream = nil;
        
    }];
}

@end
