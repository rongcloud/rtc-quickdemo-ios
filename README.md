# RongCloud-RTC iOS Quick Demo

# 融云场景 Demo
包含单群聊、音视频通话、语音聊天室、娱乐直播、教学课堂、多人会议等场景
https://www.rongcloud.cn/downloads/demo

## 目录结构说明

本目录共包含多个场景功能
.
├── CallKit             // CallKit 通话
├── CallLib             // CallLib 通话
├── Live                // 直播
│   ├── GPUImage
│   └── LivingTool
├── Meeting1v1          // 1v1 会议
├── RCRTCQuickDemo
│   ├── Home
│   ├── Login
│   └── Tool
│       ├── Category
│       ├── Constant
│       └── Request
├── screenshare         // 屏幕共享
└── ScreenSharing
    └── ShareTool



## 配置 Demo 文件
1. 在 `pod repo update` 之后, 使用 `pod install` 安装 `podfile` 中指定好的融云 `SDK` 库。

2. `pod install` 完成后, 打开生成的 `RCRTCQuickDemo.xcworkspace`。

3. 请登录官网获取AppKey, AppSecret；找到 `/RCRTCQuickDemo/Tool/Constant/Constant.m`，将红框内的 `AppKey` 和 `AppSecret` 替换为从开发者后台获取到的具体内容，然后去掉 `#error` 提醒。

4. 修改工程 `target` 中 `RCRTCQuickDemo` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo`。

5. 修改工程 `target` 中 `ScreenShare` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo.screenshare`。

6. 修改工程 `target` 中 `RCRTCQuickDemo` 和 `ScreenShare` 的 `App Group` 配置，修改为第 4 步和第 5 步新修改的 `Bundle Identifier`。

7. 选择真机设备并编译 `RCRTCQuickDemo`。