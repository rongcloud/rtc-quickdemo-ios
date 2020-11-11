//
//  BroadcasterViewController.h
//  ios-live-quick-start
//
//  Created by huan xu on 2020/10/30.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RCRTCRoleType) {
    /*!
     合流布局模式观众
     */
    RCRTCAudienceType = 0,
    /*!
     无延迟模式观众
     */
    RCRTCAudienceNodelayType = 1,
    /*!
     主播
     */
    RCRTCBroadcasterType = 2
};


@interface BroadcasterViewController : UIViewController
/* 创建房间需要的id**/
@property (nonatomic, copy)NSString *roomId;
/*
 只会存在 RCRTCAudienceNodelayType & RCRTCBroadcasterType 两种模式
 */
@property (nonatomic, assign)RCRTCRoleType role;
@end

NS_ASSUME_NONNULL_END
