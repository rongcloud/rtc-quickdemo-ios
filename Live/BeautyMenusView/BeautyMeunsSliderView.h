//
//  BeautyMeunsSliderView.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BeautyMeunsSliderView;

@protocol BeautyMeunsSliderViewDelegate <NSObject>

- (void)beautyMeunsSliderView:(BeautyMeunsSliderView *)vSlider changedValue:(NSInteger)value;

@end

@interface BeautyMeunsSliderView : UIView

@property (nonatomic, weak) id<BeautyMeunsSliderViewDelegate> delegate;

@property (nonatomic, assign) NSInteger value;

@end

NS_ASSUME_NONNULL_END
