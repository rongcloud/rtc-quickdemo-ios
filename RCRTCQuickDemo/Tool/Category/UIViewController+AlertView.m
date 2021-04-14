//
//  UIViewController+AlertView.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/14.
//

#import "UIViewController+AlertView.h"

@implementation UIViewController (AlertView)


- (void)showAlertView:(NSString *)alertString{
    
    if (!alertString.length) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:nil message:alertString preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end
