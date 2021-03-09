//
//  LiveViewController.m
//  quickdemo-live-broadcaster
//
//  Created by RongCloud on 2020/10/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "LiveViewController.h"
#import "AppConfig.h"
#import "StreamVideo.h"
#import "VideoLayoutTool.h"
#import "RCRTCMixStreamTool.h"
#import "UIAlertController+RC.h"
#import "RCMenuView.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import <RongChatRoom/RongChatRoom.h>

@interface LiveViewController ()<
RCRTCRoomEventDelegate,
RCMenuViewEventDelegate,
RCRTCStatusReportDelegate>

@property (weak, nonatomic) IBOutlet UIView *remoteContainerView;
@property (weak, nonatomic) IBOutlet RCMenuView *menuView;

@property (nonatomic, strong)RCRTCEngine *engine;
@property (nonatomic, strong)RCRTCRoom *room;
@property (nonatomic, strong)StreamVideo *localVideo;
@property (nonatomic, strong)RCRTCLiveInfo *liveInfo;

@property (nonatomic)NSMutableArray <StreamVideo *>*streamVideos;
@property (nonatomic, strong)VideoLayoutTool *layoutTool;
@property (nonatomic, assign)RCRTCRoleType roleType;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置事件代理
    [self.menuView setDelegate:self];
}

#pragma mark - RCMenuViewEventDelegate
//前置条件,需要建立IM连接
- (void)loginIMWithIndex:(NSInteger)index{
    //填写4个用户登录的 token 以数组形式存在
    NSArray *tokens = @[
        @"7dMPpxzoDjZCLXB/cBac1djRdM+2ZFkiQZdNJ4BpzW6qrAG4/ozWvd5KRQaO4srh@mwga.dy01-navqa.cn.ronghub.com;mwga.dy02-navqa.cn.ronghub.com",
        @"V9MR45srtlHbkgNkpdRdkdjRdM+2ZFkiQZdNJ4BpzW4PhkF/4Og6Sk37pNFya77Y@mwga.dy01-navqa.cn.ronghub.com;mwga.dy02-navqa.cn.ronghub.com",
        @"PEo6UkBiE/k9BW2tFhSkMdjRdM+2ZFkiQZdNJ4BpzW6WmrWZmhTaidrr3F6+Dq6n@mwga.dy01-navqa.cn.ronghub.com;mwga.dy02-navqa.cn.ronghub.com",
        @"Y+9H80Th/tN2AcJ9A0OUsdjRdM+2ZFkiQZdNJ4BpzW7oov7oDeTaZSHNONkytaIG@mwga.dy01-navqa.cn.ronghub.com;mwga.dy02-navqa.cn.ronghub.com",
    ];
    
    if (index >= tokens.count) return;
    //设置 APPKEY
    [[RCCoreClient sharedCoreClient] initWithAppKey:AppID];
    //设置导航
    [[RCCoreClient sharedCoreClient] setServerInfo:@"http://navqa.cn.ronghub.com" fileServer:nil];
    //登录IM
    [[RCCoreClient sharedCoreClient] connectWithToken:tokens[index] dbOpened:^(RCDBErrorCode code) {
    } success:^(NSString *userId) {
        NSString *successMsg = [NSString stringWithFormat:@"IM登录成功:%@",userId];
        [UIAlertController alertWithString:successMsg inCurrentVC:self];
    } error:^(RCConnectErrorCode errorCode) {
        NSString *errorMsg = [NSString stringWithFormat:@"IM登录失败code:%ld",(long)errorCode];
        [UIAlertController alertWithString:errorMsg inCurrentVC:self];
    }];
}

//退出
- (void)logout{
    [[RCCoreClient sharedCoreClient] logout];
}

//开始直播/结束直播
- (void)startLiveWithState:(BOOL)isSelected{
    self.roleType = (isSelected ? RCRTCRoleTypeHost : RCRTCRoleTypeUnknown);
    if (isSelected) {
        //加入房间
        [self setupLocalVideoView];
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeBroadcaster];
    }else{
        [self cleanRemoteContainer];
        [self exitRoom];//退出房间
    }
}

