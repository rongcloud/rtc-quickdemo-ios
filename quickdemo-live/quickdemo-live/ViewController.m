//
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import "BroadcasterViewController.h"
#import "AudienceViewController.h"

@interface ViewController ()

@property(weak, nonatomic) IBOutlet UIButton *broadcaster;
@property(weak, nonatomic) IBOutlet UIButton *audience_nor;
@property(weak, nonatomic) IBOutlet UIButton *audience_noDelay;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)BroadCaster:(id)sender {
    if (sender == self.broadcaster) {
        [self alertTextFieldWithRole:RCRTCBroadcasterType];
    } else {
        // 无延迟直播类型的观众
        [self alertTextFieldWithRole:RCRTCAudienceNodelayType];
    }
}

- (IBAction)Audience:(id)sender {
    [self alertTextFieldWithRole:RCRTCAudienceType];
}

- (void)alertTextFieldWithRole:(RCRTCRoleType)role {
    NSString *placeholder = (role == RCRTCAudienceType ? @"请输入 liveUrl" : @"请输入房间号");
    __block UITextField *tf = nil;
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"welcome live room" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = placeholder;
        tf = textField;
    }];
    UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            [self jumpLiveRoomWithRole:role key:tf.text];
        }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)jumpLiveRoomWithRole:(RCRTCRoleType)role key:(NSString *)key {
    if (!key.length) return;
    if (role == RCRTCAudienceType) {
        AudienceViewController *vc = [AudienceViewController new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.liveUrl = key;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        BroadcasterViewController *vc = [BroadcasterViewController new];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.roomId = key;
        vc.role = role;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
