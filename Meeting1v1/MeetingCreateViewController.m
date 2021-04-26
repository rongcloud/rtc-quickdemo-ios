//
//  MeetingCreateViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "MeetingCreateViewController.h"
#import "MeetingViewController.h"

static NSString * const MeetingViewControllerIdentifier = @"MeetingViewController";

/**
 * 准备加入会议控制器
 *
 * - 输入会议 ID
 * - 确认是否开启自定义加密
 */
@interface MeetingCreateViewController (){
    BOOL _enableCrypto;
}

/**
 * 房间ID输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@end

@implementation MeetingCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

/**
 * 是否开启自定义加密
 */
- (IBAction)switchValueChanged:(UISwitch *)sender {
    _enableCrypto = !_enableCrypto;
    NSLog(@"click switch, _enableCrypto:%d",_enableCrypto);
}

/**
 * 加入会议 
 */
- (IBAction)joinMeeting:(UIButton *)sender {
    
    if (!self.roomIdTextField.text || self.roomIdTextField.text.length <= 0) {
        return;
    }
    
    [self.roomIdTextField resignFirstResponder];

    MeetingViewController *meetingVC = [self.storyboard instantiateViewControllerWithIdentifier:MeetingViewControllerIdentifier];
    meetingVC.roomId = self.roomIdTextField.text;
    meetingVC.enableCryptho = _enableCrypto;
    [self.navigationController pushViewController:meetingVC animated:YES];
}

@end
