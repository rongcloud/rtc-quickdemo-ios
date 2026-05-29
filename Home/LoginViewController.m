//
//  RCRTCLoginViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LoginViewController.h"
#import "Constant.h"
#import "HomeViewController.h"

#import <RongIMLibCore/RongIMLibCore.h>

/*!
 登录页面，用来处理 IM 登录逻辑
 请求 Token
 初始化 Appkey
 连接 IM
 */
@interface LoginViewController ()

@property(nonatomic, weak) IBOutlet UITextField *appKeyTextField;
@property(nonatomic, weak) IBOutlet UITextField *tokenTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *lastAppKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastAppKey"];
    if (lastAppKey.length) {
        self.appKeyTextField.text = lastAppKey;
    } else if (AppKey.length) {
        self.appKeyTextField.text = AppKey;
    }
    if (Token.length) {
        self.tokenTextField.text = Token;
    }
}

// 点击连接 IM 服务
- (IBAction)connectIMServer:(UIButton *)sender {
    NSString *appKey = [self trimmedString:self.appKeyTextField.text];
    NSString *token = [self trimmedString:self.tokenTextField.text];
    if (appKey.length == 0 || token.length == 0) {
        return;
    }
    [self.appKeyTextField resignFirstResponder];
    [self.tokenTextField resignFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setObject:appKey forKey:@"lastAppKey"];
    // 使用客户输入的 App Key 初始化 SDK，再使用客户输入的 Token 连接 IM 服务。
    [[RCCoreClient sharedCoreClient] initWithAppKey:appKey option:nil];
    [self connectRongCloud:token];
}

// 初始化 AppKey 并连接 IM
- (void)connectRongCloud:(NSString *)token {
    [[RCCoreClient sharedCoreClient] connectWithToken:token dbOpened:nil success:^(NSString *userId) {
        NSLog(@"IM connect success,user ID : %@", userId);
        // 回调处于子线程，需要回调到主线程进行 UI 处理。
        dispatch_async(dispatch_get_main_queue(), ^{
            HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [self.navigationController pushViewController:homeVC animated:YES];
        });
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"IM connect failed, error code : %ld", (long) errorCode);
    }];
}

- (NSString *)trimmedString:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.appKeyTextField resignFirstResponder];
    [self.tokenTextField resignFirstResponder];
}

@end
