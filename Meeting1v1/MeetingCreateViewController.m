//
//  MeetingCreateViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "MeetingCreateViewController.h"
#import "MeetingViewController.h"

@interface MeetingCreateViewController ()

/**
 房间ID输入框
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
 加入会议 
 */
- (IBAction)joinMeeting:(UIButton *)sender {
    
    if (!self.roomIdTextField.text || self.roomIdTextField.text.length <= 0) {
        return;
    }
    
    [self.roomIdTextField resignFirstResponder];
    MeetingViewController *meetingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RCRTCMeetingViewController"];
    meetingVC.roomId = self.roomIdTextField.text;
    [self.navigationController pushViewController:meetingVC animated:YES];
}

@end
