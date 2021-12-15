//
//  RCRTCPKView.h
//  RCRTCQuickDemo
//
//  Created by huan xu on 2021/12/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PKViewBtnEventDelegate <NSObject>

- (void)pk_inviteWithRoomId:(NSString *)roomId userId:(NSString *)userId autoMix:(BOOL)autoMix;
- (void)pk_cancelWithRoomId:(NSString *)roomId userId:(NSString *)userId;
- (void)pk_joinOtherRoom:(NSString *)roomId;
- (void)pk_leaveOtherRoom:(NSString *)roomId;

@end

@interface RCRTCPKView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<PKViewBtnEventDelegate> delegate;

@property (nonatomic, readonly) BOOL isShowing;

- (void)showOnSuperView:(UIView *)superView;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
