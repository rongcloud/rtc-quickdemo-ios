//
//  BeautyMenusView.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/1.
//

#import <UIKit/UIKit.h>
#import "BeautyMenusViewParam.h"

NS_ASSUME_NONNULL_BEGIN

@class BeautyMenusView;

@protocol BeautyMenusViewDelegate <NSObject>

- (void)beautyMenusView:(BeautyMenusView *)beautyMenusView
             didChanged:(BeautyMenusType)type
                  value:(NSInteger)value;
    
- (void)beautyMenusView:(BeautyMenusView *)beautyMenusView
       didChangedParams:(nullable NSArray<BeautyMenusViewParam *> *)params;

@end

@interface BeautyMenusView : UIView

@property (nonatomic, weak) id<BeautyMenusViewDelegate> delegate;

- (void)showWithViewController:(UIViewController *)viewController;

- (void)dismiss;

@property (nonatomic, readonly) BOOL isShowing;

@end

NS_ASSUME_NONNULL_END
