//
//  LiveViewController.m,
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LiveViewController.h"
#import "LiveStreamVideo.h"
#import "LiveVideoLayoutTool.h"
#import "UIAlertController+RCRTC.h"
#import "LiveMixStreamTool.h"
#import "GPUImageHandle.h"
#import "BeautyMenusView.h"
#import "RCRTCPKView.h"
#import <RongFaceBeautifier/RongFaceBeautifier.h>

/*!
 主播直播显 /观众观看直播
 setRoleType   自定义的私有方法，区分主播/观众进入不同 UI 显示
 加入房间：
 主播
 1.设置切换听筒为扬声器
 2.添加本地采集预览界面
 3.加入RTC房间
 
 观众
 1.设置切换听筒为扬声器
 2.加入RTC房间
 
 观众上麦：
 1.先清理视图
 2.使用 switch role 切换为主播, 添加需要发布的流
 3.切换成功, 自行订阅

 主播下麦：
 1.先清理视图
 2.使用 switch role 切换为观众
 3.切换成功, 自行订阅直播合流
 
 退出房间：主播/观众
 1.先清理视图
 2.退出房间
 
 美颜
 1.导入 GPUImage.framework
 2.引入头文件 GPUImageHandle.h
 3.初始化 GPUImageHandle
 4.在加入 RTC 房间逻辑里设置获取采集的 buffer 回调
 
 自定义视频流
 startPublishVideoFil 发布自定义视频流
 参考 RCRTCFileSource 文件设置视频中的音频，然后混音发送
 stopPublishVideoFile 取消发布自定义视频流
 
 pk 跨房间连麦
 1.唤起 pk 邀请视图
 2.输入 roomId 和 userId,点击 '开始邀请'
 3.被邀请端点击 'ok'
 此时 A 房间能看到 B 房间的流, B 房间能看到 A 房间的流
 4.任意房间在 pk 邀请视图里点击 '离开副房间' A B 两端结束 pk

 */

@interface LiveViewController ()
<
RCRTCRoomEventDelegate,
RCRTCStatusReportDelegate,
RCRTCFileVideoOutputStreamDelegate,
BeautyMenusViewDelegate,
PKViewBtnEventDelegate,
RCRTCOtherRoomEventDelegate
>

@property (nonatomic, weak) IBOutlet UIView *remoteContainerView;
@property (nonatomic, weak) IBOutlet UIButton *closeCamera;
@property (nonatomic, weak) IBOutlet UIButton *closeMicBtn;
@property (nonatomic, weak) IBOutlet UIButton *switchStreamMode;
@property (nonatomic, weak) IBOutlet UIButton *streamLayoutBtn;
@property (nonatomic, weak) IBOutlet UIButton *closeLiveBtn;
@property (nonatomic, nonatomic) IBOutlet UIButton *connectHostBtn;
@property (nonatomic, nonatomic) IBOutlet UIButton *waterMark;
@property (nonatomic, nonatomic) IBOutlet UIButton *beautyButton;

@property (nonatomic, assign) BOOL openWaterMark;
@property (nonatomic, strong, nullable) GPUImageHandle *gpuImageHandler;
@property (nonatomic, weak) RCRTCRoom *room;
@property (nonatomic, weak) RCRTCOtherRoom *pkRoom;
@property (nonatomic, strong) RCRTCLiveInfo *liveInfo;
@property (nonatomic, strong) LiveStreamVideo *localVideo;
@property (nonatomic) NSMutableArray <LiveStreamVideo *>*streamVideos;
@property (nonatomic, strong) LiveVideoLayoutTool *layoutTool;
@property (nonatomic, strong) RCRTCFileVideoOutputStream *fileVideoOutputStream;
@property (nonatomic, strong) LiveStreamVideo *localFileStreamVideo;
@property (nonatomic, strong) RCRTCVideoView *remoteFileVideoView;
@property (nonatomic, strong) RCRTCPKView *pkView;

// 功能按钮容器
@property(nonatomic, copy) NSArray *funcBtns;
// 发布本地自定义流开关
@property(strong, nonatomic) UIButton *pushLocalButton;

@property(nonatomic, strong) UIButton *pkBtn;
// 音频配置
@property(strong, nonatomic) RCRTCEngine *engine;
// 美颜状态
@property(nonatomic, assign) BOOL openBeauty;