//观看直播/结束观看
- (void)watchLiveWithState:(BOOL)isSelected{
    self.roleType = (isSelected ? RCRTCRoleTypeAudience : RCRTCRoleTypeUnknown);
    if (isSelected) {
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
    }else{
        [self cleanRemoteContainer];
        [self exitRoom];
    }
}

//观众上下麦
- (void)connectHostWithState:(BOOL)isConnect{
    self.roleType = (isConnect ? RCRTCRoleTypeHost : RCRTCRoleTypeAudience);
    //先清理视图
    [self cleanRemoteContainer];
    //退出房间
    [self exitRoom];
    if (isConnect) {
        //上麦
        [self setupLocalVideoView];
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeBroadcaster];
    }else{//下麦
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
    }
}

//开启/关闭摄像头
- (void)cameraEnable:(BOOL)enable{
    RCRTCCameraOutputStream *DVStream = self.engine.defaultVideoStream;
    enable ? [DVStream startCapture] : [DVStream stopCapture];
}

//开启/关闭麦克风
- (void)micDisable:(BOOL)disable{
    [self.engine.defaultAudioStream setMicrophoneDisable:disable];
}
/**
 主播设置合流布局,观众端看效果

 自定义布局 RCRTCMixLayoutModeCustom = 1
 悬浮布局 RCRTCMixLayoutModeSuspension = 2
 自适应布局 RCRTCMixLayoutModeAdaptive = 3
  **默认新创建的房间是悬浮布局**
 */
- (void)streamLayout:(RCRTCMixLayoutMode)mode{
    [self streamlayoutMode:mode];
}

/// 切换摄像头
- (void)switchCamera{
    [self.engine.defaultVideoStream switchCamera];
}

- (void)subscribeType:(NSInteger)type{
    NSArray *liveStreams = [self.room getLiveStreams];
    [self subscribeRemoteResource:liveStreams isTiny:type];
}

//添加本地采集预览界面
- (void)setupLocalVideoView{
    [self.streamVideos addObject:self.localVideo];
    [self updateLayoutWithAnimation:YES];
}

//加入RTC房间
- (void)joinLiveRoomWithRole:(RCRTCLiveRoleType)roleType{
    //1.配置房间
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudioVideo;
    config.roleType = roleType;
    [self.engine setStatusReportDelegate:self];
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
        if (roleType == RCRTCLiveRoleTypeBroadcaster) {
            [self publishLocalLiveAVStream];
        }
        //3.1 单独订阅主播流
        if (room.remoteUsers.count) {
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in room.remoteUsers) {
                if (user.remoteStreams.count) {
                    [streamArray addObjectsFromArray:user.remoteStreams];
                    [self subscribeRemoteResource:streamArray orUid:nil];
                }
            }
        }
        //3.2 订阅 live 合流
        NSArray *liveStreams = [room getLiveStreams];
        if (liveStreams.count) {
            [self subscribeRemoteResource:liveStreams orUid:nil];
        }
    }];
}

//发布本地音视频流
- (void)publishLocalLiveAVStream{
    //1.视频预览
    RCRTCLocalVideoView *view = (RCRTCLocalVideoView *)self.localVideo.canvesView;
    //2.设置本地视频流
    [self.engine.defaultVideoStream setVideoView:view];
    //3.开始摄像头采集
    [self.engine.defaultVideoStream startCapture];
    //4.发布本地流到房间
    [self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        if (desc == RCRTCCodeSuccess) {
            self.liveInfo = liveInfo;
        }else {
            [UIAlertController alertWithString:@"本地流发布失败" inCurrentVC:nil];
        }
    }];
}

//退出房间
- (void)exitRoom{
    @WeakObj(self);
    [self.engine  leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"退出房间失败 code:%ld",(long)code] inCurrentVC:self];
        }
    }];
}

//自定义模式合流布局
- (void)streamlayoutMode:(RCRTCMixLayoutMode)mode{
    @WeakObj(self);
    RCRTCMixConfig *config = [RCRTCMixStreamTool setOutputConfig:mode];
    [self.liveInfo setMixConfig:config completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (code == RCRTCCodeSuccess && isSuccess) return;
        [UIAlertController alertWithString:[NSString stringWithFormat:@"合流布局切换失败code:%ld",(long)code] inCurrentVC:self];
    }];
}

