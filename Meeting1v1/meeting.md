# 配置 Demo 文件

1. 在 `pod repo update` 之后, 使用 `pod install` 安装 `podfile` 中指定好的融云 `SDK` 库。

2. `pod install` 完成后, 打开生成的 `RCRTCQuickDemo.xcworkspace`。

3. 请登录官网获取AppKey, AppSecret；找到 `/RCRTCQuickDemo/Tool/Constant/Constant.m`，将红框内的 `AppKey` 和 `AppSecret` 替换为从开发者后台获取到的具体内容，然后去掉 `#error` 提醒。

4. 修改工程 `target` 中 `RCRTCQuickDemo` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo`。

5. 修改工程 `target` 中 `ScreenShare` 的 `Bundle Identifier`，例如：`cn.rongcloud.rtcquickdemo.screenshare`。

6. 修改工程 `target` 中 `RCRTCQuickDemo` 和 `ScreenShare` 的 `App Group` 配置，修改为第 4 步和第 5 步新修改的 `Bundle Identifier`。

7. 选择真机设备并编译 `RCRTCQuickDemo`。


# 会议流程

1. 初始化 SDK 并连接融云服务器。

    参考 `/RCRTCQuickDemo/Home/LoginViewController.m`
```
// 初始化 Appkey 并连接 IM
- (void)connectRongCloud:(NSString *)token {
    
    [[RCCoreClient sharedCoreClient] initWithAppKey:AppKey];
    [[RCCoreClient sharedCoreClient] connectWithToken:token dbOpened:nil success:^(NSString *userId) {
        
        NSLog(@"IM connect success,user ID : %@",userId);
        ...
        
    } error:^(RCConnectErrorCode errorCode) {
        NSLog(@"IM connect failed, error code : %ld",(long)errorCode);
    }];
}
```

2. 指定房间 id 并加入房间

    参考 `/Meeting1v1/MeetingViewController.m`

```
// 加入房间
- (void)joinRoom {
    RCRTCVideoStreamConfig *videoConfig = [[RCRTCVideoStreamConfig alloc] init];
    videoConfig.videoSizePreset = RCRTCVideoSizePreset720x480;
    videoConfig.videoFps = RCRTCVideoFPS30;
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:videoConfig];

    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeNormal;
    
    [[RCRTCEngine sharedInstance] enableSpeaker:YES];

    [[RCRTCEngine sharedInstance] joinRoom:self.roomId
                   config:config
               completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
                   if (code == RCRTCCodeSuccess) {
                       // 3. 加入成功后进行资源的发布和订阅
                       [self afterJoinRoom:room];
                   } else {
                       
                   }
               }];
}
```

3. 加入成功后开始采集本地视频并发布本地视频流

    参考 `/Meeting1v1/MeetingViewController.m`

```
// 加入成功后进行资源发布和订阅
- (void)afterJoinRoom:(RCRTCRoom *)room {
    // 设置房间代理
    self.room = room;
    room.delegate = self;

    // 开始本地视频采集
    [[[RCRTCEngine sharedInstance] defaultVideoStream] setVideoView:self.localView];
    [[[RCRTCEngine sharedInstance] defaultVideoStream] startCapture];

    // 发布本地视频流
    [room.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess && desc == RCRTCCodeSuccess) {
            NSLog(@"本地流发布成功");
        }
    }];

    // 如果已经有远端用户在房间中, 需要订阅远端流
    if ([room.remoteUsers count] > 0) {
        NSMutableArray *streamArray = [NSMutableArray array];
        for (RCRTCRemoteUser *user in room.remoteUsers) {
            [streamArray addObjectsFromArray:user.remoteStreams];
        }
        [self subscribeRemoteResource:streamArray];
    }
}

```
    
4. 如果已经有远端用户在房间中，需要订阅远端流

    参考 `/Meeting1v1/MeetingViewController.m`

```
// 订阅房间中远端用户音视频流资源
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
    [self.room.localUser subscribeStream:streams
                             tinyStreams:nil
                              completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess && desc == RCRTCCodeSuccess) {
            NSLog(@"无端流订阅成功");
        }
    }];
    
    // 创建并设置远端视频预览视图
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            [(RCRTCVideoInputStream *) stream setVideoView:self.remoteView];
            [self.remoteView setHidden:NO];
        }
    }
}

```

5. 监听房间事件

    参考 `/Meeting1v1/MeetingViewController.m`

```
#pragma mark - RCRTCRoomEventDelegate
// 远端用户发布资源通知
- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self subscribeRemoteResource:streams];
}

// 远端用户取消发布资源通知
- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self.remoteView setHidden:YES];
}

// 远端用户离开通知
- (void)didLeaveUser:(RCRTCRemoteUser *)user {
    [self.remoteView setHidden:YES];
}
```