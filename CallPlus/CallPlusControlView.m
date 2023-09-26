//
//  CallPlusControlView.m
//  RCRTCQuickDemo
//
//  Created by huan xu on 2023/5/31.
//

#import "CallPlusControlView.h"

@interface CallPlusControlView()

@property (nonatomic, weak) IBOutlet UILabel *durationLabel;

@property (nonatomic, weak) IBOutlet UIButton *cameraEnableBtn;
@property (nonatomic, weak) IBOutlet UIButton *switchCameraBtn;
@property (nonatomic, weak) IBOutlet UIButton *micEnableBtn;
@property (nonatomic, weak) IBOutlet UIButton *speakerEnableBtn;

@property (nonatomic, weak) IBOutlet UILabel *sessionDescription;
@property (nonatomic, weak) IBOutlet UIButton *callOrHangupBtn;
@property (nonatomic, weak) IBOutlet UIButton *accpetBtn;
@property (nonatomic, weak) IBOutlet UIButton *rejectBtn;

@property (nonatomic, weak) id<CallPlusEventDelegate> delegate;

@end

@implementation CallPlusControlView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self resetSubviewsStyle];
}

- (void)resetSubviewsStyle {
    for (UIButton *btn in self.subviews) {
        if ([btn isKindOfClass:UIButton.class]) {
            btn.layer.borderColor = [UIColor systemBlueColor].CGColor;
        }
    }
}

- (void)updateUIWithStatus:(RCRTCCallStatus)status {
    switch (status) {
        case RCRTCCallStatus_Normal: {
            self.cameraEnableBtn.hidden   = YES;
            self.switchCameraBtn.hidden   = YES;
            self.micEnableBtn.hidden      = YES;
            self.speakerEnableBtn.hidden  = YES;
            self.durationLabel.hidden     = YES;
            self.rejectBtn.hidden         = YES;
            self.accpetBtn.hidden          = YES;
            self.sessionDescription.hidden = YES;
            
            self.callOrHangupBtn.hidden = NO;
            self.callOrHangupBtn.selected = NO;
            [self.callOrHangupBtn setBackgroundColor:[UIColor systemBlueColor]];
        
            for (UIButton *btn in self.subviews) {
                if ([btn isKindOfClass:UIButton.class] && btn.tag >= 500) {
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    btn.selected = NO;
                }
            }
        }
            break;
        case RCRTCCallStatus_Incoming: {
            
            self.durationLabel.hidden = YES;
            self.callOrHangupBtn.hidden = YES;
            
            self.cameraEnableBtn.hidden = NO;
            self.switchCameraBtn.hidden = NO;
            self.micEnableBtn.hidden = NO;
            self.speakerEnableBtn.hidden = NO;
            self.rejectBtn.hidden = NO;
            self.accpetBtn.hidden = NO;
            self.sessionDescription.hidden = NO;
            self.sessionDescription.text = @"收到呼叫";
        }
            break;
        case RCRTCCallStatus_Dialing: {
            
            self.durationLabel.hidden = YES;
            self.rejectBtn.hidden = YES;
            self.accpetBtn.hidden = YES;
            
            self.cameraEnableBtn.hidden = NO;
            self.switchCameraBtn.hidden = NO;
            self.micEnableBtn.hidden = NO;
            self.speakerEnableBtn.hidden = NO;

            self.sessionDescription.hidden = NO;
            self.sessionDescription.text = @"正在呼叫";
            
            self.callOrHangupBtn.hidden = NO;
            self.callOrHangupBtn.selected = YES;
            [self.callOrHangupBtn setBackgroundColor:[UIColor systemRedColor]];
        }
            break;
        case RCRTCCallStatus_Active: {
            
            self.rejectBtn.hidden = YES;
            self.accpetBtn.hidden = YES;
            self.sessionDescription.hidden = YES;
            
            self.cameraEnableBtn.hidden = NO;
            self.switchCameraBtn.hidden = NO;
            self.micEnableBtn.hidden = NO;
            self.speakerEnableBtn.hidden = NO;
            self.durationLabel.hidden = NO;
            
            self.callOrHangupBtn.hidden = NO;
            self.callOrHangupBtn.selected = YES;
            [self.callOrHangupBtn setBackgroundColor:[UIColor systemRedColor]];
        }
            break;
        default:
            break;
    }
}

/// 发起呼叫/挂断
- (IBAction)callOrHangupAction:(UIButton *)sender {
//    sender.selected = !sender.selected;
    if (!sender.selected) {
//        [sender setBackgroundColor:[UIColor systemRedColor]];
        if ([self.delegate respondsToSelector:@selector(startCallAction)]) {
            [self.delegate startCallAction];
        }
    }
    else {
//        [sender setBackgroundColor:[UIColor systemBlueColor]];
        if ([self.delegate respondsToSelector:@selector(hangupAciton)]) {
            [self.delegate hangupAciton];
        }
    }
}

/// 接听
- (IBAction)accpetCall:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(acceptAction)]) {
        [self.delegate acceptAction];
    }
}

/// 拒绝
- (IBAction)rejectCall:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(rejectAction)]) {
        [self.delegate rejectAction];
    }
}

- (IBAction)clickButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setBackgroundColor:[UIColor systemBlueColor]];
    }
    else {
        [sender setBackgroundColor:[UIColor whiteColor]];
    }
    if ([self.delegate respondsToSelector:@selector(controlActionWithType:selected:)]) {
        NSInteger eventType = sender.tag - 500;
        [self.delegate controlActionWithType:eventType selected:sender.selected];
    }
}

- (void)updateWithDuration:(NSTimeInterval)duration {
    long sec = ceil(([[NSDate date] timeIntervalSince1970] - duration));
    dispatch_async(dispatch_get_main_queue(), ^{
        if (sec < 60 * 60) {
            self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", sec / 60, sec % 60];
        }
        else {
            self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", sec / 60 / 60, (sec / 60) % 60, sec % 60];
        }
    });
}



@end
