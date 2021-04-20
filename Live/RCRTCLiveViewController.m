//
//  RCRTCLiveViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//


#import "RCRTCLiveViewController.h"
#import <RongChatRoom/RongChatRoom.h>
#import "RCRTCStreamVideo.h"
#import "RCRTCVideoLayoutTool.h"
#import "UIAlertController+RCRTC.h"
#import "RCRTCMixStreamTool.h"

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

/**
 *  主播直播显 /观众观看直播
 *  - setRoleType   自定义的私有方法，区分主播/观众进入不同 UI 显示
 *
 *  - 加入房间：
 *  - 主播
 *  - 1.设置不切换听筒为扬声器
 *  - 2.添加本地采集预览界面
 *  - 3.加入RTC房间
 *
 *  - 观众
 *  - 1.设置切换听筒为扬声器
 *  - 2.加入RTC房间
 *
 *  -  观众上麦：
 *  - 1.先清理视图
 *  - 2.退出房间
 *  - 3.添加本地采集预览界面
 *  - 4.加入 RTC 房间
 *
 *  -  观众下麦：
 *  - 1.先清理视图
 *  - 2.退出房间
 *  - 3.加入 RTC 房间
 *
 *  - 退出房间：主播/观众
 *  - 1.先清理视图
 *  - 2.退出房间
 */

@interface RCRTCLiveViewController ()<
RCRTCRoomEventDelegate,
RCRTCStatusReportDelegate>

/**
 *功能按钮
 */
@property (weak, nonatomic) IBOutlet UIView *remoteContainerView;
@property (weak, nonatomic) IBOutlet UIButton *closeCamera;
@property (weak, nonatomic) IBOutlet UIButton *closeMicBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchStreamMode;
@property (weak, nonatomic) IBOutlet UIButton *streamLayoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeLiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectHostBtn;

//音频配置
@property (strong, nonatomic) RCRTCEngine *engine;

//功能按钮容器
@property (nonatomic, copy)NSArray *funcBtns;

@property (nonatomic, strong)RCRTCRoom *room;
@property (nonatomic, strong)RCRTCLiveInfo *liveInfo;
@property (nonatomic, strong)RCRTCStreamVideo *localVideo;
@property (nonatomic)NSMutableArray <RCRTCStreamVideo *>*streamVideos;
@property (nonatomic, strong)RCRTCVideoLayoutTool *layoutTool;

@end

@implementation RCRTCLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化 UI
    [self initView];
    
    //直播类型下的角色区分：主播/观众
    [self setRoleType];
    
}



#pragma mark - startLive & watchLive

/**
 * 直播类型下的角色区分
 *1.主播开启直播
 *2.观众观看直播
 */
-(void)setRoleType{
    
    //判断用户状态改变退出按钮显示
    _closeLiveBtn.selected = _liveRoleType;
    
    switch (_liveRoleType) {
        case RCRTCLiveRoleTypeBroadcaster:
            self.title = @"直播 Demo-主播端";
            [self disableClickWith:@[self.connectHostBtn]];
            
            /*!
             当前直播角色为主播
             */
            
            //1.设置不切换听筒为扬声器
            [self.engine enableSpeaker:NO];
            
            //2.添加本地采集预览界面
            [self setupLocalVideoView];
            
            //3.加入RTC房间
            [self joinLiveRoomWithRole:RCRTCLiveRoleTypeBroadcaster];
            
            break;
        case RCRTCLiveRoleTypeAudience:
            self.title = @"直播 Demo-观众端";
            [self disableClickWith:@[self.closeCamera,
                                     self.closeMicBtn,
                                     self.streamLayoutBtn,
                                     self.switchStreamMode]];
            
            /*!
             当前直播角色为观众
             */
            
            //1.设置切换听筒为扬声器
            [self.engine enableSpeaker:YES];
            
            //2.加入RTC房间
            [self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
            break;;
        default:
            break;
    }
}


/**
 * 观众上下麦
 */
- (void)connectHostWithState:(BOOL)isConnect{
    self.liveRoleType = (isConnect ? RCRTCLiveRoleTypeBroadcaster : RCRTCLiveRoleTypeAudience);
    
    //1.先清理视图
    [self cleanRemoteContainer];
    
    //2.退出房间
    [self exitRoom];
    
    if (isConnect) {
        
        /**
         * 观众上麦
         * 1.添加本地采集预览界面
         * 2.加入 RTC 房间
         */
        
        [self setupLocalVideoView];
        
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeBroadcaster];
        
    }else{
        
        //下麦：加入 RTC 房间
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
    }
}


