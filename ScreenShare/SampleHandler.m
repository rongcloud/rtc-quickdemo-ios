//
//  SampleHandler.m
//  ScreenShare
//
//  Created by wangyanxu on 2021/4/28.
//


#import "SampleHandler.h"
//#import "RongRTCClientSocket.h"
#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLib/RongIMLib.h>
#import "RequestToken.h"
#import <RongIMKit/RCIM.h>

@interface SampleHandler () <RCRTCRoomEventDelegate>

@property (nonatomic, strong) RCRTCRoom *room;
@property (nonatomic, strong) RCRTCVideoOutputStream *videoOutputStream;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *roomId;
//@property(nonatomic , strong)RongRTCClientSocket *clientSocket;
@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
//    self.clientSocket = [[RongRTCClientSocket alloc] init];
//       [self.clientSocket createCliectSocket];
    [self requestToken];

}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    [self.room.localUser unpublishLiveStream:self.videoOutputStream completion:^(BOOL isSuccess, RCRTCCode code) {
            if (isSuccess) {
                [self exitRoom];
            }
    }];
    
 
    // User has requested to finish the broadcast.
}
-(void)exitRoom{
    
    [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        self.videoOutputStream = nil;
        
    }];
//    [[RCIMClient sharedRCIMClient] disconnect];
    
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

-(void)requestToken{
    
//    // 请填写您的 AppKey
//    self.appKey = @"cpj2xarlctx9n";
//    // 请填写用户的 Token
//
//
//    [RequestToken requestToken:@"ScreenShare"
//                               name:@"ScreenShare"
//                        portraitUrl:nil
//                  completionHandler:^(BOOL isSuccess, NSString * _Nonnull tokenString) {
//
//        if (!isSuccess) return;
//
//        /**
//         * 拿到 token 后去连接 IM 服务
//         */
//        [self connectRongCloud:tokenString];
//    }];
    
    // 请填写您的 AppKey
    self.appKey = @"cpj2xarlctx9n";
    // 请填写用户的 Token
    self.token = @"tyRrIDoMTL8jJf3D2ynFXHboe+cmZfb/MmDCFkZU9/w=@b0fu.cn.rongnav.com;b0fu.cn.rongcfg.com";
    // 请指定房间号
//    [self getByAppGroup2];
    
    [[RCIMClient sharedRCIMClient] initWithAppKey:self.appKey];
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
    
    // 连接 IM
    [[RCIMClient sharedRCIMClient] connectWithToken:self.token
                                           dbOpened:^(RCDBErrorCode code) {
        NSLog(@"dbOpened: %zd", code);
    } success:^(NSString *userId) {
        NSLog(@"connectWithToken success userId: %@", userId);
        // 加入房间
        [[RCRTCEngine sharedInstance] joinRoom:[self getByAppGroup]
                                    completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
            self.room = room;
            self.room.delegate = self;
            [self publishScreenStream];
        }];
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"ERROR status: %zd", errorCode);
    }];
    
}

-(NSString *)getByAppGroup
{
NSUserDefaults *myDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.cn.rongcloud.rtcquickdemo.screenshare"];//此处id要与开发者中心创建时一致
NSString *content = [myDefaults objectForKey:@"roomId"];
NSLog(@"lalallalala%@",content);
    return  [myDefaults objectForKey:@"roomId"];
}


//
//- (void)connectRongCloud:(NSString *)token{
//
//    [[RCIM sharedRCIM] initWithAppKey:self.appKey];
//
//    [[RCIM sharedRCIM] connectWithToken:token dbOpened:nil success:^(NSString *userId) {
//
//        NSLog(@"IM connect success,user ID : %@",userId);
//        // 请指定房间号
//        self.roomId = [self getByAppGroup];
//        [self joinRoom];
//
//    } error:^(RCConnectErrorCode errorCode) {
//        NSLog(@"IM connect failed, error code : %ld",(long)errorCode);
//    }];
//}
-(void)imClient{
    
    
  
    
    
//
//    [[RCIMClient sharedRCIMClient] initWithAppKey:self.appKey];
////    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
//
//    // 连接 IM
//    [[RCIMClient sharedRCIMClient] connectWithToken:self.token
//                                           dbOpened:^(RCDBErrorCode code) {
//        NSLog(@"dbOpened: %zd", code);
//    } success:^(NSString *userId) {
//        NSLog(@"connectWithToken success userId: %@", userId);
//    } error:^(RCConnectErrorCode errorCode) {
//        NSLog(@"ERROR status: %zd", errorCode);
//    }];
    
}

-(void)joinRoom
{
    // 加入房间
    [[RCRTCEngine sharedInstance] joinRoom:self.roomId
                                completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        self.room.delegate = self;
        [self publishScreenStream];
    }];
}


#pragma mark - Private
- (void)publishScreenStream {
    self.videoOutputStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:@"RCRTCScreenVideo"];
    RCRTCVideoStreamConfig *videoConfig = self.videoOutputStream.videoConfig;
    videoConfig.videoSizePreset = RCRTCVideoSizePreset1280x720;
    [self.videoOutputStream setVideoConfig:videoConfig];
    
    NSLog(@"%@ %@",self.room.localUser,self.room);
    [self.room.localUser publishStream:self.videoOutputStream completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess){
            NSLog(@"发布自定义流成功");}
        else{
            NSLog(@"发布自定义流失败%@",[NSString stringWithFormat:@"订阅远端流失败:%ld",(long)desc]);}
    }];
}
@end
