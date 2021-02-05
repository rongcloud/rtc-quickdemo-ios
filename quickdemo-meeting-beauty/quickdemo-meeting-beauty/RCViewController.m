//
//  RCViewController.m
//  quickdemo-meeting-beauty
//
//  Created by RongCloud on 2021/1/4.
//

#import "RCViewController.h"
#import "RCViewController+Image.h"
#import "AppConfig.h"

#import <RongRTCLib/RongRTCLib.h>
#import "GPUImageHandle.h"

@interface RCViewController ()<RCRTCRoomEventDelegate>
@property (weak, nonatomic) IBOutlet RCRTCLocalVideoView *localVideoView;
@property (weak, nonatomic) IBOutlet RCRTCRemoteVideoView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *originImage;
@property (weak, nonatomic) IBOutlet UIImageView *beutyImage;

@property(nonatomic, strong, nullable) RCRTCRoom *room;
@property(nonatomic, strong, nullable) GPUImageHandle *gpuImageHandler;
@property(nonatomic, assign) BOOL openBeauty;
@end

@implementation RCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initIMSDK];
    
}

- (IBAction)joinRoom:(UIButton *)sender {
    sender.enabled = NO;
    
    //加入房间
    [[RCRTCEngine sharedInstance] joinRoom:RoomId completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        if (code == RCRTCCodeSuccess) {
            [self aferJoinRoom:room];
        } else {
            sender.enabled = YES;
            [self joinRoom:sender];
        }
    }];
}

- (IBAction)switchCameraAction:(id)sender {
    [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
}
//开关美颜
- (IBAction)beautyAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.openBeauty = sender.selected;
}

//开启美颜之后截图对比，美颜前后效果
- (IBAction)snapshotAction:(id)sender {
    if (!self.openBeauty) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.gpuImageHandler.sampleBufferCallBack = ^(CMSampleBufferRef originBuffer, CMSampleBufferRef newBuffer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        UIImage *image1 = [strongSelf imageFromSampleBuffer:originBuffer];
        UIImage *image2 = [strongSelf imageFromSampleBuffer:newBuffer];
        strongSelf.gpuImageHandler.sampleBufferCallBack = NULL;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.originImage.image = image1;
            strongSelf.beutyImage.image = image2;
        });
    };
}


#pragma mark- Api something
- (void)initIMSDK {
    // 初始化融云 SDK
    [[RCIMClient sharedRCIMClient] initWithAppKey:APP_KEY];
    // 前置条件 IM 建立连接
    [[RCIMClient sharedRCIMClient] connectWithToken:TOKEN dbOpened:^(RCDBErrorCode code) {}
                                            success:^(NSString *userId) {
        NSLog(@"IM 连接成功 userId: %@", userId);
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"%@",[NSString stringWithFormat:@"IM 连接失败 errorCode: %ld", (long) errorCode]);
    }];
}

- (void)aferJoinRoom:(RCRTCRoom * _Nullable) room {
    self.room = room;
    self.room.delegate = self;

    // 创建并设置本地视频预览视图
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:self.localVideoView];
    
    // 开始采集视频
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
    
    // 发布本地音视频流资源
    [self publishLocalAVStream];
    
    // 加入房间时已经有远端用户在房间中，收集需要订阅的流
    if ([self.room.remoteUsers count] > 0) {
        NSMutableArray *streamArray = [NSMutableArray array];
        for (RCRTCRemoteUser *user in self.room.remoteUsers) {
            [streamArray addObjectsFromArray:user.remoteStreams];
        }
        // 订阅远端音视频流
        [self subscribeRemoteResource:streamArray];
    }
    
    //获取采集的buffer回调
    __weak typeof(self) weakSelf = self;
    [RCRTCEngine sharedInstance].defaultVideoStream.videoSendBufferCallback =
        ^CMSampleBufferRef _Nullable(BOOL valid, CMSampleBufferRef  _Nullable sampleBuffer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || !strongSelf.openBeauty) {
                return sampleBuffer;
            }

            //处理buffer 这里可以更换成第三方的api
            CMSampleBufferRef processedSampleBuffer = [strongSelf.gpuImageHandler onGPUFilterSource:sampleBuffer];
            return processedSampleBuffer ?: sampleBuffer;
        };
}

- (void)publishLocalAVStream {
    [self.room.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode code) {}];
}

- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
    
    // 订阅房间中远端用户音视频流资源
    [self.room.localUser subscribeStream:streams tinyStreams:@[] completion:^(BOOL isSuccess, RCRTCCode code) {}];
    
    // 创建并设置远端视频预览视图
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            [((RCRTCVideoInputStream *)stream) setVideoView:self.remoteVideoView];
        }
    }
}

#pragma mark-注册监听
// 如果已经在房间中，通过 RongRTCLib 库的 RCRTCRoomDelegate 中 didPublishStreams: 上报，有远端用户发布了流
- (void)didPublishStreams:(NSArray <RCRTCInputStream *>*)streams {
    // 订阅远端音视频流
    [self subscribeRemoteResource:streams];
}

- (GPUImageHandle *)gpuImageHandler {
    if (!_gpuImageHandler) {
        _gpuImageHandler = [[GPUImageHandle alloc]init];
    }
    return _gpuImageHandler;
}

#pragma mark- UI
- (void)setOpenBeauty:(BOOL)openBeauty {
    _openBeauty = openBeauty;
    self.snapshotButtom.enabled = openBeauty;
}
@end
