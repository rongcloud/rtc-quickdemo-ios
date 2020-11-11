//
//  AudienceViewController.m
//  ios-live-quick-start
//
//  Created by huan xu on 2020/10/30.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import "AudienceViewController.h"
#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLib/RongIMLib.h>
#import "LiveMenuView.h"
#import "UIAlertController+RC.h"

@interface AudienceViewController ()<RCRTCRoomEventDelegate,LiveMenuContrlEventDelegate>

@property (nonatomic, strong)RCRTCRemoteVideoView *remoteView;
@property (nonatomic, strong)LiveMenuView *menuView;

@end

@implementation AudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [self setupRemoteVideoView];
    [self setupMenuView];
    [self subscribeLiveStream];
}

// 添加远端直播画面
- (void)setupRemoteVideoView{
    RCRTCRemoteVideoView *view = [[RCRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0, (UIScreen.mainScreen.bounds.size.height -UIScreen.mainScreen.bounds.size.width)/2 , UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width)];
    view.fillMode = RCRTCVideoFillModeAspectFill;
    self.remoteView = view;
    [self.view addSubview:view];
}

// 添加菜单按钮
- (void)setupMenuView{
    [self.view addSubview:self.menuView];
    self.menuView.delegate = self;
}

// 订阅主播
- (void)subscribeLiveStream{
    @WeakObj(self);
    [[RCRTCEngine sharedInstance] subscribeLiveStream:self.liveUrl streamType:RCRTCAVStreamTypeAudioVideo completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        @StrongObj(self);
        if (desc != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:@"订阅失败,检查liveUrl" inCurrentVC:self];
        }
        // 这里会回调两次,需要针对音频类型和视频类型分别处理
        if (inputStream.mediaType == RTCMediaTypeVideo) {
            [(RCRTCVideoInputStream *)inputStream setVideoView:self.remoteView];
        }
    }];
}

// 取消订阅
- (void)unSubscribeLiveStream{
    [[RCRTCEngine sharedInstance] unsubscribeLiveStream:self.liveUrl completion:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess && code == RCRTCCodeSuccess) {
            NSLog(@"取消订阅成功");
        }
    }];
}

#pragma mark - LiveMenuContrlEventDelegate
// 暂停订阅
- (void)changeRole:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self unSubscribeLiveStream];
    }
    else{
        [self subscribeLiveStream];
    }
}
// 退出
- (void)exitRoom{
    // 取消订阅
    [self unSubscribeLiveStream];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (LiveMenuView *)menuView{
    if (!_menuView) {
        _menuView = [LiveMenuView MenuViewWithRoleType:self.roleType roomId:@""];
        _menuView.frame = UIScreen.mainScreen.bounds;
    }
    return _menuView;
}


@end
