//
//  CDNPlayerViewController.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2022/10/21.
//

#import "CDNPlayerViewController.h"
#import "CDNPalyViewCustom.h"
#import <RongRTCPlayer/RongRTCPlayer.h>
/*!
 如果设置 dataHandle 代理，mediaPlayer 将不再进行显示，需要用户自行通过回调获取数据展示；
 自行展示视图的方法系统有多种，SDK 对此没有限制，demo 自行展示的示例只是其中一种；
 */


@interface CDNPlayerViewController () <RCRTCMediaPlayerEventDelegate,RCRTCMediaPlayerDataHandle>
@property (nonatomic, strong) RCRTCMediaPlayer *mediaPlayer;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIView *mediaBackgroudView;

@property (nonatomic, strong) CDNPalyViewCustom *customCNDView;
@end

@implementation CDNPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickleftButton:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"模式" style:UIBarButtonItemStylePlain target:self action:@selector(changeRenderMode)];
    
    // 加载资源
    int res = [self.mediaPlayer openWithUrl:[NSURL URLWithString:self.cdnUrl]];
    if (res != 0) {
        NSLog(@"openWithUrl failed:%@",@(res));
    }
    // 播放器视图获取需要在加载资源之后获取
    [self initView];
    
    // 设置 dataHandle 代理并需要自行实现渲染才需要调用
//    [self initCustomView];
}
// 设置播放器渲染视图
- (void)initView {
    self.mediaPlayer.videoView.frame = self.mediaBackgroudView.bounds;
    self.mediaPlayer.videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mediaBackgroudView addSubview:self.mediaPlayer.videoView];
}

// 设置自定义渲染视图，希望自定义视图展示的时候设置
- (void)initCustomView {
    self.customCNDView = [[CDNPalyViewCustom alloc]init];
    self.customCNDView.frame = self.mediaBackgroudView.bounds;
    self.customCNDView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mediaBackgroudView addSubview:self.customCNDView];
}


// 播放
- (IBAction)playPlayerActiom:(UIButton *)sender {
    // 如果需要扬声器播放，需要用户自行设置
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    int res = [self.mediaPlayer play];
    if (res != 0) {
        NSLog(@"play failed:%@",@(res));
    }
    // 如果显示自定义渲染视图显示可以设置 dataHandle 代理并打开
//    [self.customCNDView addSampleBufferDisplayLayer];
}

// 暂停
- (IBAction)psusetPlayerActiom:(UIButton *)sender {
    int res = [self.mediaPlayer pause];
    if (res != 0) {
        NSLog(@"pause failed:%@",@(res));
    }
}
// 调节音量
- (IBAction)volumeChange:(UISlider *)sender {
    [_mediaPlayer setVolume:(int)self.volumeSlider.value ];
}

// 加载资源
- (IBAction)openPlayerActiom:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"url 地址" message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"加载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 先销毁旧的播放器
        [self.mediaPlayer destroy];
        int res = [self.mediaPlayer openWithUrl:[NSURL URLWithString:alert.textFields.firstObject.text]];
        if (res != 0) {
            NSLog(@"openWithUrl failed:%@",@(res));
        }
        // 设置播放器视图
        [self initView];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"cancel");
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请填写 url";
    }];

    [alert addAction:conform];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}

// 设置渲染模式
- (void)changeRenderMode {

    UIAlertController *alertSheet = [UIAlertController alertControllerWithTitle:@"设置渲染模式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        int res = [self.mediaPlayer setRenderMode:RCRTCVideoFillModeAspectFit];
        if (res != 0) {
            NSLog(@"setRenderMode failed:%@",@(res));
        }
    }];
    UIAlertAction *actionFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        int res = [self.mediaPlayer setRenderMode:RCRTCVideoFillModeAspectFill];
        if (res != 0) {
            NSLog(@"setRenderMode failed:%@",@(res));
        }
    }];
    UIAlertAction *actionResize = [UIAlertAction actionWithTitle:@"Resize" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        int res = [self.mediaPlayer setRenderMode:RCRTCVideoFillModeResize];
        if (res != 0) {
            NSLog(@"setRenderMode failed:%@",@(res));
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"cannel");
    }];

    [alertSheet addAction:actionFit];
    [alertSheet addAction:actionFill];
    [alertSheet addAction:actionResize];
    [alertSheet addAction:cancel];
    [self presentViewController:alertSheet animated:YES completion:nil];
  
}
#pragma mark - RCRTCMediaPlayerEventDelegate

