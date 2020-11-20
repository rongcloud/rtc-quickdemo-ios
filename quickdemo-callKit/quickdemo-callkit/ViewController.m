//
//  ViewController.m
//  quickdemo-callKit


#import "ViewController.h"
#import <RongIMLib/RongIMLib.h>
#import <RongCallKit/RongCallKit.h>

@interface ViewController ()

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) NSString *callUser1Id, *callUser2Id;
@property (nonatomic, strong) NSString *callUser1Token, *callUser2Token;
@property (nonatomic, assign) BOOL isContect1, isSingleCall;
@property (nonatomic, assign) RCCallMediaType mediaType;
@property (nonatomic, strong) UILabel *statusLabel, *infoLabel;
@property (nonatomic, strong) UIButton *callUser1Button, *callUser2Button;
@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) UISwitch *audioVideoSwitch, *singleMultiSwitch;
@property (nonatomic, strong) UILabel *mediaLabel, *singleMultiLabel;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //User1
    self.callUser1Id = @"<#userId1#>";
    self.callUser1Token = @"<#请输入使用userId1生成的token#>";
    
    //User2
    self.callUser2Id = @"<#userId2#>";
    self.callUser2Token =  @"<#请输入使用userId2生成的token#>";
    
    self.targetId = @"<#groupId#>"; //群组ID, 只有在多人通话时才会用到, 单人通话时可以不填写, 发起多人通话时, 上面的两个用户必须在此群组targetId的群里, 且targetId不能为@"",否则无法正常通话
    
    self.isContect1 = NO;
    self.isSingleCall = YES;
    self.mediaType = RCCallMediaVideo;
    
    [[RCIMClient sharedRCIMClient] initWithAppKey:@"<#AppKey#>"]; //请登录融云官网获取AppKey
    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Verbose;
    [RCCall sharedRCCall]; //必须初始化, 否则无法收到来电
    [self initUIView];
}

- (void)initUIView {
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 40)];
    [self.view addSubview:self.statusLabel];
    
    self.callUser1Button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.callUser1Button.frame = CGRectMake(40, 100, 100, 100);
    self.callUser1Button.backgroundColor = [UIColor redColor];
    [self.callUser1Button setTitle:@"CallUser1" forState:UIControlStateNormal];
    [self.callUser1Button setTitle:@"CallUser1" forState:UIControlStateHighlighted];
    [self.callUser1Button addTarget:self action:@selector(callUser1ButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.callUser1Button];
    
    self.callUser2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.callUser2Button.frame = CGRectMake(200, 100, 100, 100);
    self.callUser2Button.backgroundColor = [UIColor redColor];
    [self.callUser2Button setTitle:@"CallUser2" forState:UIControlStateNormal];
    [self.callUser2Button setTitle:@"CallUser2" forState:UIControlStateHighlighted];
    [self.callUser2Button addTarget:self action:@selector(callUser2ButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.callUser2Button];
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.callButton.frame = CGRectMake(40, 220, 100, 100);
    self.callButton.backgroundColor = [UIColor greenColor];
    [self.callButton setTitle:@"发起呼叫" forState:UIControlStateNormal];
    [self.callButton setTitle:@"发起呼叫" forState:UIControlStateHighlighted];
    [self.callButton addTarget:self action:@selector(callButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.callButton];
    
    self.mediaLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 284, 100, 24)];
    self.mediaLabel.text = @"视频通话";
    self.mediaLabel.textColor = [UIColor redColor];
    self.mediaLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.mediaLabel];
    
    self.audioVideoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(230, 280, 60, 32)];
    [self.audioVideoSwitch addTarget:self action:@selector(audioVideoSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.audioVideoSwitch setOn:YES];
    [self.view addSubview:self.audioVideoSwitch];
    
    self.singleMultiLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 244, 100, 24)];
    self.singleMultiLabel.text = @"单人通话";
    self.singleMultiLabel.textColor = [UIColor orangeColor];
    self.singleMultiLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.singleMultiLabel];
    
    self.singleMultiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(230, 240, 60, 32)];
    [self.singleMultiSwitch addTarget:self action:@selector(singleMultiSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.singleMultiSwitch setOn:YES];
    [self.view addSubview:self.singleMultiSwitch];
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 340, [UIScreen mainScreen].bounds.size.width, 300)];
    self.infoLabel.backgroundColor = [UIColor yellowColor];
    self.infoLabel.font = [UIFont systemFontOfSize:14];
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.infoLabel.text = @"  操作步骤:\n  1. 第一个手机点CallUser1连接IM\n  2. 第二个手机点CallUser2连接IM\n  3. 两个手机都连接成功之后, 点击 发起呼叫\n\n  使用说明:\n  1. 请在登录官网获取AppKey, 填写在 ViewController.m的下面方法中\n  [[RCIMClient sharedRCIMClient] initWithAppKey:@""];\n  2. 请使用自定义 User1的ID 和 User2的ID, 生成对应 User1的Token 和 User1的Token, 填写在 ViewController.m中\n  3. 如果发起多人音视频通话必须填写正确的群组targetId, 否则无法正常发起呼叫.可以通过后台管理api调用生成groupId\n  4. 使用demo中的podfile, 通过 pod install 获取最新版本的融云SDK\n  5. pod安装完成后, 请打开pod生成的 RongCallKitQuickStart.xcworkspace\n  6. 本demo使用Xcode11创建";
    [self.view addSubview:self.infoLabel];
}

