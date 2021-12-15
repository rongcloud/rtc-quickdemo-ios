//
//  RCRTCPKView.m
//  RCRTCQuickDemo
//
//  Created by huan xu on 2021/12/13.
//

#import "RCRTCPKView.h"
#import "UIView+Extension.h"

static NSString *const kLastOtherRoomId = @"kLastOtherRoomId";
static NSString *const kLastOtherUserId = @"kLastOtherUserId";
static NSString *const kLastAutoMix = @"kLastAutoMix";

@interface RCRTCPKView ()

@property (nonatomic, strong) UITextField *userIdTextField;
@property (nonatomic, strong) UITextField *roomIdTextField;

@property (nonatomic, strong) UIButton *inviteBtn;
@property (nonatomic, strong) UIButton *cancelInviteBtn;

@property (nonatomic, strong) UIButton *autoMixBtn;

@property (nonatomic, strong) UIButton *joinBtn;
@property (nonatomic, strong) UIButton *leaveBtn;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) BOOL isShowing;
@end

@implementation RCRTCPKView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self setupUI];
    }
    return self;
}

- (void)clickAction:(UIButton *)btn{
    
    NSString *roomId = self.roomIdTextField.text;
    NSString *userId = self.userIdTextField.text;
    
    if (roomId.length) {
        [[NSUserDefaults standardUserDefaults] setObject:roomId forKey:kLastOtherRoomId];
    }
    if (userId.length) {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kLastOtherUserId];
    }

    if (btn == self.inviteBtn) {
        if ([self.delegate respondsToSelector:@selector(pk_inviteWithRoomId:userId:autoMix:)]) {
            [self.delegate pk_inviteWithRoomId:roomId userId:userId autoMix:self.autoMixBtn.selected];
            return;
        }
    }
    
    if (btn == self.cancelInviteBtn) {
        if ([self.delegate respondsToSelector:@selector(pk_cancelWithRoomId:userId:)]) {
            [self.delegate pk_cancelWithRoomId:roomId userId:userId];
            return;
        }
    }
    
    if (btn == self.autoMixBtn) {
        btn.selected = !btn.selected;
        [[NSUserDefaults standardUserDefaults] setBool:btn.selected forKey:kLastAutoMix];
    }
    
    if (btn == self.joinBtn) {
        if ([self.delegate respondsToSelector:@selector(pk_joinOtherRoom:)]) {
            [self.delegate pk_joinOtherRoom:roomId];
            return;
        }
    }
    
    if (btn == self.leaveBtn) {
        if ([self.delegate respondsToSelector:@selector(pk_leaveOtherRoom:)]) {
            [self.delegate pk_leaveOtherRoom:roomId];
            return;
        }
    }
    
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height * 0.2)];
    tapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [tapView addGestureRecognizer:tap];
    [self addSubview:tapView];
    [self addSubview:self.containerView];
    [self configUI];
}

- (void)dismiss{
    [UIView animateWithDuration:0.25 animations:^{
        self.containerView.y = self.height;
        self.isShowing = NO;
    }];
    [self removeFromSuperview];
}

- (void)showOnSuperView:(UIView *)superView {
    [superView addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.containerView.y = self.height * 0.2;
        self.isShowing = YES;
    }];
}

- (void)hideKeyboard{
    [self endEditing:YES];
}

- (void)configUI{
    NSString *lastRoomId = [[NSUserDefaults standardUserDefaults] objectForKey:kLastOtherRoomId];
    NSString *lastUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kLastOtherUserId];
    BOOL autoMix = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastAutoMix] boolValue];
    
    self.roomIdTextField.text = lastRoomId;
    self.userIdTextField.text = lastUserId;
    self.autoMixBtn.selected = autoMix;
}

