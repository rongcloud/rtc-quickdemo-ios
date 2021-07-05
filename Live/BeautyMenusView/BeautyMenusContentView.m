//
//  BeautyMenusContentView.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/2.
//

#import "BeautyMenusContentView.h"
#import "BeautyMenusButton.h"
#import "BeautyMeunsFilterView.h"
#import "BeautyMeunsSliderView.h"

@interface BeautyMenusContentView ()<BeautyMenusButtonDelegale,BeautyMeunsFilterViewDelegale,BeautyMeunsSliderViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *vBottom;
@property (weak, nonatomic) IBOutlet BeautyMeunsFilterView *vFilter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vFilterBottomConstraint;

@property (weak, nonatomic) IBOutlet BeautyMeunsSliderView *vSlider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vSliderBottomConstraint;


@property (weak, nonatomic) IBOutlet BeautyMenusButton *btnFliter;
@property (weak, nonatomic) IBOutlet BeautyMenusButton *btnWhiteness;
@property (weak, nonatomic) IBOutlet BeautyMenusButton *btnRuddy;
@property (weak, nonatomic) IBOutlet BeautyMenusButton *btnSmooth;
@property (weak, nonatomic) IBOutlet BeautyMenusButton *btnBright;
@property (nonatomic, strong) BeautyMenusButton *btnSelected;
@property (nonatomic, strong) NSArray<BeautyMenusButton *> *buttons;

@end

@implementation BeautyMenusContentView

+ (instancetype)initFromXIB {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    if (!views || views.count == 0) {
        return nil;
    }
    return views.firstObject;
}

- (void)drawRect:(CGRect)rect {
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    CGFloat radius = 30.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, radius, 0);
    CGContextAddLineToPoint(context, width - radius,0);
    CGContextAddArc(context, width - radius, radius, radius, -0.5 *M_PI,0.0,0);
    CGContextAddLineToPoint(context, width, height - radius);
    CGContextAddArc(context, width - radius, height - radius, radius,0.0,0.5 *M_PI,0);
    CGContextAddLineToPoint(context, radius, height);
    CGContextAddArc(context, radius, height - radius, radius,0.5 *M_PI,M_PI,0);
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius,M_PI,1.5 *M_PI,0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:66/255.0 green:48/255.0 blue:252/255.0 alpha:1.0].CGColor);
    CGContextDrawPath(context,kCGPathFill);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 30.0;
    self.clipsToBounds = YES;
    
    self.vBottom.backgroundColor = [UIColor colorWithRed:66/255.0 green:48/255.0 blue:252/255.0 alpha:1.0];
    
    self.vFilter.delegate = self;
    self.vSlider.delegate = self;
    
    self.buttons = @[self.btnFliter, self.btnWhiteness, self.btnRuddy, self.btnSmooth, self.btnBright];
}

- (void)setupParams:(NSArray<BeautyMenusViewParam *> *)arrParams {
    [self.buttons enumerateObjectsUsingBlock:^(BeautyMenusButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < arrParams.count) {
            BeautyMenusViewParam *param = arrParams[idx];
            BOOL isSelected = [param.title isEqualToString:@"滤镜"];
            [self setButton:obj
                       type:param.type
                      title:param.title
                      image:param.image
              selectedImage:param.selectedImage
                      value:param.value
                      index:idx
                   selected:isSelected];
        }
    }];
}

- (void)setButton:(BeautyMenusButton *)button
             type:(BeautyMenusType)type
            title:(NSString *)title
            image:(NSString *)image
    selectedImage:(NSString *)selectedImage
            value:(NSInteger)value
            index:(NSInteger)index
         selected:(BOOL)isSelected {
    button.title = title;
    button.type = type;
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    button.delegate = self;
    button.value = value;
    button.index = index;
    button.selected = isSelected;
    if (isSelected) {
        [self resetLayoutWithSelected:button animated:NO];
    }
}

- (void)resetLayoutWithSelected:(BeautyMenusButton *)btn animated:(BOOL)animated {
    self.btnSelected.selected = NO;
    self.btnSelected = btn;
    self.btnSelected.selected = YES;
    
    NSLayoutConstraint *hideConstraint = self.vFilterBottomConstraint;
    NSLayoutConstraint *showConstraint = self.vSliderBottomConstraint;
    if (self.btnSelected == self.btnFliter) {
        hideConstraint = self.vSliderBottomConstraint;
        showConstraint = self.vFilterBottomConstraint;
        self.vFilter.currentIndex = self.btnSelected.value;
    } else {
        self.vSlider.value = self.btnSelected.value;
    }
    if (animated) {
        hideConstraint.constant = -130;
        [self setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.1 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            showConstraint.constant = 0;
            [self setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self layoutIfNeeded];
            } completion:nil];
        }];
    } else {
        hideConstraint.constant = -130;
        showConstraint.constant = 0;
    }
}

- (void)beautyMenusButtonDidClick:(BeautyMenusButton *)sender {
    if (self.btnSelected != sender) {
        [self resetLayoutWithSelected:sender animated:YES];
    }
}

- (void)beautyMeunsFilterViewDidClick:(NSInteger)index {
    self.vFilter.currentIndex = index;
    self.btnFliter.value = index;
    if ([self.delegate respondsToSelector:@selector(beautyMenusContentViewDidChangedBeauty:value:buttonIndex:)]) {
        [self.delegate beautyMenusContentViewDidChangedBeauty:BeautyMenusType_Filter value:index buttonIndex:self.btnSelected.index];
    }
}

- (void)beautyMeunsSliderView:(BeautyMeunsSliderView *)vSlider changedValue:(NSInteger)value {
    self.btnSelected.value = value;
    if ([self.delegate respondsToSelector:@selector(beautyMenusContentViewDidChangedBeauty:value:buttonIndex:)]) {
        [self.delegate beautyMenusContentViewDidChangedBeauty:self.btnSelected.type value:value buttonIndex:self.btnSelected.index];
    }
}

- (void)resetSelectedItem {
    [self resetLayoutWithSelected:self.btnFliter animated:NO];
}

- (void)setBeautyOn:(BOOL)isOn params:(nullable NSArray<BeautyMenusViewParam *> *)arrParams needLayout:(BOOL)isNeedLayout {
    if (isOn) {
        [self.buttons enumerateObjectsUsingBlock:^(BeautyMenusButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < arrParams.count) {
                BeautyMenusViewParam *param = arrParams[idx];
                obj.value = param.value;
            }
        }];
    } else {
        [self.buttons enumerateObjectsUsingBlock:^(BeautyMenusButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.title isEqualToString:@"亮度"]) {
                obj.value = 5;
            } else {
                obj.value = 0;
            }
        }];
    }
    if (isNeedLayout) {
        [self resetLayoutWithSelected:self.btnSelected animated:NO];
    }
}

@end
