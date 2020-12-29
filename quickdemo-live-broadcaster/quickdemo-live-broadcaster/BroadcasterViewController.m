//
//  BroadcasterViewController.m
//  quickdemo-live-broadcaster
//
//  Created by RongCloud on 2020/10/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "BroadcasterViewController.h"
#import "AppConfig.h"
#import "StreamVideo.h"
#import "VideoLayoutTool.h"
#import "RCRTCMixStreamTool.h"
#import "UIAlertController+RC.h"

@interface BroadcasterViewController ()<RCRTCRoomEventDelegate>

@property (weak, nonatomic) IBOutlet UIView *remoteContainerView;

@property (nonatomic, strong)RCRTCEngine *engine;
@property (nonatomic, strong)RCRTCRoom *room;
@property (nonatomic, strong)StreamVideo *localVideo;
@property (nonatomic, strong)RCRTCLiveInfo *liveInfo;

@property (nonatomic)NSMutableArray <StreamVideo *>*streamVideos;
@property (nonatomic, strong)VideoLayoutTool *layoutTool;

@end

@implementation BroadcasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//前置条件,需要建立IM连接
- (IBAction)loginIM:(UIButton *)sender{
    sender.enabled = NO;
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppID];
    [[RCIMClient sharedRCIMClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
    } success:^(NSString *userId) {
        NSString *successMsg = [NSString stringWithFormat:@"IM登陆成功userId:%@",userId];
        [UIAlertController alertWithString:successMsg inCurrentVC:self];
    } error:^(RCConnectErrorCode errorCode) {
        NSString *errorMsg = [NSString stringWithFormat:@"IM登陆失败code:%ld",(long)errorCode];
        [UIAlertController alertWithString:errorMsg inCurrentVC:self];
    }];
}

//开始直播
- (IBAction)startLive:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self setupLocalVideoView];
        [self joinLiveRoom];
    }
    else {
        [self exitRoom];
    }
}

//开启/关闭摄像头
- (IBAction)cameraSwitch:(UIButton *)sender {
    sender.selected = !sender.selected;
    RCRTCCameraOutputStream *DVStream = self.engine.defaultVideoStream;
    sender.selected ? [DVStream stopCapture]:[DVStream startCapture];
}

//开启/关闭麦克风
- (IBAction)micSwitch:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.engine.defaultAudioStream setMicrophoneDisable:sender.selected];
}

/**
 主播设置合流布局,观众端看效果

 自定义布局 RCRTCMixLayoutModeCustom = 1 (默认)
 悬浮布局 RCRTCMixLayoutModeSuspension = 2
 自适应布局 RCRTCMixLayoutModeAdaptive = 3
 */
- (IBAction)customStreamLayout:(UIButton *)sender {
    sender.tag >= 3 ? sender.tag = 1 : (sender.tag += 1);
    [self streamlayoutMode:sender.tag];
    switch (sender.tag) {
        case 1:
            [sender setTitle:@"自定义布局" forState:0];
            break;
        case 2:
            [sender setTitle:@"悬浮布局" forState:0];
            break;
        case 3:
            [sender setTitle:@"自适应布局" forState:0];
            break;
        default:
            break;
    }
}

//发送直播地址(*通过IM消息 这属于demo 辅助功能*)
- (IBAction)sendLiveUrl:(id)sender {
    RCTextMessage *content = [RCTextMessage messageWithContent:self.liveInfo.liveUrl];
    //这里填写指定观众的userId
    NSString *targetId = @"";
    if (!targetId.length) {
        [UIAlertController alertWithString:@"请填写指定的userId" inCurrentVC:self];
        return;
    }
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:targetId content:content pushContent:@"" pushData:@"" success:^(long messageId) {
        NSLog(@"消息发送成功%ld",messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"消息发送失败:%ld",(long)nErrorCode);
    }];
}


//添加本地采集预览界面
- (void)setupLocalVideoView{
    [self.streamVideos addObject:self.localVideo];
    [self updateLayoutWithAnimation:YES];
}

//加入房间
- (void)joinLiveRoom{
    //1.配置房间
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive; //房间类型
    config.liveType = RCRTCLiveTypeAudioVideo; //直播类型
    
    @WeakObj(self);
    [self.engine joinRoom:roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        @StrongObj(self);
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"加入房间失败code:%ld",(long)code] inCurrentVC:self];
            return;
        }
        // set delegate
        self.room = room;
        room.delegate = self;
        
        //2.发布本地默认流
        [self publishLocalLiveAVStream];
        
        //3.如果已经有远端的流
        if (room.remoteUsers.count) {
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in room.remoteUsers) {
                if (user.remoteStreams.count) {
                    [streamArray addObjectsFromArray:user.remoteStreams];
                    [self subscribeRemoteResource:streamArray orUid:nil];
                }
            }
        }
    }];
}

