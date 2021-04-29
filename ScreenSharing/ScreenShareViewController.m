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
#import "LiveStreamVideo.h"
#import "LiveVideoLayoutTool.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

@interface ScreenShareViewController ()<RongRTCServerSocketProtocol,RCRTCRoomEventDelegate>

@property (nonatomic, strong) RPSystemBroadcastPickerView *systemBroadcastPickerView;
@property(nonatomic , strong)RongRTCServerSocket *serverSocket;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property(nonatomic, strong) LiveStreamVideo *localView;
@property(nonatomic, strong) RCRTCRemoteVideoView *remoteView;
@property(nonatomic, strong) LiveStreamVideo *localShareView;
@property(nonatomic, strong) RCRTCRemoteVideoView *remoteShareView;
@property (nonatomic, strong) RCRTCVideoOutputStream *shareVideoOutputStream;

@property(nonatomic, strong) RCRTCRoom *room;
@property(nonatomic, strong) RCRTCEngine *engine;

@property (nonatomic, strong) UIButton  *screenShareButton;

@property (nonatomic)NSMutableArray <LiveStreamVideo *>*streamVideos;
@property (nonatomic, strong)LiveVideoLayoutTool *layoutTool;

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
    [self.streamVideos addObject:self.localView];
    [self updateLayoutWithAnimation:YES];
    

}


- (void)initMode {

    
    self.systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 64, 50, 80)];
    self.systemBroadcastPickerView.preferredExtension = @"cn.rongcloud.rtcquickdemo.screenshare";
    self.systemBroadcastPickerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.systemBroadcastPickerView.showsMicrophoneButton = NO;
//    [self.view addSubview:self.systemBroadcastPickerView];
   
    
//    _screenShareButton  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
//    [_screenShareButton  setTitle:@"开始共享" forState:UIControlStateNormal];
//    [_screenShareButton  setTitle:@"关闭共享" forState:UIControlStateSelected];
//    [_screenShareButton  setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
//    [_screenShareButton  setTitleColor:[UIColor systemBlueColor] forState:UIControlStateSelected];
//    [_screenShareButton  addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.screenShareButton ];
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.systemBroadcastPickerView ];
    


}
//
//-(void)shareButtonAction:(UIButton *)button{
//
//    button.selected = !button.selected;
//    if (button.selected) {
//        [[self.systemBroadcastPickerView findButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
//
////        [self.serverSocket createServerSocket];
////        RCRTCLocalVideoView *localShareVideoView = (RCRTCLocalVideoView *)self.localShareView
////        .canvesView;
////
////
////
////
////        localShareVideoView.fillMode = RCRTCVideoFillModeAspectFit;
////        localShareVideoView.frameAnimated = NO;
////
////        NSString *tag = @"RongRTCScreenShare";
////        self.shareVideoOutputStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:tag];
////    //    self.shareVideoOutputStream.videoSource
////        RCRTCVideoStreamConfig *videoConfig = self.shareVideoOutputStream.videoConfig;
////        videoConfig.videoSizePreset = RCRTCVideoSizePreset320x240;
////        [self.shareVideoOutputStream setVideoConfig:videoConfig];
////        [self.shareVideoOutputStream setVideoView:localShareVideoView];
////
////
////
////        [self.room.localUser publishStream:self.shareVideoOutputStream
////                                completion:^(BOOL isSuccess, RCRTCCode desc) {
////            if (desc == RCRTCCodeSuccess) {
////                [self.streamVideos addObject:self.localShareView];
////                [self updateLayoutWithAnimation:YES];
////
////            }
////            else {
////
////            }
////        }];
//    }else{
//        [[self.systemBroadcastPickerView findButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
//
////        [self.room.localUser unpublishStream:self.shareVideoOutputStream
////                                  completion:^(BOOL isSuccess, RCRTCCode desc) {
////            if (isSuccess) {
////                [self.streamVideos removeObject:self.localShareView];
////                self.shareVideoOutputStream = nil;
////                [self updateLayoutWithAnimation:YES];
////            }
////        }];
//    }
//
//
//}
/**
 * 布局视图动画
 */
