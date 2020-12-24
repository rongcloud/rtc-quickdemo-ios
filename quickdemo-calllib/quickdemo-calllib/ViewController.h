//
//  ViewController.h
//  CallLibQuickstart
//
//  Created by Zafer.Lee on 2020/12/24.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *loginUser1;
@property (weak, nonatomic) IBOutlet UIButton *loginUser2;
@property (weak, nonatomic) IBOutlet UILabel *loginStatus;

@property (weak, nonatomic) IBOutlet UIView *positionView1;//占据本地视频位置
@property (weak, nonatomic) IBOutlet UIView *positionView2;//占据远端视频位置

@property (weak, nonatomic) IBOutlet UIButton *callOffBtn;
@property (weak, nonatomic) IBOutlet UIButton *callAcceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *callRejectBtn;

@end

