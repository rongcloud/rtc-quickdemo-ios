//
//  RCMenuView.m
//  quickdemo-live-broadcaster
//
//  Created by huan xu on 2021/1/4.
//  Copyright © 2021 huan xu. All rights reserved.
//

#import "RCMenuView.h"

@interface RCMenuView()

@property (weak, nonatomic) IBOutlet UIButton *userBtn_A;
@property (weak, nonatomic) IBOutlet UIButton *userBtn_B;
@property (weak, nonatomic) IBOutlet UIButton *userBtn_C;
@property (weak, nonatomic) IBOutlet UIButton *userBtn_D;

@property (weak, nonatomic) IBOutlet UIButton *startLiveBtn;

@property (weak, nonatomic) IBOutlet UIButton *wacthLiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectHostBtn;

@property (weak, nonatomic) IBOutlet UIButton *closeCamera;
@property (weak, nonatomic) IBOutlet UIButton *closeMicBtn;

@property (weak, nonatomic) IBOutlet UIButton *streamLayoutBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;

@property (nonatomic, copy)NSArray *userBtns;
@property (nonatomic, copy)NSArray *funcBtns;
@property (nonatomic, assign)RCRTCRoleType roleType;
@property (nonatomic, assign)BOOL isLogin;

@end

@implementation RCMenuView

- (IBAction)userLogin:(UIButton *)sender {
    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    if (sender.selected) {
        [self updateLoginState:sender.tag];
        [self disableClickWith:@[self.connectHostBtn]];
        if ([self.delegate respondsToSelector:@selector(loginIMWithIndex:)]) {
            [self.delegate loginIMWithIndex:sender.tag];
        }
    }else{
        if (self.roleType != RCRTCRoleTypeUnknown) {
            sender.selected = !sender.selected;
            return;
        }
        [self resetLoginBtnState];
        [self disableClickWith:nil];
        if ([self.delegate respondsToSelector:@selector(logout)]) {
            [self.delegate logout];
        }
    }
    self.isLogin = sender.selected;
}

- (IBAction)startLiveAction:(UIButton *)sender{
    
    if (!self.isLogin) return;

    NSLog(@"%@",sender.titleLabel.text);
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(startLiveWithState:)]) {
        self.roleType = (sender.selected ? RCRTCRoleTypeHost : RCRTCRoleTypeUnknown);
        [self.delegate startLiveWithState:sender.selected];
    }
}

- (IBAction)watchLiveAction:(UIButton *)sender{
    
    if (!self.isLogin) return;
    
    NSLog(@"%@",sender.titleLabel.text);
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(watchLiveWithState:)]) {
        self.roleType = (sender.selected ? RCRTCRoleTypeAudience : RCRTCRoleTypeUnknown);
        [self.delegate watchLiveWithState:sender.selected];
    }
}

- (IBAction)connectHostAction:(UIButton *)sender {
    
    if (self.roleType != RCRTCRoleTypeAudience) return;
    
    NSLog(@"%@",sender.titleLabel.text);
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self disableClickWith:@[self.startLiveBtn,
                                 self.wacthLiveBtn]];
    }else{
        [self disableClickWith:@[self.startLiveBtn,
                                 self.closeCamera,
                                 self.closeMicBtn,
                                 self.streamLayoutBtn,
                                 self.sendMsgBtn]];
    }
    if ([self.delegate respondsToSelector:@selector(connectHostWithState:)]) {
        [self.delegate connectHostWithState:sender.selected];
    }
}


- (IBAction)closeCameraAction:(UIButton *)sender{
    
    if (self.roleType != RCRTCRoleTypeHost) return;
    
    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(cameraEnable:)]) {
        [self.delegate cameraEnable:!sender.selected];
    }
}
- (IBAction)closeMicAction:(UIButton *)sender{
    
    if (self.roleType != RCRTCRoleTypeHost) return;
    
    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(micDisable:)]) {
        [self.delegate micDisable:sender.selected];
    }
}
- (IBAction)streamLayutAction:(UIButton *)sender{
    
    if (self.roleType != RCRTCRoleTypeHost) return;
    
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(streamLayout:)]) {
        sender.tag >= 3 ? sender.tag = 1 : (sender.tag += 1);
        [self.delegate streamLayout:(RCRTCMixLayoutMode)sender.tag];
        switch (sender.tag) {
            case 1:
                [sender setTitle:@"自定义布局" forState:0];
                break;
            case 2:
                [sender setTitle:@"悬浮布局" forState:0];
                break;
            case 3:
                [sender setTitle:@"自适应布局" forState:0];
                break;
            default:
                break;
        }
    }
}

- (IBAction)sendMsgAction:(UIButton *)sender{
    
    if (self.roleType != RCRTCRoleTypeHost) return;
    
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(sendLiveUrl)]) {
        [self.delegate sendLiveUrl];
    }
}




#pragma mark - private method

- (void)setRoleType:(RCRTCRoleType)roleType{
    _roleType = roleType;
    switch (_roleType) {
        case RCRTCRoleTypeUnknown:
            [self disableClickWith:@[self.connectHostBtn]];
            break;
        case RCRTCRoleTypeHost:
            [self disableClickWith:@[self.wacthLiveBtn,
                                     self.connectHostBtn]];
            break;
        case RCRTCRoleTypeAudience:
            [self disableClickWith:@[self.startLiveBtn,
                                     self.closeCamera,
                                     self.closeMicBtn,
                                     self.streamLayoutBtn,
                                     self.sendMsgBtn]];
            break;;
        default:
            break;
    }
}

- (void)disableClickWith:(NSArray *)btns{
    for (UIButton *btn in self.funcBtns) {
        [btn setBackgroundColor:[UIColor systemBlueColor]];
        btn.enabled = YES;
    }
    for (UIButton *btn in btns) {
        [btn setBackgroundColor:[UIColor grayColor]];
        btn.enabled = NO;
    }
}

- (void)updateLoginState:(NSInteger)tag{
    self.userBtns = @[
        self.userBtn_A,
        self.userBtn_B,
        self.userBtn_C,
        self.userBtn_D];
    self.funcBtns = @[
        self.startLiveBtn,
        self.wacthLiveBtn,
        self.connectHostBtn,
        self.closeCamera,
        self.closeMicBtn,
        self.streamLayoutBtn,
        self.sendMsgBtn];
    for (UIButton *btn in self.userBtns) {
        if (btn.tag != tag) {
            btn.backgroundColor = [UIColor grayColor];
            btn.enabled = NO;
        }
    }
}

- (void)resetLoginBtnState{
    for (UIButton *btn in self.userBtns) {
        btn.backgroundColor = [UIColor systemBlueColor];
        btn.enabled = YES;
    }
}


- (void)layoutSubviews{
    self.liveUrlLabel.layer.borderColor = [UIColor grayColor].CGColor;
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:UIButton.class]) {
            UIButton *btn = (UIButton *)subView;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        }
    }
}




@end
