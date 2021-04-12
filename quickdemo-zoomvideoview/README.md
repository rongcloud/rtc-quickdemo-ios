# RongRTCZoomVideoVIew
RongRTCZoomVideoVIew for iOS.

这个开源示例项目演示了如何快速集成RongRTCLib视频SDK，实现1对1视频通话。
运行前需要申请融云开发者账号，并申请开通音视频功能[开通地址](https://www.rongcloud.cn/docs/)，

在这个示例项目中包含了以下功能：

- 加入通话和离开通话；
- 麦克风静音和解除静音；
- 切换前置摄像头和后置摄像头；

1.申请完成之后在 **AppID.m**文件中填写 AppID , token

```
   NSString *const token = @"<#这是连接IM的token#>";
   NSString *const AppID = @"<#这里填写你的appID#>";
```

2.运行之前请先执行 pod install 安装一下需要的依赖库（RongIMLib, RongRTCLib）
3.目前仅支持真机测试


## 实现流程

1. 使用 appID 初始化 , 填写 token 进行 IM连接 
2. 加入房间
3. 设置本地预览视图
4. 发布资源
5. 收到远端发布的资源，订阅资源，设置远端预览视图
6. 离开房间


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
