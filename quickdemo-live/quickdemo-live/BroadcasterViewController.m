//
//  Copyright © 2020 huan xu. All rights reserved.
//

#import "BroadcasterViewController.h"
#import <RongRTCLib/RongRTCLib.h>
#import "StreamVideo.h"
#import "VideoLayoutTool.h"
#import "LiveMenuView.h"
#import "UIAlertController+RC.h"

@interface BroadcasterViewController ()<RCRTCRoomEventDelegate,LiveMenuContrlEventDelegate>

@property (nonatomic, strong)LiveMenuView *menuView;
@property (nonatomic, strong)UIView *remoteContainerView;
@property (nonatomic, strong)RCRTCEngine *engine;
@property (nonatomic, strong)RCRTCRoom *room;

@property (nonatomic, strong)NSMutableArray <StreamVideo *>*streamVideos;
@property (nonatomic, strong)StreamVideo *localVideo;
@property (nonatomic, strong)VideoLayoutTool *layoutTool;
@property (nonatomic, strong)RCRTCLiveInfo *liveInfo;

@end

@implementation BroadcasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // Do any additional setup after loading the view.

    [self initializeEngine];
    [self setupMenuView];
    [self setupLocalVideoView];
    [self joinLiveRoom];
}

// 初始化引擎
- (void)initializeEngine{
    self.engine = [RCRTCEngine sharedInstance];
    [self.engine useSpeaker:YES];
}

// 添加菜单按钮界面
- (void)setupMenuView{
    self.remoteContainerView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.menuView.delegate = self;
    [self.view addSubview:self.remoteContainerView];
    [self.view addSubview:self.menuView];
}

// 添加本地采集预览界面
- (void)setupLocalVideoView{
    if (self.role == RCRTCBroadcasterType) {
        // 只有主播模式才会一开始添加本地视频流
        [self.streamVideos addObject:self.localVideo];
        [self updateLayoutWithAnimation:YES];
    }
}

// 加入房间
- (void)joinLiveRoom{
    // 1.配置房间
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive; // 房间类型
    config.liveType = RCRTCLiveTypeAudioVideo; // 直播类型
    
    @WeakObj(self);
    [[RCRTCEngine sharedInstance] joinRoom:self.roomId
                                    config:config
                                completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        @StrongObj(self);
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"加入房间失败: %ld",code] inCurrentVC:self];
            return;
        }
        // set delegate
        self.room = room;
        room.delegate = self;
        
        if (self.role == RCRTCBroadcasterType) {
            //2.发布自己的流
            [self publishLocalLiveAVStream];
        }
        
        //3.如果已经有远端的流
        if (room.remoteUsers.count) {
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in room.remoteUsers) {
                if (user.remoteStreams.count) {
                    [streamArray addObjectsFromArray:user.remoteStreams];
                    [self subscribeRemoteResource:streamArray orUid:nil];
                }
            }
        }else if (self.role == RCRTCAudienceNodelayType) {
            [UIAlertController alertWithString:@"当前房间内暂无其他主播!!!" inCurrentVC:self];
        }
    }];
}

// 发布本地音视频流
- (void)publishLocalLiveAVStream {
    
    RCRTCLocalVideoView *view = (RCRTCLocalVideoView *)self.localVideo.canvesView;
    // 设置本地音视频流
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:view];
    // 开始摄像头采集
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
    
    // 发布本地流到房间
    [self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        if (desc == RCRTCCodeSuccess) {
            // 默认设置一次自定义合流布局
            self.liveInfo = liveInfo;
            [liveInfo setMixStreamConfig:[self setOutputConfig:RCRTCMixLayoutModeCustom] completion:^(BOOL isSuccess, RCRTCCode code) {
                
            }];
            NSLog(@"本地发布成功: liveUrl = %@",liveInfo.liveUrl);
            alert.message = liveInfo.liveUrl;
            UIAlertAction *okAtion = [UIAlertAction actionWithTitle:@"复制 liveUrl 到剪切板" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [UIPasteboard generalPasteboard].string = liveInfo.liveUrl;
            }];
            [alert addAction:okAtion];
        }else {
            alert.message = @"本地发布失败，请退出房间重试";
            UIAlertAction *okAtion = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAtion];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

