//
//  BeautyMenusContentView.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/2.
//

#import <UIKit/UIKit.h>
#import "BeautyMenusViewParam.h"

NS_ASSUME_NONNULL_BEGIN

@class BeautyMenusContentView;

@protocol BeautyMenusContentViewDelegate <NSObject>

- (void)beautyMenusContentViewDidChangedBeauty:(BeautyMenusType)type
                                         value:(NSInteger)value
                                   buttonIndex:(NSInteger)index;

@end

@interface BeautyMenusContentView : UIView

+ (instancetype)initFromXIB;

@property (nonatomic, weak) id<BeautyMenusContentViewDelegate> delegate;

- (void)setupParams:(NSArray<BeautyMenusViewParam *> *)arrParams;
- (void)resetSelectedItem;

- (void)setBeautyOn:(BOOL)isOn
             params:(nullable NSArray<BeautyMenusViewParam *> *)arrParams
         needLayout:(BOOL)isNeedLayout;

@end

NS_ASSUME_NONNULL_END
