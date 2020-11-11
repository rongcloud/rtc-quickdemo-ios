//
//  UIAlertController+RC.h
//  ios-live-quick-start
//
//  Created by huan xu on 2020/11/6.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (RC)

+ (void)alertWithString:(NSString *)string inCurrentVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
