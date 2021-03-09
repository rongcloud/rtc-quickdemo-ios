//
//  RCMenuView.h
//  quickdemo-live
//
//  Created by RongCloud on 2020/10/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RCRTCMixConfig.h>

typedef NS_ENUM (NSInteger, RCRTCRoleType) {
    RCRTCRoleTypeUnknown  = 0, //未确定身份
    RCRTCRoleTypeAudience = 1, //观众
    RCRTCRoleTypeHost     = 2, //主播
};

NS_ASSUME_NONNULL_BEGIN

@protocol RCMenuViewEventDelegate <NSObject>

- (void)loginIMWithIndex:(NSInteger)index;
- (void)logout;
- (void)startLiveWithState:(BOOL)isSelected;
- (void)watchLiveWithState:(BOOL)isSelected;
- (void)connectHostWithState:(BOOL)isConnect;
- (void)cameraEnable:(BOOL)enable;
- (void)micDisable:(BOOL)disable;
- (void)streamLayout:(RCRTCMixLayoutMode)mode;

/// 切换大小流
/// @param type  1:小流, 默认是 0:大流
@optional
- (void)subscribeType:(NSInteger)type;

@optional
- (void)switchCamera;

@end

@interface RCMenuView : UIView

@property (nonatomic, weak)id<RCMenuViewEventDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
