# 配置 Demo 文件

1. 在 `pod repo update` 之后, 使用 `pod install` 安装 `podfile` 中指定好的融云 `SDK` 库。

2. `pod install` 完成后, 打开生成的 `RCRTCQuickDemo.xcworkspace`。

3. 请登录官网获取AppKey, AppSecret；找到 `/RCRTCQuickDemo/Tool/Constant/Constant.m`，将红框内的 `AppKey` 和 `AppSecret`
   替换为从开发者后台获取到的具体内容，然后去掉 `#error` 提醒。

4. 修改工程 `target` 中 `RCRTCQuickDemo` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo`。

5. 修改工程 `target` 中 `ScreenShare` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo.screenshare`。

6. 修改工程 `target` 中 `RCRTCQuickDemo` 和 `ScreenShare` 的 `App Group` 配置，修改为第 4 步和第 5 步新修改的 `Bundle Identifier`。

7. 选择真机设备并编译 `RCRTCQuickDemo`。

# 流程说明

1. 初始化 SDK 并连接融云服务器。可以参考 `/RCRTCQuickDemo/Home/LoginViewController.m`中的方法，通过 AppKey 与 token 并连接融云服务器。

2. 配置呼叫前的一些准备参数。

3. 通过 `RCCallClient` 中的 `startCall` 接口发起呼叫。

4. 被呼叫方可通过实现 `RCCallSessionDelegate` 代理方法 `didReceiveCall` 来监听通话呼入。

5. 通过代理方法的 `callSession` 对象来控制接听和挂断。

详细代码可参考 `CallLibViewController.m`
