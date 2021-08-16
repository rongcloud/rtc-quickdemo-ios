//
//  ViewController.m
//  quickdemo-zoomvideoview
//
//  Created by LiuLinhong on 2021/04/07.
//

#import "ViewController.h"
#import "AppID.h"
#import <Masonry.h>
#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLibCore/RongIMLibCore.h>

#define kScreenWidth self.view.frame.size.width
#define kScreenHeight self.view.frame.size.height


@interface ViewController () <RCRTCRoomEventDelegate>

@property(nonatomic, strong) UIView *menuView;
@property(nonatomic, strong) RCRTCLocalVideoView *localView;
@property(nonatomic, strong) RCRTCRemoteVideoView *remoteView;
@property(nonatomic, strong) UIView *remoteCoverView;
@property(nonatomic, strong) RCRTCRoom *room;
@property(nonatomic, strong) RCRTCEngine *engine;
@property(nonatomic, strong) RCRTCVideoPreviewView *zoomView;
@property(nonatomic, assign) CGRect cellRect;
@property(nonatomic, assign) CGFloat previousDistance;
@property(nonatomic, assign) CGPoint panStartPoint;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initializeRCRTCEngine];
    [self setupLocalVideoView];
    [self setupRemoteVideoView];
    [self setupRoomMenuView];
    [self initializeRCIMCoreClient];
    [self initGestureRecognizer];
}

- (void)initializeRCIMCoreClient {
    //融云SDK 5.0.0 及其以上版本使用
    [[RCCoreClient sharedCoreClient] initWithAppKey:AppID];
    [[RCCoreClient sharedCoreClient] connectWithToken:token
                                             dbOpened:^(RCDBErrorCode code) {
                                                 NSLog(@"MClient dbOpened code: %zd", code);
                                             } success:^(NSString *userId) {
                NSLog(@"IM连接成功userId: %@", userId);
                [self joinRoom];
            }                                   error:^(RCConnectErrorCode status) {
                NSLog(@"IM连接失败errorCode: %ld", (long) status);
            }];

    /*
    //融云SDK 5.0.0 以下版本, 不包含5.0.0 使用
    //初始化融云 SDK
    [[RCIMClient sharedRCIMClient] initWithAppKey:AppID];
    RCIMClient.sharedRCIMClient.logLevel = RC_Log_Level_None;
    
    //前置条件 IM建立连接
    [[RCIMClient sharedRCIMClient] connectWithToken:token
                                           dbOpened:^(RCDBErrorCode code) {}
                                            success:^(NSString *userId) {
        NSLog(@"IM连接成功userId:%@",userId);
    }
                                              error:^(RCConnectErrorCode errorCode) {
        NSLog(@"IM连接失败errorCode:%ld",(long)errorCode);
    }];
    */
}

- (void)initializeRCRTCEngine {
    self.engine = [RCRTCEngine sharedInstance];
    [self.engine enableSpeaker:YES];
}

#pragma mark - 添加本地采集预览界面

- (void)setupLocalVideoView {
    RCRTCLocalVideoView *localView = [[RCRTCLocalVideoView alloc] initWithFrame:self.view.bounds];
    localView.frameAnimated = NO;
    localView.fillMode = RCRTCVideoFillModeAspectFit;
    [self.view addSubview:localView];
    self.localView = localView;
    self.zoomView = localView;
}

#pragma mark - 添加远端视频小窗口

- (void)setupRemoteVideoView {
    CGRect rect = CGRectMake(kScreenWidth - 120, 20, 100, 100 * 4 / 3);
    _remoteCoverView = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:_remoteCoverView];

    self.cellRect = CGRectMake(0, 0, _remoteCoverView.frame.size.width, _remoteCoverView.frame.size.height);
    _remoteView = [[RCRTCRemoteVideoView alloc] initWithFrame:self.cellRect];
    _remoteView.frameAnimated = NO;
    _remoteView.fillMode = RCRTCVideoFillModeAspectFill;
    [_remoteView setHidden:YES];
    [_remoteCoverView addSubview:_remoteView];
}

#pragma mark - 添加控制按钮层

- (void)setupRoomMenuView {
    [self.view addSubview:self.menuView];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-50);
        make.size.mas_offset(CGSizeMake(kScreenWidth, 50));
    }];
}

#pragma mark - 初始化手势

- (void)initGestureRecognizer {
    //点击切换大小屏
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(switchVideoViewAction)];
    [self.remoteCoverView addGestureRecognizer:tapGesture];

    //两指Zoom
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(pinchGestureAction:)];
    [self.view addGestureRecognizer:pinchGesture];

    //拖拽
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(panGestureAction:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGesture];

}

#pragma mark - 加入房间

/*
 回调成功后:
 1.本地视频采集
 2.发布本地视频流
 3.加入房间时如果已经有远端用户在房间中, 需要订阅远端流
 */