#pragma mark - Getter
- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height , self.width, self.height * 0.8)];
        _containerView.backgroundColor = [UIColor whiteColor];
    
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [_containerView addGestureRecognizer:tap];
        
        UIButton *closeBtn = [UIButton buttonWithType:0];
        [closeBtn setTitle:@"关闭" forState:0];
        [closeBtn setTitleColor:[UIColor grayColor] forState:0];
        [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_containerView addSubview:closeBtn];
        [_containerView addSubview:self.userIdTextField];
        [_containerView addSubview:self.roomIdTextField];
        
        [_containerView addSubview:self.autoMixBtn];
        
        [_containerView addSubview:self.inviteBtn];
        [_containerView addSubview:self.cancelInviteBtn];
        
        [_containerView addSubview:self.joinBtn];
        [_containerView addSubview:self.leaveBtn];
        
        closeBtn.frame = CGRectMake(self.width - 75, 10, 60, 40);
        self.userIdTextField.frame = CGRectMake(15, closeBtn.bottom + 15, self.width - 30, 40);
        self.roomIdTextField.frame = CGRectMake(15, self.userIdTextField.bottom + 15, self.width - 30, 40);
        
        self.autoMixBtn.frame = CGRectMake(0, self.roomIdTextField.bottom + 10, 100, 40);
        self.autoMixBtn.centerX = self.centerX;
        
        self.inviteBtn.frame = CGRectMake(15, self.autoMixBtn.bottom + 15, self.width - 30, 40);
        self.cancelInviteBtn.frame = CGRectMake(15, self.inviteBtn.bottom + 15, self.width - 30, 40);
        self.joinBtn.frame = CGRectMake(15, self.cancelInviteBtn.bottom + 15, self.width - 30, 40);
        self.leaveBtn.frame = CGRectMake(15, self.joinBtn.bottom + 15, self.width - 30, 40);
    }
    return _containerView;
}

- (UITextField *)userIdTextField{
    if (!_userIdTextField) {
        _userIdTextField = [[UITextField alloc] init];
        _userIdTextField.placeholder = @" User Id";
        _userIdTextField.layer.borderWidth = 0.7;
        _userIdTextField.layer.cornerRadius = 5;
        _userIdTextField.font = [UIFont systemFontOfSize:15];
        _userIdTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _userIdTextField;
}

- (UITextField *)roomIdTextField{
    if (!_roomIdTextField) {
        _roomIdTextField = [[UITextField alloc] init];
        _roomIdTextField.placeholder = @" Room Id";
        _roomIdTextField.layer.borderWidth = 0.7;
        _roomIdTextField.layer.cornerRadius = 5;
        _roomIdTextField.font = [UIFont systemFontOfSize:15];
        _roomIdTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _roomIdTextField;
}

- (UIButton *)inviteBtn{
    if (!_inviteBtn) {
        _inviteBtn = [UIButton buttonWithType:0];
        _inviteBtn.backgroundColor = [UIColor systemBlueColor];
        [_inviteBtn setTitle:@"开始邀请" forState:0];
        [_inviteBtn setTitleColor:[UIColor whiteColor] forState:0];
        [_inviteBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inviteBtn;
}

- (UIButton *)cancelInviteBtn{
    if (!_cancelInviteBtn) {
        _cancelInviteBtn = [UIButton buttonWithType:0];
        _cancelInviteBtn.backgroundColor = [UIColor systemBlueColor];
        [_cancelInviteBtn setTitle:@"取消邀请" forState:0];
        [_cancelInviteBtn setTitleColor:[UIColor whiteColor] forState:0];
        [_cancelInviteBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelInviteBtn;
}

- (UIButton *)autoMixBtn{
    if (!_autoMixBtn) {
        _autoMixBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_autoMixBtn setTitle:@" 自动合流" forState:UIControlStateNormal];
        [_autoMixBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_autoMixBtn setImage:[UIImage imageNamed:@"btn_uncheck"] forState:UIControlStateNormal];
        [_autoMixBtn setImage:[UIImage imageNamed:@"btn_check"] forState:UIControlStateSelected];
        _autoMixBtn.selected = YES;
        _autoMixBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_autoMixBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoMixBtn;
}

- (UIButton *)joinBtn{
    if (!_joinBtn) {
        _joinBtn = [UIButton buttonWithType:0];
        _joinBtn.backgroundColor = [UIColor systemBlueColor];
        [_joinBtn setTitle:@"加入副房间" forState:0];
        [_joinBtn setTitleColor:[UIColor whiteColor] forState:0];
        [_joinBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _joinBtn;
}

- (UIButton *)leaveBtn{
    if (!_leaveBtn) {
        _leaveBtn = [UIButton buttonWithType:0];
        _leaveBtn.backgroundColor = [UIColor systemBlueColor];
        [_leaveBtn setTitle:@"离开副房间" forState:0];
        [_leaveBtn setTitleColor:[UIColor whiteColor] forState:0];
        [_leaveBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leaveBtn;
}


@end
