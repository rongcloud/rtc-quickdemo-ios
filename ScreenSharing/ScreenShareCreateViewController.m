//
//  ScreenShareCreateViewController.m
//  RCRTCQuickDemo
//
//  Created by wangyanxu on 2021/4/28.
//

#import "ScreenShareCreateViewController.h"
#import "ScreenShareViewController.h"
static NSString * const ScreenShareViewControllerIdentifier = @"ScreenShareViewController";


@interface ScreenShareCreateViewController (){
    BOOL _enableCrypto;
}

/**
 * 房间ID输入框
 */
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextField;

@end

@implementation ScreenShareCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}



/**
 * 加入会议
 */
- (IBAction)joinMeeting:(UIButton *)sender {
    
    if (!self.roomIdTextField.text || self.roomIdTextField.text.length <= 0) {
        return;
    }
    
    [self.roomIdTextField resignFirstResponder];

    ScreenShareViewController *screenShareVC = [self.storyboard instantiateViewControllerWithIdentifier:ScreenShareViewControllerIdentifier];
    screenShareVC.roomId = self.roomIdTextField.text;
    [self.navigationController pushViewController:screenShareVC animated:YES];
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
