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

@property (weak, nonatomic) IBOutlet UIButton *joinRoomBtn;
@property (weak, nonatomic) IBOutlet UIButton *wacthLiveBtn;
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

- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super initWithCoder:coder]) {
        
    }
    return self;
}

- (IBAction)userLogin:(UIButton *)sender {
    [self updateButtonstate:sender.tag];
    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(loginIMWithIndex:)]) {
        [self.delegate loginIMWithIndex:sender.tag];
    }
}

- (IBAction)joinRoomAction:(UIButton *)sender{
    NSLog(@"%@",sender.titleLabel.text);
    sender.selected = !sender.selected;
    if (sender.selected) {
        if ([self.delegate respondsToSelector:@selector(startLive:)]) {
            self.roleType = RCRTCRoleTypeHost;
            [self.delegate startLive:self.roleType];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(startLive:)]) {
            self.roleType = RCRTCRoleTypeAudience;
            [self.delegate startLive:self.roleType];
        }
    }
}
- (IBAction)watchLiveAction:(UIButton *)sender{
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(watchLive)]) {
        self.roleType = RCRTCRoleTypeAudience;
        [self.delegate watchLive];
    }
}
- (IBAction)closeCameraAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(cameraEnable:)]) {
        [self.delegate cameraEnable:!sender.selected];
    }
}
- (IBAction)closeMicAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(micDisable:)]) {
        [self.delegate micDisable:sender.selected];
    }
}


- (IBAction)streamLayutAction:(UIButton *)sender{
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
    NSLog(@"%@",sender.titleLabel.text);
    if ([self.delegate respondsToSelector:@selector(sendLiveUrl)]) {
        [self.delegate sendLiveUrl];
    }
}

- (void)setRoleType:(RCRTCRoleType)roleType{
    _roleType = roleType;
    if (_roleType == RCRTCRoleTypeHost) {
        [self disableClickWith:@[self.wacthLiveBtn]];
    }else if (_roleType == RCRTCRoleTypeAudience){
        [self disableClickWith:@[self.closeCamera,self.closeMicBtn,self.streamLayoutBtn,self.sendMsgBtn]];
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

- (void)updateButtonstate:(NSInteger)tag{
    self.userBtns = @[
        self.userBtn_A,
        self.userBtn_B,
        self.userBtn_C,
        self.userBtn_D];
    self.funcBtns = @[
        self.joinRoomBtn,
        self.wacthLiveBtn,
        self.closeCamera,
        self.closeMicBtn,
        self.streamLayoutBtn,
        self.sendMsgBtn];
    for (UIButton *btn in self.userBtns) {
        btn.enabled = NO;
        if (btn.tag != tag) {
            btn.backgroundColor = [UIColor grayColor];
        }
    }
}

- (void)layoutSubviews{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:UIButton.class]) {
            UIButton *btn = (UIButton *)subView;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        }
    }
}




@end