//退出

#pragma mark - LiveMenuContrlEventDelegate
- (void)exitRoom{
    @WeakObj(self);
    [self.engine leaveRoom:self.roomId completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (isSuccess && code == RCRTCCodeSuccess) {
            self.engine = nil;
        }else{
            [UIAlertController alertWithString:[NSString stringWithFormat:@"退出房间失败 code: %ld",code] inCurrentVC:self];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

// 麦克风静音
- (void)microphoneIsMute:(BOOL)isMute{
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:isMute];
}
    
// 本地摄像头切换
- (void)changeCamera{
    [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
}

// 切换主播/观众
- (void)changeRole:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (self.role == RCRTCBroadcasterType) {
        // 取消本地发布
        @WeakObj(self);
        [self.room.localUser unpublishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
            @StrongObj(self);
            if (desc == RCRTCCodeSuccess && isSuccess) {
                // 修改按钮显隐状态
                self.role = RCRTCAudienceNodelayType;
                self.menuView.roleType = self.role;
            }
        }];
        [self unsubscribeRemoteResource:nil orUid:@"0"];
    }
    else if (self.role == RCRTCAudienceNodelayType){
        // 重新发布
        [self.streamVideos addObject:self.localVideo];
        [self publishLocalLiveAVStream];
        // 修改按钮显隐状态
        self.role = RCRTCBroadcasterType;
        self.menuView.roleType = self.role;
    }
    [self updateLayoutWithAnimation:YES];
}

// 自定义模式合流布局
- (void)streamlayoutMode:(RCRTCMixLayoutMode)mode{
    @WeakObj(self);
    [self.liveInfo setMixStreamConfig:[self setOutputConfig:mode] completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (code == RCRTCCodeSuccess && isSuccess) {
            [UIAlertController alertWithString:@"合流布局切换成功" inCurrentVC:self];
            return;
        }
        [UIAlertController alertWithString:[NSString stringWithFormat:@"合流布局切换失败 code: %ld",code] inCurrentVC:self];
    }];
}

#pragma mark - RCRTCRoomEventDelegate

- (void)didOfflineUser:(RCRTCRemoteUser*)user{
    NSLog(@"掉线");
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

#pragma mark - private Method

// 取消订阅远端流
- (void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orUid:(NSString *)uid {
    if (!uid) {
        if (streams.count) {
            RCRTCInputStream *stream = [streams lastObject];
            uid = stream.userId;
        }
    }
    StreamVideo *v = [self fetchStreamVideoWithId:uid];
    if (v) {
        [v.canvesView removeFromSuperview];
        [self.streamVideos removeObject:v];
        [self updateLayoutWithAnimation:YES];
    }
}

// 订阅远端流
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams orUid:(NSString *)uid{
    if (!uid) {
        if (streams.count) {
            RCRTCInputStream *stream = [streams lastObject];
            uid = stream.userId;
        }
    }
    StreamVideo *v = [self creatStreamVideoWithId:uid];
    if (![self.streamVideos containsObject:v]) {
        [self.streamVideos insertObject:v atIndex:0];
    }

    // 订阅房间中远端用户音视频流资源
    [self.room.localUser subscribeStream:streams tinyStreams:nil completion:^(BOOL isSuccess, RCRTCCode desc) {}];
    
    // 创建并设置远端视频预览视图
    NSInteger i = 0;
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            StreamVideo *sVideo = [self fetchStreamVideoWithId:stream.userId];
            RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)sVideo.canvesView;
            [(RCRTCVideoInputStream *)stream setVideoView:remoteView];
            i++;
        }
    }
    if (i > 0) {
        [self updateLayoutWithAnimation:YES];
    }
}

