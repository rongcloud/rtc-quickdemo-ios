//
//  BeautyMenusButton.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/2.
//

#import "BeautyMenusButton.h"

@interface BeautyMenusButton()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIImage *imgNormal;
@property (nonatomic, strong) UIImage *imgSelected;

@end

@implementation BeautyMenusButton

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

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    _label.text = _title;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (state == UIControlStateNormal) {
        self.imgNormal = image;
    } else {
        self.imgSelected = image;
    }
}

- (IBAction)clickButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(beautyMenusButtonDidClick:)]) {
        [self.delegate beautyMenusButtonDidClick:self];
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _label.textColor = selected ? self.selectedColor : [UIColor whiteColor];
    _imageView.image = selected ? self.imgSelected : self.imgNormal;
}

- (UIColor *)selectedColor {
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:252/255.0 green:92/255.0 blue:39/255.0 alpha:1];
    }
    return _selectedColor;
}


@end
