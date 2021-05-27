# RongCloud-RTC iOS Quick Demo

融云 iOS RTC 快速示例 Demo

共分为 5 个模块
 
- 会议 1v1
- 直播
- CallLib
- CallKit
- 屏幕共享会议

# 配置 Demo 文件
1. 在 `pod repo update` 之后, 使用 `pod install` 安装 `podfile` 中指定好的融云 `SDK` 库。

2. `pod install` 完成后, 打开生成的 `RCRTCQuickDemo.xcworkspace`。

3. 请登录官网获取AppKey, AppSecret；找到 `/RCRTCQuickDemo/Tool/Constant/Constant.m`，将红框内的 `AppKey` 和 `AppSecret` 替换为从开发者后台获取到的具体内容，然后去掉 `#error` 提醒。

4. 修改工程 `target` 中 `RCRTCQuickDemo` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo`。

5. 修改工程 `target` 中 `ScreenShare` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo.screenshare`。

6. 修改工程 `target` 中 `RCRTCQuickDemo` 和 `ScreenShare` 的 `App Group` 配置，修改为第 4 步和第 5 步新修改的 `Bundle Identifier`。

7. 选择真机设备并编译 `RCRTCQuickDemo`。

