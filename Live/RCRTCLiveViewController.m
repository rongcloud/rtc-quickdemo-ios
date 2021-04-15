//
//  RCRTCLiveViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/14.
//

#import "RCRTCLiveViewController.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import <RongChatRoom/RongChatRoom.h>
#import "RCRTCStreamVideo.h"
#import "RCRTCVideoLayoutTool.h"
#import "UIAlertController+RCRTC.h"
#import "UIViewController+AlertView.h"
#import "RCRTCMixStreamTool.h"

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

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

//功能按钮区分
@property (nonatomic, copy)NSArray *userBtns;
@property (nonatomic, copy)NSArray *funcBtns;

@property (nonatomic, strong)RCRTCRoom *room;
@property (nonatomic, strong)RCRTCStreamVideo *localVideo;
@property (nonatomic, strong)RCRTCLiveInfo *liveInfo;

@property (nonatomic)NSMutableArray <RCRTCStreamVideo *>*streamVideos;
@property (nonatomic, strong)RCRTCVideoLayoutTool *layoutTool;
@end

@implementation RCRTCLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setRoleType];
    self.funcBtns = @[
        self.closeLiveBtn,
        self.connectHostBtn,
        self.closeCamera,
        self.closeMicBtn,
        self.streamLayoutBtn,
        self.switchStreamMode];
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

//用户状态功能区分
-(void)setRoleType{
    switch (_liveRoleType) {
        case RCRTCLiveRoleTypeBroadcaster:
            self.title = @"直播 Demo-主播端";
            [self disableClickWith:@[self.connectHostBtn]];
            [self.engine enableSpeaker:NO];
            //开直播
            [self startLiveWithState];
            break;
        case RCRTCLiveRoleTypeAudience:
            self.title = @"直播 Demo-观众端";
            [self disableClickWith:@[self.closeLiveBtn,
                                     self.closeCamera,
                                     self.closeMicBtn,
                                     self.streamLayoutBtn,
                                     self.switchStreamMode]];
            [self.engine enableSpeaker:YES];
            [self watchLiveWithState];
            break;;
        default:
            break;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

//    [self cleanRemoteContainer];
//    [self exitRoom];//退出房间
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}



#pragma mark - button func

- (IBAction)closeLiveAction:(UIButton *)sender{
     
    sender.selected = !sender.selected;

    self.liveRoleType = (sender.selected ?RCRTCLiveRoleTypeAudience : RCRTCLiveRoleTypeBroadcaster);
        [self startLiveWithState];

}

- (IBAction)watchLiveAction:(UIButton *)sender{
//    if (!self.isLogin) return;
//    NSLog(@"%@",sender.titleLabel.text);
//    sender.selected = !sender.selected;
//    if ([self.delegate respondsToSelector:@selector(watchLiveWithState:)]) {
//        self.roleType = (sender.selected ? RCRTCRoleTypeAudience : RCRTCRoleTypeUnknown);
//        [self.delegate watchLiveWithState:sender.selected];
//    }
}

//上麦 下麦
- (IBAction)connectHostAction:(UIButton *)sender {
       
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self disableClickWith:@[self.closeLiveBtn]];
    }else{
        [self disableClickWith:@[self.closeLiveBtn,
                                 self.closeCamera,
                                 self.closeMicBtn,
                                 self.streamLayoutBtn,
                                 self.switchStreamMode]];
    }
    
    [self connectHostWithState:sender.selected];
   
}

//关闭摄像头
- (IBAction)closeCameraAction:(UIButton *)sender{
    
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    
    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    [self cameraEnable:!sender.selected];
    
}

//关闭麦克风
- (IBAction)closeMicAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;
    [self micDisable:sender.selected];

}
//自定义布局
- (IBAction)streamLayutAction:(UIButton *)sender{
    
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;

    NSLog(@"%@",sender.titleLabel.text);
   
        sender.tag >= 3 ? sender.tag = 1 : (sender.tag += 1);
        [self streamLayout:(RCRTCMixLayoutMode)sender.tag];
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

//切换摄像头

- (IBAction)switchStreamAction:(UIButton *)sender{
    
    if (self.liveRoleType == RCRTCLiveRoleTypeAudience) return;

    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    [self switchCamera];
    
    [self subscribeType:sender.isSelected];
}


#pragma mark - private method

//- (void)setRoleType:(RCRTCRoleType)roleType{
//    _roleType = roleType;
//    switch (_roleType) {
//        case RCRTCRoleTypeUnknown:
//            [self disableClickWith:@[self.connectHostBtn]];
//            break;
//        case RCRTCRoleTypeHost:
//
//            break;
//        case RCRTCRoleTypeAudience:
//
//            break;;
//        default:
//            break;
//    }
//}

//功能按钮状态切换
- (void)disableClickWith:(NSArray *)btns{
    for (UIButton *btn in self.funcBtns) {
        [btn setBackgroundColor:[UIColor systemBlueColor]];
        btn.enabled = YES;
    }
    for (UIButton *btn in btns) {
        [btn setBackgroundColor:[UIColor grayColor]];
        btn.enabled = NO;
    }
}

//- (void)updateLoginState:(NSInteger)tag{
//    self.userBtns = @[
//        self.userBtn_A,
//        self.userBtn_B,
//        self.userBtn_C,
//        self.userBtn_D];
//    self.funcBtns = @[
//        self.startLiveBtn,
//        self.wacthLiveBtn,
//        self.connectHostBtn,
//        self.closeCamera,
//        self.closeMicBtn,
//        self.streamLayoutBtn,
//        self.switchStreamMode];
//    for (UIButton *btn in self.userBtns) {
//        if (btn.tag != tag) {
//            btn.backgroundColor = [UIColor grayColor];
//            btn.enabled = NO;
//        }
//    }
//}
//
//- (void)resetLoginBtnState{
//    for (UIButton *btn in self.userBtns) {
//        btn.backgroundColor = [UIColor systemBlueColor];
//        btn.enabled = YES;
//    }
//}
//
//- (void)layoutSubviews{
//    [super layoutSubviews];
//
//}



#pragma mark - 详细实现

//开始直播/结束直播
- (void)startLiveWithState{
//    self.liveRoleType = (isSelected ? RCRTCLiveRoleTypeBroadcaster : RCRTCLiveRoleTypeAudience);
    if (!self.liveRoleType) {
        //加入房间
        [self setupLocalVideoView];
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeBroadcaster];
    }else{
        [self cleanRemoteContainer];
        [self exitRoom];//退出房间
    }
}

//观看直播/结束观看
- (void)watchLiveWithState{
//    self.roleType = (isSelected ? RCRTCRoleTypeAudience : RCRTCRoleTypeUnknown);
//    if (isSelected) {
        [self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
//    }else{
//        [self cleanRemoteContainer];
//        [self exitRoom];
//    }
}
//观众上下麦
- (void)connectHostWithState:(BOOL)isConnect{
    self.liveRoleType = (isConnect ? RCRTCLiveRoleTypeBroadcaster : RCRTCLiveRoleTypeAudience);
    
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

-(RCRTCStreamVideo *)setupRemoteViewWithUid:(NSString *)uid combineStream:(RCRTCInputStream *)stream{
    RCRTCStreamVideo *sVideo = [self creatStreamVideoWithId:uid];
    RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)sVideo.canvesView;
    [(RCRTCVideoInputStream *)stream setVideoView:remoteView];
    return sVideo;
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
