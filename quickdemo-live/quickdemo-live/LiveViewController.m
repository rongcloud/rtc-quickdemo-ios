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

@interface LiveViewController ()<RCRTCRoomEventDelegate,RCMenuViewEventDelegate,RCIMClientReceiveMessageDelegate>

@property (weak, nonatomic) IBOutlet UIView *remoteContainerView;
@property (weak, nonatomic) IBOutlet RCMenuView *menuView;

@property (nonatomic, strong)RCRTCEngine *engine;
@property (nonatomic, strong)RCRTCRoom *room;
@property (nonatomic, strong)StreamVideo *localVideo;
@property (nonatomic, strong)RCRTCLiveInfo *liveInfo;

@property (nonatomic, copy)NSString *liveUrl;
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
    NSArray *tokens= @[
        @"<#token1#>",
        @"<#token2#>",
        @"<#token3#>",
        @"<#token4#>"];
    
    if (index >= tokens.count) return;
    
    //设置 APPKEY
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppID];
    //接受消息回调
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    //登录IM
    [[RCIMClient sharedRCIMClient] connectWithToken:tokens[index] dbOpened:^(RCDBErrorCode code) {
    } success:^(NSString *userId) {
        NSString *successMsg = [NSString stringWithFormat:@"IM登录成功:%@",userId];
        [UIAlertController alertWithString:successMsg inCurrentVC:self];
        //加入IM聊天室
        [self joinIMChatRoom];
    } error:^(RCConnectErrorCode errorCode) {
        NSString *errorMsg = [NSString stringWithFormat:@"IM登录失败code:%ld",(long)errorCode];
        [UIAlertController alertWithString:errorMsg inCurrentVC:self];
    }];
}

//退出
- (void)logout{
    //退出聊天室
    [[RCIMClient sharedRCIMClient] quitChatRoom:roomId success:^{
        NSLog(@"退出IM聊天室成功");
        //退出IM
        [[RCIMClient sharedRCIMClient] logout];
        self.liveUrl = nil;
    } error:^(RCErrorCode status) {
        NSLog(@"退出IM聊天室失败:%ld",(long)status);
    }];
}

//开始直播/结束直播
- (void)startLiveWithState:(BOOL)isSelected{
    self.roleType = (isSelected ? RCRTCRoleTypeHost : RCRTCRoleTypeUnknown);
    if (isSelected) {
        //加入房间
        [self setupLocalVideoView];
        [self joinLiveRoom];
    }else{
        [self cleanRemoteContainer];
        [self exitRoom];//退出房间
        self.liveUrl = nil;
    }
}

//观看直播/结束观看
- (void)watchLiveWithState:(BOOL)isSelected{
    self.roleType = (isSelected ? RCRTCRoleTypeAudience : RCRTCRoleTypeUnknown);
    if (isSelected) {
        [self subscribeLiveStream];//订阅url
    }else{
        [self cleanRemoteContainer];
        [self unSubscribeLiveStream];//取消订阅
    }
}

//观众上下麦
- (void)connectHostWithState:(BOOL)isConnect{
    self.roleType = (isConnect ? RCRTCRoleTypeHost : RCRTCRoleTypeAudience);
    //先清理视图
    [self cleanRemoteContainer];
    if (isConnect) {//上麦
        [self unSubscribeLiveStream];
        [self setupLocalVideoView];
        [self joinLiveRoom];
    }else{//下麦
        [self exitRoom];
        [self subscribeLiveStream];
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

//发送直播地址(*通过IM消息 这属于demo 辅助功能*)
- (void)sendLiveUrl{
    //加入IM聊天室
    if (!self.liveInfo.liveUrl.length) return;
    RCTextMessage *content = [RCTextMessage messageWithContent:self.liveUrl];
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM targetId:roomId content:content pushContent:@"" pushData:@"" success:^(long messageId) {
        NSLog(@"消息发送成功");
    } error:^(RCErrorCode nErrorCode, long messageId) {
        [UIAlertController alertWithString:@"消息发送失败" inCurrentVC:nil];
    }];
}


#pragma mark - private method
// 加入IM聊天室(辅助流程收发直播地址)
- (void)joinIMChatRoom{
    [[RCIMClient sharedRCIMClient] joinChatRoom:roomId
                                    messageCount:-1
                                        success:^{
        NSLog(@"加入IM聊天室成功");
    } error:^(RCErrorCode status) {
        NSLog(@"加入IM聊天室失败:%ld",(long)status);
    }];
}

//添加本地采集预览界面
- (void)setupLocalVideoView{
    [self.streamVideos addObject:self.localVideo];
    [self updateLayoutWithAnimation:YES];
}

//加入RTC房间
- (void)joinLiveRoom{
    //1.配置房间
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudioVideo;
    
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
        
        //3.如果已经有远端的流,需要订阅
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
            self.liveUrl = liveInfo.liveUrl;
            NSLog(@"本地发布成功:liveUrl:%@",liveInfo.liveUrl);
        }else {
            [UIAlertController alertWithString:@"本地流发布失败" inCurrentVC:nil];
        }
    }];
}

//订阅主播
- (void)subscribeLiveStream{
    @WeakObj(self);
    [self.engine subscribeLiveStream:self.liveUrl streamType:RCRTCAVStreamTypeAudioVideo completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        @StrongObj(self);
        if (desc != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:@"订阅失败,检查liveUrl" inCurrentVC:self];
        }
        // 注意 * 当前block这里会回调两次,需要针对流类型处理
        if (inputStream.mediaType == RTCMediaTypeVideo) {
            StreamVideo *v = [self setupRemoteViewWithUid:inputStream.userId combineStream:inputStream];
            [self.streamVideos addObject:v];
            [self updateLayoutWithAnimation:YES];
        }
    }];
}

//取消订阅
- (void)unSubscribeLiveStream{
    [self.engine unsubscribeLiveStream:self.liveUrl completion:^(BOOL isSuccess, RCRTCCode code) {
        if (code != RCRTCCodeSuccess) {
            NSString *errorMsg = [NSString stringWithFormat:@"取消订阅失败code:%ld",(long)code];
            [UIAlertController alertWithString:errorMsg inCurrentVC:self];
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
    // 订阅房间中远端用户音视频流资源
    [self.room.localUser subscribeStream:streams
                             tinyStreams:@[]
                              completion:^(BOOL isSuccess, RCRTCCode desc) {}];
    // 创建并设置远端视频预览视图
    NSInteger i = 0;
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            uid = stream.userId;
            [self setupRemoteViewWithUid:uid combineStream:stream];
            i++;
        }
    }
    if (i > 0) {
        [self updateLayoutWithAnimation:YES];
    }
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

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object{
    RCTextMessage *textMsg = (RCTextMessage *)message.content;
    self.liveUrl = textMsg.content;
}

#pragma mark - RCRTCRoomEventDelegate
- (void)didOfflineUser:(RCRTCRemoteUser*)user{
    NSLog(@"user:%@掉线",user.userId);
    [self unsubscribeRemoteResource:nil orUid:user.userId];
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

#pragma mark - setter & getter

- (void)setLiveUrl:(NSString *)liveUrl{
    _liveUrl = liveUrl;
    NSString *text = @"liveUrl:";
    if (_liveUrl.length) {
        text = [text stringByAppendingString:_liveUrl];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.menuView.liveUrlLabel setText:text];
    });
}

- (RCRTCEngine *)engine{
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
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
