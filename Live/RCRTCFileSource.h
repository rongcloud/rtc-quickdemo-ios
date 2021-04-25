//
//  RCRTCFileSource.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.

//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <RongRTCLib/RongRTCLib.h>
/**
 * 发送自定义视频流设置音频与混音
 */

@protocol RCRTCFileCapturerDelegate <NSObject>

- (void)didWillStartRead;
- (void)didReadCompleted;

@end

@protocol RCRTCVideoObserverInterface;

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCFileSource : NSObject <RCRTCVideoSourceInterface>

@property (nonatomic,weak)id <RCRTCFileCapturerDelegate> delegate;

@property (nonatomic, copy, readonly)NSString *currentPath;

- (instancetype)initWithFilePath:(NSString *)filePath;

- (BOOL)stop;

@end

NS_ASSUME_NONNULL_END
