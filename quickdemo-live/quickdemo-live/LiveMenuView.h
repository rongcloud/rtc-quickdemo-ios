//
//  LiveMenuView.h
//  ios-live-quick-start
//
//  Created by huan xu on 2020/11/6.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RCRTCMixConfig.h>

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveMenuContrlEventDelegate <NSObject>

@optional
- (void)exitRoom;
- (void)microphoneIsMute:(BOOL)isMute;
- (void)changeCamera;
- (void)changeRole:(UIButton *)btn;
- (void)streamlayoutMode:(RCRTCMixLayoutMode)mode;

@end

@interface LiveMenuView : UIView
@property (nonatomic, weak)id <LiveMenuContrlEventDelegate> delegate;

/*
 角色区分
 0:合流布局模式观众
 1:无延迟模式观众
 2:正常主播
 */
@property (nonatomic, assign)NSInteger roleType;

+ (instancetype)MenuViewWithRoleType:(NSInteger)roleType roomId:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END
