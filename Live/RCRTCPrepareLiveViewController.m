//
//  RCRTCPrepareLiveViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCRTCPrepareLiveViewController.h"
#import "RCRTCLiveViewController.h"

@interface RCRTCPrepareLiveViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@end

@implementation RCRTCPrepareLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 * 主播身份：开始直播
 */
- (IBAction)startLive:(UIButton *)sender {
    
    if (![self checkTextField]) return;
    
    [self.roomIdTextField resignFirstResponder];
    
    [self.roomIdTextField resignFirstResponder];
    RCRTCLiveViewController *liveVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RCRTCLiveViewController"];
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
    
    [self.roomIdTextField resignFirstResponder];
    RCRTCLiveViewController *liveVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RCRTCLiveViewController"];
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
