//
//  ViewBuilder.h
//  quickdemo-liveAcross
//
//  Created by RongCloud on 2020/12/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewBuilder : NSObject

@property (nonatomic, strong) UIButton *user1Button, *user2Button;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *roomIdLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UIView *displayBackView;
@property (nonatomic, strong) RCRTCLocalVideoView *localVideoView;
@property (nonatomic, strong) RCRTCRemoteVideoView *remoteVideoView;

- (instancetype)initWithViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
