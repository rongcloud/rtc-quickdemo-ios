//
//  BeautyMenusButton.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/2.
//

#import <UIKit/UIKit.h>
#import "BeautyMenusViewParam.h"

NS_ASSUME_NONNULL_BEGIN

@class BeautyMenusButton;

@protocol BeautyMenusButtonDelegale <NSObject>

- (void)beautyMenusButtonDidClick:(BeautyMenusButton *)sender;

@end

@interface BeautyMenusButton : UIView

@property (nonatomic, weak) id<BeautyMenusButtonDelegale> delegate;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger value;

- (void)setImage:(UIImage *)image forState:(UIControlState)state;

@property (nonatomic, assign) BeautyMenusType type;

@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
