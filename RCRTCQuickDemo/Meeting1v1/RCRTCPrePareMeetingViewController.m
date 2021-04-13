//
//  RCRTCPrePareMeetingViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import "RCRTCPrePareMeetingViewController.h"
#import "RCRTCMeetingViewController.h"

@interface RCRTCPrePareMeetingViewController ()

/**
 房间ID输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@end

@implementation RCRTCPrePareMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


/**
 加入会议
 */
- (IBAction)joinMeeting:(UIButton *)sender {
    
    if (!self.roomIdTextField.text || self.roomIdTextField.text.length <= 0) {
        return;
    }
    
    RCRTCMeetingViewController *meetingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RCRTCMeetingViewController"];
    meetingVC.roomId = self.roomIdTextField.text;
    [self.navigationController pushViewController:meetingVC animated:YES];
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