@property (nonatomic, strong) BeautyMenusView *vBeautyMenus;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     * 必要步骤：
     *
     * 参考 RCRTCLoginViewController.m 中的 connectRongCloud 方法进行初始化
     */
    // 初始化 UI
    [self initView];

    // 直播类型下的角色区分：主播/观众
    [self setRoleType];
}

#pragma mark - startLive & watchLive

/**
 * 直播类型下的角色区分
 * 1.主播开启直播
 * 2.观众观看直播
 */
- (void)setRoleType {
    // 判断用户状态改变退出按钮显示
    _closeLiveBtn.selected = _liveRoleType;

    switch (_liveRoleType) {
        // 当前直播角色为主播
        case RCRTCLiveRoleTypeBroadcaster:
            self.title = @"直播 Demo-主播端";
            [self disableClickWith:@[self.connectHostBtn]];

            // 1.设置切换听筒为扬声器
            [self.engine enableSpeaker:YES];

            // 2.添加本地采集预览界面
            [self setupLocalVideoView];

            // 3.加入RTC房间
            [self joinLiveRoomWithRole:RCRTCLiveRoleTypeBroadcaster];

            break;
            // 当前直播角色为观众
        case RCRTCLiveRoleTypeAudience:
            self.title = @"直播 Demo-观众端";
            [self disableClickWith:@[self.closeCamera,
                    self.closeMicBtn,
                    self.streamLayoutBtn,
                    self.switchStreamMode,
                    self.beautyButton,
                    self.pushLocalButton,
                    self.waterMark]];

            // 1.设置切换听筒为扬声器
            [self.engine enableSpeaker:YES];
            // 2.加入 RTC 房间
            [self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
            break;;
        default:
            break;
    }
}

// 观众上下麦
- (void)connectHostWithState:(BOOL)isConnect {
    //1.清理视图
    [self cleanRemoteContainer];
    if (isConnect) {
        //设置摄像头采集,本地预览
        [self.engine.defaultVideoStream setVideoView:self.localVideo.canvesView];
        [self.engine.defaultVideoStream startCapture];
        [self setupLocalVideoView];
        //2.切换成主播
        NSArray *streams = @[self.engine.defaultAudioStream,self.engine.defaultVideoStream];
        [self.room.localUser switchToBroadcaster:streams onSucceed:^(RCRTCLiveInfo * _Nonnull liveInfo) {
            //3.切换成功, 订阅远端用户流
            self.liveRoleType = RCRTCLiveRoleTypeBroadcaster;
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in self.room.remoteUsers) {
                if (user.remoteStreams.count) {
                    [streamArray addObjectsFromArray:user.remoteStreams];
                }
            }
            if (streamArray.count) {
                [self subscribeRemoteResource:streamArray];
            }
        } onFailed:^(RCRTCCode code) {
            NSLog(@"OnFailed:%@",@(code));
        } onKicked:^{
            NSLog(@"OnKicked");
        }];
    }else{
        //2.切换成观众
        [self.room.localUser switchToAudienceOnSucceed:^{
            
            self.liveRoleType = RCRTCLiveRoleTypeAudience;
            [self.engine.defaultVideoStream stopCapture];
            //3.订阅直播合流
            NSArray *liveStreams = [self.room getLiveStreams];
            if (liveStreams.count) {
                [self subscribeRemoteResource:liveStreams];
            }
            
        } onFailed:^(RCRTCCode code) {
            NSLog(@"OnFailed:%@",@(code));
        } onKicked:^{
            NSLog(@"OnKicked");
        }];
    }
}

#pragma mark - setter & getter

- (LiveStreamVideo *)localFileStreamVideo {
    if (!_localFileStreamVideo) {
        _localFileStreamVideo = [LiveStreamVideo LocalStreamVideo];
    }
    return _localFileStreamVideo;
}

- (RCRTCEngine *)engine {
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
    }
    return _engine;
}

- (LiveVideoLayoutTool *)layoutTool {
    if (!_layoutTool) {
        _layoutTool = [LiveVideoLayoutTool new];
    }
    return _layoutTool;
}

- (NSMutableArray<LiveStreamVideo *> *)streamVideos {
    if (!_streamVideos) {
        _streamVideos = [NSMutableArray array];
    }
    return _streamVideos;
}

- (LiveStreamVideo *)localVideo {
    if (!_localVideo) {
        _localVideo = [LiveStreamVideo LocalStreamVideo];
    }
    return _localVideo;
}

