//
//  UIAlertController+RCRTC.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (RCRTC)
+ (void)alertWithString:(NSString *)string inCurrentViewController:(UIViewController * _Nullable)vc;
@end

NS_ASSUME_NONNULL_END
