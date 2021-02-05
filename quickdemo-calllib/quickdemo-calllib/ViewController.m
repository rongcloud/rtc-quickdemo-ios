//
//  ViewController.m
//  CallLibQuickstart
//
//  Created by RongCloud on 2020/12/24.
//

#import "ViewController.h"
#import <RongCallLib/RongCallLib.h>
#import "AppConfig.h"

@interface ViewController ()<RCCallReceiveDelegate,RCCallSessionDelegate>
@property (nonatomic, copy) NSString *loginUID;
@property (nonatomic,strong)RCCallSession *callSession;
@property (nonatomic,strong) UIView *localVideo;//承载本地视频
@property (nonatomic,strong) UIView *remoteVideo;//承载远端视频
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginUID = @"";
    // RCAppKey 设置
    [[RCIMClient sharedRCIMClient] initWithAppKey:RCAppKey];
    //设置链接协议
    [[RCCallClient sharedRCCallClient] setDelegate:self];
}
#pragma mark- sdk use
//建立链接=即登录
- (void)createConnect:(NSString *)token {
    __weak typeof(self)weakSelf = self;
    [[RCIMClient sharedRCIMClient] connectWithToken:token dbOpened:^(RCDBErrorCode code) {} success:^(NSString *userId) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf updateLoginUI:userId];
        });
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"connect filed code %ld",errorCode);
    }];
}

//发起会话
- (void)startCall:(NSString *)targetId {
    _callSession = [[RCCallClient sharedRCCallClient] startCall:ConversationType_PRIVATE targetId:targetId to:@[targetId] mediaType:RCCallMediaVideo sessionDelegate:self extra:nil];
    [_callSession addDelegate:self];
    [_callSession setMinimized:NO];
    [_callSession setSpeakerEnabled:YES];
}

//接受会话
- (void)acceptCall {
    [self.callSession accept:self.callSession.mediaType];
}

//拒绝挂断
- (void)rejectCall {
    [self.callSession hangup];
}

#pragma mark-RCCallReceiveDelegate
//收到视频邀请协议回调
- (void)didReceiveCall:(RCCallSession *)callSession {
    _callSession = callSession;
    [_callSession addDelegate:self];
    [_callSession setMinimized:NO];
    
    [self updateUI:NO select:NO];
}

#pragma mark-RCCallSessionDelegate
//建立通话成功
- (void)callDidConnect {
    [self.callSession setVideoView:self.localVideo
                            userId:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
    [self.callSession setVideoView:self.remoteVideo userId:self.callSession.targetId];
    
    [self updateUI:YES select:YES];
}
//远端挂断
- (void)callDidDisconnect {
    [self updateUI:YES select:NO];
}

#pragma mark-
#pragma mark- UI Event
- (IBAction)loginAction:(UIButton *)sender {
    [self createConnect:RCUserToken1];
}

- (IBAction)loginAction2:(id)sender {
    [self createConnect:RCUserToken2];
}

- (IBAction)callOffAction:(UIButton *)sender {
    if (sender.isSelected) {
        [self rejectCall];
    } else {
        NSString *callId = [self.loginUID isEqualToString:RCUserId1] ? RCUserId2 : RCUserId1;
        [self startCall:callId];
    }
    sender.selected = !sender.selected;
}

- (IBAction)callRejectAction:(id)sender {
    [self rejectCall];
    [self updateUI:YES select:NO];
}

- (IBAction)callAcceptAction:(id)sender {
    [self acceptCall];
    [self updateUI:YES select:YES];
}

#pragma mark-private
//更新按钮状态
- (void)updateLoginUI:(NSString *)userId {
    self.loginUID = userId;
    self.loginStatus.text = [NSString stringWithFormat:@"当前登录用户id为%@",userId];
    self.loginUser1.hidden = YES;
    self.loginUser2.hidden = YES;
    self.callOffBtn.hidden = NO;
}

- (void)updateUI:(BOOL)show select:(BOOL)select {
    self.callRejectBtn.hidden = show;
    self.callAcceptBtn.hidden = show;
    self.callOffBtn.hidden = !show;
    self.callOffBtn.selected = select;
    
    if (!select && show) {
        [self.localVideo removeFromSuperview];
        self.localVideo = nil;
        [self.remoteVideo removeFromSuperview];
        self.remoteVideo = nil;
    }
}

- (UIView *)localVideo {
    if (!_localVideo) {
        _localVideo = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.positionView1.bounds.size.width, self.positionView1.bounds.size.height)];
        [self.positionView1 addSubview:_localVideo];
    }
    return _localVideo;
}

- (UIView *)remoteVideo {
    if (!_remoteVideo) {
        _remoteVideo = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.positionView2.bounds.size.width, self.positionView2.bounds.size.height)];
        [self.positionView2 addSubview:_remoteVideo];
    }
    return _remoteVideo;
}
@end