- (NSArray *)funcBtns {
    if (!_funcBtns) {
        _funcBtns = @[
                self.closeLiveBtn,
                self.connectHostBtn,
                self.closeCamera,
                self.closeMicBtn,
                self.streamLayoutBtn,
                self.switchStreamMode,
                self.beautyButton,
                self.pushLocalButton,
                self.waterMark];
    }
    return _funcBtns;
}

- (GPUImageHandle *)gpuImageHandler {
    if (!_gpuImageHandler) {
        _gpuImageHandler = [[GPUImageHandle alloc] init];
    }
    return _gpuImageHandler;
}

- (BeautyMenusView *)vBeautyMenus {
    if (!_vBeautyMenus) {
        _vBeautyMenus = [[BeautyMenusView alloc] initWithFrame:self.view.bounds];
        _vBeautyMenus.delegate = self;
    }
    return _vBeautyMenus;
}

#pragma mark - UI

/*!
 设置导航左侧发布按钮
 设置导航右侧美颜按钮
 */
- (void)initView {
    _pushLocalButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    [_pushLocalButton setTitle:@"发布本地" forState:UIControlStateNormal];
    [_pushLocalButton setTitle:@"关闭本地" forState:UIControlStateSelected];
    [_pushLocalButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [_pushLocalButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateSelected];
    [_pushLocalButton addTarget:self action:@selector(publishLocalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_pushLocalButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.pkBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

// 功能按钮状态切换
- (void)disableClickWith:(NSArray *)btns {
    for (UIButton *btn in self.funcBtns) {
        if (btn == _pushLocalButton) {
            _pushLocalButton.alpha = 1;
            continue;
        }
        [btn setBackgroundColor:[UIColor colorWithRed:29.0 / 255.0 green:183.0 / 255.0 blue:1.0 alpha:1]];
        btn.enabled = YES;
    }
    for (UIButton *btn in btns) {
        if (btn == _pushLocalButton) {
            _pushLocalButton.alpha = 0;
            continue;
        }
        [btn setBackgroundColor:[UIColor grayColor]];
        btn.enabled = NO;
    }
}

// 添加本地采集预览界面
- (void)setupLocalVideoView {
    [self.streamVideos addObject:self.localVideo];
    [self updateLayoutWithAnimation:YES];
}

// 清空视图
- (void)cleanRemoteContainer {
    [self.streamVideos removeAllObjects];
    for (UIView *subview in self.remoteContainerView.subviews) {
        [subview removeFromSuperview];
    }
}

#pragma mark - Event

// 离开房间
- (IBAction)closeLiveAction:(UIButton *)sender {
    // 1.清理视图
    [self cleanRemoteContainer];
    // 2.退出房间
    [self exitRoom];
    [self.navigationController popViewControllerAnimated:YES];
    // 3.重置美颜
    [[RCRTCBeautyEngine sharedInstance] reset];
}

// 上麦/下麦状态判断
- (IBAction)connectHostAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self disableClickWith:nil];
    } else {
        [self disableClickWith:@[self.closeCamera,
                self.closeMicBtn,
                self.streamLayoutBtn,
                self.switchStreamMode,
                self.beautyButton,
                self.pushLocalButton,
                self.waterMark]];
    }
    // 上麦/下麦
    [self connectHostWithState:sender.selected];
}

// 开关摄像头
- (IBAction)closeCameraAction:(UIButton *)sender {
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    sender.selected = !sender.selected;
    // 开关摄像头
    RCRTCCameraOutputStream *DVStream = self.engine.defaultVideoStream;
    !sender.selected ? [DVStream startCapture] : [DVStream stopCapture];
}

// 开/关麦克风
- (IBAction)closeMicAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    /*!
     关闭/打开麦克风
     @param disable YES 关闭，NO 打开
     */
    [self.engine.defaultAudioStream setMicrophoneDisable:sender.selected];
}

