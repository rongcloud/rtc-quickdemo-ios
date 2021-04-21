//
//  LiveViewController.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveViewController : UIViewController

/**
 * 加入的房间 ID
 */
@property(nonatomic, strong) NSString *roomId;

/**
 *身份状态 主播/观众
 */
@property(nonatomic, assign) RCRTCLiveRoleType liveRoleType;

@end

NS_ASSUME_NONNULL_END
