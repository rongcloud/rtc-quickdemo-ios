//
//  RCRTCHomeViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/8.
//

#import "RCRTCHomeViewController.h"
#import <RongIMKit/RCIM.h>

#import "RCRTCPrePareMeetingViewController.h"

@interface RCRTCHomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;

@end

@implementation RCRTCHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initUI];
}

- (void)initUI{
    
    self.navigationItem.hidesBackButton = YES;
    self.currentUserLabel.text = [NSString stringWithFormat:@"UserID：%@",[RCIM sharedRCIM].currentUserInfo.userId];
}

/**
 * 点击会议按钮
 */
- (IBAction)clickMeetingBtn:(UIButton *)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RCRTCMeeting" bundle:nil];
    RCRTCPrePareMeetingViewController *prePareMeetingVC = [sb instantiateViewControllerWithIdentifier:@"RCRTCPrePareMeetingViewController"];
    [self.navigationController pushViewController:prePareMeetingVC animated:YES];
}

/**
 * 注销当前账户
 */
- (IBAction)logout:(UIButton *)sender {
    
    [[RCIM sharedRCIM] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
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
