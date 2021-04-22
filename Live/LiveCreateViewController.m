//
//  LiveCreateViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LiveCreateViewController.h"
#import "LiveViewController.h"

static NSString * const LiveViewControllerIdentifier = @"LiveViewController";

/**
 * 主播/观众 区分身份直播入口类
 *
 * 根据身份不同参数不同
 * 主播 RCRTCLiveRoleTypeBroadcaster
 * 观众 RCRTCLiveRoleTypeAudience
 *
 */
@interface LiveCreateViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@end

@implementation LiveCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 * 主播身份：开始直播
 */
- (IBAction)startLive:(UIButton *)sender {
    
    if (![self checkTextField]) return;
    
    [self.roomIdTextField resignFirstResponder];
    
    LiveViewController *liveVC = [self.storyboard instantiateViewControllerWithIdentifier:LiveViewControllerIdentifier];
    liveVC.roomId = self.roomIdTextField.text;
    liveVC.liveRoleType = RCRTCLiveRoleTypeBroadcaster;
    [self.navigationController pushViewController:liveVC animated:YES];
}

/**
 * 观众身份：观看直播
 */
- (IBAction)watchLive:(UIButton *)sender {
    
    if (![self checkTextField]) return;
    
    [self.roomIdTextField resignFirstResponder];
    
    LiveViewController *liveVC = [self.storyboard instantiateViewControllerWithIdentifier:LiveViewControllerIdentifier];
    liveVC.roomId = self.roomIdTextField.text;
    liveVC.liveRoleType = RCRTCLiveRoleTypeAudience;
    [self.navigationController pushViewController:liveVC animated:YES];
}

- (BOOL)checkTextField{
    
    if (!self.roomIdTextField.text || self.roomIdTextField.text.length <= 0 ){
        return NO;
    }
    return YES;
}


@end
