//
//  CDNMenuViewController.m
//  RCRTCQuickDemo
//
//  Created by Zafer.Lee on 2021/7/13.
//

#import "CDNMenuViewController.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface CDNMenuViewController ()
@property (nonatomic, assign) NSInteger selectIndex;
@end

@implementation CDNMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.selectIndex = -1;
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)selectVideoSize:(UIButton *)sender {
    for (int i=0; i<3; i++) {
        UIButton *btn = [self.view viewWithTag:541+i];
        btn.backgroundColor = RGB(169, 207, 255);
    }
    
    self.selectIndex = sender.tag - 541;
    sender.backgroundColor = RGB(96, 215, 255);
}


- (IBAction)reSubAction:(id)sender {
    if (self.selectIndex>=0 && self.selectIndexHandle) {
        self.selectIndexHandle(self.selectIndex);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

@end
