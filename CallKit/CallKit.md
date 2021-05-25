# 配置 Demo 文件
1. 在 `pod repo update` 之后, 使用 `pod install` 安装 `podfile` 中指定好的融云 `SDK` 库。

2. `pod install` 完成后, 打开生成的 `RCRTCQuickDemo.xcworkspace`。

3. 请登录官网获取AppKey, AppSecret；找到 `/RCRTCQuickDemo/Tool/Constant/Constant.m`，将红框内的 `AppKey` 和 `AppSecret` 替换为从开发者后台获取到的具体内容，然后去掉 `#error` 提醒。

4. 修改工程 `target` 中 `RCRTCQuickDemo` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo`。

5. 修改工程 `target` 中 `ScreenShare` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo.screenshare`。

6. 修改工程 `target` 中 `RCRTCQuickDemo` 和 `ScreenShare` 的 `App Group` 配置，修改为第 4 步和第 5 步新修改的 `Bundle Identifier`。

7. 选择真机设备并编译 `RCRTCQuickDemo`。

# 流程说明
1. 初始化 SDK 并连接融云服务器。可以参考 `/RCRTCQuickDemo/Home/LoginViewController.m`中的方法，通过 AppKey 与 token 并连接融云服务器。

2. 请先确保初始化该单例 '[RCCall sharedRCCall]'，只有初始化该单例才能进行拨打电话，接听来电等操作。

3. 申请音频通话。
```objectivec
// 音频通话
[[RCCall sharedRCCall] startSingleCall:self.useridTextField.text mediaType:RCCallMediaAudio];
```

4. 申请视频通话。
```objectivec
// 视频通话
[[RCCall sharedRCCall] startSingleCall:self.useridTextField.text mediaType:RCCallMediaVideo];
```
5. 后台接听来电需要在 'AppDelegate.m' 里注册本地通知，可参考该 Demo 内的实现。
```objectivec
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
```
