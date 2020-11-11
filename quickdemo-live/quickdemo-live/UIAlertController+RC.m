//
//  UIAlertController+RC.m
//  ios-live-quick-start
//
//  Created by huan xu on 2020/11/6.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import "UIAlertController+RC.h"

@implementation UIAlertController (RC)
+ (void)alertWithString:(NSString *)string inCurrentVC:(UIViewController *)vc{
    if (!string.length) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        if (vc) {
            [vc presentViewController:alert animated:YES completion:nil];
        }else{
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];            
        }
    });
}
@end
