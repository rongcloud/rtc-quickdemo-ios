//
//  UIAlertController+RCRTC.h
//  RCRTCQuickDemo
//
//  Created by apple on 2021/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (RCRTC)
+ (void)alertWithString:(NSString *)string inCurrentVC:(UIViewController * _Nullable)vc;
@end

NS_ASSUME_NONNULL_END
