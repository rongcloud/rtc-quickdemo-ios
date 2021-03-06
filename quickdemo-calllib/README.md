# iOS-IMkitAndCallKit-quick-start
IMkitAndCallKit Quick Start for iOS.

这个开源示例项目演示了如何快速集成聊天列表音视频聊天SDK。
运行前需要申请融云开发者账号[开通地址](https://www.rongcloud.cn/docs/)，

在这个示例项目中包含了以下功能：

1>.A设备
发起单聊，选择你配置的列表用户的一个创建单聊

2>.B设备
- 登录1中被选的id


1.申请完成之后在 **AppConfig.h**文件中填写 RCAppKey , RCUserId1，RCUserToken1（id和token的获取也可参考demo中“helpImg.png”图片）
需要两个userid和token

```
#define RCAppKey @"<#这里填写你的 App Key#>"
#define RCUserId1 @"<#这里填写用户id#>"
#define RCUserToken1 @"<#这里填写用户token#>"
#define RCUserId2 @"<#这里填写用户id#>"
#define RCUserToken2 @"<#这里填写用户token#>"
...
```

> 注意: 假设两个真机设备互通测试时，需要同一个 RCAppKey 和两个不同的 RCUserToken1

2.运行之前请先执行 pod install 安装一下需要的依赖库（RongCloudIM/IMLib, RongCloudRTC/RongCallLib）
    podfile中添加  
        pod 'RongCloudIM/IMKit', '~> 4.1.0.1'
        pod 'RongCloudIM/IMLib', '~> 4.1.0.1'
        pod 'RongCloudRTC', '~> 4.1.0.1'
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