// 发布本地音视频流
- (void)publishLocalLiveAVStream {
    //视频预览
    RCRTCLocalVideoView *view = (RCRTCLocalVideoView *)self.localVideo.canvesView;
    //设置本地视频流
    [self.engine.defaultVideoStream setVideoView:view];
    //开始摄像头采集
    [self.engine.defaultVideoStream startCapture];
    
    
    //发布本地流到房间
    [self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        if (desc == RCRTCCodeSuccess) {
            //默认设置一次自定义合流布局
            self.liveInfo = liveInfo;
            [self streamlayoutMode:RCRTCMixLayoutModeCustom];
            NSLog(@"本地发布成功:liveUrl:%@",liveInfo.liveUrl);
            alert.message = liveInfo.liveUrl;
            UIAlertAction *okAtion = [UIAlertAction actionWithTitle:@"复制liveUrl到剪切板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [UIPasteboard generalPasteboard].string = liveInfo.liveUrl;
            }];
            [alert addAction:okAtion];
        }else {
            alert.message = @"本地发布失败,请退出房间重试";
            UIAlertAction *okAtion = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAtion];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

//退出房间
- (void)exitRoom{
    @WeakObj(self);
    [self.engine  leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (isSuccess && code == RCRTCCodeSuccess) {
            [self.streamVideos removeAllObjects];
            return;
        }
        [UIAlertController alertWithString:[NSString stringWithFormat:@"退出房间失败 code:%ld",(long)code] inCurrentVC:self];
    }];
}

//自定义模式合流布局
- (void)streamlayoutMode:(RCRTCMixLayoutMode)mode{
    @WeakObj(self);
    RCRTCMixConfig *config = [RCRTCMixStreamTool setOutputConfig:mode];
    [self.liveInfo setMixConfig:config completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (code == RCRTCCodeSuccess && isSuccess) {
            [UIAlertController alertWithString:@"合流布局切换成功" inCurrentVC:self];
            return;
        }
        [UIAlertController alertWithString:[NSString stringWithFormat:@"合流布局切换失败code:%ld",(long)code] inCurrentVC:self];
    }];
}


#pragma mark - RCRTCRoomEventDelegate

- (void)didOfflineUser:(RCRTCRemoteUser*)user{
    NSLog(@"掉线");
}

- (void)didLeaveUser:(RCRTCRemoteUser*)user{
    [self unsubscribeRemoteResource:nil orUid:user.userId];
}

- (void)didPublishStreams:(NSArray <RCRTCInputStream *>*)streams{
    [self subscribeRemoteResource:streams orUid:nil];
}

- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *>*)streams{
    [self unsubscribeRemoteResource:streams orUid:nil];
}

#pragma mark - private Method
//取消订阅远端流
- (void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orUid:(NSString *)uid {
    if (!uid) {
        for (RCRTCInputStream *stream in streams) {
            if (stream.mediaType == RTCMediaTypeVideo) {
                uid = stream.userId;
                if ([stream.tag isEqualToString:@"RongRTCFileVideo"]) {
                    uid = [uid stringByAppendingString:stream.tag];
                }
            }
        }
    }
    StreamVideo *sVideo = [self fetchStreamVideoWithId:uid];
    if (sVideo) {
        [sVideo.canvesView removeFromSuperview];
        [self.streamVideos removeObject:sVideo];
        [self updateLayoutWithAnimation:YES];
    }
}

//订阅远端流
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orUid:(NSString *)uid{
    // 订阅房间中远端用户音视频流资源
    [self.room.localUser subscribeStream:streams tinyStreams:nil completion:^(BOOL isSuccess, RCRTCCode desc) {}];
    // 创建并设置远端视频预览视图
    NSInteger i = 0;
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            uid = stream.userId;
            if ([stream.tag isEqualToString:@"RongRTCFileVideo"]) {
                uid = [uid stringByAppendingString:stream.tag];
            }
            StreamVideo *sVideo = [self creatStreamVideoWithId:uid];
            RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)sVideo.canvesView;
            [(RCRTCVideoInputStream *)stream setVideoView:remoteView];
            i++;
        }
    }
    if (i > 0) {
        [self updateLayoutWithAnimation:YES];
    }
}

- (StreamVideo *)creatStreamVideoWithId:(NSString *)uid{
    StreamVideo *sVideo = [self fetchStreamVideoWithId:uid];
    if (!sVideo) {
        sVideo = [[StreamVideo alloc] initWithUid:uid];
        [self.streamVideos insertObject:sVideo atIndex:0];
    }
    return sVideo;
}

- (StreamVideo *)fetchStreamVideoWithId:(NSString *)uid{
    for (StreamVideo *sVideo in self.streamVideos) {
        if ([uid isEqualToString:sVideo.userId]) {
            return sVideo;
        }
    }
    return nil;
}

- (void)updateLayoutWithAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateInterface];
        }];
    }
    else {
        [self updateInterface];
    }
}

- (void)updateInterface{
    [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
}

#pragma mark - lazy loading
- (RCRTCEngine *)engine{
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
//        [_engine enableSpeaker:YES];
    }
    return _engine;
}

- (VideoLayoutTool *)layoutTool{
    if (!_layoutTool) {
        _layoutTool = [VideoLayoutTool new];
    }
    return _layoutTool;
}

- (NSMutableArray<StreamVideo *> *)streamVideos{
    if (!_streamVideos) {
        _streamVideos = [NSMutableArray array];
    }
    return _streamVideos;
}

- (StreamVideo *)localVideo{
    if (!_localVideo) {
        _localVideo = [StreamVideo LocalStreamVideo];
    }
    return _localVideo;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


@end
