//
//  ScreenShareViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "ScreenShareViewController.h"
#import <ReplayKit/ReplayKit.h>
#import "UIAlertController+RCRTC.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RPSystemBroadcastPickerView+SearchButton.h"
#import "ScreenShareStreamVideo.h"
#import "ScreenShareVideoLayoutTool.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

static NSString * const ScreenShareBuildID = @"cn.rongcloud.rtcquickdemo.screenshare";
static NSString * const ScreenShareGroupID = @"group.cn.rongcloud.rtcquickdemo.screenshare";

API_AVAILABLE(ios(12.0))
@interface ScreenShareViewController ()<RCRTCRoomEventDelegate>

@property (nonatomic, strong) RPSystemBroadcastPickerView *systemBroadcastPickerView;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, strong) ScreenShareStreamVideo *localView;
@property (nonatomic, strong) RCRTCRemoteVideoView *remoteView;
@property (nonatomic, strong) ScreenShareStreamVideo *localShareView;
@property (nonatomic, strong) RCRTCRemoteVideoView *remoteShareView;
@property (nonatomic, strong) RCRTCVideoOutputStream *shareVideoOutputStream;
@property (nonatomic, strong) RCRTCRoom *room;
@property (nonatomic, strong) RCRTCEngine *engine;
@property (nonatomic, strong) UIButton  *screenShareButton;
@property (nonatomic) NSMutableArray <ScreenShareStreamVideo *> *streamVideos;
@property (nonatomic, strong) ScreenShareVideoLayoutTool *layoutTool;

@end

@implementation ScreenShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*!
     必要步骤：
     1.参考 RCRTCLoginViewController.m 中的 connectRongCloud 方法进行初始化
     */
    
    [self initView];
    // 2.加入房间
    [self joinRoom];
}

#pragma mark - UI
- (void)initView {
    [self initMode];
    [self setupLocalVideoView];
    [self initLeftBackButton];
}

// 添加本地采集预览界面
- (void)setupLocalVideoView {
    [self.streamVideos addObject:self.localView];
    [self updateLayoutWithAnimation:YES];
}

// 添加录制按钮
- (void)initMode {
    if (@available(iOS 12.0, *)) {
        self.systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 64, 50, 80)];
        self.systemBroadcastPickerView.preferredExtension = ScreenShareBuildID;
        self.systemBroadcastPickerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0];
        self.systemBroadcastPickerView.showsMicrophoneButton = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.systemBroadcastPickerView ];
    } else {
        // Fallback on earlier versions
    }
}

- (void)initLeftBackButton {
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setTitle:@"退出会议" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
}

// 布局视图动画
- (void)updateLayoutWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.layoutTool layoutVideos:self.streamVideos inContainer:self.containerView];
        }];
    }else{
        [self.layoutTool layoutVideos:self.streamVideos inContainer:self.containerView];
    }
}

#pragma mark - RTC
// 加入房间
- (void)joinRoom {
    RCRTCVideoStreamConfig *videoConfig = [[RCRTCVideoStreamConfig alloc] init];
    videoConfig.videoSizePreset = RCRTCVideoSizePreset720x480;
    videoConfig.videoFps = RCRTCVideoFPS30;
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:videoConfig];
    
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeNormal;
    
    [self.engine enableSpeaker:YES];

    __weak typeof(self) weakSelf = self;
    [self.engine joinRoom:self.roomId
                   config:config
               completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code == RCRTCCodeSuccess) {
            // 3. 加入成功后进行资源的发布和订阅
            [self afterJoinRoom:room];
        } else {
            [UIAlertController alertWithString:@"加入房间失败" inCurrentViewController:strongSelf];
        }
    }];
}

// 加入成功后进行资源发布和订阅
- (void)afterJoinRoom:(RCRTCRoom *)room {
    // 设置房间代理
    self.room = room;
    room.delegate = self;
    
    RCRTCLocalVideoView *view = (RCRTCLocalVideoView *)self.localView.canvesView;
    view.fillMode = RCRTCVideoFillModeAspectFit;

    // 开始本地视频采集
    [[self.engine defaultVideoStream] setVideoView:view];
    [[self.engine defaultVideoStream] startCapture];
    
    // 发布本地视频流
    [room.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess && desc == RCRTCCodeSuccess) {
            NSLog(@"本地流发布成功");
            [self setAppGroup];
        }
    }];
    
    // 如果已经有远端用户在房间中, 需要订阅远端流
    if ([room.remoteUsers count] > 0) {
        NSMutableArray *streamArray = [NSMutableArray array];
        for (RCRTCRemoteUser *user in room.remoteUsers) {
            [streamArray addObjectsFromArray:user.remoteStreams];
        }
        [self subscribeRemoteResource:streamArray];
    }
}

