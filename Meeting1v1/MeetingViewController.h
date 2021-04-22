//
//  MeetingViewController.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetingViewController : UIViewController

/**
 *  输入的房间 id
 */
@property (nonatomic, strong) NSString *roomId;

/**
 * 是否开启自定义加密
 */
@property (nonatomic, assign) BOOL enableCryptho;

@end

NS_ASSUME_NONNULL_END
