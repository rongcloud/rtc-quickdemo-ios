//
//  ViewController.m
//  quickdemo-liveAcross
//
//  Created by RongCloud on 2020/12/24.
//

#import "ViewController.h"
#import <RongIMLib/RongIMLib.h>
#import <RongRTCLib/RongRTCLib.h>
#import "ViewBuilder.h"
#import "AppConfig.h"

@interface ViewController () <RCRTCRoomEventDelegate, RCRTCOtherRoomEventDelegate>

@property (nonatomic, copy) NSString *user1Token, *user2Token;
@property (nonatomic, copy) NSString *inviteeRoomId;
@property (nonatomic, copy) NSString *inviteeUserId;
@property (nonatomic, assign) BOOL imConnected;
@property (nonatomic, strong) RCRTCRoom *room;
@property (nonatomic, strong) RCRTCOtherRoom *otherRoom;
@property (nonatomic, strong) ViewBuilder *viewBuilder;
@property (nonatomic, strong) UIAlertController *inviteAlertControler;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //跨房间连麦官网开发文档: https://docs.rongcloud.cn/v4/views/rtc/livevideo/guide/joinManage/joinAcross/ios.html
    
    //请填写登录用户1的token
    self.user1Token = USERID;
    
    //请填写登录用户2的token
    self.user2Token = TOKEN;
    
    self.imConnected = NO;
    
    //请填写您的 AppKey
    [[RCIMClient sharedRCIMClient] initWithAppKey:APP_KEY];
    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Verbose;
    
    self.viewBuilder = [[ViewBuilder alloc] initWithViewController:self];
}

#pragma mark - 登录用户1
- (void)user1ButtonAction {
    self.viewBuilder.user2Button.hidden = YES;
    [self connectJoin:self.user1Token];
}

#pragma mark - 登录用户2
- (void)user2ButtonAction {
    self.viewBuilder.user1Button.hidden = YES;
    [self connectJoin:self.user2Token];
}

#pragma mark - 连接IM
- (void)connectJoin:(NSString *)token {
    if (self.imConnected) {
        //已连接IM, 直接加入主房间
        [self joinMainRoom];
    }
    else {
        //连接IM成功后, 加入主房间
        [[RCIMClient sharedRCIMClient] connectWithToken:token
                                               dbOpened:^(RCDBErrorCode code) {}
                                                success:^(NSString *userId) {
            self.imConnected = YES;
            [self displayUserId:[NSString stringWithFormat:@"UserId: %@", userId]];
            [self displayStatusTip:@"IM连接成功"];
            [self joinMainRoom];
        } error:^(RCConnectErrorCode errorCode) {
            [self displayStatusTip:[NSString stringWithFormat:@"IM connect Error status: %zd", errorCode]];
        }];
    }
}

#pragma mark - 加入主房间
- (void)joinMainRoom {
    NSString *roomId = [NSString stringWithFormat:@"%zd", [self getRandomNumber:100000 to:999999]];
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    
    [[RCRTCEngine sharedInstance] joinRoom:roomId
                                    config:config
                                completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        if (code == 0) {
            self.room = room;
            self.room.delegate = self;
            
            [self displayRoomId:[NSString stringWithFormat:@"RoomID: %@", self.room.roomId]];
            [self.viewBuilder.displayBackView addSubview:self.viewBuilder.localVideoView];
            [self displayStatusTip:@"加入主房间成功"];
            
            //发布本地资源
            [self.room.localUser publishDefaultStreams:^(BOOL isSuccess, RCRTCCode code) {}];
        }
        else {
            [self displayStatusTip:[NSString stringWithFormat:@"加入主房间失败: %zd", code]];
        }
    }];
    
    //设置本地视频View
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:self.viewBuilder.localVideoView];
    //打开摄像头采集
    [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
    //打开扬声器
    [[RCRTCEngine sharedInstance] enableSpeaker:YES];
}

#pragma mark - 加入副房间
- (void)joinOtherRoom:(NSString *)otherRoomId {
    [[RCRTCEngine sharedInstance] joinOtherRoom:otherRoomId
                                     completion:^(RCRTCOtherRoom * _Nullable room, RCRTCCode code) {
        if (code == 0) {
            self.otherRoom = room;
            self.otherRoom.delegate = self;
            [self displayStatusTip:@"加入副房间成功"];
            
            //订阅 副房间 -> 远端用户 -> 已发布的资源
            if (self.otherRoom.remoteUsers.count > 0) {
                NSMutableArray *streamArray = [NSMutableArray array];
                for (RCRTCRemoteUser *user in self.otherRoom.remoteUsers) {
                    for (RCRTCInputStream *stream in user.remoteStreams) {
                        [streamArray addObject:stream];
                    }
                }
                
                if ([streamArray count]) {
                    [self subscribeRemoteResource:streamArray];
                }
            }
        }
        else {
            [self displayStatusTip:[NSString stringWithFormat:@"加入副房间失败: %zd", code]];
        }
    }];
}

