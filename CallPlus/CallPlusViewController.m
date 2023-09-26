//
//  CallLibViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "CallPlusViewController.h"
#import "CallPlusControlView.h"
#import "UIAlertController+RCRTC.h"
#import <RongCallPlusLib/RongCallPlusLib.h>

@interface CallPlusViewController () <RCCallPlusEventDelegate, RCCallPlusResultDelegate, CallPlusEventDelegate, RCCallPlusStatusReportDelegate>
// 本地和远端视图
@property (nonatomic, weak) IBOutlet RCCallPlusVideoView *localVideoView;
@property (nonatomic, weak) IBOutlet RCCallPlusRemoteVideoView *remoteView;
@property (nonatomic, weak) IBOutlet UITextField *targetIdTextField;
// 操作按钮
@property (nonatomic, weak) IBOutlet CallPlusControlView *controlView;

@property (nonatomic,   copy) NSString *callId;
@property (nonatomic, strong) RCCallPlusSession *callSession;
@property (nonatomic, strong) dispatch_source_t durationTimer;

@end

@implementation CallPlusViewController

- (void)dealloc {
    NSLog(@"CallPlusViewController:%@ dealloc", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化 UI
    [self initView];
    // 配置呼叫前的一些准备参数
    [self initConfig];
}

#pragma mark - Init

// 初始化相关 UI
- (void)initView {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.controlView setDelegate:self];
    [self.controlView updateUIWithStatus:RCRTCCallStatus_Normal];
}

// 初始化相关配置
- (void)initConfig {
    self.localVideoView.userId = self.title;
    
    [[RCCallPlusClient sharedInstance] setCallEventDelegate:self];
    [[RCCallPlusClient sharedInstance] setCallResultDelegate:self];
    [[RCCallPlusClient sharedInstance] setStatusReportDelegate:self];
}

- (void)startCallAction {
    /// 设置本地视图
    [[RCCallPlusClient sharedInstance] startCamera];
    [[RCCallPlusClient sharedInstance] setVideoView:self.localVideoView];
    /// 设置远端视图
    self.remoteView.userId = self.targetIdTextField.text;
    [[RCCallPlusClient sharedInstance] setVideoView:self.remoteView];
    /// 发起呼叫
    [[RCCallPlusClient sharedInstance] startCallWithUserIds:@[self.targetIdTextField.text]
                                                   callType:RCCallPlusSingleType
                                                  mediaType:RCCallPlusAudioVideoMediaType];
}

- (void)hangupAciton {
    [[RCCallPlusClient sharedInstance] stopCamera];
    [[RCCallPlusClient sharedInstance] removeVideoViewByUserId:self.localVideoView.userId];
    
    NSString *callId = self.callSession.callId ? self.callSession.callId : self.callId;
    [[RCCallPlusClient sharedInstance] hangupWithCallId:callId];
}

- (void)acceptAction {
    [[RCCallPlusClient sharedInstance] acceptWithCallId:self.callSession.callId];
}

- (void)rejectAction {
    [[RCCallPlusClient sharedInstance] hangupWithCallId:self.callSession.callId];
}

#pragma mark - CallPlusEventDelegate
- (void)controlActionWithType:(NSInteger)eventType selected:(BOOL)selected {
    switch (eventType) {
        case 0://开关摄像头
            if (selected) {
                [[RCCallPlusClient sharedInstance] stopCamera];
                [[RCCallPlusClient sharedInstance] removeVideoViewByUserId:self.localVideoView.userId];
            }
            else {
                [[RCCallPlusClient sharedInstance] startCamera];
                [[RCCallPlusClient sharedInstance] setVideoView:self.localVideoView];
            }
            break;
        case 1://切换摄像头
            [[RCCallPlusClient sharedInstance] switchCamera];
            break;
        case 2://开关麦克风
            [RCCallPlusClient sharedInstance].enableMicrophone = !selected;
            break;
        case 3://扬声器听筒切换
            [RCCallPlusClient sharedInstance].enableSpeaker = !selected;
            break;
        default:
        break;
    }
}