// 当播放器的状态发生转变时，会触发以下回调。
- (void)onPlayer:(RCRTCMediaPlayer *)player didChangedState:(RCRTCPlaybackState)state {
    NSString *desc = nil;
    switch (state) {
        case RCRTCPlaybackStateIdle: {
            desc = @"didChangedState: Idle";
        }
            break;
        case RCRTCPlaybackStateLoading: {
            desc = @"didChangedState: Loading";
        }
            break;
        case RCRTCPlaybackStatePlayAble: {
            desc = @"didChangedState: PlayAble";
        }
            break;
        case RCRTCPlaybackStatePlaying: {
               desc = @"didChangedState: Playing";
        }
            break;
        case RCRTCPlaybackStatePausing: {
               desc = @"didChangedState: Pausing";
        }
            break;
        case RCRTCPlaybackStateError: {
            desc = @"didChangedState: Error";
        }
            break;
        default:
            break;
    }
    if (desc.length) {
        NSLog(@"%@",desc);
    }
}

// 视频分辨率变更通知
- (void)onPlayer:(RCRTCMediaPlayer *)player didChangedVideoSize:(CGSize)size {
    NSLog(@"%@",[NSString stringWithFormat:@"didChangedVideoSize:%@",NSStringFromCGSize(size)]);
}

// 音频首帧渲染
- (void)onFirstAudioFrameRenderWithPlayer:(RCRTCMediaPlayer *)player {
    NSLog(@"onFirstAudioFrameRenderWithPlayer");
}
// 视频首帧渲染
- (void)onFirstVideoFrameRenderWithPlayer:(RCRTCMediaPlayer *)player {
    NSLog(@"onFirstVideoFrameRenderWithPlayer");
}

// 获取 SEI 数据
- (void)onPlayer:(RCRTCMediaPlayer *)player handleSEIData:(NSString *)data {
//    NSLog(@"handleSEIData:%@",data);
}

// 发生错误通知
- (void)onPlayer:(RCRTCMediaPlayer *)player didOccurError:(NSInteger)errCode {
    
}

#pragma mark - RCRTCMediaPlayerDataHandle

// 获取视频流数据
- (void)onPlayer:(RCRTCMediaPlayer *)player handleVideoFrame:(RCRTCMediaPlayerVideoFrame *)videoFrame{
    // NV12
    if (videoFrame.pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        CVReturn result = noErr;
        NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey: @{}};
        CVPixelBufferRef pixelBufferRef;
        result = CVPixelBufferCreate(kCFAllocatorDefault,
                                        videoFrame.width,
                                        videoFrame.height,
                                        kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                        (__bridge CFDictionaryRef)pixelAttributes,
                                        &pixelBufferRef);
        if (result != noErr || !pixelBufferRef) {
            NSLog(@"CVPixelBufferCreate failed:%@",@(result));
            return;
        }
        {
            CVPixelBufferLockBaseAddress(pixelBufferRef, 0);
                
            void *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBufferRef, 0);
            void *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBufferRef, 1);
            size_t heightY = CVPixelBufferGetHeightOfPlane(pixelBufferRef, 0);
            size_t heightUV = CVPixelBufferGetHeightOfPlane(pixelBufferRef, 1);
            size_t dstStrideY = CVPixelBufferGetBytesPerRowOfPlane(pixelBufferRef, 0);
            size_t dstStrideUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBufferRef, 1);
            if (videoFrame.yBuffer) {
                memcpy(yDestPlane, videoFrame.yBuffer, dstStrideY * heightY);
            }
            if (videoFrame.uBuffer) {
                memcpy(uvDestPlane,videoFrame.uBuffer, dstStrideUV * heightUV);
            }
            CVPixelBufferUnlockBaseAddress(pixelBufferRef, 0);
        }
        // pixelBufferRef to do something
        [self.customCNDView dispatchPixelBuffer:pixelBufferRef];
        CVBufferRelease(pixelBufferRef);
    }
    
}
// 获取音频数据
- (void)onPlayer:(RCRTCMediaPlayer *)player handleAudioFrame:(RCRTCMediaPlayerAudioFrame *)audioFrame{

}

#pragma mark - back and destory
// 返回之前页面并销毁播放器
- (void)clickleftButton:(UIButton *)sender{
    [self.mediaPlayer destroy];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter
- (RCRTCMediaPlayer *)mediaPlayer {
    if (!_mediaPlayer) {
        _mediaPlayer = [[RCRTCMediaPlayer alloc] init];
        _mediaPlayer.delegate = self;
        
// 设置数据回调代理，需要注意设置此代理后，播放不再展示数据，需要用户自行展示
//        _mediaPlayer.dataHandle = self;
//        [_mediaPlayer setVolume:100];
    }
    return _mediaPlayer;
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
