//
//  CDNLiveViewController.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/7/13.
//

#import "CDNLiveViewController.h"
#import "UIAlertController+RCRTC.h"

@interface CDNLiveViewController ()
@property (nonatomic, strong) RCRTCLocalVideoView *localVideoView;

@end

@implementation CDNLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.roomIdLabel.text = [NSString stringWithFormat:@"roomId: %@",self.roomId];
    [self initUI];
}

- (IBAction)cdnEnableAction:(UIButton *)sender {
    if (self.room == nil || !self.liveInfo) {
        return;
    }
    BOOL enable = !sender.selected;
    sender.enabled = NO;
    [self.liveInfo enableInnerCDN:enable completion:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                sender.selected = !sender.selected;
            });
        }
        if (code == 48006 || code == 48007) {
            //内置cdn自动模式下
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIAlertController alertWithString:@"内置cdn自动模式下,调用无效，详情参考官网使用说明" inCurrentViewController:nil];
            });
        }
        sender.enabled = YES;
    }];
}

- (IBAction)closeLiveAction:(id)sender {
    [[RCRTCEngine sharedInstance].defaultVideoStream stopCapture];

    // 退出房间
    [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess && code == RCRTCCodeSuccess) {
            NSLog(@"退出房间成功 code: %ld", (long) code);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)initUI {
    RCRTCLocalVideoView *view = self.localVideoView;
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:view];
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
}


-(RCRTCLocalVideoView *)localVideoView {
    if (!_localVideoView) {
        _localVideoView = [[RCRTCLocalVideoView alloc]initWithFrame:self.view.bounds];
        [self.view insertSubview:_localVideoView atIndex:0];
    }
    return _localVideoView;
}
@end
