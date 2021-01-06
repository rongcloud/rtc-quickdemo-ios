//
//  UIAlertController+RC.h
//  quickdemo-live-broadcaster
//
//  Created by RongCloud on 2020/10/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (RC)

+ (void)alertWithString:(NSString *)string inCurrentVC:(UIViewController * _Nullable)vc;

@end

NS_ASSUME_NONNULL_END
