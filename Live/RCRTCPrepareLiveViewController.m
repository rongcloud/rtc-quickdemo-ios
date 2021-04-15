//
//  RCRTCPrepareLiveViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/14.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
