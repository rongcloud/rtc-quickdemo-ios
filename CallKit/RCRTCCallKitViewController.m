//
//  RCRTCCallKitViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCRTCCallKitViewController.h"
#import "UIViewController+AlertView.h"
#import <RongCallKit/RongCallKit.h>


@interface RCRTCCallKitViewController ()
@property (weak, nonatomic) IBOutlet UITextField *useridTextField;
@property (weak, nonatomic) IBOutlet UIButton *callMediaAudio;
@property (weak, nonatomic) IBOutlet UIButton *callMediaVideo;

@end

@implementation RCRTCCallKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 

    //必须初始化, 否则无法收到来电
    [RCCall sharedRCCall];
}

/**
 * 音频通话
 */
- (IBAction)callMediaAudio:(UIButton *)sender {
    if (!self.useridTextField.text ||self.useridTextField.text.length == 0) {
        return;
    }
    [self.useridTextField resignFirstResponder];
    
    //呼叫自己过滤
    if ([[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:self.useridTextField.text]) {
        [self showAlertView:@"不允许呼叫自己"];
        return;
    }
  
    //音频通话
    [[RCCall sharedRCCall] startSingleCall:self.useridTextField.text mediaType:RCCallMediaAudio];
    
}


/**
 * 视频通话
 */
- (IBAction)callMediaVideo:(UIButton *)sender {
    
    if (!self.useridTextField.text ||self.useridTextField.text.length == 0) {
        return;
    }
    [self.useridTextField resignFirstResponder];
    
    //呼叫自己过滤
    if ([[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:self.useridTextField.text]) {
        [self showAlertView:@"不允许呼叫自己"];
        return;
    }
    
    //视频通话
    [[RCCall sharedRCCall] startSingleCall:self.useridTextField.text mediaType:RCCallMediaVideo];
}

- (IBAction)keyboardHide:(UITextField *)sender {
    [self.useridTextField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.useridTextField resignFirstResponder];
}

@end
