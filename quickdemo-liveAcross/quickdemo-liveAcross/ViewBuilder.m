//
//  ViewBuilder.m
//  quickdemo-liveAcross
//
//  Created by RongCloud on 2020/12/24.
//

#import "ViewBuilder.h"
#import "ViewController.h"


@interface ViewBuilder ()

@property (nonatomic, weak) ViewController *viewController;
@property (nonatomic, strong) UIButton *inviteButton, *leaveButton;
@property (nonatomic, strong) UIButton *cancelInviteButton;

@end


@implementation ViewBuilder

- (instancetype)initWithViewController:(UIViewController *)vc {
    self = [super init];
    if (self)
    {
        self.viewController = (ViewController *) vc;
        [self initUIView];
    }
    return self;
}

- (void)initUIView {
    CGFloat inset = 20;
    CGFloat buttonX = 60;
    CGFloat buttonWidth = ([UIScreen mainScreen].bounds.size.width - inset * 3) / 2;
    CGFloat buttonHeight = 44;
    
    //登录用户1
    self.user1Button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.user1Button.frame = CGRectMake(inset, buttonX, buttonWidth, buttonHeight);
    [self.user1Button.layer setMasksToBounds:YES];
    [self.user1Button.layer setCornerRadius:4.0];
    self.user1Button.backgroundColor = [UIColor lightGrayColor];
    [self.user1Button setTitle:@"登录用户1" forState:UIControlStateNormal];
    [self.user1Button setTitle:@"登录用户1" forState:UIControlStateHighlighted];
    [self.user1Button addTarget:self.viewController action:@selector(user1ButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:self.user1Button];
    
    //登录用户2
    self.user2Button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.user2Button.frame = CGRectMake(inset * 2 + buttonWidth, buttonX, buttonWidth, buttonHeight);
    [self.user2Button.layer setMasksToBounds:YES];
    [self.user2Button.layer setCornerRadius:4.0];
    self.user2Button.backgroundColor = [UIColor lightGrayColor];
    [self.user2Button setTitle:@"登录用户2" forState:UIControlStateNormal];
    [self.user2Button setTitle:@"登录用户2" forState:UIControlStateHighlighted];
    [self.user2Button addTarget:self.viewController action:@selector(user2ButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:self.user2Button];
    
    //房间号
    self.roomIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset,
                                                                 self.user1Button.frame.origin.y + self.user1Button.frame.size.height + 10,
                                                                 [UIScreen mainScreen].bounds.size.width - inset * 2,
                                                                 30)];
    [self.viewController.view addSubview:self.roomIdLabel];
    
    //userID
    self.userIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset,
                                                                 self.roomIdLabel.frame.origin.y + self.roomIdLabel.frame.size.height,
                                                                 [UIScreen mainScreen].bounds.size.width - inset * 2,
                                                                 30)];
    [self.viewController.view addSubview:self.userIdLabel];
    
    //状态信息
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset,
                                                                 self.userIdLabel.frame.origin.y + self.userIdLabel.frame.size.height,
                                                                 [UIScreen mainScreen].bounds.size.width - inset * 2,
                                                                 30)];
    [self.viewController.view addSubview:self.statusLabel];
    
    //背景黑色
    self.displayBackView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    self.statusLabel.frame.origin.y + self.statusLabel.frame.size.height + 10,
                                                                    [UIScreen mainScreen].bounds.size.width,
                                                                    [UIScreen mainScreen].bounds.size.width * 3 / 4)];
    
    self.displayBackView.backgroundColor = [UIColor blackColor];
    [self.viewController.view addSubview:self.displayBackView];
    
    //本地视频View
    self.localVideoView = [[RCRTCLocalVideoView alloc] initWithFrame:CGRectMake(inset, 0, buttonWidth, self.displayBackView.frame.size.height)];
    self.localVideoView.fillMode = RCRTCVideoFillModeAspectFill;
    //    [self.displayBackView addSubview:self.localVideoView];
    
    //远端视频View
    self.remoteVideoView = [[RCRTCRemoteVideoView alloc] initWithFrame:CGRectMake(self.user2Button.frame.origin.x,
                                                                                  0,
                                                                                  buttonWidth,
                                                                                  self.displayBackView.frame.size.height)];
    self.remoteVideoView.fillMode = RCRTCVideoFillModeAspectFill;
    //    [self.displayBackView addSubview:self.remoteVideoView];
    
    //邀请按钮
    self.inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.inviteButton.frame = CGRectMake(inset,
                                         self.displayBackView.frame.origin.y + self.displayBackView.frame.size.height + inset,
                                         100,
                                         buttonHeight);
    [self.inviteButton.layer setMasksToBounds:YES];
    [self.inviteButton.layer setCornerRadius:4.0];
    self.inviteButton.backgroundColor = [UIColor lightGrayColor];
    [self.inviteButton setTitle:@"邀请连麦" forState:UIControlStateNormal];
    [self.inviteButton setTitle:@"邀请连麦" forState:UIControlStateHighlighted];
    [self.inviteButton addTarget:self.viewController action:@selector(inviteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:self.inviteButton];
    
    //取消邀请按钮
    self.cancelInviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.cancelInviteButton.frame = CGRectMake(inset,
                                               self.inviteButton.frame.origin.y + self.inviteButton.frame.size.height + inset,
                                               100,
                                               buttonHeight);
    [self.cancelInviteButton.layer setMasksToBounds:YES];
    [self.cancelInviteButton.layer setCornerRadius:4.0];
    self.cancelInviteButton.backgroundColor = [UIColor lightGrayColor];
    [self.cancelInviteButton setTitle:@"取消邀请" forState:UIControlStateNormal];
    [self.cancelInviteButton setTitle:@"取消邀请" forState:UIControlStateHighlighted];
    [self.cancelInviteButton addTarget:self.viewController action:@selector(cancelInviteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:self.cancelInviteButton];
    
    //离开房间按钮
    self.leaveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.leaveButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 20 - 100,
                                        self.displayBackView.frame.origin.y + self.displayBackView.frame.size.height + inset,
                                        100,
                                        buttonHeight);
    [self.leaveButton.layer setMasksToBounds:YES];
    [self.leaveButton.layer setCornerRadius:4.0];
    self.leaveButton.backgroundColor = [UIColor lightGrayColor];
    [self.leaveButton setTitle:@"离开房间" forState:UIControlStateNormal];
    [self.leaveButton setTitle:@"离开房间" forState:UIControlStateHighlighted];
    [self.leaveButton addTarget:self.viewController action:@selector(leaveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:self.leaveButton];
}

@end