#pragma mark - setter & getter

- (RCRTCEngine *)engine{
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
    }
    return _engine;
}
- (RCRTCVideoLayoutTool *)layoutTool{
    if (!_layoutTool) {
        _layoutTool = [RCRTCVideoLayoutTool new];
    }
    return _layoutTool;
}
- (NSMutableArray<RCRTCStreamVideo *> *)streamVideos{
    if (!_streamVideos) {
        _streamVideos = [NSMutableArray array];
    }
    return _streamVideos;
}
- (RCRTCStreamVideo *)localVideo{
    if (!_localVideo) {
        _localVideo = [RCRTCStreamVideo LocalStreamVideo];
    }
    return _localVideo;
}
-(NSArray *)funcBtns{
    if (!_funcBtns) {
        _funcBtns =  @[
            self.closeLiveBtn,
            self.connectHostBtn,
            self.closeCamera,
            self.closeMicBtn,
            self.streamLayoutBtn,
            self.switchStreamMode];
    }
    return _funcBtns;
}


#pragma mark - UI

- (void)initView{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

/**
 * 功能按钮状态切换
 */
- (void)disableClickWith:(NSArray *)btns{
    for (UIButton *btn in self.funcBtns) {
        [btn setBackgroundColor:[UIColor colorWithRed:29.0/255.0 green:183.0/255.0 blue:1.0 alpha:1]];
        btn.enabled = YES;
    }
    for (UIButton *btn in btns) {
        [btn setBackgroundColor:[UIColor grayColor]];
        btn.enabled = NO;
    }
}

/**
 *添加本地采集预览界面
 */
- (void)setupLocalVideoView{
    [self.streamVideos addObject:self.localVideo];
    [self updateLayoutWithAnimation:YES];
}



/**
 * 清空视图
 */
- (void)cleanRemoteContainer{
    [self.streamVideos removeAllObjects];
    for (UIView *subview in self.remoteContainerView.subviews) {
        [subview removeFromSuperview];
    }
}


#pragma mark - Event


/**
 * 离开房间
 */
- (IBAction)closeLiveAction:(UIButton *)sender{
    
    
    //1.清理视图
    [self cleanRemoteContainer];
    
    //2.退出房间
    [self exitRoom];
    
    
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 * 上麦/下麦状态判断
 */
- (IBAction)connectHostAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self disableClickWith:nil];
    }else{
        [self disableClickWith:@[self.closeCamera,
                                 self.closeMicBtn,
                                 self.streamLayoutBtn,
                                 self.switchStreamMode]];
    }
    
    //上麦/下麦
    [self connectHostWithState:sender.selected];
    
}

/**
 * 开关摄像头
 */
- (IBAction)closeCameraAction:(UIButton *)sender{
    
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    
    sender.selected = !sender.selected;
    
    //开关摄像头
    RCRTCCameraOutputStream *DVStream = self.engine.defaultVideoStream;
    !sender.selected ? [DVStream startCapture] : [DVStream stopCapture];
    
}


/**
 * 开/关麦克风
 */
- (IBAction)closeMicAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    
    /**
     *关闭/打开麦克风
     *@param disable YES 关闭，NO 打开
     */
    [self.engine.defaultAudioStream setMicrophoneDisable:sender.selected];
}


/**
 * 自定义布局状态判断
 */
- (IBAction)streamLayutAction:(UIButton *)sender{
    
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    
    
    sender.tag >= 3 ? sender.tag = 1 : (sender.tag += 1);
    
    //自定义布局刷新
    [self streamlayoutMode:(RCRTCMixLayoutMode)sender.tag];
    
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



/**
 * 切换摄像头状态判断
 */
- (IBAction)switchStreamAction:(UIButton *)sender{
    
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    
    sender.selected = !sender.selected;
    
    //切换摄像头
    [self.engine.defaultVideoStream switchCamera];
}


/**
 * 布局视图动画
 */
- (void)updateLayoutWithAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
        }];
    }else{
        [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
    }
}



#pragma mark - RTC

/**
 主播设置合流布局,观众端看效果
 
 自定义布局 RCRTCMixLayoutModeCustom = 1
 悬浮布局 RCRTCMixLayoutModeSuspension = 2
 自适应布局 RCRTCMixLayoutModeAdaptive = 3
 **默认新创建的房间是悬浮布局**
 */