// 自定义布局状态判断
- (IBAction)streamLayoutAction:(UIButton *)sender {
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    sender.tag >= 3 ? sender.tag = 1 : (sender.tag += 1);
    // 自定义布局刷新
    [self streamlayoutMode:(RCRTCMixLayoutMode) sender.tag];

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

// 切换摄像头状态判断
- (IBAction)switchStreamAction:(UIButton *)sender {
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    sender.selected = !sender.selected;
    // 切换摄像头
    [self.engine.defaultVideoStream switchCamera];
}

// 切换美颜
- (IBAction)beautyAction:(UIButton *)sender {
    if (!self.vBeautyMenus.isShowing) {
        [self.vBeautyMenus showWithViewController:self];
    }
}

// 添删水印
- (IBAction)waterMark:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.openWaterMark = sender.selected;
    [self changeFliterIsOpenBearty:self.openBeauty isOpenWarkMark:self.openWaterMark];
    [self.gpuImageHandler rotateWaterMark:sender.selected];

}

// 发送本地自定义流
- (void)publishLocalButtonAction:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self startPublishVideoFile];
    } else {
        [self stopPublishVideoFile];
    }
}

// 发布自定义流
- (void)startPublishVideoFile {

    RCRTCVideoView *localFileVideoView = (RCRTCVideoView *) self.localFileStreamVideo.canvesView;
    localFileVideoView.fillMode = RCRTCVideoFillModeAspectFit;
    localFileVideoView.frameAnimated = NO;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"video_demo1_low"
                                                     ofType:@"mp4"];
    
    RCRTCVideoStreamConfig *videoConfig = self.fileVideoOutputStream.videoConfig;
    videoConfig.videoSizePreset = RCRTCVideoSizePreset720x480;
    
    NSString *tag = @"RongRTCFileVideo";
    self.fileVideoOutputStream = [[RCRTCEngine sharedInstance] createFileVideoOutputStream:path
                                                                              replaceAudio:NO
                                                                                  playback:YES
                                                                                       tag:tag
                                                                                    config:videoConfig];
    [self.fileVideoOutputStream setVideoView:localFileVideoView];
    self.fileVideoOutputStream.delegate = self;

    [self.room.localUser publishLiveStream:self.fileVideoOutputStream
                                completion:^(BOOL isSuccess, RCRTCCode code, RCRTCLiveInfo *_Nullable liveInfo) {
                                    if (code == RCRTCCodeSuccess) {
                                        [self.streamVideos addObject:self.localFileStreamVideo];
                                        [self updateLayoutWithAnimation:YES];
                                    } else {
                                    }
                                }];
}

// 取消发布自定义视频流
- (void)stopPublishVideoFile {
    if (self.fileVideoOutputStream) {
        [self.fileVideoOutputStream stop];
        self.fileVideoOutputStream.delegate = nil;
    }
    [self.room.localUser unpublishLiveStream:self.fileVideoOutputStream
                                  completion:^(BOOL isSuccess, RCRTCCode code) {
                                      if (isSuccess) {
                                          [self.streamVideos removeObject:self.localFileStreamVideo];
                                          self.localFileStreamVideo = nil;
                                          self.fileVideoOutputStream = nil;
                                          [self updateLayoutWithAnimation:YES];
                                      }
                                  }];
}

// 布局视图动画
- (void)updateLayoutWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
        }];
    } else {
        [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
    }
}

#pragma mark - RTC
/*!
 主播设置合流布局,观众端看效果
 自定义布局 RCRTCMixLayoutModeCustom = 1
 悬浮布局 RCRTCMixLayoutModeSuspension = 2
 自适应布局 RCRTCMixLayoutModeAdaptive = 3
 默认新创建的房间是悬浮布局
 */

// 加入 RTC 房间
- (void)joinLiveRoomWithRole:(RCRTCLiveRoleType)roleType {
    // 1.配置房间
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudioVideo;
    config.roleType = roleType;
    [self.engine setStatusReportDelegate:self];
    __weak typeof(self) weakSelf = self;
    [self.engine joinRoom:_roomId config:config completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"加入房间失败 code:%ld", (long) code] inCurrentViewController:strongSelf];
            return;
        }
        self.room = room;
        room.delegate = self;
        if (roleType == RCRTCLiveRoleTypeBroadcaster) {
            // 2.发布本地默认流
            [self publishLocalLiveAVStream];
            // 设置视频纹理渲染
            [self setBuffer];
            // 3.1单独订阅主播流
            if (room.remoteUsers.count) {
                NSMutableArray *streamArray = [NSMutableArray array];
                for (RCRTCRemoteUser *user in room.remoteUsers) {
                    if (user.remoteStreams.count) {
                        [streamArray addObjectsFromArray:user.remoteStreams];
                        [self subscribeRemoteResource:streamArray];
                    }
                }
            }
        } else {
            // 3.2 观众订阅 live 合流
            NSArray *liveStreams = [room getLiveStreams];
            if (liveStreams.count) {
                [self subscribeRemoteResource:liveStreams];
            }
        }
    }];
}