//取消订阅远端流
- (void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orUid:(NSString *)uid {
    if (!uid) {
        for (RCRTCInputStream *stream in streams) {
            if (stream.mediaType == RTCMediaTypeVideo) {
                uid = stream.userId;
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
    [self subscribeRemoteResource:streams isTiny:NO];
}

- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams isTiny:(BOOL)isTiny{
    // 订阅房间中远端用户音视频流资源
    NSArray *tinyStream = isTiny ? streams : @[];
    NSArray *ordinaryStream = isTiny ? @[] : streams;
    [self.room.localUser subscribeStream:ordinaryStream
                             tinyStreams:tinyStream
                              completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (desc != RCRTCCodeSuccess) {
            NSString *errorStr = [NSString stringWithFormat:@"订阅远端流失败:%ld",(long)desc];
            [UIAlertController alertWithString:errorStr inCurrentVC:nil];
            return;
        }
        NSLog(@"切换成功");
        // 创建并设置远端视频预览视图
        NSInteger i = 0;
        for (RCRTCInputStream *stream in streams) {
            if (stream.mediaType == RTCMediaTypeVideo) {
                [self setupRemoteViewWithUid:stream.userId combineStream:stream];
                i++;
            }
        }
        if (i > 0) {
            [self updateLayoutWithAnimation:YES];
        }
    }];
}

//清空视图
- (void)cleanRemoteContainer{
    [self.streamVideos removeAllObjects];
    for (UIView *subview in self.remoteContainerView.subviews) {
        [subview removeFromSuperview];
    }
}

- (StreamVideo *)setupRemoteViewWithUid:(NSString *)uid combineStream:(RCRTCInputStream *)stream{
    StreamVideo *sVideo = [self creatStreamVideoWithId:uid];
    RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)sVideo.canvesView;
    [(RCRTCVideoInputStream *)stream setVideoView:remoteView];
    return sVideo;
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
        [UIView animateWithDuration:0.25 animations:^{
            [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
        }];
    }else{
        [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
    }
}

#pragma mark - RCRTCRoomEventDelegate
//直播合流发布
- (void)didPublishLiveStreams:(NSArray<RCRTCInputStream*> *)streams{
    NSLog(@"已发布liveStream:%@",streams);
    [self subscribeRemoteResource:streams orUid:nil];
}
//直播合流取消发布
- (void)didUnpublishLiveStreams:(NSArray<RCRTCInputStream*> *)streams{
    NSLog(@"取消发布liveStream:%@",streams);
    [self unsubscribeRemoteResource:streams orUid:nil];
}
//新用户加入
- (void)didJoinUser:(RCRTCRemoteUser *)user{
    NSLog(@"didJoinUser:%@",user);
}
//离开
- (void)didLeaveUser:(RCRTCRemoteUser *)user{
    NSLog(@"didLeaveUser:%@",user);
    [self unsubscribeRemoteResource:nil orUid:user.userId];
}
//远端掉线
- (void)didOfflineUser:(RCRTCRemoteUser*)user{
    NSLog(@"didOfflineUser:%@",user.userId);
    [self unsubscribeRemoteResource:nil orUid:user.userId];
}
//流连接成功
- (void)didConnectToStream:(RCRTCInputStream *)stream{
    NSLog(@"didConnectToStream:%@",stream);
}

- (void)didReportStatusForm:(RCRTCStatusForm *)form{
    NSLog(@"--recvStats:%@",form.recvStats);
}

#pragma mark - setter & getter
- (RCRTCEngine *)engine{
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
        [_engine setMediaServerUrl:@"https://rtc-data-bdcbj.rongcloud.net"];
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

- (void)setRoleType:(RCRTCRoleType)roleType{
    _roleType = roleType;
    switch (_roleType) {
        case RCRTCRoleTypeUnknown:
            self.title = @"直播 Demo";
            break;
        case RCRTCRoleTypeHost:
            self.title = @"直播 Demo-主播端";
            [self.engine enableSpeaker:NO];
            break;
        case RCRTCRoleTypeAudience:
            self.title = @"直播 Demo-观众端";
            [self.engine enableSpeaker:YES];
            break;;
        default:
            break;
    }
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