- (void)joinRoom {
    [[RCRTCEngine sharedInstance] joinRoom:RoomId
                                completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
                                    if (code == RCRTCCodeSuccess) {
                                        //设置房间代理
                                        self.room = room;
                                        room.delegate = self;

                                        // 1.本地视频采集
                                        [[self.engine defaultVideoStream] setVideoView:self.localView];
                                        [[self.engine defaultVideoStream] startCapture];

                                        [self.engine enableSpeaker:YES];

                                        // 2.发布本地视频流
                                        [room.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode desc) {
                                            if (isSuccess && desc == RCRTCCodeSuccess) {
                                                NSLog(@"本地流发布成功");
                                            }
                                        }];

                                        // 3.加入房间时如果已经有远端用户在房间中, 需要订阅远端流
                                        if ([room.remoteUsers count] > 0) {
                                            NSMutableArray *streamArray = [NSMutableArray array];
                                            for (RCRTCRemoteUser *user in room.remoteUsers) {
                                                [streamArray addObjectsFromArray:user.remoteStreams];
                                            }
                                            // 订阅远端音视频流
                                            [self subscribeRemoteResource:streamArray];
                                        }
                                    } else {
                                        NSLog(@"加入房间失败");
                                    }
                                }];
}

#pragma mark - Action

//麦克风静音
- (void)micMute:(UIButton *)btn {
    btn.selected = !btn.selected;
    [self.engine.defaultAudioStream setMicrophoneDisable:btn.selected];
}

//本地摄像头切换
- (void)switchCamera:(UIButton *)btn {
    btn.selected = !btn.selected;
    [self.engine.defaultVideoStream switchCamera];
}

//挂断
- (void)exitRoom {
    //关闭摄像头采集
    [self.engine.defaultVideoStream stopCapture];
    [self.remoteView removeFromSuperview];

    //退出房间
    [self.engine leaveRoom:^(BOOL isSuccess, RCRTCCode code) {
        if (isSuccess && code == RCRTCCodeSuccess) {
            NSLog(@"退出房间成功code:%ld", (long) code);
        }
    }];
}

#pragma mark - Gesture Action

//切换大小屏显示本地/远端视频View
- (void)switchVideoViewAction {
    if (CGRectEqualToRect(self.remoteView.frame, self.cellRect)) {
        //远端放置在大屏
        self.remoteView.fillMode = RCRTCVideoFillModeAspectFit;
        self.remoteView.frame = self.view.bounds;
        [self.view addSubview:self.remoteView];

        //本地旋转在小屏
        self.localView.fillMode = RCRTCVideoFillModeAspectFill;
        self.localView.frame = self.cellRect;
        [self.remoteCoverView addSubview:self.localView];

        self.zoomView = self.remoteView;
    } else {
        //本地放置在大屏
        self.localView.fillMode = RCRTCVideoFillModeAspectFit;
        self.localView.frame = self.view.bounds;
        [self.view addSubview:self.localView];

        //远端旋转在小屏
        self.remoteView.fillMode = RCRTCVideoFillModeAspectFill;
        self.remoteView.frame = self.cellRect;
        [self.remoteCoverView addSubview:self.remoteView];

        self.zoomView = self.localView;
    }

    [self.view addSubview:self.remoteCoverView];
    [self.view addSubview:self.menuView];
}

//放大缩小Zoom手势
- (void)pinchGestureAction:(UIPinchGestureRecognizer *)gesture {
    if (gesture.numberOfTouches != 2) {
        return;
    }

    CGPoint tmpP0 = [gesture locationOfTouch:0 inView:self.view];
    CGPoint tmpP1 = [gesture locationOfTouch:1 inView:self.view];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint startP0 = tmpP0.x < tmpP1.x ? tmpP0 : tmpP1;
            CGPoint startP1 = tmpP0.x < tmpP1.x ? tmpP1 : tmpP0;
            self.previousDistance = [self distanceFromPointX:startP0 distanceToPointY:startP1];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint changedP0 = tmpP0.x < tmpP1.x ? tmpP0 : tmpP1;
            CGPoint changedP1 = tmpP0.x < tmpP1.x ? tmpP1 : tmpP0;
            CGFloat changedDistance = [self distanceFromPointX:changedP0 distanceToPointY:changedP1];
            CGFloat deltaTrangleEdge = sqrt(2 * pow(changedDistance - self.previousDistance, 2));

            if (changedDistance > self.previousDistance) {
                CGFloat increaseX = self.zoomView.frame.origin.x - deltaTrangleEdge > 0 ? 0 : self.zoomView.frame.origin.x - deltaTrangleEdge;
                CGFloat increaseY = self.zoomView.frame.origin.y - deltaTrangleEdge > 0 ? 0 : self.zoomView.frame.origin.y - deltaTrangleEdge;

                if (self.zoomView.frame.size.width + increaseX <= kScreenWidth) {
                    increaseX = self.zoomView.frame.origin.x;
                }
                if (self.zoomView.frame.size.height + increaseY <= kScreenHeight) {
                    increaseY = self.zoomView.frame.origin.y;
                }

                self.zoomView.frame = CGRectMake(increaseX,
                        increaseY,
                        self.zoomView.frame.size.width + deltaTrangleEdge * 2,
                        self.zoomView.frame.size.height + deltaTrangleEdge * 2);
            } else {
                CGFloat decreaseX = self.zoomView.frame.origin.x + deltaTrangleEdge > 0 ? 0 : self.zoomView.frame.origin.x + deltaTrangleEdge;
                CGFloat decreaseY = self.zoomView.frame.origin.y + deltaTrangleEdge > 0 ? 0 : self.zoomView.frame.origin.y + deltaTrangleEdge;

                if (self.zoomView.frame.size.width + decreaseX <= kScreenWidth) {
                    decreaseX = kScreenWidth - self.zoomView.frame.size.width + deltaTrangleEdge * 2;
                }
                if (self.zoomView.frame.size.height + decreaseY <= kScreenHeight) {
                    decreaseY = kScreenHeight - self.zoomView.frame.size.height + deltaTrangleEdge * 2;
                }

                self.zoomView.frame = CGRectMake(decreaseX,
                        decreaseY,
                        self.zoomView.frame.size.width - deltaTrangleEdge * 2,
                        self.zoomView.frame.size.height - deltaTrangleEdge * 2);
            }

            self.previousDistance = changedDistance;

            if (self.zoomView.frame.size.width < kScreenWidth
                    || self.zoomView.frame.size.height < kScreenHeight) {
                self.zoomView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }
        }
            break;
        default:
            break;
    }
}