- (StreamVideo *)creatStreamVideoWithId:(NSString *)uid{
    StreamVideo *sVideo = [self fetchStreamVideoWithId:uid];
    if (sVideo) {
        return sVideo;
    }
    return [[StreamVideo alloc] initWithUid:uid];
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
        [UIView animateWithDuration:0.3 animations:^{
            [self updateInterface];
        }];
    } else {
        [self updateInterface];
    }
}

- (void)updateInterface{
    [self.layoutTool layoutVideos:self.streamVideos inContainer:self.remoteContainerView];
}

// 设置合流布局
- (RCRTCMixConfig *)setOutputConfig:(RCRTCMixLayoutMode)mode{
    // 布局配置类
    RCRTCMixConfig *streamConfig = [[RCRTCMixConfig alloc] init];
    // 选择模式
    streamConfig.layoutMode = mode;
    // 设置合流视频参数：宽 = 300，高 = 300, 帧率 = 30, 码率 = 500
    streamConfig.mediaConfig.videoConfig.videoLayout.width = 300;
    streamConfig.mediaConfig.videoConfig.videoLayout.height = 300;
    streamConfig.mediaConfig.videoConfig.videoLayout.fps = 20;
    streamConfig.mediaConfig.videoConfig.videoLayout.bitrate = 500;
    
    // 音频配置
    streamConfig.mediaConfig.audioConfig.bitrate = 300;
    // 设置是否裁剪
    streamConfig.mediaConfig.videoConfig.videoExtend.renderMode = 1;

    NSMutableArray *streamArr = [NSMutableArray array];
    // 添加本地输出流
    NSArray<RCRTCOutputStream *> *localStreams
    = RCRTCEngine.sharedInstance.currentRoom.localUser.localStreams;
    for (RCRTCOutputStream *vStream in localStreams) {
        if (vStream.mediaType == RTCMediaTypeVideo) {
            [streamArr addObject:vStream];
        }
    }
    
    switch (mode) {
        case RCRTCMixLayoutModeCustom:
            // 自定义布局
        {
            // 如果是自定义布局需要设置下面这些
            NSArray<RCRTCRemoteUser *> *remoteUsers = RCRTCEngine.sharedInstance.currentRoom.remoteUsers;
            for (RCRTCRemoteUser* remoteUser in remoteUsers) {
                for (RCRTCInputStream *inputStream in remoteUser.remoteStreams) {
                    if (inputStream.mediaType == RTCMediaTypeVideo) {
                        [streamArr addObject:inputStream];
                    }
                }
            }
            [self customLayoutWithStreams:streamArr streamConfig:streamConfig];
        }
            break;
        case RCRTCMixLayoutModeSuspension:
            //悬浮布局
        {
            RCRTCOutputStream *vStream = [streamArr lastObject];
            streamConfig.hostVideoStream = vStream;
        }
            break;
        case RCRTCMixLayoutModeAdaptive:
            //自适应布局
        {
            RCRTCOutputStream *vStream = [streamArr lastObject];
            streamConfig.hostVideoStream = vStream;
        }
            break;
        default:
            break;
    }

    return streamConfig;
}

