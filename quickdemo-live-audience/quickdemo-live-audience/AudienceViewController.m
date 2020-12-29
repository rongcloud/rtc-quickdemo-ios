//
//  AudienceViewController.m
//  quickdemo-live-audience
//
//  Created by RongCloud on 2020/10/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "AudienceViewController.h"
#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLib/RongIMLib.h>
#import "AppConfig.h"
#import "UIAlertController+RC.h"


@interface AudienceViewController ()<RCRTCRoomEventDelegate,RCIMClientReceiveMessageDelegate>

@property (nonatomic, strong)RCRTCRemoteVideoView *remoteView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextView *liveUrlText;
@property (nonatomic, copy)NSString *liveUrl;
@property (nonatomic, strong)RCRTCEngine *engine;

@end

@implementation AudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loginIM];
    [self setupRemoteVideoView];
}

//前置条件,需要建立IM连接
- (void)loginIM{
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppID];
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    [[RCIMClient sharedRCIMClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
    } success:^(NSString *userId) {
        NSString *successMsg = [NSString stringWithFormat:@"IM登陆成功userId:%@",userId];
        [UIAlertController alertWithString:successMsg inCurrentVC:self];
    } error:^(RCConnectErrorCode errorCode) {
        NSString *errorMsg = [NSString stringWithFormat:@"IM登陆失败code:%ld",(long)errorCode];
        [UIAlertController alertWithString:errorMsg inCurrentVC:self];
    }];
}

//添加远端直播画面
- (void)setupRemoteVideoView{
    [self.containerView addSubview:self.remoteView];
}

//开始/停止观看
- (IBAction)startWatch:(UIButton *)sender {
    sender.selected = !sender.selected;
    sender.selected ? [self subscribeLiveStream]:[self unSubscribeLiveStream];
}

- (IBAction)tobeHost:(UIButton *)sender {
    //todo:
}

//订阅主播
- (void)subscribeLiveStream{
    @WeakObj(self);
    [self.engine subscribeLiveStream:self.liveUrl streamType:RCRTCAVStreamTypeAudioVideo completion:^(RCRTCCode desc, RCRTCInputStream * _Nullable inputStream) {
        @StrongObj(self);
        if (desc != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:@"订阅失败,检查liveUrl" inCurrentVC:self];
        }
        // 注意 * 当前block这里会回调两次,需要针对流类型处理
        if (inputStream.mediaType == RTCMediaTypeVideo) {
            [(RCRTCVideoInputStream *)inputStream setVideoView:self.remoteView];
        }
    }];
}

//取消订阅
- (void)unSubscribeLiveStream{
    [self.engine unsubscribeLiveStream:self.liveUrl completion:^(BOOL isSuccess, RCRTCCode code) {
        if (code != RCRTCCodeSuccess) {
            NSString *errorMsg = [NSString stringWithFormat:@"取消订阅失败code::%ld",(long)code];
            [UIAlertController alertWithString:errorMsg inCurrentVC:self];
        }
    }];
}

#pragma mark - RCIMClientReceiveMessageDelegate
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RCTextMessage *textMsg = (RCTextMessage *)message.content;
        self.liveUrl = textMsg.content;
        self.liveUrlText.text = [NSString stringWithFormat:@"liveUrl:%@",self.liveUrl];
    });
}

#pragma mark - lazy loading
- (RCRTCEngine *)engine{
    if (!_engine) {
        _engine = [RCRTCEngine sharedInstance];
//        [_engine enableSpeaker:YES];
    }
    return _engine;
}

- (RCRTCRemoteVideoView *)remoteView{
    if (!_remoteView) {
        _remoteView = [[RCRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0,0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width)];
        _remoteView.fillMode = RCRTCVideoFillModeAspectFill;
    }
    return _remoteView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
