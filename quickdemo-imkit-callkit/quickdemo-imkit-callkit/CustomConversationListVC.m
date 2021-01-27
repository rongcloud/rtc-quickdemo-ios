//
//  ConversationListVC.m
//  ImKitDemo
//
//  Created by RongCloud on 2021/1/25.
//会话列表

#import "CustomConversationListVC.h"
#import "UIViewController+SelectUser.h"
#import "CustomConversationViewController.h"
#import "AppConfig.h"

@interface CustomConversationListVC ()<RCIMUserInfoDataSource,RCIMConnectionStatusDelegate,RCIMReceiveMessageDelegate>

@end

@implementation CustomConversationListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"开启单聊" style:UIBarButtonItemStylePlain target:self action:@selector
                                        (rightBarButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //添加用户信息代理
    [RCIM sharedRCIM].userInfoDataSource = self;
    
    //设置用户信息在本地持久化存储。SDK 获取过的用户信息将保存在数据库中，即使 App 重新启动也能再次读取。
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    
    //设置状态监听
    [RCIM sharedRCIM].connectionStatusDelegate = self;
    
    //接收消息
    [RCIM sharedRCIM].receiveMessageDelegate = self;

}

- (void)rightBarButtonItemPressed:(id)sender {
    [self connectWithoutUserid:self.loginId handle:^(NSString *uid, NSString *uToken) {
        CustomConversationViewController *conversationVC = [[CustomConversationViewController alloc] init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        conversationVC.targetId = uid;
        [self.navigationController pushViewController:conversationVC animated:YES];
    }];
}
/*
 在 CustomConversationListViewController 中重写 RCConversationListViewController 的 onSelectedTableRow 事件并传入 conversationType 和 targetId，即可点击进入聊天会话界面
 */
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath {

    CustomConversationViewController *conversationVC = [[CustomConversationViewController alloc] initWithConversationType:model.conversationType targetId:model.targetId];
    //会话标题
    conversationVC.title = [NSString stringWithFormat:@"%@",model.targetId];
    [self.navigationController pushViewController:conversationVC animated:YES];
}

#pragma mark- 🌺RCIMUserInfoDataSource
// 实现用户信息提供者的代理函数
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    //开发者需要将 userId 对应的用户信息返回，下列仅为示例
    //实际项目中，开发者有可能需要到 App Server 获取 userId 对应的用户信息，再通过 completion 返回给 SDK。
    NSArray *fileUsers = [self readFileUsers];
    if (fileUsers && fileUsers.count > 0) {
        for (NSDictionary *user in fileUsers) {
            NSString *uid = user[@"userid"];
            if ([self.loginId isEqualToString:uid]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = user[@"username"];
                });
            }
            if (uid && [userId isEqualToString:uid]) {
                RCUserInfo *userInfo = [[RCUserInfo alloc] initWithUserId:uid name:user[@"username"] portrait:user[@"useravatar"]];
                if (completion) {
                    completion(userInfo);
                }
                return;
            }
        }
    }
}

#pragma mark-  🌺RCIMConnectionStatusDelegate
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{

}

#pragma mark-  🌺RCIMReceiveMessageDelegate
//通过此方法可以获取到每条消息，left 会依次递减直到 0。开发者可以根据 left 数量来优化 App 体验和性能，比如收到大量消息时等待 left 为 0 再刷新 UI。
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {

}
@end
