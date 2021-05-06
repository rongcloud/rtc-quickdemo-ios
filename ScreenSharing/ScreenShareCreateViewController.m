//
//  ScreenShareCreateViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "ScreenShareCreateViewController.h"
#import "ScreenShareViewController.h"

static NSString * const ScreenShareViewControllerIdentifier = @"ScreenShareViewController";

@interface ScreenShareCreateViewController () {
    BOOL _enableCrypto;
}

// 房间 ID 输入框
@property (nonatomic, weak) IBOutlet UITextField *roomIdTextField;

@end

@implementation ScreenShareCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

// 加入会议
- (IBAction)joinMeeting:(UIButton *)sender {
    if (!self.roomIdTextField.text || self.roomIdTextField.text.length <= 0) {
        return;
    }
    [self.roomIdTextField resignFirstResponder];
    
    ScreenShareViewController *screenShareVC = [self.storyboard instantiateViewControllerWithIdentifier:ScreenShareViewControllerIdentifier];
    screenShareVC.roomId = self.roomIdTextField.text;
    [self.navigationController pushViewController:screenShareVC animated:YES];
}

@end