// 设置视频渲染纹理
- (void)setBuffer {
    __weak typeof(self) weakSelf = self;
    [RCRTCEngine sharedInstance].defaultVideoStream.videoSendBufferCallback =
            ^CMSampleBufferRef _Nullable(BOOL valid, CMSampleBufferRef _Nullable sampleBuffer) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf || (!strongSelf.openBeauty && !strongSelf.openWaterMark)) {
                    return sampleBuffer;
                }
                CMSampleBufferRef processedSampleBuffer = [strongSelf.gpuImageHandler onGPUFilterSource:sampleBuffer];
                return processedSampleBuffer ?: sampleBuffer;
            };
}

// 退出房间
- (void)exitRoom {
    [self.engine.defaultVideoStream stopCapture];
    __weak typeof(self) weakSelf = self;
    [self.engine leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"退出房间失败 code:%ld", (long) code] inCurrentViewController:strongSelf];
        }
    }];

    // 如果是主播且在发布自定义流，退出本地发送
    if (self.pushLocalButton.selected && !self.liveRoleType) {
        [self stopPublishVideoFile];
    }
}

// 发布本地音视频流
- (void)publishLocalLiveAVStream {
    // 1.初始化渲染视图
    RCRTCVideoView *view = (RCRTCVideoView *) self.localVideo.canvesView;
    // 2.设置视频流的渲染视图
    [self.engine.defaultVideoStream setVideoView:view];
    // 3.设置视频流参数
    RCRTCVideoStreamConfig *videoConfig =self.engine.defaultVideoStream.videoConfig;
    videoConfig.videoSizePreset = RCRTCVideoSizePreset1280x720;
    [self.engine.defaultVideoStream setVideoConfig:videoConfig];
    // 4.开始摄像头采集
    [self.engine.defaultVideoStream startCapture];
    // 5.发布本地流到房间
    [self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo *_Nullable liveInfo) {
        if (desc == RCRTCCodeSuccess) {
            self.liveInfo = liveInfo;
        } else {
            [UIAlertController alertWithString:@"本地流发布失败" inCurrentViewController:nil];
        }
    }];
}

// 自定义合流布局
- (void)streamlayoutMode:(RCRTCMixLayoutMode)mode {
    __weak typeof(self) weakSelf = self;
    RCRTCMixConfig *config = [LiveMixStreamTool setOutputConfig:mode];
    [self.liveInfo setMixConfig:config completion:^(BOOL isSuccess, RCRTCCode code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code == RCRTCCodeSuccess && isSuccess) return;
        [UIAlertController alertWithString:[NSString stringWithFormat:@"合流布局切换失败 code:%ld", (long) code] inCurrentViewController:strongSelf];
    }];
}

// 取消订阅流 Id 所对应的 View
- (void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orStreamId:(NSString *)streamId {
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            streamId = stream.streamId;
            [self fetchStreamVideoOffLineWithStreamId:streamId];
        }
    }
}

// 订阅远端流
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
    [self subscribeRemoteResource:streams isTiny:NO];
}

- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams isTiny:(BOOL)isTiny {
    // 订阅房间中远端用户音视频流资源
    NSArray *tinyStream = isTiny ? streams : @[];
    NSArray *ordinaryStream = isTiny ? @[] : streams;
    [self.room.localUser subscribeStream:ordinaryStream
                             tinyStreams:tinyStream
                              completion:^(BOOL isSuccess, RCRTCCode desc) {
                                  if (desc != RCRTCCodeSuccess) {
                                      NSString *errorStr = [NSString stringWithFormat:@"订阅远端流失败:%ld", (long) desc];
                                      [UIAlertController alertWithString:errorStr inCurrentViewController:nil];
                                      return;
                                  }

                                  // 创建并设置远端视频预览视图
                                  NSInteger i = 0;
                                  for (RCRTCInputStream *stream in streams) {
                                      if (stream.mediaType == RTCMediaTypeVideo) {
                                          [self setupRemoteViewWithStream:stream];
                                          i++;
                                      }
                                  }
                                  if (i > 0) {
                                      [self updateLayoutWithAnimation:YES];
                                  }
                              }];
}

