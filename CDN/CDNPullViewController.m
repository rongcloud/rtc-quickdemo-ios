//
//  CDNPullViewController.m
//  RCRTCQuickDemo
//
//  Created by Zafer.Lee on 2021/7/13.
//

#import "CDNPullViewController.h"
#import "UIAlertController+RCRTC.h"
#import "CDNMenuViewController.h"
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

@interface CDNPullViewController () <RCRTCRoomEventDelegate, RCRTCEngineEventDelegate>
@property (weak, nonatomic) IBOutlet UIButton *subBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (nonatomic, strong) RCRTCRemoteVideoView *cdnVideoView;
@end

@implementation CDNPullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
    self.roomIdLabel.text = [NSString stringWithFormat:@"roomId: %@",self.roomId];
    self.room.delegate = self;
    [RCRTCEngine sharedInstance].delegate = self;
}

#pragma mark- Touch Event
- (IBAction)closeLiveAction:(id)sender {
    self.room.delegate = nil;
    [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess && code == RCRTCCodeSuccess) {
            NSLog(@"退出房间成功 code: %ld", (long) code);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)subLiveAction:(id)sender {
    [self subCDNStream];
}

- (IBAction)muteAction:(UIButton *)sender {
    RCRTCCDNInputStream *rtmpStream = [self.room getCDNStream];
    if (!rtmpStream)
        return;
    
    [rtmpStream setIsMute:sender.selected];
    sender.selected = !sender.selected;
}

- (IBAction)refrenLiveAction:(id)sender {
    RCRTCCDNInputStream *rtmpStream = [self.room getCDNStream];
    if (!rtmpStream)
        return;
    
    @WeakObj(self);
    [self.room.localUser unsubscribeStream:rtmpStream completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        [self subCDNStream];
    }];
}

- (IBAction)changeVideoSizeAction:(id)sender {
    CDNMenuViewController *menu = [self.storyboard instantiateViewControllerWithIdentifier:@"CDNMenuViewController"];
    menu.modalPresentationStyle = UIModalPresentationFullScreen;
    menu.selectIndexHandle = ^(NSInteger index) {
        if (index == 0)
            [self selectVideoSize:RCRTCVideoSizePreset640x360];
        else if (index == 1)
            [self selectVideoSize:RCRTCVideoSizePreset1280x720];
        else if (index == 2)
            [self selectVideoSize:RCRTCVideoSizePreset1920x1080];
    };
    menu.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    menu.modalPresentationStyle = UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
    [self presentViewController:menu animated:YES completion:^{
    }];
}

#pragma mark- Private Method
- (void)subCDNStream {
    if (self.room == nil) {
        return;
    }
    RCRTCCDNInputStream *rtmpStream = [self.room getCDNStream];
    if (!rtmpStream) {
        return;
    }
    
    [rtmpStream setVideoView:self.cdnVideoView];
    @WeakObj(self);
    [self.room.localUser subscribeStream:@[rtmpStream] tinyStreams:@[] completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (isSuccess) {
            self.subBtn.hidden = YES;
            self.muteBtn.hidden = NO;
        }
    }];
}

//设置订阅流分辨率
- (void)selectVideoSize:(RCRTCVideoSizePreset)videoSizePreset {
    RCRTCCDNInputStream *rtmpStream = [self.room getCDNStream];
    if (!rtmpStream) {
        return;
    }
    [rtmpStream setVideoConfig:videoSizePreset fpsValue:RCRTCVideoFPS30 completion:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess) {
        }
    }];
}

#pragma mark- RCRTCRoomEventDelegate
- (void)didPublishCDNStream:(RCRTCCDNInputStream *)stream {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIAlertController alertWithString:@"主播已经开播" inCurrentViewController:nil];
    });
    [self subCDNStream];
}

- (void)didUnpublishCDNStream:(RCRTCCDNInputStream *)stream {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIAlertController alertWithString:@"主播已经停播" inCurrentViewController:nil];
    });
    RCRTCCDNInputStream *rtmpStream = [self.room getCDNStream];
    if (!rtmpStream)
        return;
    [self.room.localUser unsubscribeStream:rtmpStream completion:^(BOOL isSuccess, RCRTCCode code) {
    }];
}

#pragma mark- RCRTCEngineEventDelegate
- (void)didOccurError:(RCRTCCode)errorCode {
    NSLog(@"%zd",errorCode);
}

#pragma mark- Getter
-(RCRTCRemoteVideoView *)cdnVideoView {
    if (!_cdnVideoView) {
        _cdnVideoView = [[RCRTCRemoteVideoView alloc]initWithFrame:self.view.bounds];
        [self.view insertSubview:_cdnVideoView atIndex:0];
    }
    return _cdnVideoView;
}
@end
