//
//  RCRTCCreateMeetingViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import "RCRTCCreateMeetingViewController.h"
#import "RCRTCMeetingViewController.h"

@interface RCRTCCreateMeetingViewController ()

/**
 房间ID输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@end

@implementation RCRTCCreateMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}


/**
 加入会议 
 */
- (IBAction)joinMeeting:(UIButton *)sender {
    
    if (!self.roomIdTextField.text || self.roomIdTextField.text.length <= 0) {
        return;
    }
    
    [self.roomIdTextField resignFirstResponder];
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
