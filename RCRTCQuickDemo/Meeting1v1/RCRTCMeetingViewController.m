//
//  RCRTCMeetingViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/9.
//

#import "RCRTCMeetingViewController.h"
#import <RongRTCLib/RongRTCLib.h>

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

@interface RCRTCMeetingViewController () <RCRTCRoomEventDelegate>
@property (weak, nonatomic) IBOutlet RCRTCRemoteVideoView *remoteView;
@property (weak, nonatomic) IBOutlet RCRTCLocalVideoView *localView;
@property(nonatomic, strong) RCRTCRoom *room;
@property(nonatomic, strong) RCRTCEngine *engine;

@property(nonatomic, assign) BOOL isFull;

@end

@implementation RCRTCMeetingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"room id %@",self.roomId);
    [self initView];
    
    [self joinRoom];
}

- (void)initView{
    self.navigationController.navigationBarHidden = YES;
    self.localView.fillMode = RCRTCVideoFillModeAspectFill;
    //添加点击手势,可切换大小视图
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWithView:)];
    [self.localView addGestureRecognizer:tap];
    self.remoteView.fillMode = RCRTCVideoFillModeAspectFill;
}

// 加入房间
- (void)joinRoom {
    RCRTCVideoStreamConfig *videoConfig = [[RCRTCVideoStreamConfig alloc] init];
    videoConfig.videoSizePreset = RCRTCVideoSizePreset1280x720;
    videoConfig.videoFps = RCRTCVideoFPS30;
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:videoConfig];

    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudioVideo;
    [self.engine enableSpeaker:NO];

    @WeakObj(self);
    [self.engine joinRoom:self.roomId
                   config:config
               completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
                   @StrongObj(self);
                   if (code == RCRTCCodeSuccess) {
                       [self afterJoinRoom:room];
                   } else {
                       [self alertString:@"加入房间失败"];
                   }
               }];
}

- (void)viewDidLayoutSubviews{
    NSLog(@"");
}

- (void)tapWithView:(UIGestureRecognizer *)ges {
////    [CATransaction begin];
////    [CATransaction setDisableActions:YES];
//    CGRect frame = self.remoteView.frame;
//    CGRect frame1 = self.localView.frame;
//    self.remoteView.frame = CGRectMake(100, 100, 100, 100);
//    self.localView.frame = frame;
////    [CATransaction commit];
//    self.isFull = !self.isFull;
//
////    [self viewDidLayoutSubviews];


}

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

- (RCRTCEngine *)engine {
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
        [_engine enableSpeaker:YES];
    }
    return _engine;
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
