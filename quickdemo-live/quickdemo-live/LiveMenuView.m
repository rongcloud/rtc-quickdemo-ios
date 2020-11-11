//
//  LiveMenuView.m
//  ios-live-quick-start
//
//  Created by huan xu on 2020/11/6.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import "LiveMenuView.h"
#import <Masonry/Masonry.h>

@interface LiveMenuView()
@property (nonatomic, copy)NSString *title;
@end

@implementation LiveMenuView
{
    UIButton *_closeBtn;
    UIButton *_micMuteBtn;
    UIButton *_cameraBtn;
    UIButton *_layoutModeBtn;
    UIButton *_changeRoleBtn;
}

+ (instancetype)MenuViewWithRoleType:(NSInteger)roleType roomId:(NSString *)roomId{
    LiveMenuView *view = [[self alloc] initWithTitle:roomId];
    view.roleType = roleType;
    return view;
}

- (instancetype)initWithTitle:(NSString *)title{
    if (self = [super init]) {
        self.title = title;
        [self setupSubviews];
    }
    return self;
}

- (void)setRoleType:(NSInteger)roleType{
    /*
     角色区分
     0:合流布局模式观众
     1:无延迟模式观众
     2:正常主播
     */
    _roleType = roleType;
    switch (_roleType) {
        case 0:
        {
            _micMuteBtn.hidden = YES;
            _cameraBtn.hidden = YES;
            _changeRoleBtn.hidden = YES;
            _layoutModeBtn.hidden = YES;
        }
            break;
        case 1:
        {
            _micMuteBtn.hidden = YES;
            _cameraBtn.hidden = YES;
            _changeRoleBtn.hidden = NO;
            _layoutModeBtn.hidden = YES;
        }
            break;
        case 2:
        {
            _micMuteBtn.hidden = NO;
            _cameraBtn.hidden = NO;
            _changeRoleBtn.hidden = NO;
            _layoutModeBtn.hidden = NO;
        }
            break;
        default:
            break;
    }
}


- (void)btnClick:(UIButton *)btn{
    if (btn == _closeBtn) {
        [self.delegate exitRoom];
    }else if (btn == _micMuteBtn){
        btn.selected = !btn.selected;
        [self.delegate microphoneIsMute:btn.selected];
    }else if (btn == _cameraBtn){
        btn.selected = !btn.selected;
        [self.delegate changeCamera];
    }else if (btn == _changeRoleBtn){
        [self.delegate changeRole:btn];
    }else if (btn == _layoutModeBtn){
        if (btn.tag >= 3) {
            btn.tag = RCRTCMixLayoutModeCustom;
        }else{
            btn.tag ++;
        }
        [self _layoutStyleWtihBtn:btn];
        [self.delegate streamlayoutMode:btn.tag];
    }
}

- (void)_layoutStyleWtihBtn:(UIButton *)btn{
    switch (btn.tag) {
        case RCRTCMixLayoutModeCustom:
            [btn setTitle:@"自定义" forState:UIControlStateNormal];
            break;
        case  RCRTCMixLayoutModeSuspension:
            [btn setTitle:@"悬浮" forState:UIControlStateNormal];
            break;
        case RCRTCMixLayoutModeAdaptive:
            [btn setTitle:@"自适应" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [btn.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.mas_equalTo(0);
        make.size.mas_offset(CGSizeMake(20, 20));
    }];
}


- (void)setupSubviews{
    UIButton *closeBtn = [UIButton buttonWithType:0];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:0];
    [closeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = self.title;
    titleLabel.textColor = [UIColor whiteColor];
    
    UIButton *micMuteBtn = [UIButton buttonWithType:0];
    [micMuteBtn setImage:[UIImage imageNamed:@"mute"] forState:0];
    [micMuteBtn setImage:[UIImage imageNamed:@"mute_hover"] forState:UIControlStateSelected];
    [micMuteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *cameraBtn = [UIButton buttonWithType:0];
    [cameraBtn setImage:[UIImage imageNamed:@"camera"] forState:0];
    [cameraBtn setImage:[UIImage imageNamed:@"camera_hover"] forState:UIControlStateSelected];
    [cameraBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *layoutModeBtn = [UIButton buttonWithType:0];
    [layoutModeBtn setImage:[UIImage imageNamed:@"layout_mode"] forState:0];
    layoutModeBtn.tag = RCRTCMixLayoutModeCustom;
    [self _layoutStyleWtihBtn:layoutModeBtn];
    [layoutModeBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [layoutModeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *changeRoleBtn = [UIButton buttonWithType:0];
    [changeRoleBtn setImage:[UIImage imageNamed:@"stop_video"] forState:0];
    [changeRoleBtn setImage:[UIImage imageNamed:@"stop_video_s"] forState:UIControlStateSelected];
    [changeRoleBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _closeBtn = closeBtn;
    _micMuteBtn = micMuteBtn;
    _cameraBtn = cameraBtn;
    _layoutModeBtn = layoutModeBtn;
    _changeRoleBtn = changeRoleBtn;

    [self addSubview:closeBtn];
    [self addSubview:titleLabel];
    [self addSubview:micMuteBtn];
    [self addSubview:cameraBtn];
    [self addSubview:changeRoleBtn];
    [self addSubview:layoutModeBtn];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(30);
        make.right.mas_offset(-20);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(closeBtn);
        make.centerX.mas_equalTo(0);
    }];
    [micMuteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-20);
        make.left.mas_offset(20);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-20);
        make.left.equalTo(micMuteBtn.mas_right).offset(20);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    [changeRoleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-20);
        make.right.mas_offset(-20);
        make.size.mas_offset(CGSizeMake(40, 40));
    }];
    [layoutModeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(changeRoleBtn.mas_top).offset(-20);
        make.right.equalTo(changeRoleBtn.mas_right);
        make.height.mas_offset(20);
    }];
}


@end
