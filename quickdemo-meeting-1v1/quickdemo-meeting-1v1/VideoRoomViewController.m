//
//  Copyright © 2020 RongCloud. All rights reserved.
//

//#import <Masonry.h>
#import <RongRTCLib/RongRTCLib.h>

#import "VideoRoomViewController.h"
#import "AppConfig.h"

#define kScreenWidth self.view.frame.size.width
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

// ROOM_ID 所要加入的房间 ID
#define ROOM_ID @"HelloRongCloud"

@interface VideoRoomViewController () <RCRTCRoomEventDelegate>

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property(nonatomic, strong) RCRTCLocalVideoView *localView;
@property(nonatomic, strong) RCRTCRemoteVideoView *remoteView;
@property(nonatomic, strong) RCRTCRoom *room;
@property(nonatomic, strong) RCRTCEngine *engine;

@end

@implementation VideoRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initIMSDK];
    [self setupLocalVideoView];
    [self setupRemoteVideoView];
}

- (void)initIMSDK {
    // 初始化融云 SDK
    [[RCIMClient sharedRCIMClient] initWithAppKey:APP_KEY];
    // 前置条件 IM 建立连接
    @WeakObj(self);
    [[RCIMClient sharedRCIMClient] connectWithToken:TOKEN dbOpened:^(RCDBErrorCode code) {}                       success:^(NSString *userId) {
        NSLog(@"IM 连接成功 userId: %@", userId);
        @StrongObj(self);
        [self joinRoom];
    }error:^(RCConnectErrorCode errorCode) {
        // 无网络情况下，SDK 会反复尝试，并不会走该回调提示用户
        @StrongObj(self);
        [self alertString:[NSString stringWithFormat:@"IM 连接失败 errorCode: %ld", (long) errorCode]];
    }];
}

// 添加本地采集预览界面
- (void)setupLocalVideoView {
    RCRTCLocalVideoView *localView = [[RCRTCLocalVideoView alloc] initWithFrame:self.view.bounds];
    localView.fillMode = RCRTCVideoFillModeAspectFill;
    [self.containerView addSubview:localView];
    self.localView = localView;
    
    //添加点击手势,可切换大小视图
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithView:)];
    [self.localView addGestureRecognizer:tap];
}

// 添加远端视频小窗口
- (void)setupRemoteVideoView {
    CGRect rect = CGRectMake(kScreenWidth - 120, 40, 100, 100 * 4 / 3);
    _remoteView = [[RCRTCRemoteVideoView alloc] initWithFrame:rect];
    _remoteView.fillMode = RCRTCVideoFillModeAspectFill;
    [_remoteView setHidden:YES];
    [self.containerView addSubview:_remoteView];
}


// 加入房间
- (void)joinRoom {
    @WeakObj(self);
    [self.engine joinRoom:ROOM_ID
               completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        @StrongObj(self);
        if (code == RCRTCCodeSuccess) {
            [self afterJoinRoom:room];
        } else {
            [self alertString:@"加入房间失败"];
        }
    }];
}

- (void)afterJoinRoom:(RCRTCRoom *)room {
    // 1. 设置房间代理
    self.room = room;
    room.delegate = self;

    // 2. 开始本地视频采集
    [[self.engine defaultVideoStream] setVideoView:self.localView];
    [[self.engine defaultVideoStream] startCapture];

    // 3. 发布本地视频流
    [room.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess && desc == RCRTCCodeSuccess) {
            NSLog(@"本地流发布成功");
        }
    }];

    // 4. 如果已经有远端用户在房间中, 需要订阅远端流
    if ([room.remoteUsers count] > 0) {
        NSMutableArray *streamArray = [NSMutableArray array];
        for (RCRTCRemoteUser *user in room.remoteUsers) {
            [streamArray addObjectsFromArray:user.remoteStreams];
        }
        [self subscribeRemoteResource:streamArray];
    }
}

// 麦克风静音
- (IBAction)micMute:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.engine.defaultAudioStream setMicrophoneDisable:sender.selected];
}

// 本地摄像头切换
- (IBAction)changeCamera:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.engine.defaultVideoStream switchCamera];
}

// 挂断
- (IBAction)hangupAction:(UIButton *)sender {
    // 取消本地发布
    [self.room.localUser unpublishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
    }];
    // 关闭摄像头采集
    [self.engine.defaultVideoStream stopCapture];
    [self.remoteView removeFromSuperview];
    // 退出房间
    [self.engine leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess && code == RCRTCCodeSuccess) {
            NSLog(@"退出房间成功 code: %ld", (long) code);
        }
    }];
}

#pragma mark - RCRTCRoomEventDelegate

- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self subscribeRemoteResource:streams];
}

- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self.remoteView setHidden:YES];
}

- (void)didLeaveUser:(RCRTCRemoteUser *)user {
    [self.remoteView setHidden:YES];
}

- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
    // 订阅房间中远端用户音视频流资源
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


#pragma mark - private method

- (void)alertString:(NSString *)string {
    if (!string.length) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)tapWithView:(UIGestureRecognizer *)ges{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect frame = self.remoteView.frame;
    self.remoteView.frame = self.localView.frame;
    self.localView.frame = frame;
    [CATransaction commit];
    
    if (ges.view.frame.size.width >= kScreenWidth) {
        [self.containerView bringSubviewToFront:self.remoteView];
    }else{
        [self.containerView bringSubviewToFront:self.localView];
    }
}


- (RCRTCEngine *)engine {
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
        [_engine enableSpeaker:YES];
    }
    return _engine;
}


@end