- (void)callUser1ButtonAction {
    self.isContect1 = YES;
    [[RCIMClient sharedRCIMClient] connectWithToken:self.callUser1Token
                                           dbOpened:^(RCDBErrorCode code) {}
                                            success:^(NSString *userId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = [NSString stringWithFormat:@"  Success UserId: %@", userId];
        });
    } error:^(RCConnectErrorCode errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = [NSString stringWithFormat:@"  Error status: %zd", errorCode];
        });
    }];
}

- (void)callUser2ButtonAction {
    self.isContect1 = NO;
    [[RCIMClient sharedRCIMClient] connectWithToken:self.callUser2Token
                                           dbOpened:^(RCDBErrorCode code) {}
                                            success:^(NSString *userId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = [NSString stringWithFormat:@"Success UserId: %@", userId];
        });
    } error:^(RCConnectErrorCode errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = [NSString stringWithFormat:@"Error status: %zd", errorCode];
        });
    }];
}

- (void)singleMultiSwitchAction {
    if (self.singleMultiSwitch.on) {
        self.singleMultiLabel.text = @"单人通话";
        self.singleMultiLabel.textColor = [UIColor orangeColor];
    }
    else {
        self.singleMultiLabel.text = @"多人通话";
        self.singleMultiLabel.textColor = [UIColor darkGrayColor];
    }
    
    self.isSingleCall = self.singleMultiSwitch.on;
}

- (void)audioVideoSwitchAction {
    if (self.audioVideoSwitch.on) {
        self.mediaType = RCCallMediaVideo;
        self.mediaLabel.text = @"视频通话";
        self.mediaLabel.textColor = [UIColor redColor];
    }
    else {
        self.mediaType = RCCallMediaAudio;
        self.mediaLabel.text = @"音频通话";
        self.mediaLabel.textColor = [UIColor blueColor];
    }
}

- (void)callButtonAction {
    if (self.isSingleCall) {
        NSString *calledUserId = self.isContect1 ? self.callUser2Id : self.callUser1Id;
        [[RCCall sharedRCCall] startSingleCall:calledUserId mediaType:self.mediaType];
    }
    else {
        NSAssert(self.targetId.length > 0, @"群组的self.targetId不能为空, 请填写正确的群组ID, 否则无法正常发起呼叫");
        NSArray *userIdArray = self.isContect1 ? @[self.callUser2Id] : @[self.callUser1Id];
        [[RCCall sharedRCCall] startMultiCallViewController:ConversationType_GROUP targetId:self.targetId mediaType:self.mediaType userIdList:userIdArray];
    }
}



@end
