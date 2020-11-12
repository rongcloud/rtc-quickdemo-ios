//
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudienceViewController: UIViewController

/// 主播端创建的直播地址
@property(nonatomic, copy) NSString *liveUrl;
/// 默认 RCRTCAudienceType
@property(nonatomic, assign) NSInteger roleType;
@end

NS_ASSUME_NONNULL_END
