//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LoginViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "CustomConversationListVC.h"
#import "UIViewController+SelectUser.h"

@interface LoginViewController ()
@property (nonatomic, copy) NSString *loginId;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[RCIM sharedRCIM] initWithAppKey:RCAppKey];
}

- (IBAction)loginAction:(id)sender {
    [self selectUserLoginHandle:^(NSString *uid, NSString *uToken) {
        self.loginId = uid;
        [self connectWithToken:uToken];
    }];
}

- (void)connectWithToken:(NSString *)token {
    [[RCIM sharedRCIM] connectWithToken:token
                               dbOpened:^(RCDBErrorCode code) {}
                                success:^(NSString *userId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initRootController];
        });
    } error:^(RCConnectErrorCode status) {}];
}

- (void)initRootController {
    CustomConversationListVC *vc = [[CustomConversationListVC alloc] initWithDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)] collectionConversationType:@[@(ConversationType_SYSTEM)]];
    vc.loginId = self.loginId;
    vc.title = @"会话列表";
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:vc];
    [UIApplication sharedApplication].keyWindow.rootViewController = homeNav;
    [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
}

@end