// 创建并设置远端视频预览视图
- (LiveStreamVideo *)setupRemoteViewWithStream:(RCRTCInputStream *)stream {

    LiveStreamVideo *sVideo = [self creatStreamVideoWithStreamId:stream.streamId];
    sVideo.userId = stream.userId;
    RCRTCVideoView *remoteView = (RCRTCVideoView *) sVideo.canvesView;

    //如果为自定义视频流则适配显示
    if ([stream.tag isEqualToString:@"RongRTCFileVideo"]) {

        remoteView.fillMode = RCRTCVideoFillModeAspectFit;

    }
    //设置视频流的渲染视图
    [(RCRTCVideoInputStream *) stream setVideoView:remoteView];
    return sVideo;
}

// 判断是否已有预览视图
- (LiveStreamVideo *)creatStreamVideoWithStreamId:(NSString *)streamId {
    LiveStreamVideo *sVideo = [self fetchStreamVideoWithStreamId:streamId];
    if (!sVideo) {
        sVideo = [[LiveStreamVideo alloc] initWithStreamId:streamId];
        [self.streamVideos insertObject:sVideo atIndex:0];
    }
    return sVideo;
}

// 根据 streamId 确认唯一的音视频流
- (LiveStreamVideo *)fetchStreamVideoWithStreamId:(NSString *)streamId {
    for (LiveStreamVideo *sVideo in self.streamVideos) {
        if ([streamId isEqualToString:sVideo.streamId]) {
            return sVideo;
        }
    }
    return nil;
}

// 远端掉线/离开回掉调用，根据流 id 删除远端用户的所有音视频流
- (void)fetchStreamVideoOffLineWithStreamId:(NSString *)streamId {
    NSArray *arr = [NSArray arrayWithArray:self.streamVideos];
    for (LiveStreamVideo *sVideo in arr) {
        if ([streamId isEqualToString:sVideo.streamId]) {
            if (sVideo) {
                [sVideo.canvesView removeFromSuperview];
                [self.streamVideos removeObject:sVideo];

            }
        }
    }
    [self updateLayoutWithAnimation:YES];
}

// 远端掉线/离开回掉调用，根据用户 id 删除远端用户的所有音视频流
- (void)fetchStreamVideoOffLineWithUserId:(NSString *)userId {
    NSArray *arr = [NSArray arrayWithArray:self.streamVideos];
    for (LiveStreamVideo *sVideo in arr) {
        if ([userId isEqualToString:sVideo.userId]) {
            if (sVideo) {
                [sVideo.canvesView removeFromSuperview];
                [self.streamVideos removeObject:sVideo];

            }
        }
    }
    [self updateLayoutWithAnimation:YES];
}

#pragma mark - RCRTCRoomEventDelegate
- (void)didSwitchRoleWithUser:(RCRTCRemoteUser *)user roleType:(RCRTCLiveRoleType)roleType{
    if(roleType == RCRTCLiveRoleTypeAudience){
        [self fetchStreamVideoOffLineWithUserId:user.userId];
    }
 
}
// 主播监听其他主播发布资源并订阅
- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    if(!_liveRoleType){
        [self subscribeRemoteResource:streams];
    }
}
- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    if(!_liveRoleType){
        [self unsubscribeRemoteResource:streams orStreamId:nil];
    }
}
// 直播合流发布
- (void)didPublishLiveStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self subscribeRemoteResource:streams];
}

// 直播合流取消发布
- (void)didUnpublishLiveStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self unsubscribeRemoteResource:streams orStreamId:nil];
}

// 新用户加入
- (void)didJoinUser:(RCRTCRemoteUser *)user {

}

// 离开
- (void)didLeaveUser:(RCRTCRemoteUser *)user {
    [self unsubscribeRemoteResource:user.remoteStreams orStreamId:nil];
}

// 远端掉线
- (void)didOfflineUser:(RCRTCRemoteUser *)user {
    [self unsubscribeRemoteResource:user.remoteStreams orStreamId:nil];
}

// 流连接成功
- (void)didConnectToStream:(RCRTCInputStream *)stream {
}

