1. 初始化 SDK 并连接融云服务器。可以参考 `/RCRTCQuickDemo/Home/LoginViewController.m`中的方法，通过 AppKey 与 token 并连接融云服务器。

2. 请先确保初始化该单例 '[RCCall sharedRCCall]'，只有初始化该单例才能进行拨打电话，接听来电等操作。

3. 申请音频通话。
'''
// 音频通话
[[RCCall sharedRCCall] startSingleCall:self.useridTextField.text mediaType:RCCallMediaAudio];
'''

4. 申请视频通话。
'''
// 视频通话
[[RCCall sharedRCCall] startSingleCall:self.useridTextField.text mediaType:RCCallMediaVideo];
'''
5. 后台接听来电需要在 'AppDelegate.m' 里注册本地通知，可参考该 Demo 内的实现。
'''
// 注册通知，接收接听来电
- (void)registerAPN {
    // iOS10 以上
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
    } else {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
}
'''