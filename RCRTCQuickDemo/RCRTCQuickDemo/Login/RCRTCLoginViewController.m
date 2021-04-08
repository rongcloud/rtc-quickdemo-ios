//
//  RCRTCLoginViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/7.
//

#import "RCRTCLoginViewController.h"
#import "RCRTCHomeViewController.h"

@interface RCRTCLoginViewController ()

@end

@implementation RCRTCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (IBAction)connectIMServer:(UIButton *)sender {

    RCRTCHomeViewController *mainVC = [[RCRTCHomeViewController alloc] init];
    [self.navigationController pushViewController:mainVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
