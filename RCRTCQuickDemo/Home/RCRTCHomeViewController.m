//
//  RCRTCHomeViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCRTCHomeViewController.h"
#import "RCRTCCreateMeetingViewController.h"
#import "RCRTCPrepareLiveViewController.h"
#import "UIViewController+AlertView.h"
#import "RCRTCCallLibViewController.h"
#import "RCRTCCallKitViewController.h"

#import <RongIMKit/RongIMKit.h>

static NSString * const MeetingStoryboardName = @"RCRTCMeeting";
static NSString * const MeetingControllerIdentifier = @"RCRTCCreateMeetingViewController";

static NSString * const LiveStoryboardName = @"RCRTCLive";
static NSString * const LiveControllerIdentifier = @"RCRTCPrepareLiveViewController";

static NSString * const CallLibStoryboardName = @"RCRTCCallLib";
static NSString * const CallLibControllerIdentifier = @"RCRTCCallLibViewController";

static NSString * const CallKitStoryboardName = @"RCRTCCallKit";
static NSString * const CallKitControllerIdentifier = @"RCRTCCallKitViewController";
/**
 * 首页 包含集成的多种场景功能
 *
 * - meeting 1v1: 1v1 会议
 * - live   : 直播
 * - calllib: 根据 calllib 完成 1v1 呼叫功能
 * - callkit: 根据 callKit 完成 1v1 呼叫功能
 */
@interface RCRTCHomeViewController () <RCIMConnectionStatusDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;

@end

@implementation RCRTCHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    /**
     * 配置 IM
     */
    [self setRongCloudDelegate];
}

- (void)initUI{
    
    self.navigationItem.hidesBackButton = YES;
    self.currentUserLabel.text = [NSString stringWithFormat:@"UserID：%@",[RCIM sharedRCIM].currentUserInfo.userId];
}

- (void)setRongCloudDelegate{
    
    /**
     * 设置连接状态监听
     */
    [RCIM sharedRCIM].connectionStatusDelegate = self;
}

#pragma mark - Event
/**
 * 点击会议按钮
 */
- (IBAction)clickMeetingBtn:(UIButton *)sender {
    [self pushViewController:MeetingStoryboardName identifier:MeetingControllerIdentifier];
}

/**
 * 点击直播按钮
 */
- (IBAction)clickLiveBtn:(UIButton *)sender {
    [self pushViewController:LiveStoryboardName identifier:LiveControllerIdentifier];
}

/**
 * 点击 callLib 呼叫
 */
- (IBAction)clickCallLibBtn:(UIButton *)sender {
    [self pushViewController:CallLibStoryboardName identifier:CallLibControllerIdentifier];
}

/**
 * 点击 callkit 呼叫
 */
- (IBAction)clickCallKitBtn:(UIButton *)sender {
    [self pushViewController:CallKitStoryboardName identifier:CallKitControllerIdentifier];
}

/**
 * 注销当前账户
 */
- (IBAction)logout:(UIButton *)sender {
    
    [[RCIM sharedRCIM] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)pushViewController:(NSString *)storyboardName identifier:(NSString *)identifier{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *callKitVC = [sb instantiateViewControllerWithIdentifier:identifier];
    [self.navigationController pushViewController:callKitVC animated:YES];
}

#pragma mark - RCIMConnectionStatusDelegate
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    
    /**
     * 互踢提示
     */
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow.rootViewController showAlertView:@"当前用户在其他设备登陆"];
        });
    }
}

@end
