//
//  RCRTCHomeViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCRTCHomeViewController.h"
#import <RongIMKit/RCIM.h>

#import "RCRTCCreateMeetingViewController.h"
#import "RCRTCPrepareLiveViewController.h"
#import "UIViewController+AlertView.h"
#import "RCRTCCallLibViewController.h"
#import "RCRTCCallKitViewController.h"

@interface RCRTCHomeViewController () <RCIMConnectionStatusDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;

@end

@implementation RCRTCHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
    
    [self setRongCloudDelegate];
}

- (void)initUI{
    
    self.navigationItem.hidesBackButton = YES;
    self.currentUserLabel.text = [NSString stringWithFormat:@"UserID：%@",[RCIM sharedRCIM].currentUserInfo.userId];
}

- (void)setRongCloudDelegate{
    [RCIM sharedRCIM].connectionStatusDelegate = self;
}

/**
 * 点击会议按钮
 */
- (IBAction)clickMeetingBtn:(UIButton *)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RCRTCMeeting" bundle:nil];
    RCRTCCreateMeetingViewController *prePareMeetingVC = [sb instantiateViewControllerWithIdentifier:@"RCRTCCreateMeetingViewController"];
    [self.navigationController pushViewController:prePareMeetingVC animated:YES];
}

- (IBAction)clickLiveBtn:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RCRTCLive" bundle:nil];
    RCRTCPrepareLiveViewController *prePareLiveVC = [sb instantiateViewControllerWithIdentifier:@"RCRTCPrepareLiveViewController"];
    [self.navigationController pushViewController:prePareLiveVC animated:YES];
}

- (IBAction)clickCallLibBtn:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RCRTCCallLib" bundle:nil];
    RCRTCCallLibViewController *callLibVC = [sb instantiateViewControllerWithIdentifier:@"RCRTCCallLibViewController"];
    [self.navigationController pushViewController:callLibVC animated:YES];
}
- (IBAction)clickCallKitBtn:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RCRTCCallKit" bundle:nil];
    RCRTCCallKitViewController *callKitVC = [sb instantiateViewControllerWithIdentifier:@"RCRTCCallKitViewController"];
    [self.navigationController pushViewController:callKitVC animated:YES];
}

/**
 * 注销当前账户
 */
- (IBAction)logout:(UIButton *)sender {
    
    [[RCIM sharedRCIM] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
 
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
 
        [self.navigationController popToRootViewControllerAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow.rootViewController showAlertView:@"当前用户在其他设备登陆"];
        });
    }
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
