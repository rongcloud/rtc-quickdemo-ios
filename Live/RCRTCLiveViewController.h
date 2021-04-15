//
//  RCRTCLiveViewController.h
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/14.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCLiveViewController : UIViewController

/**
 * 加入的房间 ID
 */
@property(nonatomic, strong) NSString *roomId;

@property(nonatomic, assign) RCRTCLiveRoleType liveRoleType;

@end

NS_ASSUME_NONNULL_END