- (void)updateLayoutWithAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.layoutTool layoutVideos:self.streamVideos inContainer:self.containerView];
        }];
    }else{
        [self.layoutTool layoutVideos:self.streamVideos inContainer:self.containerView];
    }
}
- (void)cleanRemoteContainer{
    [self.streamVideos removeAllObjects];
    for (UIView *subview in self.containerView.subviews) {
        [subview removeFromSuperview];
    }
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

    RCRTCLocalVideoView *view = (RCRTCLocalVideoView *)self.localView.canvesView;

    view.fillMode = RCRTCVideoFillModeAspectFill;

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
- (void)setAppGroup
{
 NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.cn.rongcloud.rtcquickdemo.screenshare"];//此处id要与开发者中心创建时一致
    [myDefaults setObject:self.roomId forKey:@"roomId"];
 NSLog(@"lalallalala%@", [myDefaults valueForKey:@"roomId"]);
}

/**
 * 订阅房间中远端用户音视频流资源
 */
//- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
//
//    [self.room.localUser subscribeStream:streams tinyStreams:nil completion:^(BOOL isSuccess, RCRTCCode desc) {
//
//    }];
//    // 创建并设置远端视频预览视图
//    for (RCRTCInputStream *stream in streams) {
//        if (stream.mediaType == RTCMediaTypeVideo) {
//            [(RCRTCVideoInputStream *) stream setVideoView:self.remoteView];
//            [self.remoteView setHidden:NO];
//        }
//    }
//}


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

/**
 * 取消订阅远端流
 */
-(void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orStreamId:(NSString *)streamId {
    
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            streamId = stream.streamId;
            [self fetchStreamVideoOffLineWithStreamId:streamId];
        }
    }
    
}


/**
 * 订阅远端流
 */
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams{
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
                [self setupRemoteViewWithStream:stream];
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
-(LiveStreamVideo *)setupRemoteViewWithStream:(RCRTCInputStream *)stream{
    
    LiveStreamVideo *sVideo = [self creatStreamVideoWithStreamId:stream.streamId];
    RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)sVideo.canvesView;
    
    //如果为屏幕共享则适配显示
    if([stream.tag isEqualToString:@"RongRTCScreenShare"]){
        
        remoteView.fillMode = RCRTCVideoFillModeAspectFit;
        
    }
    //设置视频流的渲染视图
    [(RCRTCVideoInputStream *)stream setVideoView:remoteView];
    return sVideo;
}


/**
 *判断是否已有预览视图
 */
- (LiveStreamVideo *)creatStreamVideoWithStreamId:(NSString *)streamId{
    LiveStreamVideo *sVideo = [self fetchStreamVideoWithStreamId:streamId];
    if (!sVideo) {
        sVideo = [[LiveStreamVideo alloc] initWithStreamId:streamId];
        [self.streamVideos insertObject:sVideo atIndex:0];
    }
    return sVideo;
}

/**
 * 根据 streamId 确认唯一的音视频流
 */
- (LiveStreamVideo *)fetchStreamVideoWithStreamId:(NSString *)streamId{
    for (LiveStreamVideo *sVideo in self.streamVideos) {
        if ([streamId isEqualToString:sVideo.streamId]) {
            return sVideo;
        }
    }
    return nil;
}

/**
 * 远端掉线/离开回掉调用，删除远端用户的所有音视频流
 */
- (void)fetchStreamVideoOffLineWithStreamId:(NSString *)streamId{
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

#pragma mark - RCRTCRoomEventDelegate

/**
 * 远端用户发布资源通知
 */
-(void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    
    [self subscribeRemoteResource:streams];
}

/**
 * 远端用户取消发布资源
 */
- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams{
    
    [self unsubscribeRemoteResource:streams orStreamId:nil];
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
    
    [self unsubscribeRemoteResource:user.remoteStreams orStreamId:nil];
}


/**
 * 远端掉线
 */
- (void)didOfflineUser:(RCRTCRemoteUser*)user{
    [self unsubscribeRemoteResource:user.remoteStreams orStreamId:nil];
}


#pragma mark - lazy load

- (LiveStreamVideo *)localShareView{
    if (!_localShareView) {
        _localShareView = [LiveStreamVideo LocalStreamVideo];
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

- (NSMutableArray<LiveStreamVideo *> *)streamVideos{
    if (!_streamVideos) {
        _streamVideos = [NSMutableArray array];
    }
    return _streamVideos;
}
- (LiveStreamVideo *)localView{
    if (!_localView) {
        _localView = [LiveStreamVideo LocalStreamVideo];
    }
    return _localView;
}
- (LiveVideoLayoutTool *)layoutTool{
    if (!_layoutTool) {
        _layoutTool = [LiveVideoLayoutTool new];
    }
    return _layoutTool;
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
