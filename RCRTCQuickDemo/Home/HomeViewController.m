//
//  RCRTCHomeViewController.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "HomeViewController.h"
#import "UIAlertController+RCRTC.h"
#import "HomeTableViewCell.h"

# import <RongIMLibCore/RongIMLibCore.h>

/*!
 首页 包含集成的多种场景功能
 meeting 1v1: 1v1 会议
 live   : 直播
 calllib: 根据 calllib 完成 1v1 呼叫功能
 callkit: 根据 callKit 完成 1v1 呼叫功能
 */
@interface HomeViewController () <RCConnectionStatusChangeDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UILabel *currentUserLabel;

// 存放所有类型的数组
@property(strong, nonatomic) NSArray *sourceArray;

@end

@implementation HomeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RCRTCList" ofType:@"plist"];
    self.sourceArray = [NSArray arrayWithContentsOfFile:plistPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // 配置 IM
    [self setRongCloudDelegate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)initUI {
    self.currentUserLabel.text = [NSString stringWithFormat:@"User ID ：%@", [RCCoreClient sharedCoreClient].currentUserInfo.userId];
}

- (void)setRongCloudDelegate {
    // 设置连接状态监听
    [[RCCoreClient sharedCoreClient] setRCConnectionStatusChangeDelegate:self];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    [cell setDataModel:self.sourceArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.sourceArray objectAtIndex:indexPath.row];
    NSString *storyboardName = cellData[@"storyboardName"];
    NSString *controllerIdentifier = cellData[@"controllerIdentifier"];
    [self pushViewController:storyboardName identifier:controllerIdentifier];
}

// 注销当前账户
- (IBAction)logout:(UIButton *)sender {

    [[RCCoreClient sharedCoreClient] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)pushViewController:(NSString *)storyboardName identifier:(NSString *)identifier {

    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *callKitVC = [sb instantiateViewControllerWithIdentifier:identifier];
    [self.navigationController pushViewController:callKitVC animated:YES];
}

#pragma mark - RCConnectionStatusChangeDelegate

- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    // 互踢提示
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIAlertController alertWithString:@"当前用户在其他设备登陆" inCurrentViewController:nil];
        });
    }
}

@end
