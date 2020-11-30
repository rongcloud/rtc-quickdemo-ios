# iOS-live-quick-start
RTC Quick Start for iOS.

这个开源示例项目演示了如何快速集成RongRTCLib视频SDK，低延迟直播，观众连麦，合流布局等场景。
运行前需要申请融云开发者账号，并申请开通音视频功能[开通地址](https://www.rongcloud.cn/docs/)，

在这个示例项目中包含了以下功能：

1>.主播端
- 创建房间；
- 麦克风静音和解除静音；
- 切换前置摄像头和后置摄像头；
- 角色切换观众/主播

2>.低延迟观众端
- 加入房间
- 角色切换观众/主播

3>.合流观众端
- 订阅主播
- 退出


1.申请完成之后在 **AppKeyToken.h**文件中填写 APP_KEY , TOKEN

```
#define APP_KEY @"<#这里填写你的 App Key#>"
#define TOKEN @"<#这是连接 IM 的 Token#>"
```

> 注意: 假设两个真机设备互通测试时，需要同一个 APP_KEY 和两个不同的 TOKEN

2.运行之前请先执行 pod install 安装一下需要的依赖库（RongIMLib, RongRTCLib）
3.需要适当修改 Bundle Identifier 支持真机自签名

## 环境准备

- XCode 10.0 +
- iOS 真机设备
- 不支持模拟器


## 联系我们

- 如果你遇到了困难，可以先参阅 [常见问题](https://docs.rongcloud.cn/v4/views/im/ui/faq/overview.html)
- 完整的 API 文档见 [文档中心](https://docs.rongcloud.cn/v4/)
- 如果你想了解RongRTCLib SDK在复杂场景下的应用，可以参考 [官方场景案例](https://www.rongcloud.cn/downloads/demo)
- 如果你想了解融云的一些社区开发者维护的项目，可以查看 [社区](https://geekonline.rongcloud.cn/)

## 代码许可

The MIT License (MIT)
