//
//  CDNViewController.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/7/13.
//

#import "CDNViewController.h"
#import <RongRTCLib/RongRTCLib.h>
#import "CDNLiveViewController.h"
#import "CDNPullViewController.h"
#import "CDNPlayerViewController.h"
static NSString *const CDNLiveViewControllerId = @"CDNLiveViewController";
static NSString *const CDNPullViewControllerId = @"CDNPullViewController";
static NSString *const CDNPlayerViewControllerId = @"CDNPlayerViewController";



#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

@interface CDNViewController ()
@property (weak, nonatomic) IBOutlet UITextField *roomIdTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *cdnUrlTextFiled;

@property (nonatomic, strong) RCRTCRoom *room;
@property (nonatomic, strong) RCRTCLiveInfo *liveInfo;
@end

@implementation CDNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cdnUrlTextFiled.text = @"http://220.161.87.62:8800/hls/0/index.m3u8";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)beginLive:(id)sender {
    [self joinRoomRoleType:RCRTCLiveRoleTypeBroadcaster];
    
}

- (IBAction)joinLive:(id)sender {
    [self joinRoomRoleType:RCRTCLiveRoleTypeAudience];
}

- (IBAction)playCNDPlayer:(id)sender {
    [self jumpToCDNPlayer];
}

- (void)joinRoomRoleType:(RCRTCLiveRoleType)roleType {
    //1.配置房间
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    config.liveType = RCRTCLiveTypeAudioVideo;
    config.roleType = roleType;
    NSString *roomId = self.roomIdTextFiled.text;
    if (!roomId || roomId.length == 0) {
        return;
    }
    @WeakObj(self);
    [[RCRTCEngine sharedInstance] joinRoom:roomId config:config completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        @StrongObj(self);
        if (code == RCRTCCodeSuccess) {
            self.room = room;
            if (roleType == RCRTCLiveRoleTypeBroadcaster) {
                [self publishLocalLiveAVStream];
            } else {
                [self jumpToPullCDNLive];
            }
        } else {
            NSLog(@"%ld",code);
        }
    }];
}

//发布本地音视频流
- (void)publishLocalLiveAVStream {
    @WeakObj(self);
    [self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
        @StrongObj(self);
        if (isSuccess) {
            self.liveInfo = liveInfo;
            [self setMixConfig];
        } else {
            NSLog(@"%ld",desc);
        }
    }];
}

//设置分辨率和帧率
- (void)setMixConfig {
    RCRTCMixConfig *streamConfig = [[RCRTCMixConfig alloc] init];
    streamConfig.mediaConfig.videoConfig.videoLayout.width = 1080;
    streamConfig.mediaConfig.videoConfig.videoLayout.height = 1920;
    streamConfig.mediaConfig.videoConfig.videoLayout.fps = 30;
    @WeakObj(self);
    [self.liveInfo setMixConfig:streamConfig completion:^(BOOL isSuccess, RCRTCCode code) {
        @StrongObj(self);
        if (code == RCRTCCodeSuccess) {
            [self jumpToPushCDNLive];
        }
    }];
}

- (void)jumpToPushCDNLive {
    CDNLiveViewController *publishLiveVC = [self.storyboard instantiateViewControllerWithIdentifier:CDNLiveViewControllerId];
    publishLiveVC.room = self.room;
    publishLiveVC.liveInfo = self.liveInfo;
    publishLiveVC.roomId = self.roomIdTextFiled.text;
    [self.navigationController pushViewController:publishLiveVC animated:YES];
}

- (void)jumpToPullCDNLive {
    CDNPullViewController *joinLiveVC = [self.storyboard instantiateViewControllerWithIdentifier:CDNPullViewControllerId];
    joinLiveVC.room = self.room;
    joinLiveVC.roomId = self.roomIdTextFiled.text;
    [self.navigationController pushViewController:joinLiveVC animated:YES];
}


- (void)jumpToCDNPlayer {
    if (self.cdnUrlTextFiled.text.length == 0) {
        return;
    }
    CDNPlayerViewController *cdnPlayer = [self.storyboard instantiateViewControllerWithIdentifier:CDNPlayerViewControllerId];
    cdnPlayer.cdnUrl = self.cdnUrlTextFiled.text;
    [self.navigationController pushViewController:cdnPlayer animated:YES];
}
@end
