# 通话/直播前质量检测
### 通话前质量检测
从v5.1.9 起用户可以通过**startEchoTest:**方法在加入频道前，启动通话测试。该测试的目的是测试系统的音频设备（耳麦、扬声器等）是否正常在通话/直播前 用户可以通过设备检测接口，查看自己的设备是否都是可用状态。

### 实现方法

开始前请确保已在项目中实现了基本的音视频通信或直播功能，调用 **startEchoTest:** 方法。调用该方法时，您需要设置一个 interval 参数，表示获取本次测试结果的间隔时间。该参数单位为秒，取值范围为 [2,10],小于2s按2秒处理，大于10按10s处理。
```
[[RCRTCEngine sharedInstance] startEchoTest:interval];
```
成功调用 **startEchoTest:** 方法后，引导用户先说一段话，如果声音在设置的时间间隔后回放出来，且用户能听到自己刚才说的话，则表示系统音频设备和网络连接都是正常的。

获取音频设备测试结果后，调用 **stopEchoTest** 方法停止语音通话检测。
```
[[RCRTCEngine sharedInstance] stopEchoTest];
```
 调用 **startEchoTest:** 后必须调用 **stopEchoTest** 以结束测试，否则不能进行下一次回声测试。

### 示例代码

```
/*!
 开启回声测试。10 表示 10 秒后播放本次测试录到的声音，获取测试结果。    
 等待并检查是否可以听到自己的声音回放。
*/ 
[[RCRTCEngine sharedInstance] startEchoTest:10];

/*!
 停止测试
*/ 
[[RCRTCEngine sharedInstance] stopEchoTest];
```

### 开发注意事项
 尽量避免在直播间时候调用通话测试，否则会影响正常通话。



