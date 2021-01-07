//
//  RCMenuView.h
//  quickdemo-live-broadcaster
//
//  Created by huan xu on 2021/1/4.
//  Copyright © 2021 huan xu. All rights reserved.
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
- (void)sendLiveUrl;

@end

@interface RCMenuView : UIView

@property (nonatomic, weak)id<RCMenuViewEventDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *liveUrlLabel;

@end

NS_ASSUME_NONNULL_END
