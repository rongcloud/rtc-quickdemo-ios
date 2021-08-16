//
//  BeautyMeunsSliderView.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/3.
//

#import "BeautyMeunsSliderView.h"

@interface BeautyMeunsSliderView ()

@property (weak, nonatomic) IBOutlet UILabel *labValue;
@property (weak, nonatomic) IBOutlet UISlider *vSlider;

@end

@implementation BeautyMeunsSliderView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        UIView *contentView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
        contentView.frame = self.bounds;
        [self addSubview:contentView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.vSlider addTarget:self action:@selector(sliderChangeValue:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderChangeValue:(UISlider *)slider {
    NSInteger newValue = [[NSString stringWithFormat:@"%.0f",slider.value] integerValue];
    if (newValue != self.value && [self.delegate respondsToSelector:@selector(beautyMeunsSliderView:changedValue:)]) {
        [self.delegate beautyMeunsSliderView:self changedValue:newValue];
    }
    _value = newValue;
    self.labValue.text = [NSString stringWithFormat:@"%ld",(long)newValue];
}

- (void)setValue:(NSInteger)value {
    _value = value;
    self.vSlider.value = value;
    self.labValue.text = [NSString stringWithFormat:@"%ld",(long)value];
}

@end
