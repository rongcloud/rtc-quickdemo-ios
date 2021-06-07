//
//  BeautyMeunsFliter.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/3.
//

#import "BeautyMeunsFilterView.h"

@interface BeautyMeunsFilterView ()

@property (weak, nonatomic) IBOutlet UIView *vNone;
@property (weak, nonatomic) IBOutlet UIView *vEsthetic;
@property (weak, nonatomic) IBOutlet UIView *vFresh;
@property (weak, nonatomic) IBOutlet UIView *vRomantic;

@property (weak, nonatomic) IBOutlet UIImageView *imgNone;
@property (weak, nonatomic) IBOutlet UIImageView *imgEsthetic;
@property (weak, nonatomic) IBOutlet UIImageView *imgFresh;
@property (weak, nonatomic) IBOutlet UIImageView *imgRomantic;

@property (weak, nonatomic) IBOutlet UILabel *labNone;
@property (weak, nonatomic) IBOutlet UILabel *labEsthetic;
@property (weak, nonatomic) IBOutlet UILabel *labFresh;
@property (weak, nonatomic) IBOutlet UILabel *labRomantic;

@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) NSArray<UIView *> *arrViews;
@property (nonatomic, strong) NSArray<UILabel *> *arrLabels;

@end

@implementation BeautyMeunsFilterView

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
    
    self.imgNone.layer.cornerRadius = 15;
    self.imgEsthetic.layer.cornerRadius = 15;
    self.imgFresh.layer.cornerRadius = 15;
    self.imgRomantic.layer.cornerRadius = 15;
    
    self.imgNone.clipsToBounds = YES;
    self.imgEsthetic.clipsToBounds = YES;
    self.imgFresh.clipsToBounds = YES;
    self.imgRomantic.clipsToBounds = YES;
    
    self.vNone.layer.borderColor = self.selectedColor.CGColor;
    self.vEsthetic.layer.borderColor = [UIColor clearColor].CGColor;
    self.vFresh.layer.borderColor = [UIColor clearColor].CGColor;
    self.vRomantic.layer.borderColor = [UIColor clearColor].CGColor;
    
    self.vNone.layer.borderWidth = 1.5;
    self.vEsthetic.layer.borderWidth =  1.5;
    self.vFresh.layer.borderWidth = 1.5;
    self.vRomantic.layer.borderWidth =  1.5;
    
    self.vNone.layer.cornerRadius = 10;
    self.vEsthetic.layer.cornerRadius =  10;
    self.vFresh.layer.cornerRadius = 10;
    self.vRomantic.layer.cornerRadius =  10;
    
    self.vNone.clipsToBounds = YES;
    self.vEsthetic.clipsToBounds = YES;
    self.vFresh.clipsToBounds = YES;
    self.vRomantic.clipsToBounds = YES;
    
    self.labNone.textColor = self.selectedColor;
    
    self.arrViews = @[self.vNone, self.vEsthetic, self.vFresh, self.vRomantic];
    self.arrLabels = @[self.labNone, self.labEsthetic, self.labFresh, self.labRomantic];
}

- (IBAction)clickFilter:(UIButton *)sender {
    if (self.currentIndex != sender.tag) {
        if ([self.delegate respondsToSelector:@selector(beautyMeunsFilterViewDidClick:)]) {
            [self.delegate beautyMeunsFilterViewDidClick:sender.tag];
        }
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        self.arrViews[_currentIndex].layer.borderColor = [UIColor clearColor].CGColor;
        self.arrLabels[_currentIndex].textColor = [UIColor whiteColor];
        _currentIndex = currentIndex;
        self.arrViews[_currentIndex].layer.borderColor = self.selectedColor.CGColor;
        self.arrLabels[_currentIndex].textColor = self.selectedColor;
    }
}

- (UIColor *)selectedColor {
    if (!_selectedColor) {
        _selectedColor = [UIColor colorWithRed:252/255.0 green:92/255.0 blue:39/255.0 alpha:1];
    }
    return _selectedColor;
}

@end