#pragma mark - 离开主房间, leaveRoom:方法中包含离开已经加入的副房间
- (void)leaveButtonAction {
    if (!self.room) {
        [self displayStatusTip:@"未登录加入主房间前, 无法离开房间"];
        return;
    }
    else {
        [self displayStatusTip:@"离开主房间 和 已经加入的副房间"];
    }
    
    [self.viewBuilder.localVideoView removeFromSuperview];
    [self.viewBuilder.remoteVideoView removeFromSuperview];
    self.viewBuilder.roomIdLabel.text = @"";
    self.viewBuilder.statusLabel.text = @"";
    
    self.room = nil;
    self.otherRoom = nil;
    
    [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {}];
}

#pragma mark - 邀请连麦按钮点击事件
- (void)inviteButtonAction {
    if (self.otherRoom) {
        [self displayStatusTip:@"正在连麦中, 无法再次发起跨房间连麦邀请"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __block UITextField *roomIdTextField = nil;
        __block UITextField *userIdTextField = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"对方RoomID和UserID"
                                                                       message:@"请输入对方 '加入的主房间RoomID' 和 'UserID'"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
            textField.placeholder = @"RoomID";
            roomIdTextField = textField;
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
            textField.placeholder = @"UserID";
            userIdTextField = textField;
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
            //被邀请方的RoomId和UserId
            self.inviteeRoomId = roomIdTextField.text;
            self.inviteeUserId = userIdTextField.text;
            
            if (self.inviteeRoomId.length == 0 || self.inviteeUserId.length == 0) {
                [self displayStatusTip:@"请填写对方的roomId和userId"];
                return;
            }
            
            //邀请方连麦过程1: 在加入主房间成功后的基础上, 发起跨房间连麦邀请
            [self.room.localUser requestJoinOtherRoom:self.inviteeRoomId
                                               userId:self.inviteeUserId
                                              autoMix:YES
                                                extra:@""
                                           completion:^(BOOL isSuccess, RCRTCCode code) {
                NSString *tip = isSuccess ? @"发起邀请成功" : [NSString stringWithFormat:@"发起邀请失败: %zd", code];
                [self displayStatusTip:tip];
            }];
        }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - 取消已经发出的邀请
- (void)cancelInviteButtonAction {
    if (self.inviteeRoomId.length == 0 || self.inviteeUserId.length == 0) {
        [self displayStatusTip:@"先发起邀请后才能取消"];
        return;
    }
    
    //邀请发起方取消已经发出的邀请
    [self.room.localUser cancelRequestJoinOtherRoom:self.inviteeRoomId
                                             userId:self.inviteeUserId
                                              extra:@""
                                         completion:^(BOOL isSuccess, RCRTCCode code) {
        NSString *tip = isSuccess ? @"取消邀请成功" : [NSString stringWithFormat:@"取消邀请失败: %zd", code];
        [self displayStatusTip:tip];
    }];
}

#pragma mark - 订阅远端资源
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
    if (![streams count]) {
        return;
    }
    
    [self.room.localUser subscribeStream:streams
                             tinyStreams:@[]
                              completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess) {
            for (RCRTCInputStream *stream in streams) {
                if (stream.mediaType == RTCMediaTypeVideo) {
                    [((RCRTCVideoInputStream *)stream) setVideoView:self.viewBuilder.remoteVideoView];
                    [self.viewBuilder.displayBackView addSubview:self.viewBuilder.remoteVideoView];
                }
            }
            [self displayStatusTip:@"订阅资源成功"];
        }
        else {
            [self displayStatusTip:[NSString stringWithFormat:@"订阅资源失败: %zd", desc]];
        }
    }];
}

#pragma mark - RCRTCRoomEventDelegate
- (void)didPublishStreams:(NSArray <RCRTCInputStream *>*)streams {
    [self subscribeRemoteResource:streams];
}

