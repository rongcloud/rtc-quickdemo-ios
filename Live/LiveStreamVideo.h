//
//  LiveStreamVideo.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 用户 userId ,流 streamId 标识唯一的 LiveStreamVideo 对象
 */
@interface LiveStreamVideo : NSObject

@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *streamId;

/**
 * 包含子类的 RCRTCLocalVideoView 和 RCRTCRemoteVideoView
 */
@property (nonatomic, strong)RCRTCVideoPreviewView *canvesView;

/**
 * RCRTCRemoteVideoView 初始化
 * @param uid 用户id
 */
- (instancetype)initWithUid:(NSString *)uid withStreamId:(NSString *)stream;

/**
 * 本地 RCRTCLocalVideoView 初始化
 */
+ (instancetype)LocalStreamVideo;

@end

NS_ASSUME_NONNULL_END