- (void)didReportStatusForm:(RCRTCStatusForm *)form {
}
//收到 pk 邀请
- (void)didRequestJoinOtherRoom:(NSString *)inviterRoomId
                  inviterUserId:(NSString *)inviterUserId
                          extra:(NSString *)extra{
    NSString *message = [NSString stringWithFormat:@"收到来自 %@ 的 pk 邀请",inviterUserId];
    [UIAlertController alertWithString:message okAction:^{
        [self.room.localUser responseJoinOtherRoom:inviterRoomId userId:inviterUserId agree:YES autoMix:YES extra:@"" completion:^(BOOL isSuccess, RCRTCCode code) {
            if (isSuccess) {
                [self joinOtherRoom:inviterRoomId];
            }
        }];
    } cancelAction:^{
        [self.room.localUser responseJoinOtherRoom:inviterRoomId userId:inviterUserId agree:NO autoMix:YES extra:@"" completion:^(BOOL isSuccess, RCRTCCode code) {
            
        }];
    } onVC:self];
    
}
//收到 pk 取消
- (void)didCancelRequestOtherRoom:(NSString *)inviterRoomId
                    inviterUserId:(NSString *)inviterUserId
                            extra:(NSString *)extra{
    [UIAlertController alertWithString:@"pk 邀请取消" inCurrentViewController:self];
}

- (void)didResponseJoinOtherRoom:(NSString *)inviterRoomId
                   inviterUserId:(NSString *)inviterUserId
                   inviteeRoomId:(NSString *)inviteeRoomId
                   inviteeUserId:(NSString *)inviteeUserId
                           agree:(BOOL)agree
                           extra:(NSString *)extra{
    if (agree) {
        [self joinOtherRoom:inviteeRoomId];
    }
}

- (void)didFinishOtherRoom:(NSString *)roomId userId:(NSString *)userId{
    [self leaveOtherRoom:roomId];
}

#pragma mark - RCRTCOtherRoomEventDelegate
- (void)room:(RCRTCBaseRoom *)room didLeaveUser:(RCRTCRemoteUser *)user{
    [self unsubscribeRemoteResource:user.remoteStreams orStreamId:nil];
}

- (void)room:(RCRTCBaseRoom *)room didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    [self unsubscribeRemoteResource:streams orStreamId:nil];
}

#pragma mark - RCRTCFileVideoOutputStreamDelegate

- (void)fileVideoOutputStreamDidStartRead:(RCRTCFileVideoOutputStream *)stream {
    RCRTCLocalVideoView *localFileVideoView = (RCRTCLocalVideoView *) self.localFileStreamVideo.canvesView;
    [localFileVideoView flushVideoView];
}

- (void)fileVideoOutputStreamDidReadCompleted:(RCRTCFileVideoOutputStream *)stream {
    RCRTCLocalVideoView *localFileVideoView = (RCRTCLocalVideoView *) self.localFileStreamVideo.canvesView;
    [localFileVideoView flushVideoView];
}

- (void)fileVideoOutputStreamDidFailed:(RCRTCFileVideoOutputStream *)stream {
    NSLog(@"自定义视频解码失败，tag:%@", stream.streamId);
}

#pragma mark - BeautyMenusViewDelegate
- (void)beautyMenusView:(BeautyMenusView *)beautyMenusView
             didChanged:(BeautyMenusType)type
                  value:(NSInteger)value {
    if (type == BeautyMenusType_Filter) {
        RCRTCBeautyFilter beautyFilter = value;
        [[RCRTCBeautyEngine sharedInstance] setBeautyFilter:beautyFilter];
    } else {
        RCRTCBeautyOption *option = [[RCRTCBeautyEngine sharedInstance] getCurrentBeautyOption];
        switch (type) {
            case BeautyMenusType_Whiteness:
                option.whitenessLevel = value;
                break;
            case BeautyMenusType_Smooth:
                option.smoothLevel = value;
                break;
            case BeautyMenusType_Ruddy:
                option.ruddyLevel = value;
                break;
            case BeautyMenusType_Bright:
                option.brightLevel = value;
                break;
            default:
                break;
        }
        [[RCRTCBeautyEngine sharedInstance] setBeautyOption:YES option:option];
    }
}

