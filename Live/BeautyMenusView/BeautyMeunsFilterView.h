//
//  BeautyMeunsFilterView.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BeautyMenusButton;

@protocol BeautyMeunsFilterViewDelegale <NSObject>

- (void)beautyMeunsFilterViewDidClick:(NSInteger)index;

@end

@interface BeautyMeunsFilterView : UIView

@property (nonatomic, weak) id<BeautyMeunsFilterViewDelegale> delegate;

@property (nonatomic, assign) NSInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
