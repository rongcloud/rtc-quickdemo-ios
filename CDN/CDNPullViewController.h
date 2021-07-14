//
//  CDNPullViewController.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/7/13.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDNPullViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *roomIdLabel;
@property (nonatomic, strong) RCRTCRoom *room;
@property (nonatomic, copy) NSString *roomId;
@end

NS_ASSUME_NONNULL_END
