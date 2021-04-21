//
//  RCRTCLoginViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LoginViewController.h"
#import "RequestToken.h"
#import "Constant.h"
#import "HomeViewController.h"

#import <RongIMKit/RCIM.h>

/**
 * 登录页面，用来处理 IM 登录逻辑
 *
 * - 请求 Token
 * - 初始化 Appkey
 * - 连接 IM
 */
@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *useridTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 * 点击连接 IM 服务
 */
- (IBAction)connectIMServer:(UIButton *)sender {
    
    if (!self.useridTextField.text ||self.useridTextField.text.length == 0) {
        return;
    }
    [self.useridTextField resignFirstResponder];
    
    /**
     * 获取 Token
     */
    [RequestToken requestToken:self.useridTextField.text
                               name:self.useridTextField.text
                        portraitUrl:nil
                  completionHandler:^(BOOL isSuccess, NSString * _Nonnull tokenString) {
        
        if (!isSuccess) return;
        
        /**
         * 拿到 token 后去连接 IM 服务
         */
        [self connectRongCloud:tokenString];
    }];
}

/**
 * ① 初始化 Appkey 并 连接 IM
 */
- (void)connectRongCloud:(NSString *)token{
    
    [[RCIM sharedRCIM] initWithAppKey:AppKey];
    
    [[RCIM sharedRCIM] connectWithToken:token dbOpened:nil success:^(NSString *userId) {
        
        NSLog(@"IM connect success,user ID : %@",userId);
        /**
         * 回调处于子线程，需要回调到主线程进行 UI 处理。
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [self.navigationController pushViewController:homeVC animated:YES];
        });
        
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"IM connect failed, error code : %ld",(long)errorCode);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.useridTextField resignFirstResponder];
}

@end