// 离开房间
- (void)exitRoom {
    // 判断当前用户是否在屏幕工共享
    for (RCRTCRemoteUser *user in self.room.remoteUsers) {
        NSString *screenUserId = [NSString stringWithFormat:@"%@RTC", self.room.localUser.userId];
        if ([screenUserId isEqualToString:user.userId]) {
            [UIAlertController alertWithString:@"当前用户仍在屏幕共享，请先关闭共享" inCurrentViewController:nil];
            return;
        }
    }
    
    // 取消本地发布并关闭摄像头采集
    [self.engine.defaultVideoStream stopCapture];
    
    // 退出房间
    [self.engine leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess && code == RCRTCCodeSuccess) {
            NSLog(@"退出房间成功 code: %ld", (long) code);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

// 取消订阅远端流
- (void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams
                       orStreamId:(NSString *)streamId {
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

- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams
                         isTiny:(BOOL)isTiny {
    for (RCRTCInputStream *tmpStream in streams) {
        NSString *screenUserId = [NSString stringWithFormat:@"%@RTC", self.room.localUser.userId];
        if ([screenUserId isEqualToString:tmpStream.userId]) {
            return;
        }
    }
    
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
- (ScreenShareStreamVideo *)setupRemoteViewWithStream:(RCRTCInputStream *)stream {
    ScreenShareStreamVideo *sVideo = [self creatStreamVideoWithStreamId:stream.streamId];
    RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)sVideo.canvesView;
    remoteView.fillMode = RCRTCVideoFillModeAspectFit;
    
    // 设置视频流的渲染视图
    [(RCRTCVideoInputStream *)stream setVideoView:remoteView];
    return sVideo;
}

// 判断是否已有预览视图
- (ScreenShareStreamVideo *)creatStreamVideoWithStreamId:(NSString *)streamId {
    ScreenShareStreamVideo *sVideo = [self fetchStreamVideoWithStreamId:streamId];
    if (!sVideo) {
        sVideo = [[ScreenShareStreamVideo alloc] initWithStreamId:streamId];
        [self.streamVideos insertObject:sVideo atIndex:0];
    }
    return sVideo;
}

// 根据 streamId 确认唯一的音视频流
- (ScreenShareStreamVideo *)fetchStreamVideoWithStreamId:(NSString *)streamId {
    for (ScreenShareStreamVideo *sVideo in self.streamVideos) {
        if ([streamId isEqualToString:sVideo.streamId]) {
            return sVideo;
        }
    }
    return nil;
}

// 远端掉线/离开回掉调用，删除远端用户的所有音视频流
- (void)fetchStreamVideoOffLineWithStreamId:(NSString *)streamId {
    NSArray *arr = [NSArray arrayWithArray:self.streamVideos];
    for (ScreenShareStreamVideo *sVideo in arr) {
        if ([streamId isEqualToString:sVideo.streamId]) {
            if (sVideo) {
                [sVideo.canvesView removeFromSuperview];
                [self.streamVideos removeObject:sVideo];
            }
        }
    }
    [self updateLayoutWithAnimation:YES];
}

#pragma mark - RCRTCRoomEventDelegate
// 远端用户发布资源通知
- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self subscribeRemoteResource:streams];
}

//  远端用户取消发布资源
- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams {
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
- (void)didOfflineUser:(RCRTCRemoteUser*)user {
    [self unsubscribeRemoteResource:user.remoteStreams orStreamId:nil];
}

// 屏幕共享 Groups 数据写入
- (void)setAppGroup {
    // 此处 id 要与开发者中心创建时一致
    NSUserDefaults *rongCloudDefaults = [[NSUserDefaults alloc] initWithSuiteName:ScreenShareGroupID];
    [rongCloudDefaults setObject:self.roomId forKey:@"roomId"];
    [rongCloudDefaults setObject:self.room.localUser.userId forKey:@"userId"];
}

#pragma mark - Event
// 麦克风静音
- (IBAction)micMute:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:sender.selected];
}

// 切换摄像头
- (IBAction)changeCamera:(UIButton *)sender {
    sender.selected = !sender.selected;
    [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
}

// 挂断并离开
- (IBAction)clickHangup:(id)sender {
    [self exitRoom];
}

// 返回按钮
- (void)backItemClick {
    [self exitRoom];
}
#pragma mark - setter && getter
- (ScreenShareStreamVideo *)localShareView {
    if (!_localShareView) {
        _localShareView = [ScreenShareStreamVideo LocalStreamVideo];
    }
    return _localShareView;
}

- (RCRTCEngine *)engine {
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
        [_engine enableSpeaker:YES];
    }
    return _engine;
}

- (NSMutableArray<ScreenShareStreamVideo *> *)streamVideos {
    if (!_streamVideos) {
        _streamVideos = [NSMutableArray array];
    }
    return _streamVideos;
}

- (ScreenShareStreamVideo *)localView {
    if (!_localView) {
        _localView = [ScreenShareStreamVideo LocalStreamVideo];
    }
    return _localView;
}

- (ScreenShareVideoLayoutTool *)layoutTool {
    if (!_layoutTool) {
        _layoutTool = [ScreenShareVideoLayoutTool new];
    }
    return _layoutTool;
}

@end
