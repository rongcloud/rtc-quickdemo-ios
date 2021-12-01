//
//  DeviceViewController.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/10/9.
//

#import "DeviceViewController.h"
#import <RongRTCLib/RCRTCEngine.h>

@interface DeviceViewController ()

@property (nonatomic   ,weak) IBOutlet UIButton    *audioEchoButton;
@property (nonatomic   ,weak) IBOutlet UIButton    *audioEchoStopButton;
@property (nonatomic   ,weak) IBOutlet UILabel     *timeCountLabel;
@property (nonatomic   ,weak) IBOutlet UILabel     *timeCountLabelDetail;
@property (weak,   nonatomic) IBOutlet UITextField *audioEchoTextField;
@property (nonatomic ,assign) NSInteger    numUP;
@property (nonatomic ,assign) NSInteger    numDown;
@property (nonatomic ,assign) NSInteger    maxTime;
@property (nonatomic   ,weak) NSTimer     *audioEchoTimer;

@end

@implementation DeviceViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 禁用返回手势
       if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
           self.navigationController.interactivePopGestureRecognizer.enabled = NO;
       }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 开启返回手势
       if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
           self.navigationController.interactivePopGestureRecognizer.enabled = YES;
       }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.audioEchoTimer) {
        [self.audioEchoTimer invalidate];
    }
    [[RCRTCEngine sharedInstance] stopEchoTest];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设备检测";
    self.numUP = 0;
    self.numDown = 0;
}

- (void)requestMicroPhoneAuth
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {

    }];
}

- (void)goMicroPhoneSet
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"您还没有允许麦克风权限"
                                                                    message:@"去设置一下吧"
                                                             preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    UIAlertAction * setAction = [UIAlertAction actionWithTitle:@"去设置"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [UIApplication.sharedApplication openURL:url
                                             options:nil
                                   completionHandler:^(BOOL success) {

            }];
        });
    }];
    [alert addAction:cancelAction];
    [alert addAction:setAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)repeatAction {
    if (!self.audioEchoButton.enabled) {
        if (self.numUP < self.maxTime) {
            self.numUP ++;
            self.numDown ++;
            [UIView animateWithDuration:0.3 animations:^{
                self.timeCountLabel.alpha = 1;
                self.timeCountLabelDetail.alpha = 1;
            }];
            [self.timeCountLabel setText:[NSString stringWithFormat:@"%ld",self.numUP]];
            if (self.numUP == self.maxTime) {
//                [[RCRTCEngine sharedInstance] stopEchoTest];
            }
        }else {

            self.numDown --;
            if (self.numDown == 0) {
                [self.timeCountLabel setText:[NSString stringWithFormat:@"%ld",self.numDown]];
                self.timeCountLabel.alpha = 0;
                self.timeCountLabelDetail.alpha = 0;
                self.audioEchoButton.enabled = YES;
                [self.audioEchoTimer invalidate];
                return;
            }else {
                [self.timeCountLabel setText:[NSString stringWithFormat:@"%ld",self.numDown]];
                [self.timeCountLabelDetail setText:@"现在您应该能听到刚才说的话！"];
            }
        }
    }
}

- (IBAction)audioEchoAction:(id)sender {
    AVAuthorizationStatus microPhoneStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        switch (microPhoneStatus) {
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
            {
                // 被拒绝
                [self goMicroPhoneSet];
            }
                break;
            case AVAuthorizationStatusNotDetermined:
            {
                // 没弹窗
                [self requestMicroPhoneAuth];
            }
                break;
            case AVAuthorizationStatusAuthorized:
            {
                // 有授权
                [self start:sender];
            }
                break;

            default:
                break;
        }
}

- (void)start:(UIButton *)sender {
    
    if (self.audioEchoTextField.text.length == 0) {
        NSLog(@"请输入时间");
        return;
    }
    if (!self.audioEchoStopButton.hidden) {
        NSLog(@"请先关闭录制");
        return;
    }
    self.audioEchoButton.enabled = NO;
    self.audioEchoStopButton.hidden = NO;
    self.numUP = 0;
    self.numDown = 0;
    self.audioEchoTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(repeatAction)
                                                         userInfo:nil
                                                          repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.audioEchoTimer forMode:NSRunLoopCommonModes];

    if (self.audioEchoTextField.text.intValue > 10) {
        self.maxTime = 10;
    } else if (self.audioEchoTextField.text.intValue <= 2) {
        self.maxTime = 2;
    }else {
        self.maxTime = self.audioEchoTextField.text.intValue;
    }
    [[RCRTCEngine sharedInstance] startEchoTest:self.maxTime];

}

- (IBAction)audioEchoStopAction:(UIButton *)sender {
    sender.hidden = YES;
    self.timeCountLabel.alpha = 0;
    self.timeCountLabelDetail.alpha = 0;
    self.audioEchoButton.enabled = YES;
    [self.audioEchoTimer invalidate];
    self.audioEchoTimer = nil;
    [[RCRTCEngine sharedInstance] stopEchoTest];
}


@end