- (void)didRequestJoinOtherRoom:(NSString *)inviterRoomId
                  inviterUserId:(NSString *)inviterUserId
                          extra:(NSString *)extra {
    //被邀请方连麦过程1: 被邀请方收到连麦邀请回调后, 做出接受/拒绝响应
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"拒绝"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *_Nonnull action) {
        [self.room.localUser responseJoinOtherRoom:inviterRoomId
                                            userId:inviterUserId
                                             agree:NO //拒绝邀请
                                           autoMix:YES
                                             extra:@""
                                        completion:^(BOOL isSuccess, RCRTCCode code) {
        }];
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"接受"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *_Nonnull action) {
        [self.room.localUser responseJoinOtherRoom:inviterRoomId
                                            userId:inviterUserId
                                             agree:YES //同意邀请
                                           autoMix:YES
                                             extra:@""
                                        completion:^(BOOL isSuccess, RCRTCCode code) {
            if (isSuccess) {
                //被邀请方连麦过程2: 被邀请方接受邀请后, 加入对方房间
                [self joinOtherRoom:inviterRoomId];
                [self displayStatusTip:@"接受邀请成功"];
            }
            else {
                [self displayStatusTip:[NSString stringWithFormat:@"接受邀请失败: %zd", code]];
            }
        }];
    }];
    
    NSString *msg = [NSString stringWithFormat:@"%@ 邀请连麦, 是否接受?", inviterUserId];
    self.inviteAlertControler = [UIAlertController alertControllerWithTitle:@"收到连麦邀请"
                                                                    message:msg
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [self.inviteAlertControler addAction:cancelAction];
    [self.inviteAlertControler addAction:okAction];
    [self presentViewController:self.inviteAlertControler
                       animated:YES
                     completion:nil];
}

- (void)didCancelRequestOtherRoom:(NSString *)inviterRoomId
                    inviterUserId:(NSString *)inviterUserId
                            extra:(NSString *)extra {
    //被邀请方连麦过程3: 被邀请方在做出 接受/拒绝 响应前, 邀请方主动取消了本次邀请
    [self.inviteAlertControler dismissViewControllerAnimated:YES
                                                  completion:^{}];
    [self displayStatusTip:@"发起方已取消邀请"];
}

- (void)didResponseJoinOtherRoom:(NSString *)inviterRoomId
                   inviterUserId:(NSString *)inviterUserId
                   inviteeRoomId:(NSString *)inviteeRoomId
                   inviteeUserId:(NSString *)inviteeUserId
                           agree:(BOOL)agree
                           extra:(NSString *)extra {
    if (agree) {
        [self displayStatusTip:@"对方同意邀请"];
        
        //邀请方连麦过程2: 邀请方收到被邀请方 '接受' 连麦响应后, 加入被邀请方房间
        [self joinOtherRoom:inviteeRoomId];
    }
    else {
        [self displayStatusTip:@"对方拒绝邀请"];
    }
}

- (void)didFinishOtherRoom:(NSString *)roomId
                    userId:(NSString *)userId {
    //连麦结束流程:
    //邀请方或被邀请方调用离开自己的主房间 leaveRoom: 或 调用离开对方的房间后,
    //对方会收到此回调, 也需要调用离开对方房间, 以达到结束跨房间连麦的目的
    [self.inviteAlertControler dismissViewControllerAnimated:YES
                                                  completion:^{}];
    [self.viewBuilder.remoteVideoView removeFromSuperview];
    [self displayStatusTip:@"对方结束连麦"];
    
    self.otherRoom = nil;
    [[RCRTCEngine sharedInstance] leaveOtherRoom:roomId
                                  notifyFinished:NO
                                      completion:^(BOOL isSuccess, RCRTCCode code) {}];
}

#pragma mark - RCRTCOtherRoomEventDelegate
- (void)room:(RCRTCBaseRoom *)room didLeaveUser:(RCRTCRemoteUser *)user {
    [self.viewBuilder.remoteVideoView removeFromSuperview];
}

#pragma mark - Private
- (void)displayRoomId:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewBuilder.roomIdLabel.text = msg;
    });
}

- (void)displayUserId:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewBuilder.userIdLabel.text = msg;
    });
}

- (void)displayStatusTip:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.viewBuilder.statusLabel.text = msg;
    });
}

- (NSInteger)getRandomNumber:(int)fromValue to:(int)toValue {
    return (NSInteger)(fromValue + (arc4random() % (toValue - fromValue + 1)));
}

@end
