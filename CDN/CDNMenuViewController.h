//
//  CDNMenuViewController.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDNMenuViewController : UIViewController
@property (nonatomic, copy) void (^selectIndexHandle)(NSInteger index);
@end

NS_ASSUME_NONNULL_END
