//
//  BeautyMenusView.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/1.
//

#import "BeautyMenusView.h"
#import "BeautyMenusContentView.h"

@interface BeautyMenusView()<BeautyMenusContentViewDelegate>

@property (nonatomic, strong) BeautyMenusContentView *vContent;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, strong) NSMutableArray<BeautyMenusViewParam *> *arrParams;

@property (nonatomic, strong) UIView *vBeauty;
@property (nonatomic, strong) UISwitch *switchBeauty;

@end

@implementation BeautyMenusView

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0 ? 15 : 0;
    }
    CGFloat height = 250 + bottom;
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
    if (self) {
        [self initParams];
        _vContent = [BeautyMenusContentView initFromXIB];
        _vContent.delegate = self;
        _vContent.frame = self.bounds;
        [_vContent setupParams:self.arrParams];
        [self addSubview:_vContent];
    }
    self.layer.cornerRadius = 30;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(3,-7);
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 5;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
    
    return self;
}

- (void)initParams {
    _arrParams = [NSMutableArray array];
    [_arrParams addObject: [[BeautyMenusViewParam alloc] initWithType:BeautyMenusType_Filter
                                                                value:0
                                                                title:@"滤镜"
                                                                image:@"beautyRuddise"
                                                        selectedImage:@"beautyRuddise_selected"]];
    [_arrParams addObject: [[BeautyMenusViewParam alloc] initWithType:BeautyMenusType_Whiteness
                                                                value:0
                                                                title:@"美白"
                                                                image:@"beautyRuddise"
                                                        selectedImage:@"beautyRuddise_selected"]];
    [_arrParams addObject: [[BeautyMenusViewParam alloc] initWithType:BeautyMenusType_Ruddy
                                                                value:0
                                                                title:@"红润"
                                                                image:@"beautyRuddise"
                                                        selectedImage:@"beautyRuddise_selected"]];
    [_arrParams addObject: [[BeautyMenusViewParam alloc] initWithType:BeautyMenusType_Smooth
                                                                value:0
                                                                title:@"磨皮"
                                                                image:@"beautyRuddise"
                                                        selectedImage:@"beautyRuddise_selected"]];
    [_arrParams addObject: [[BeautyMenusViewParam alloc] initWithType:BeautyMenusType_Bright
                                                                value:5
                                                                title:@"亮度"
                                                                image:@"beautyRuddise"
                                                        selectedImage:@"beautyRuddise_selected"]];
}

- (void)tap { }

- (void)showWithViewController:(UIViewController *)viewController {
    if (self.isShowing) {
        return;
    }
    
    UIView *targetView = viewController.view;
    UIView *vMask = [self createMaskViewWithFrame:targetView.bounds];
    [targetView addSubview:vMask];
    
    CGFloat targetW = CGRectGetWidth(targetView.frame);
    CGFloat targetH = CGRectGetHeight(targetView.frame);
    self.frame = CGRectMake(0, targetH, targetW, self.frame.size.height);
    [vMask addSubview:self];
    
    
    self.vBeauty.frame = CGRectMake(CGRectGetWidth(targetView.frame) - 15 - CGRectGetWidth(self.vBeauty.frame), 0, CGRectGetWidth(self.vBeauty.frame), CGRectGetHeight(self.vBeauty.frame));
    [vMask addSubview:self.vBeauty];
    
    CGFloat topH = CGRectGetHeight(viewController.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, targetH - self.frame.size.height, targetW, self.frame.size.height);
        self.vBeauty.frame = CGRectMake(CGRectGetMinX(self.vBeauty.frame), topH + 20, CGRectGetWidth(self.vBeauty.frame), CGRectGetHeight(self.vBeauty.frame));
    } completion:^(BOOL finished) {
        self.isShowing = YES;
    }];
}

- (void)dismiss {
    if (!self.isShowing) {
        return;
    }

    UIView *superView = self.superview;
    CGFloat targetW = CGRectGetWidth(superView.frame);
    CGFloat targetH = CGRectGetHeight(superView.frame);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = CGRectMake(0, targetH, targetW, self.frame.size.height);
        self.vBeauty.frame = CGRectMake(CGRectGetMinX(self.vBeauty.frame), 0, CGRectGetWidth(self.vBeauty.frame), CGRectGetHeight(self.vBeauty.frame));
    } completion:^(BOOL finished) {
        [self.vBeauty removeFromSuperview];
        [self removeFromSuperview];
        [superView removeFromSuperview];
        self.isShowing = NO;
    }];
}

- (UIView *)createMaskViewWithFrame:(CGRect)frame {
    UIView *vMask = [[UIView alloc] initWithFrame:frame];
    vMask.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView:)];
    [vMask addGestureRecognizer:tap];
    return vMask;
}

- (void)clickMaskView:(UITapGestureRecognizer *)tap {
    [self dismiss];
}

- (void)beautyMenusContentViewDidChangedBeauty:(BeautyMenusType)type
                                         value:(NSInteger)value
                                   buttonIndex:(NSInteger)index {
    _arrParams[index].value = value;
    if (self.switchBeauty.isOn) {
        if ([self.delegate respondsToSelector:@selector(beautyMenusView:didChanged:value:)]) {
            [self.delegate beautyMenusView:self didChanged:type value:value];
        }
    } else {
        self.switchBeauty.on = YES;
        [_vContent setBeautyOn:YES params:_arrParams needLayout:NO];
        if ([self.delegate respondsToSelector:@selector(beautyMenusView:didChangedParams:)]) {
            [self.delegate beautyMenusView:self didChangedParams:_arrParams];
        }
    }
}

- (void)didClickBeautySwitch:(UISwitch *)sender {
    if (sender.isOn) {
        [_vContent setBeautyOn:YES params:_arrParams needLayout:YES];
        if ([self.delegate respondsToSelector:@selector(beautyMenusView:didChangedParams:)]) {
            [self.delegate beautyMenusView:self didChangedParams:_arrParams];
        }
    } else {
        [_vContent setBeautyOn:NO params:nil needLayout:YES];
        if ([self.delegate respondsToSelector:@selector(beautyMenusView:didChangedParams:)]) {
            [self.delegate beautyMenusView:self didChangedParams:nil];
        }
    }
}

- (UIView *)vBeauty {
    if (!_vBeauty) {
        CGFloat switchW = 52, switchH = 32, space = 10;
        UILabel *labBeauty = [[UILabel alloc] init];
        labBeauty.text = @"美颜";
        labBeauty.textColor = [UIColor whiteColor];
        [labBeauty sizeToFit];
        labBeauty.frame = CGRectMake(0, (switchH - CGRectGetHeight(labBeauty.frame)) * 0.5, CGRectGetWidth(labBeauty.frame), CGRectGetHeight(labBeauty.frame));
        
        CGFloat labW = CGRectGetWidth(labBeauty.frame);
        _switchBeauty = [[UISwitch alloc] initWithFrame:CGRectMake(labW +space, 0,  switchW, switchH)];
        _switchBeauty.on = YES;
        [_switchBeauty addTarget:self action:@selector(didClickBeautySwitch:) forControlEvents:UIControlEventValueChanged];
        
        _vBeauty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labW + space + switchW, switchH)];
        _vBeauty.backgroundColor = [UIColor clearColor];
        [_vBeauty addSubview:labBeauty];
        [_vBeauty addSubview:_switchBeauty];
    }
    return _vBeauty;
}

@end
