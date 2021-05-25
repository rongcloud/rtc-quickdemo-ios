# 文件说明

`/Live/LiveViewController.m`：直播的主要实现类，包括主播的发布以及取消发布资源，订阅以及取消订阅资源，发布本地自定义资源以及水印美颜；观众端的订阅与取消订阅资源，上下麦等操作。

`/Live/RCRTCFileSource.m`：本地自定义视频发送的处理类。

`/Live/GPUImageHandle`：对 GPUImage 的封装类，可以参考里面的代码实现水印美颜，也可自定义设置。

`/Live/LivingTool`：里面包括直播的合流布局配置类`/Live/LiveMixStreamTool`，直播本地发布订阅的音视频流的布局类`/Live/LiveVideoLayoutTool`，预览图创建标识 Id 类`/Live/LiveStreamVideo`。

# 配置 Demo 文件
    
1. 在 `pod repo update` 之后, 使用 `pod install` 安装 `podfile` 中指定好的融云 `SDK` 库。

2. `pod install` 完成后, 打开生成的 `RCRTCQuickDemo.xcworkspace`。

3. 请登录官网获取AppKey, AppSecret；找到 `/RCRTCQuickDemo/Tool/Constant/Constant.m`，将红框内的 `AppKey` 和 `AppSecret` 替换为从开发者后台获取到的具体内容，然后去掉 `#error` 提醒。

4. 修改工程 `target` 中 `RCRTCQuickDemo` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo`。

5. 修改工程 `target` 中 `ScreenShare` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo.screenshare`。

6. 修改工程 `target` 中 `RCRTCQuickDemo` 和 `ScreenShare` 的 `App Group` 配置，修改为第 4 步和第 5 步新修改的 `Bundle Identifier`。

7. 选择真机设备并编译 `RCRTCQuickDemo`。

> 直播在角色上分为观众端与主播端：

# 主播端：

1. 初始化 SDK 并连接融云服务器。可以参考 `/RCRTCQuickDemo/Home/LoginViewController.m`中的方法，通过 AppKey 与 token 并连接融云服务器。

2. 连接 IM 服务成功后，主播端首先要进行房间配置的相关配置操作，需确定房间类型为直播类型以及直播角色类型为主播。
```objectivec
// 1.设置切换听筒为扬声器
[self.engine enableSpeaker:YES];

// 2.添加本地采集预览界面
[self setupLocalVideoView];

// 3.配置房间，加入 RTC 房间
RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
config.roomType = RCRTCRoomTypeLive;
config.liveType = RCRTCLiveTypeAudioVideo;
config.roleType = roleType;
'''
3. 房间配置完成后，主播端首先调用 `RCRTCEngine` 的 `joinRoom: config: completion:`方法创建一个直播类型房间。
'''
__weak typeof(self) weakSelf = self;
[self.engine joinRoom:_roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (code != RCRTCCodeSuccess) {
        [UIAlertController alertWithString:[NSString stringWithFormat:@"加入房间失败 code:%ld",(long)code] inCurrentViewController:strongSelf];
        return;
    }
    
    self.room = room;
    room.delegate = self;
    // 如果是主播
    if (roleType == RCRTCLiveRoleTypeBroadcaster) {
        
        // 4.发布本地默认流
        [self publishLocalLiveAVStream];
        
        // 设置视频纹理渲染
        [self setBuffer];
        
        // 5.单独订阅主播流
        if (room.remoteUsers.count) {
            NSMutableArray *streamArray = [NSMutableArray array];
            for (RCRTCRemoteUser *user in room.remoteUsers) {
                if (user.remoteStreams.count) {
                    [streamArray addObjectsFromArray:user.remoteStreams];
                    [self subscribeRemoteResource:streamArray];
                }
            }
        }
    }else{
        // 4. 如果是观众，订阅 live 合流
    }
}];
```

4. 创建直播类型房间成功后，你需要创建并设置本地视频流的渲染图并添加在本地视图上，开启摄像头采集，并通过 block 返回的 `RCRTCRoom` 对象主播发布资源。

```objectivec
// 1.初始化渲染视图
RCRTCLocalVideoView *view = (RCRTCLocalVideoView *)self.localVideo.canvesView;
// 2.设置视频流的渲染视图
[self.engine.defaultVideoStream setVideoView:view];
// 3.开始摄像头采集
[self.engine.defaultVideoStream startCapture];
// 4.发布本地流到房间
[self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
    if (desc == RCRTCCodeSuccess) {
        self.liveInfo = liveInfo;
    }else {
        [UIAlertController alertWithString:@"本地流发布失败" inCurrentViewController:nil];
    }
}];
```
5. 如果已经有远端用户在房间中，需要订阅远端（创建并设置远端视频流的渲染图并添加在本地视图上）。
```objectivec
// 3.1单独订阅主播流
if (room.remoteUsers.count) {
    NSMutableArray *streamArray = [NSMutableArray array];
    for (RCRTCRemoteUser *user in room.remoteUsers) {
        if (user.remoteStreams.count) {
            [streamArray addObjectsFromArray:user.remoteStreams];
            [self subscribeRemoteResource:streamArray];
        }
    }
}
```

```objectivec
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams isTiny:(BOOL)isTiny {
    // 订阅房间中远端用户音视频流资源
    NSArray *tinyStream = isTiny ? streams : @[];
    NSArray *ordinaryStream = isTiny ? @[] : streams;
    [self.room.localUser subscribeStream:ordinaryStream
                             tinyStreams:tinyStream
                              completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (desc != RCRTCCodeSuccess) {
            NSString *errorStr = [NSString stringWithFormat:@"订阅远端流失败:%ld",(long)desc];
            [UIAlertController alertWithString:errorStr inCurrentViewController:nil];
            return;
        }
        
        // 创建并设置远端视频预览视图（设置 RCRTCRemoteVideoView 并添加到本地的视图上）
        NSInteger i = 0;
        for (RCRTCInputStream *stream in streams) {
            if (stream.mediaType == RTCMediaTypeVideo) {
                [self setupRemoteViewWithStream:stream];
                i++;
            }
        }
        if (i > 0) {
            [self updateLayoutWithAnimation:YES];
        }
    }];
}
```

