//
//  RCRTCLoginViewController.m
//  RCRTCQuickDemo
//
//  Created by yifan on 2021/4/7.
//

#import "RCRTCLoginViewController.h"
#import "RCRTCRequestToken.h"
#import <RongIMKit/RCIM.h>
#import "RCRTCHomeViewController.h"


@interface RCRTCLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *useridTextField;

@end

@implementation RCRTCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (IBAction)connectIMServer:(UIButton *)sender {

    if (!self.useridTextField.text ||self.useridTextField.text.length == 0) {
        return;
    }
    
    [self.useridTextField resignFirstResponder];
    

    [RCRTCRequestToken requestToken:@"1" name:@"woshi" portraitUrl:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
    }];
    
//    [RCIM sharedRCIM] connectWithToken:<#(NSString *)#> dbOpened:<#^(RCDBErrorCode code)dbOpenedBlock#> success:<#^(NSString *userId)successBlock#> error:<#^(RCConnectErrorCode errorCode)errorBlock#>
//    RCRTCHomeViewController *mainVC = [[RCRTCHomeViewController alloc] init];
//    [self.navigationController pushViewController:mainVC animated:YES];
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
