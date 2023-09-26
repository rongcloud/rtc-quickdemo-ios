//
//  CallPlusControlView.h
//  RCRTCQuickDemo
//
//  Created by huan xu on 2023/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 当前 UI 的几种状态
 */
typedef NS_ENUM(NSInteger, RCRTCCallStatus) {
    /// 默认，可呼叫状态
    RCRTCCallStatus_Normal = 0,
    /// 正在呼入
    RCRTCCallStatus_Incoming = 1,
    /// 正在呼出
    RCRTCCallStatus_Dialing = 2,
    /// 通话中
    RCRTCCallStatus_Active = 3
};


@protocol CallPlusEventDelegate <NSObject>

- (void)controlActionWithType:(NSInteger)eventType
                     selected:(BOOL)selected;

- (void)startCallAction;

- (void)hangupAciton;

- (void)acceptAction;

- (void)rejectAction;

@end

@interface CallPlusControlView : UIView

- (void)setDelegate:(id<CallPlusEventDelegate>)delegate;

- (void)updateUIWithStatus:(RCRTCCallStatus)status;

- (void)updateWithDuration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
