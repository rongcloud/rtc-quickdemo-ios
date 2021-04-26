//
//  MeetingViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//


#import "MeetingViewController.h"
#import <RongRTCLib/RongRTCLib.h>
#import "UIAlertController+RCRTC.h"
#import "MeetingCryptoImpl.h"


#define kScreenWidth self.view.frame.size.width
#define kScreenHeight self.view.frame.size.height

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

/**
 * 会议类
 *
 * 基本功能包括：
 * - 确认是否开启自定义加解密 (https://docs.rongcloud.cn/v4/views/rtc/meeting/guide/advanced/crypto/ios.html)
 * - 加入会议房间
 * - 发布本地资源
 * - 订阅远端资源
 * - 取消本地发布并关闭摄像头
 * - 退出房间
 */
@interface MeetingViewController () <RCRTCRoomEventDelegate>

@property (weak, nonatomic) IBOutlet RCRTCLocalVideoView *containerView;

@property(nonatomic, strong) RCRTCLocalVideoView *localView;
@property(nonatomic, strong) RCRTCRemoteVideoView *remoteView;

@property(nonatomic, strong) RCRTCRoom *room;
@property(nonatomic, strong) RCRTCEngine *engine;

@property(nonatomic, assign) BOOL isFullScreen;

@property(nonatomic, strong) MeetingCryptoImpl *cryptoImpl;

@end

@implementation MeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /**
     * 必要步骤：
     *
     * 1.参考 RCRTCLoginViewController.m 中的 connectRongCloud 方法进行初始化
     */
    
    // 初始化 UI
    [self initView];
    
    
    // 配置进入会议前的一些准备参数
    [self initConfig];
    /**
     * 2. 加入房间
     */
    [self joinRoom];
    
}

- (void)initConfig{
    
    if (!self.enableCryptho) return;
    
    /**
     * 设置自定义加密代理
     *
     * 如果参数为 nil 则关闭自定义加解密，如果参数非 nil 则打开自定义加解密
     */
    [self.engine setAudioCustomizedDecryptorDelegate:self.cryptoImpl];
    [self.engine setAudioCustomizedEncryptorDelegate:self.cryptoImpl];
    [self.engine setVideoCustomizedDecryptorDelegate:self.cryptoImpl];
    [self.engine setVideoCustomizedEncryptorDelegate:self.cryptoImpl];
}

#pragma mark - UI

- (void)initView{
    
    self.navigationController.navigationBarHidden = YES;

    [self setupLocalVideoView];
    [self setupRemoteVideoView];
}

/**
 * 添加本地采集预览界面
 */
- (void)setupLocalVideoView {
    self.localView = [[RCRTCLocalVideoView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight/2)];
    self.localView.fillMode = RCRTCVideoFillModeAspectFill;
    [self.containerView addSubview:self.localView];

    // 添加点击手势,可切换大小视图
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithView:)];
    [self.localView addGestureRecognizer:tap];
}

/**
 * 添加远端视频小窗口
 */
- (void)setupRemoteVideoView {
    self.remoteView = [[RCRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0, kScreenHeight/2, kScreenWidth, kScreenHeight/2)];
    self.remoteView.fillMode = RCRTCVideoFillModeAspectFill;
    [self.containerView addSubview:self.remoteView];
    
    // 添加点击手势,可切换大小视图
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithView:)];
    [self.remoteView addGestureRecognizer:tap];
}

#pragma mark - RTC

/**
 * 加入房间
 */
- (void)joinRoom {
    RCRTCVideoStreamConfig *videoConfig = [[RCRTCVideoStreamConfig alloc] init];
    videoConfig.videoSizePreset = RCRTCVideoSizePreset1280x720;
    videoConfig.videoFps = RCRTCVideoFPS30;
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:videoConfig];

    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeNormal;
    
    [self.engine enableSpeaker:NO];

    @WeakObj(self);
    [self.engine joinRoom:self.roomId
                   config:config
               completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
                   @StrongObj(self);
                   if (code == RCRTCCodeSuccess) {
                       
                       /**
                        * 3. 加入成功后进行资源的发布和订阅
                        */
                       [self afterJoinRoom:room];
                   } else {
                       [UIAlertController alertWithString:@"加入房间失败" inCurrentViewController:self];
                   }
               }];
}

