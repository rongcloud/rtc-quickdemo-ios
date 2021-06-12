# 前言

我们可以通过苹果的 Extension 来实现屏幕共享技术。这里我们将通过使用 iOS11 之后新增的系统级别的录屏能力，来实现录制自身 App 以外，手机屏幕内容的效果（受 iOS 系统的 ReplayKit 库限制, iOS12 前在
App 中调用 Extension 启动屏幕共享时, 只能作用于 App 内, 如果退出 App 则无法得到屏幕内容）。

# 文件说明

`/ScreenSharing/ScreenShareViewController.m`：屏幕共享'宿主 App'的主要实现类。

`/ScreenSharing/ShareTool`：会议本地发布订阅的音视频流的布局类`/ScreenSharing/ShareTool/ScreenShareVideoLayoutTool`，预览图创建标识 Id
类`/ScreenSharing/ShareTool/ScreenShareStreamVideo`。

`/ScreenShare/SampleHandler`:发布屏幕共享音视频流的主要类。

# 配置 Demo 文件

1. 在 `pod repo update` 之后, 使用 `pod install` 安装 `podfile` 中指定好的融云 `SDK` 库。

2. `pod install` 完成后, 打开生成的 `RCRTCQuickDemo.xcworkspace`。

3. 请登录官网获取AppKey, AppSecret；找到 `/RCRTCQuickDemo/Tool/Constant/Constant.m`，将红框内的 `AppKey` 和 `AppSecret`
   替换为从开发者后台获取到的具体内容，然后去掉 `#error` 提醒。

4. 修改工程 `target` 中 `RCRTCQuickDemo` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo`。

5. 修改工程 `target` 中 `ScreenShare` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo.screenshare`。

6. 修改工程 `target` 中 `RCRTCQuickDemo` 和 `ScreenShare` 的 `App Group` 配置，修改为第 4 步和第 5 步新修改的 `Bundle Identifier`。

7. 找到 `/RCRTCQuickDemo/ScreenSharing/ScreenShareViewController.m`，修改静态变量 `ScreenShareBuildID` 与 `ScreenShareGroupID`
   为改动后的实际值，例如：`cn.rongcloud.rtcquickdemo.screenshare` 与 `group.cn.rongcloud.rtcquickdemo.screenshare`
   ；同时修改 `/RCRTCQuickDemo/ScreenShare/SampleHandler.m` 中的静态变量 `ScreenShareGroupID` 为改动后的实际值。

8. 选择真机设备并编译 `RCRTCQuickDemo`。

**受限于 RongIMLib 库中的默认2分钟断开连接的限制, 需要修改如下 pod 路径下的 .plist 配置文件:**
'/Pods/RongCloudIM/IMLibCore/RCConfig.plist'在此文件中添加:

```objectivec
<key>Connection</key>
    <dict>
        <key>ForceKeepAlive</key>
        <true/>
    </dict>
```

其中: Connection 和 ForceKeepAlive 类型为 Key 值, ture 的类型为Bool。

# 共享实现

我们知道苹果的 Extension 是不能直接和宿主 App 进行通讯的，那么如果想在屏幕共享 Extension 里面进行数据传输，那么屏幕共享 Extension 也需要导入我们融云的 RongCloudRTC，并且调用
joinRoom 接口，虽然可能我们的宿主 App 已经加入房间了，但是我们屏幕共享 target 是不知道的，所以就可以这样做，宿主 App 加入房间，通过苹果的 App Group
技术，记下房间号，当我们屏幕共享开启的时候，加入这个房间号就可以了。这里需要注意的是，宿主 APP 和屏幕共享是两个 userId
，相当于屏幕共享是一个单独的人，加入房间发布了一道流。那既然加入房间了，剩下的就是发流，发流就很简单了，屏幕共享有自己的回调。

## 宿主 App

宿主App在加入房间后通过苹果的 App Groups 技术记下房间号，需要屏幕共享时，通过点击录制按钮通知屏幕共享 target。参考`/ScreenSharing/ScreenShareViewController.m`。

### 添加录制按钮

**示例代码：**

```objectivec
// 添加录制按钮
- (void)initMode {
    self.systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 64, 50, 80)];
    self.systemBroadcastPickerView.preferredExtension = @“你的屏幕共享 target 的 Bundle Identifier”;
    self.systemBroadcastPickerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.systemBroadcastPickerView.showsMicrophoneButton = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.systemBroadcastPickerView ];
}
```

### 利用 App Groups 技术记录宿主 App 进入的房间号

**示例代码：**

```objectivec
// 屏幕共享 Groups 数据写入
- (void)setAppGroup {
    // 此处 id 要与开发者中心创建时一致
    NSUserDefaults *rongCloudDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"你的屏幕共享 Extension 的 Group ID"];
    [rongCloudDefaults setObject:self.roomId forKey:@"roomId"];
}
```

## 屏幕共享 Extension

屏幕共享 target 在收到录制通知后，需要通过新的 userId 初始化 SDK 并连接融云服务器。然后通过苹果的 App Groups
技术取出房间号，然后以另一个用户的身份加入房间，发布音视频流。参考`/ScreenShare/SampleHandler`。

### 利用 App Groups 技术取出宿主 App 进入的房间号

**示例代码：**

```objectivec
- (void)getByAppGroup {
    // 此处 id 要与开发者中心创建时一致
    NSUserDefaults *rongCloudDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"你的屏幕共享 Extension 的 Group ID"];
    self.roomId =  [rongCloudDefaults objectForKey:@"roomId"];
}
```

### 初始化并连接

开发者需要在操作前需要用不同于宿主 App 的 userId 进行初始化 SDK 并连接融云服务器。 Token 的获取可以参考 demo 中的 `/RCRTCQuickDemo/Tool/Request/RequestToken.h`。

**示例代码：**

```objectivec
[[RCIMClient sharedRCIMClient] initWithAppKey:AppKey];
    // 连接 IM
    [[RCIMClient sharedRCIMClient] connectWithToken:token
                                           dbOpened:^(RCDBErrorCode code) {
    } success:^(NSString *userId) {
        // 可以在此处加入房间
    } error:^(RCConnectErrorCode errorCode) {
}];
```

### 加入房间

连接 SDK 成功后，加入到与宿主 App 相同的房间中。

**示例代码：**

```objectivec
[[RCRTCEngine sharedInstance] joinRoom:self.roomId
                                completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
    self.room = room;
    self.room.delegate = self;
    // 发布资源
    [self publishScreenStream];
}];
```

### 发布资源

加入房间成功后就可以使用publishStream: completion方法来发布本地指定音视频流。

**示例代码：**

```objectivec
self.videoOutputStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:@"RCRTCScreenVideo"];
RCRTCVideoStreamConfig *videoConfig = self.videoOutputStream.videoConfig;
videoConfig.videoSizePreset = RCRTCVideoSizePreset1920x1080;
videoConfig.videoFps = RCRTCVideoFPS24;
[self.videoOutputStream setVideoConfig:videoConfig];
[self.room.localUser publishStream:self.videoOutputStream
                        completion:^(BOOL isSuccess, RCRTCCode desc) {
}];
```

### 写入录制的音视频流

在系统回调方法里，向我们发布的本地流里利用 RCRTCVideoOutputStrea 对象的`write: error:` 方法写入屏幕共享的媒体流。

**示例代码：**

```objectivec
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self.videoOutputStream write:sampleBuffer error:nil];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}
```

> [!TIP]
> Broadcast Upload Extension 的内存使用限制为 50 MB，请确保屏幕共享的 Extension 内存使用不超过 50 MB。
