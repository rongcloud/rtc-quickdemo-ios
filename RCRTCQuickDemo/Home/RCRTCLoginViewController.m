//
//  RCRTCLoginViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/7.
//

#import "RCRTCLoginViewController.h"
#import "RCRTCRequestToken.h"
#import <RongIMKit/RCIM.h>
#import "RCRTCConstant.h"
#import "RCRTCHomeViewController.h"


@interface RCRTCLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *useridTextField;

@end

@implementation RCRTCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
     * 请求 token 值
     */
    [RCRTCRequestToken requestToken:self.useridTextField.text name:self.useridTextField.text portraitUrl:nil completionHandler:^(BOOL isSuccess, NSString * _Nonnull tokenString) {
        
        if (!isSuccess) {
            NSLog(@"请求 token 失败");
            return;
        }
        
        [self connectRongCloud:tokenString];
    }];
}

/**
 * ① 初始化 Appkey
 * ② 连接 IM
 */
- (void)connectRongCloud:(NSString *)token{

    [[RCIM sharedRCIM] initWithAppKey:AppKey];
    
    [[RCIM sharedRCIM] connectWithToken:token dbOpened:nil success:^(NSString *userId) {
        
        NSLog(@"IM连接成功,用户ID：%@",userId);
        /**
         * 回调处于子线程，需要回调到主线程进行 UI 处理。
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            RCRTCHomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RCRTCHomeViewController"];
            [self.navigationController pushViewController:homeVC animated:YES];
        });
        
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"IM连接失败 %ld",(long)errorCode);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.useridTextField resignFirstResponder];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