- (void)customLayoutWithStreams:(NSMutableArray *)streams streamConfig:(RCRTCMixConfig *)streamConfig{
    NSInteger streamCount = streams.count;
    int itemWidth = 150;
    int itemHeight = itemWidth;
    if (streamCount == 1) {
        RCRTCStream *firstStream = [streams firstObject];
        RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
        inputConfig.videoStream = firstStream;
        inputConfig.x = (300-itemWidth)/2;   // 坐标示例，具体根据自己布局设置
        inputConfig.y = 0; // 坐标示例，具体根据自己布局设置
        inputConfig.width = itemWidth;   // 坐标示例，具体根据自己布局设置
        inputConfig.height = itemHeight;  // 坐标示例，具体根据自己布局设置
        [streamConfig.customLayouts addObject:inputConfig];
    }else if (streamCount == 2){
        RCRTCStream *firstStream = [streams firstObject];
        RCRTCStream *lastStream = [streams lastObject];
        
        RCRTCCustomLayout *inputConfig1 = [[RCRTCCustomLayout alloc] init];
        inputConfig1.videoStream = firstStream;
        inputConfig1.x = (300-itemWidth)/2;   // 坐标示例，具体根据自己布局设置
        inputConfig1.y = 0; // 坐标示例，具体根据自己布局设置
        inputConfig1.width = itemWidth;   // 坐标示例，具体根据自己布局设置
        inputConfig1.height = itemHeight;  // 坐标示例，具体根据自己布局设置
        [streamConfig.customLayouts addObject:inputConfig1];
        
        RCRTCCustomLayout *inputConfig2 = [[RCRTCCustomLayout alloc] init];
        inputConfig2.videoStream = lastStream;
        inputConfig2.x = 0;   // 坐标示例，具体根据自己布局设置
        inputConfig2.y = itemHeight; // 坐标示例，具体根据自己布局设置
        inputConfig2.width = itemWidth;   // 坐标示例，具体根据自己布局设置
        inputConfig2.height = itemHeight;  // 坐标示例，具体根据自己布局设置
        [streamConfig.customLayouts addObject:inputConfig2];
    }else if (streamCount == 3){
        RCRTCStream *firstStream = [streams firstObject];
        RCRTCStream *secondStream = streams[1];
        RCRTCStream *lastStream = [streams lastObject];
        
        RCRTCCustomLayout *inputConfig1 = [[RCRTCCustomLayout alloc] init];
        inputConfig1.videoStream = firstStream;
        inputConfig1.x = (300-itemWidth)/2;   // 坐标示例，具体根据自己布局设置
        inputConfig1.y = 0; // 坐标示例，具体根据自己布局设置
        inputConfig1.width = itemWidth;   // 坐标示例，具体根据自己布局设置
        inputConfig1.height = itemHeight;  // 坐标示例，具体根据自己布局设置
        [streamConfig.customLayouts addObject:inputConfig1];
        
        RCRTCCustomLayout *inputConfig2 = [[RCRTCCustomLayout alloc] init];
        inputConfig2.videoStream = secondStream;
        inputConfig2.x = 0;   // 坐标示例，具体根据自己布局设置
        inputConfig2.y = itemHeight; // 坐标示例，具体根据自己布局设置
        inputConfig2.width = itemWidth;   // 坐标示例，具体根据自己布局设置
        inputConfig2.height = itemHeight;  // 坐标示例，具体根据自己布局设置
        [streamConfig.customLayouts addObject:inputConfig2];
        
        RCRTCCustomLayout *inputConfig3 = [[RCRTCCustomLayout alloc] init];
        inputConfig3.videoStream = lastStream;
        inputConfig3.x = itemWidth;   // 坐标示例，具体根据自己布局设置
        inputConfig3.y = itemHeight; // 坐标示例，具体根据自己布局设置
        inputConfig3.width = itemWidth;   // 坐标示例，具体根据自己布局设置
        inputConfig3.height = itemHeight;  // 坐标示例，具体根据自己布局设置
        [streamConfig.customLayouts addObject:inputConfig3];
        
    }else{
        int i = 0;
        for (RCRTCStream *stream in streams) {
            RCRTCCustomLayout *inputConfig = [[RCRTCCustomLayout alloc] init];
            inputConfig.videoStream = stream;
            inputConfig.x = 100 * i;   // 坐标示例，具体根据自己布局设置
            inputConfig.y = 100 * (i/3); // 坐标示例，具体根据自己布局设置
            inputConfig.width = 100;   // 坐标示例，具体根据自己布局设置
            inputConfig.height = 100;  // 坐标示例，具体根据自己布局设置
            [streamConfig.customLayouts addObject:inputConfig];
            i++;
        }
    }
}


#pragma mark - lazy loading

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

- (UIView *)menuView{
    if (!_menuView) {
        _menuView = [LiveMenuView MenuViewWithRoleType:self.role roomId:self.roomId];
        [_menuView setFrame:UIScreen.mainScreen.bounds];
    }
    return _menuView;
}

@end
