//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface StreamVideo : NSObject

@property (nonatomic, copy)NSString *userId;

/// 包含子类的 RCRTCLocalVideoView 和 RCRTCRemoteVideoView
@property (nonatomic, strong)RCRTCVideoPreviewView *canvesView;

/// RCRTCRemoteVideoView 初始化
/// @param uid 用户id
- (instancetype)initWithUid:(NSString *)uid;

/// 本地 RCRTCLocalVideoView 初始化
+ (instancetype)LocalStreamVideo;

@end

NS_ASSUME_NONNULL_END