/**
 * 加入成功后进行资源发布和订阅
 */
- (void)afterJoinRoom:(RCRTCRoom *)room {
    // 设置房间代理
    self.room = room;
    room.delegate = self;

    // 开始本地视频采集
    [[self.engine defaultVideoStream] setVideoView:self.localView];
    [[self.engine defaultVideoStream] startCapture];

    // 发布本地视频流
    [room.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess && desc == RCRTCCodeSuccess) {
            NSLog(@"本地流发布成功");
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

/**
 * 订阅房间中远端用户音视频流资源
 */
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
     
    [self.room.localUser subscribeStream:streams tinyStreams:nil completion:^(BOOL isSuccess, RCRTCCode desc) {
        
    }];
    // 创建并设置远端视频预览视图
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            [(RCRTCVideoInputStream *) stream setVideoView:self.remoteView];
            [self.remoteView setHidden:NO];
        }
    }
}

#pragma mark - Event
/**
 * 点击视图进行大小窗口切换
 */
- (void)tapWithView:(UIGestureRecognizer *)ges {
    self.isFullScreen = !self.isFullScreen;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect frame = self.containerView.bounds;
    
    if ([ges.view isKindOfClass:[RCRTCRemoteVideoView class]]) {
        if (self.isFullScreen) {
            self.remoteView.frame = frame;
        }else{
            self.remoteView.frame = CGRectMake(0, kScreenHeight/2, kScreenWidth, kScreenHeight/2);
        }
    } else if ([ges.view isKindOfClass:[RCRTCLocalVideoView class]]){
        if (self.isFullScreen) {
            self.localView.frame = frame;
        }else{
            self.localView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight/2);
        }
    }
    [CATransaction commit];
    
    if (ges.view.frame.size.height >= kScreenHeight) {
        [self.containerView bringSubviewToFront:ges.view];
    } else {
        [self.containerView bringSubviewToFront:ges.view];
    }
}

/**
 * 麦克风静音
 */
- (IBAction)micMute:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.engine.defaultAudioStream setMicrophoneDisable:sender.selected];
}

/**
 * 切换摄像头
 */
- (IBAction)changeCamera:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.engine.defaultVideoStream switchCamera];
}

/**
 * 挂断并离开
 */
- (IBAction)clickHangup:(id)sender {
    
    /**
     * 4. 取消本地发布并关闭摄像头采集
     */
    [self.room.localUser unpublishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
    }];
    [self.engine.defaultVideoStream stopCapture];
    [self.remoteView removeFromSuperview];
    
    /**
     * 5. 退出房间
     */
    [self.engine leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess && code == RCRTCCodeSuccess) {
            NSLog(@"退出房间成功 code: %ld", (long) code);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}



#pragma mark - RCRTCRoomEventDelegate

/**
 * 远端用户发布资源通知
 */
- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self subscribeRemoteResource:streams];
}

/**
 * 远端用户取消发布资源通知
 */
- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self.remoteView setHidden:YES];
}

/**
 * 远端用户离开通知
 */
- (void)didLeaveUser:(RCRTCRemoteUser *)user {
    [self.remoteView setHidden:YES];
}

#pragma mark - lazy load

- (RCRTCEngine *)engine {
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
        [_engine enableSpeaker:YES];
    }
    return _engine;
}

- (MeetingCryptoImpl *)cryptoImpl{
    if (!_cryptoImpl) {
        _cryptoImpl = [[MeetingCryptoImpl alloc] init];
    }
    return _cryptoImpl;
}


@end
