//
//  UIViewController+SelectUser.m
//  ImKitDemo
//
//  Created by RongCloud on 2021/1/25.
//

#import "UIViewController+SelectUser.h"
@implementation UIViewController (SelectUser)

- (void)selectUserLoginHandle:(CompleteHandle)handle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"选择登陆用户" preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *fileUsers = [self readFileUsers];
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    for (NSDictionary *user in fileUsers) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:user[@"userid"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *token = data[action.title];
            if (handle) {
                handle(action.title, token);
            }
        }];
        [data setValue:user[@"usertoken"] forKey:user[@"userid"]];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)connectWithoutUserid:(NSString *)userid handle:(CompleteHandle)handle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"选择呼叫用户" preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *fileUsers = [self readFileUsers];
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    for (NSDictionary *user in fileUsers) {
        if (![userid isEqualToString:user[@"userid"]]) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:user[@"userid"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *token = data[action.title];
                if (handle) {
                    handle(action.title, token);
                }
            }];
            [data setValue:user[@"usertoken"] forKey:user[@"userid"]];
            [alertController addAction:action];
        }
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (NSArray *)readFileUsers {
    return [self debugData];
    NSArray *fileUsers = @[@{@"userid":RCUserId1,@"usertoken":RCUserToken1,@"username":@"一号选手",@"useravatar":@"https://pics6.baidu.com/feed/f703738da9773912e78658d33157851f377ae2b2.jpeg?token=d427d6ca54e115dd7f13549cfb047168"},@{@"userid":RCUserId2,@"usertoken":RCUserToken2,@"username":@"二号选手",@"useravatar":@"https://up.enterdesk.com/edpic_source/5c/5d/4e/5c5d4eb27af795887437c292221b884c.jpg"},@{@"userid":RCUserId3,@"usertoken":RCUserToken3,@"username":@"三号选手",@"useravatar":@"https://up.enterdesk.com/edpic_source/5c/5d/4e/5c5d4eb27af795887437c292221b884c.jpg"},@{@"userid":RCUserId4,@"usertoken":RCUserToken4,@"username":@"四号选手",@"useravatar":@"https://up.enterdesk.com/edpic_source/9c/ca/a7/9ccaa7cec2564a12a08be49ea65a1c75.jpg"}];
    
    return fileUsers;
}

- (NSArray*)debugData {
    //获取Plist路径搜索Plist文件并赋值给path
    NSString *Path =[[NSBundle mainBundle] pathForResource:@"UserList.plist" ofType:nil];
    //读取文件
    NSArray *fileUsers =[NSArray arrayWithContentsOfFile:Path];
    return fileUsers;
}
@end