/**
 * 加入 RTC 房间
 */
-(void)joinLiveRoomWithRole:(RCRTCLiveRoleType)roleType{
    //1.配置房间
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudioVideo;
    config.roleType = roleType;
    [self.engine setStatusReportDelegate:self];
    @WeakObj(self);
    [self.engine joinRoom:_roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        @StrongObj(self);
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"加入房间失败 code:%ld",(long)code] inCurrentViewController:self];
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



/**
 * 退出房间
 */
- (void)exitRoom{
    @WeakObj(self);
    [self.engine  leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"退出房间失败 code:%ld",(long)code] inCurrentViewController:self];
        }
    }];
}



/**
 * 发布本地音视频流
 */
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
            [UIAlertController alertWithString:@"本地流发布失败" inCurrentViewController:nil];
        }
    }];
}


/**
 * 自定义合流布局
 */
- (void)streamlayoutMode:(RCRTCMixLayoutMode)mode{
    @WeakObj(self);
    RCRTCMixConfig *config = [RCRTCMixStreamTool setOutputConfig:mode];
    [self.liveInfo setMixConfig:config completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (code == RCRTCCodeSuccess && isSuccess) return;
        [UIAlertController alertWithString:[NSString stringWithFormat:@"合流布局切换失败 code:%ld",(long)code] inCurrentViewController:self];
    }];
}

/**
 * 取消订阅远端流
 */
-(void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orUid:(NSString *)uid {
    if (!uid) {
        for (RCRTCInputStream *stream in streams) {
            if (stream.mediaType == RTCMediaTypeVideo) {
                uid = stream.userId;
            }
        }
    }
    RCRTCStreamVideo *sVideo = [self fetchStreamVideoWithId:uid];
    if (sVideo) {
        [sVideo.canvesView removeFromSuperview];
        [self.streamVideos removeObject:sVideo];
        [self updateLayoutWithAnimation:YES];
    }
}


/**
 * 订阅远端流
 */
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
            [UIAlertController alertWithString:errorStr inCurrentViewController:nil];
            return;
        }
        
        
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

/**
 * 创建并设置远端视频预览视图
 */
-(RCRTCStreamVideo *)setupRemoteViewWithUid:(NSString *)uid combineStream:(RCRTCInputStream *)stream{
    
    RCRTCStreamVideo *sVideo = [self creatStreamVideoWithId:uid];
    RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)sVideo.canvesView;
    
    //设置视频流的渲染视图
    [(RCRTCVideoInputStream *)stream setVideoView:remoteView];
    return sVideo;
}


/*
 *判断是否已有预览视图
 */
- (RCRTCStreamVideo *)creatStreamVideoWithId:(NSString *)uid{
    RCRTCStreamVideo *sVideo = [self fetchStreamVideoWithId:uid];
    if (!sVideo) {
        sVideo = [[RCRTCStreamVideo alloc] initWithUid:uid];
        [self.streamVideos insertObject:sVideo atIndex:0];
    }
    return sVideo;
}

- (RCRTCStreamVideo *)fetchStreamVideoWithId:(NSString *)uid{
    for (RCRTCStreamVideo *sVideo in self.streamVideos) {
        if ([uid isEqualToString:sVideo.userId]) {
            return sVideo;
        }
    }
    return nil;
}



#pragma mark - RCRTCRoomEventDelegate


/**
 * 直播合流发布
 */
- (void)didPublishLiveStreams:(NSArray<RCRTCInputStream*> *)streams{
    
    [self subscribeRemoteResource:streams orUid:nil];
}

/**
 * 直播合流取消发布
 */
- (void)didUnpublishLiveStreams:(NSArray<RCRTCInputStream*> *)streams{
    
    [self unsubscribeRemoteResource:streams orUid:nil];
}


/**
 * 新用户加入
 */
- (void)didJoinUser:(RCRTCRemoteUser *)user{
    
}


/**
 * 离开
 */
- (void)didLeaveUser:(RCRTCRemoteUser *)user{
    [self unsubscribeRemoteResource:nil orUid:user.userId];
}


/**
 * 远端掉线
 */
- (void)didOfflineUser:(RCRTCRemoteUser*)user{
    [self unsubscribeRemoteResource:nil orUid:user.userId];
}

/**
 * 流连接成功
 */
- (void)didConnectToStream:(RCRTCInputStream *)stream{
    
}

- (void)didReportStatusForm:(RCRTCStatusForm *)form{
    
}


@end
