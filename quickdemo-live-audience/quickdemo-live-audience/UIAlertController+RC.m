//
//  UIAlertController+RC.m
//  quickdemo-live-audience
//
//  Created by RongCloud on 2020/10/29.
//  Copyright © 2020 RongCloud. All rights reserved.
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
