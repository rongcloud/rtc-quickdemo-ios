//
//  ScreenShareViewController.m
//  RCRTCQuickDemo
//
//  Created by wangyanxu on 2021/4/28.
//

#import "ScreenShareViewController.h"
#import <ReplayKit/ReplayKit.h>
#import "RongRTCServerSocket.h"
#import "UIAlertController+RCRTC.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RPSystemBroadcastPickerView+SearchButton.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

@interface ScreenShareViewController ()<RongRTCServerSocketProtocol,RCRTCRoomEventDelegate>

@property (nonatomic, strong) RPSystemBroadcastPickerView *systemBroadcastPickerView;
@property(nonatomic , strong)RongRTCServerSocket *serverSocket;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property(nonatomic, strong) RCRTCLocalVideoView *localView;
@property(nonatomic, strong) RCRTCRemoteVideoView *remoteView;
@property(nonatomic, strong) RCRTCLocalVideoView *localShareView;
@property(nonatomic, strong) RCRTCRemoteVideoView *remoteShareView;
@property (nonatomic, strong) RCRTCVideoOutputStream *shareVideoOutputStream;

@property(nonatomic, strong) RCRTCRoom *room;
@property(nonatomic, strong) RCRTCEngine *engine;

@property (nonatomic, strong) UIButton  *screenShareButton;


@end

@implementation ScreenShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self joinRoom];
}
#pragma mark - UI

- (void)initView{
    
    [self initMode];
    [self setupLocalVideoView];
//    [self setupRemoteVideoView];
}

/**
 * 添加本地采集预览界面
 */
- (void)setupLocalVideoView {
    self.localView = [[RCRTCLocalVideoView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight/2)];
    self.localView.fillMode = RCRTCVideoFillModeAspectFill;
    [self.containerView addSubview:self.localView];

}


- (void)initMode {

    
    self.systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 64, 50, 80)];
    self.systemBroadcastPickerView.preferredExtension = @"com.rongcloud.support.ScreenShare";
    self.systemBroadcastPickerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.systemBroadcastPickerView.showsMicrophoneButton = NO;
//    [self.view addSubview:self.systemBroadcastPickerView];
   
    
    _screenShareButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
    [_screenShareButton  setTitle:@"开始共享" forState:UIControlStateNormal];
    [_screenShareButton  setTitle:@"关闭共享" forState:UIControlStateSelected];
    [_screenShareButton  setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [_screenShareButton  setTitleColor:[UIColor systemBlueColor] forState:UIControlStateSelected];
    [_screenShareButton  addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.screenShareButton ];
    


}

-(void)shareButtonAction:(UIButton *)button{
    
    button.selected = !button.selected;
    if (button.selected) {
        [[self.systemBroadcastPickerView findButton] sendActionsForControlEvents:UIControlEventTouchUpInside];

    }else{
        [[self.systemBroadcastPickerView findButton] sendActionsForControlEvents:UIControlEventTouchUpInside];

        
    }
    
    [self.serverSocket createServerSocket];

    
    self.localShareView = [[RCRTCLocalVideoView alloc] initWithFrame:CGRectMake(0, ScreenHeight/2, ScreenWidth, ScreenHeight/2)];
    [self.containerView addSubview:self.localShareView];
    
    
    self.localShareView.fillMode = RCRTCVideoFillModeAspectFit;
    self.localShareView.frameAnimated = NO;
    
    NSString *tag = @"RongRTCScreenVideo";
    self.shareVideoOutputStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:tag];
//    self.shareVideoOutputStream.videoSource
    RCRTCVideoStreamConfig *videoConfig = self.shareVideoOutputStream.videoConfig;
    videoConfig.videoSizePreset = RCRTCVideoSizePreset320x240;
    [self.shareVideoOutputStream setVideoConfig:videoConfig];
    [self.shareVideoOutputStream setVideoView:self.localShareView];

    
    
    [self.room.localUser publishLiveStream:self.shareVideoOutputStream completion:^(BOOL isSuccess, RCRTCCode code, RCRTCLiveInfo * _Nullable liveInfo) {
            if (code == RCRTCCodeSuccess) {
//                [self.streamVideos addObject:self.localshareStreamVideo];
//                [self updateLayoutWithAnimation:YES];
                
            }
            else {
                
            }
    }];
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


-(void)viewWillDisappear:(BOOL)animated{
    
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

-(RongRTCServerSocket *)serverSocket{
    
    if (!_serverSocket) {
        RongRTCServerSocket *socket = [[RongRTCServerSocket alloc] init];
        socket.delegate = self;
        
        _serverSocket = socket;
    }
    return _serverSocket;
}
-(void)didProcessSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // 这里拿到了最终的数据，比如最后可以使用融云的音视频SDK RTCLib 进行传输就可以了
  
    

    [self.shareVideoOutputStream write:sampleBuffer error:nil];
    
 
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