- (void)beautyMenusView:(BeautyMenusView *)beautyMenusView
       didChangedParams:(NSArray<BeautyMenusViewParam *> *)params {
    if (params) {
        __block RCRTCBeautyFilter beautyFilter = RCRTCBeautyFilterNone;
        RCRTCBeautyOption *option = [[RCRTCBeautyEngine sharedInstance] getCurrentBeautyOption];
        [params enumerateObjectsUsingBlock:^(BeautyMenusViewParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            switch (obj.type) {
                case BeautyMenusType_Filter:
                    beautyFilter = obj.value;
                    break;
                case BeautyMenusType_Whiteness:
                    option.whitenessLevel = obj.value;
                    break;
                case BeautyMenusType_Ruddy:
                    option.ruddyLevel = obj.value;
                    break;
                case BeautyMenusType_Smooth:
                    option.smoothLevel = obj.value;
                    break;
                case BeautyMenusType_Bright:
                    option.brightLevel = obj.value;
                    break;
                default:
                    break;
            }
        }];
        [[RCRTCBeautyEngine sharedInstance] setBeautyOption:YES option:option];
        [[RCRTCBeautyEngine sharedInstance] setBeautyFilter:beautyFilter];
    } else {
        [[RCRTCBeautyEngine sharedInstance] reset];
    }
}

#pragma mark - private method

// 滤镜种类判断
- (void)changeFliterIsOpenBearty:(BOOL)isOpenBearty isOpenWarkMark:(BOOL)isOpenWarkMark {
    if (isOpenBearty && isOpenWarkMark) {
        [self.gpuImageHandler beautyAndWaterMark];
    } else if (isOpenBearty) {
        [self.gpuImageHandler onlyBeauty];
    } else {
        [self.gpuImageHandler onlyWaterMark];
    }
}

- (void)showPKView:(UIButton *)btn{
    if (self.pkView.isShowing) {
        [self.pkView dismiss];
    }
    else {
        [self.pkView showOnSuperView:self.view];
    }
}

- (void)joinOtherRoom:(NSString *)roomId {
    __weak typeof(self) weakSelf = self;
    [self.engine joinOtherRoom:roomId completion:^(RCRTCOtherRoom * _Nullable room, RCRTCCode code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code == RCRTCCodeSuccess) {
            room.delegate = self;
            strongSelf.pkRoom = room;
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in room.remoteUsers) {
                if (user.remoteStreams.count) {
                    [streamArray addObjectsFromArray:user.remoteStreams];
                }
            }
            if (streamArray.count) {
                [strongSelf subscribeRemoteResource:streamArray];
            }
        }
    }];
}

- (void)leaveOtherRoom:(NSString *)roomId {
    
    NSMutableArray *streamArray = [NSMutableArray array];
    for (RCRTCRemoteUser *user in self.pkRoom.remoteUsers) {
        if (user.remoteStreams.count) {
            [streamArray addObjectsFromArray:user.remoteStreams];
        }
    }
    if (streamArray.count) {
        [self unsubscribeRemoteResource:streamArray orStreamId:nil];
    }
    
    [self.engine leaveOtherRoom:roomId notifyFinished:YES completion:^(BOOL isSuccess, RCRTCCode code) {
        if (!isSuccess) {
            [UIAlertController alertWithString:@"离开副房间失败" inCurrentViewController:nil];
        }
    }];
}

#pragma mark - PKViewBtnEventDelegate
- (void)pk_inviteWithRoomId:(NSString *)roomId userId:(NSString *)userId autoMix:(BOOL)autoMix{
    [self.room.localUser requestJoinOtherRoom:roomId userId:userId autoMix:autoMix extra:@"" completion:^(BOOL isSuccess, RCRTCCode code) {}];
}

- (void)pk_cancelWithRoomId:(NSString *)roomId userId:(NSString *)userId{
    [self.room.localUser cancelRequestJoinOtherRoom:roomId userId:userId extra:@"" completion:^(BOOL isSuccess, RCRTCCode code) {}];
}

- (void)pk_joinOtherRoom:(NSString *)roomId{
    [self joinOtherRoom:roomId];
}

- (void)pk_leaveOtherRoom:(NSString *)roomId{
    [self leaveOtherRoom:roomId];
}

- (UIButton *)pkBtn{
    if (!_pkBtn) {
        _pkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        [_pkBtn setTitle:@"PK" forState:UIControlStateNormal];
        [_pkBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [_pkBtn addTarget:self action:@selector(showPKView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pkBtn;
}

- (RCRTCPKView *)pkView{
    if (!_pkView) {
        _pkView = [[RCRTCPKView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
        _pkView.delegate = self;
    }
    return _pkView;
}


@end
