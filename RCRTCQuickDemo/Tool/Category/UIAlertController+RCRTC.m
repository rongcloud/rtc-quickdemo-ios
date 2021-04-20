//
//  UIAlertController+RCRTC.m
//  RCRTCQuickDemo
//
//  Created by apple on 2021/4/15.
//

#import "UIAlertController+RCRTC.h"

@implementation UIAlertController (RCRTC)
+ (void)alertWithString:(NSString *)string inCurrentViewController:(UIViewController *)vc{
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
