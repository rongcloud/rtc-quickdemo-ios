//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCRTCCallLibViewController.h"
#import <RongCallLib/RongCallLib.h>

/**
 * 当前 UI 的几种状态
 */
typedef NS_ENUM(NSInteger,RCRTCCallStatus){
    /**
     * 默认，可呼叫状态
     */
    RCRTCCallStatus_Normal = 0,
    /**
     * 正在呼入
     */
    RCRTCCallStatus_Incoming = 1,
    /**
     * 正在呼出
     */
    RCRTCCallStatus_Dialing = 2,
    /**
     * 通话中
     */
    RCRTCCallStatus_Active = 3,
};

@interface RCRTCCallLibViewController () <RCCallReceiveDelegate,RCCallSessionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *targetIdTextField;

/**
 * 本地和远端视图
 */
@property (weak, nonatomic) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet UIView *remoteView;

/**
 * 操作按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UIButton *accpetBtn;
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;
@property (weak, nonatomic) IBOutlet UILabel *sessionDescription;

@property (nonatomic,strong)RCCallSession *callSession;

@end

@implementation RCRTCCallLibViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    [self initCallLib];
}

#pragma mark - Init

/**
 * 初始化相关 UI
 */
- (void)initUI{
    [self updateUIWithStatus:RCRTCCallStatus_Normal];
}

/**
 * 初始化相关配置
 */
- (void)initCallLib{
    //设置链接协议
    [[RCCallClient sharedRCCallClient] setDelegate:self];
}

#pragma mark - Button Action
/**
 * 发起呼叫
 */
- (IBAction)startCall:(UIButton *)sender {
    _callSession = [[RCCallClient sharedRCCallClient] startCall:ConversationType_PRIVATE targetId:self.targetIdTextField.text to:@[self.targetIdTextField.text] mediaType:RCCallMediaVideo sessionDelegate:self extra:nil];
    [_callSession addDelegate:self];
    [_callSession setMinimized:NO];
    [_callSession setSpeakerEnabled:YES];
    [self updateUIWithStatus:RCRTCCallStatus_Dialing];
}

/**
 * 接听会话
 */
- (IBAction)accpetCall:(UIButton *)sender {
    [self.callSession accept:self.callSession.mediaType];
    [self updateUIWithStatus:RCRTCCallStatus_Active];
}

/**
 * 挂断会话
 */
- (IBAction)rejectCall:(UIButton *)sender {
    [self.callSession hangup];
    [self updateUIWithStatus:RCRTCCallStatus_Normal];
}

#pragma mark - RCCallReceiveDelegate

/**
 * 接收到通话呼入的回调
 */
- (void)didReceiveCall:(RCCallSession *)callSession{
    _callSession = callSession;
    [_callSession addDelegate:self];
    [_callSession setMinimized:NO];
    [self updateUIWithStatus:RCRTCCallStatus_Incoming];
}

#pragma mark - RCCallSessionDelegate

/**
 * 通话已接通
 */
- (void)callDidConnect{
    
    [self.callSession setVideoView:self.localView
                            userId:[RCCoreClient sharedCoreClient].currentUserInfo.userId];
    [self.callSession setVideoView:self.remoteView userId:self.callSession.targetId];
    [self updateUIWithStatus:RCRTCCallStatus_Active];
}

/**
 * 通话已结束
 */
- (void)callDidDisconnect{
    [self updateUIWithStatus:RCRTCCallStatus_Normal];
}

#pragma mark - UI Status
/**
 * UI 状态控制
 */
- (void)updateUIWithStatus:(RCRTCCallStatus)status{
    
    [self.targetIdTextField resignFirstResponder];
    switch (status) {
        case RCRTCCallStatus_Normal:
        {
            self.localView.hidden = YES;
            self.remoteView.hidden = YES;
            self.callBtn.hidden = NO;
            self.rejectBtn.hidden = YES;
            self.accpetBtn.hidden = YES;
            self.sessionDescription.hidden = YES;
        }
            break;
        case RCRTCCallStatus_Incoming:
        {
            self.callBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.accpetBtn.hidden = NO;
            self.sessionDescription.hidden = NO;
            self.sessionDescription.text = @"收到呼叫";
        }
            break;
        case RCRTCCallStatus_Dialing:
        {
            self.callBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.accpetBtn.hidden = YES;
            self.sessionDescription.hidden = NO;
            self.sessionDescription.text = @"正在呼叫";
        }
            break;
        case RCRTCCallStatus_Active:
        {
            self.localView.hidden = NO;
            self.remoteView.hidden = NO;
            self.callBtn.hidden = YES;
            self.rejectBtn.hidden = NO;
            self.accpetBtn.hidden = YES;
            self.sessionDescription.hidden = YES;
        }
            break;
        default:
            break;
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
 
    [self.targetIdTextField resignFirstResponder];
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