6. 主播离开房间时调用 `RCRTCEngine` 中的 `leaveRoom: completion: `即可，离开房间时不需要取消订阅，SDK 内部会处理。
```objectivec
// 退出房间
- (void)exitRoom {
    [self.engine.defaultVideoStream stopCapture];
    __weak typeof(self) weakSelf = self;
    [self.engine  leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"退出房间失败 code:%ld",(long)code] inCurrentViewController:strongSelf];
        }
    }];
    
    // 如果是主播且在发布自定义流，退出本地发送
    if (self.pushLocalButton.selected && !self.liveRoleType) {
        [self stopPublishVideoFile];
    }
}
```
# 观众端：

1. 初始化 SDK 并连接融云服务器。可以参考 `/RCRTCQuickDemo/Home/LoginViewController.m`中的方法，通过 AppKey 与 token 并连接融云服务器。

2. 连接 IM 服务成功后，观众端首先要进行房间配置的相关配置操作，需确定房间类型为直播类型以及直播角色类型为观众。
```objectivec
// 1. 设置切换听筒为扬声器
[self.engine enableSpeaker:YES];

// 2. 配置房间
[self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
config.roomType = RCRTCRoomTypeLive;
config.liveType = RCRTCLiveTypeAudioVideo;
config.roleType = RCRTCLiveRoleTypeAudience;
```
3. 房间配置完成后，观众端首先调用 `RCRTCEngine` 的 `joinRoom: config: completion: `方法加入一个直播类型房间。
```objectivec
__weak typeof(self) weakSelf = self;
[self.engine joinRoom:_roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (code != RCRTCCodeSuccess) {
        [UIAlertController alertWithString:[NSString stringWithFormat:@"加入房间失败 code:%ld",(long)code] inCurrentViewController:strongSelf];
        return;
    }
    
    self.room = room;
    room.delegate = self;
    // 如果是主播
    if (roleType == RCRTCLiveRoleTypeBroadcaster) {
        // 主播发布订阅
    }else{
        // 观众订阅 live 合流
        NSArray *liveStreams = [room getLiveStreams];
        if (liveStreams.count) {
            // 观众可在此订阅
            [self subscribeRemoteResource:liveStreams];
        }

    }
}];
```
4. 远端用户发布音视频流后，创建并设置远端视频流的渲染图并添加在本地视图上，然后可以通过加入房间后返回的 `RCRTCRoom` 中的 localUser 中的订阅方法订阅多路远端指定音视频流。同一个流只能填写在 avStreams 或 tinyStreams 中的一个数组中。

```objectivec
// 1. 设置切换听筒为扬声器
[self.engine enableSpeaker:YES];

// 2. 配置房间
[self joinLiveRoomWithRole:RCRTCLiveRoleTypeAudience];
RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
config.roomType = RCRTCRoomTypeLive;
config.liveType = RCRTCLiveTypeAudioVideo;
config.roleType = RCRTCLiveRoleTypeAudience;
```
3. 房间配置完成后，观众端首先调用 `RCRTCEngine` 的 `joinRoom: config: completion: `方法加入一个直播类型房间。
```objectivec
// 订阅房间中远端用户音视频流资源
NSArray *tinyStream = isTiny ? streams : @[];
NSArray *ordinaryStream = isTiny ? @[] : streams;
[self.room.localUser subscribeStream:ordinaryStream
                         tinyStreams:tinyStream
                          completion:^(BOOL isSuccess, RCRTCCode desc) {
    if (desc != RCRTCCodeSuccess) {
        NSString *errorStr = [NSString stringWithFormat:@"订阅远端流失败:%ld",(long)desc];
        [UIAlertController alertWithString:errorStr inCurrentViewController:nil];
        return;
    }
    
    // 创建并设置远端视频预览视图
    NSInteger i = 0;
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            // 创建并设置远端视频预览视图
            [self setupRemoteViewWithStream:stream];
            i++;
        }
    }
    if (i > 0) {
        [self updateLayoutWithAnimation:YES];
    }
}];
```

5. 观众可以调用 RCRTCRoom 中的取消订阅的方法，取消订阅该用户的音视频流。退出房间时不需要取消订阅，SDK 内部会处理。

6. 观众离开房间时调用 `RCRTCEngine` 中的 `leaveRoom: completion: ` 即可，离开房间时不需要取消订阅，SDK 内部会处理。

```objectivec
// 退出房间
- (void)exitRoom {
    [self.engine.defaultVideoStream stopCapture];
    __weak typeof(self) weakSelf = self;
    [self.engine  leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code != RCRTCCodeSuccess) {
            [UIAlertController alertWithString:[NSString stringWithFormat:@"退出房间失败 code:%ld",(long)code] inCurrentViewController:strongSelf];
        }
    }];
    
    // 如果是主播且在发布自定义流，退出本地发送
    if (self.pushLocalButton.selected && !self.liveRoleType) {
        [self stopPublishVideoFile];
    }
}
```
# 观众上下麦：

观众上麦本质是观众先离开当前房间，然后再以主播身份加入房间，之后逻辑可参考主播端实现。
观众下麦本质是观众上麦后（此时直播角色类型已变为主播），先离开房间，然后以观众身份加入房间，之后逻辑可参考观众端实现。