//拖拽手势
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    CGPoint tmpLocation = [gesture locationInView:self.view];

    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.panStartPoint = tmpLocation;
    } else if (gesture.state != UIGestureRecognizerStateEnded && gesture.state != UIGestureRecognizerStateFailed) {
        CGFloat deltaX = self.panStartPoint.x - tmpLocation.x;
        CGFloat deltaY = self.panStartPoint.y - tmpLocation.y;

        CGFloat x = self.zoomView.frame.origin.x - deltaX > 0 ? 0 : self.zoomView.frame.origin.x - deltaX;
        CGFloat y = self.zoomView.frame.origin.y - deltaY > 0 ? 0 : self.zoomView.frame.origin.y - deltaY;

        if (self.zoomView.frame.size.width + x <= kScreenWidth) {
            x = self.zoomView.frame.origin.x;
        }
        if (self.zoomView.frame.size.height + y <= kScreenHeight) {
            y = self.zoomView.frame.origin.y;
        }

        self.zoomView.frame = CGRectMake(x, y, self.zoomView.frame.size.width, self.zoomView.frame.size.height);
        self.panStartPoint = tmpLocation;
    }
}

#pragma mark - RCRTCRoomEventDelegate

- (void)didPublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self subscribeRemoteResource:streams];
}

- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *> *)streams {
    [self.remoteView setHidden:YES];
}

- (void)didLeaveUser:(RCRTCRemoteUser *)user {
    [self.remoteView setHidden:YES];
}

#pragma mark - 订阅资源

- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
    // 创建并设置远端视频预览视图
    for (RCRTCInputStream *stream in streams) {
        if (stream.mediaType == RTCMediaTypeVideo) {
            [(RCRTCVideoInputStream *) stream setVideoView:self.remoteView];
            [self.remoteView setHidden:NO];
        }
    }

    // 订阅房间中远端用户音视频流资源
    [self.room.localUser subscribeStream:streams
                             tinyStreams:nil
                              completion:^(BOOL isSuccess, RCRTCCode desc) {
                              }];
}

#pragma mark - Getter

- (UIView *)menuView {
    if (!_menuView) {
        UIButton *muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [muteButton setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
        [muteButton setImage:[UIImage imageNamed:@"mute_hover"] forState:UIControlStateSelected];
        [muteButton addTarget:self action:@selector(micMute:) forControlEvents:UIControlEventTouchUpInside];

        UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [exitButton setImage:[UIImage imageNamed:@"hang_up"] forState:UIControlStateNormal];
        [exitButton addTarget:self action:@selector(exitRoom) forControlEvents:UIControlEventTouchUpInside];

        UIButton *switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [switchCameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [switchCameraButton setImage:[UIImage imageNamed:@"camera_hover"] forState:UIControlStateSelected];
        [switchCameraButton addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];

        _menuView = [UIView new];
        [_menuView addSubview:muteButton];
        [_menuView addSubview:exitButton];
        [_menuView addSubview:switchCameraButton];

        CGFloat padding = (kScreenWidth - 50 * 3) / 4;
        CGSize btnSize = CGSizeMake(50, 50);

        [muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(padding);
            make.centerY.mas_equalTo(0);
            make.size.mas_offset(btnSize);
        }];
        [exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.size.mas_offset(btnSize);
        }];
        [switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-padding);
            make.centerY.mas_equalTo(0);
            make.size.mas_offset(btnSize);
        }];
    }
    return _menuView;
}

#pragma mark - Private

- (CGFloat)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end {
    CGFloat distance;
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt(pow(xDist, 2) + pow(yDist, 2));
    return distance;
}

@end