#pragma mark - RCCallPlusEventDelegate
/// 接收到呼入会话通知
/// @param session 会话
- (void)didReceivedCall:(RCCallPlusSession *)session {
    self.callSession = session;
    [self.controlView updateUIWithStatus:RCRTCCallStatus_Incoming];
    
    /// 设置本地视图
    [[RCCallPlusClient sharedInstance] startCamera];
    [[RCCallPlusClient sharedInstance] setVideoView:self.localVideoView];
    /// 设置远端视图
    self.remoteView.userId = session.inviterUserId;
    [[RCCallPlusClient sharedInstance] setVideoView:self.remoteView];
}

/// 建立通话成功
/// @param session 会话
- (void)didCallConnected:(RCCallPlusSession *)session {
    [self.controlView updateUIWithStatus:RCRTCCallStatus_Active];
}

/// 通话关闭
/// @param session 会话
/// @param reason 关闭原因
- (void)didCallEnded:(RCCallPlusSession *)session
              reason:(RCCallPlusReason)reason {
    [self.controlView updateUIWithStatus:RCRTCCallStatus_Normal];
    
//    [[RCCallPlusClient sharedInstance] stopCamera];
//    [[RCCallPlusClient sharedInstance] removeVideoViewByUserId:self.localVideoView.userId];
    
    [self cancelTimer];
}

- (void)didVideoViewRendered:(RCCallPlusCode)code userId:(NSString *)userId {
    NSLog(@"didVideoViewRendered:%@ userId:%@",@(code), userId);
}

- (void)didCallStartTimeFromServer:(NSInteger)callStartTime {
    [self timeWithDuration:[[NSDate date] timeIntervalSince1970]];
}

// 开始计时
- (void)timeWithDuration:(NSInteger)duration {
    [self cancelTimer];
    dispatch_queue_t queue = dispatch_queue_create("com.duration.timerQueue", DISPATCH_QUEUE_SERIAL);
    self.durationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.durationTimer, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.durationTimer, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.controlView updateWithDuration:duration];
    });
    dispatch_resume(self.durationTimer);
}

// 计时器
- (void)cancelTimer {
    if (self.durationTimer) {
        dispatch_source_cancel(self.durationTimer);
        self.durationTimer = nil;
    }
}


#pragma mark - RCCallPlusResultDelegate

/// 开始通话回调
/// @param code 状态码, 0:成功 非0:失败
/// @param callId 通话id
/// @param busylineUsers 忙线用户列表
- (void)didStartCallResultCode:(RCCallPlusCode)code
                        callId:(nullable NSString *)callId
                 busylineUsers:(nullable NSArray<RCCallPlusUser *> *)busylineUsers {
    if (code == RCCallPlusCodeSuccess) {
        self.callId = callId;
        [self.controlView updateUIWithStatus:RCRTCCallStatus_Dialing];
    }
    else {
        NSString *errDesc = [NSString stringWithFormat:@"didStartCallResultCode:%@",@(code)];
        [UIAlertController alertWithString:errDesc inCurrentViewController:nil];
    }
}

/// 接受通话回调
/// @param code 状态码, 0:成功 非0:失败
/// @param callId 通话id
- (void)didAcceptCallResultCode:(RCCallPlusCode)code callId:(NSString *)callId {
    if (code == RCCallPlusCodeSuccess) {
        [self.controlView updateUIWithStatus:RCRTCCallStatus_Active];
    }
    else {
        NSLog(@"didAcceptCallResultCode:%@",@(code));
    }
}

/// 挂断通话回调
/// @param code 状态码, 0:成功 非0:失败
/// @param callId 通话id
- (void)didHangupCallResultCode:(RCCallPlusCode)code callId:(NSString *)callId {
    if (code == RCCallPlusCodeSuccess) {
        [self.controlView updateUIWithStatus:RCRTCCallStatus_Normal];
    }
    else {
        NSLog(@"didHangupCallResultCode:%@",@(code));
    }
}

#pragma mark - RCCallPlusStatusReportDelegate
/// 接收丢包率信息回调
/// @param stats key:用户Id -- RCCallPlusPacketLossStats: 丟包率(0-100)，码率(kbps)
- (void)didReceivePacketLoss:(NSDictionary<NSString *, RCCallPlusPacketLossStats *>*)stats {
    
}

/// 发送丢包率信息回调
/// @param lossRate 丢包率(0-100)
/// @param delay 发送端的网络延迟(ms)
- (void)didSendPacketLoss:(float)lossRate delay:(int)delay {
    
}

#pragma mark - Private
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.targetIdTextField resignFirstResponder];
}



@end
