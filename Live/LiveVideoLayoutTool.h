//
//  LiveVideoLayoutTool.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 * 约束布局
 */
NS_ASSUME_NONNULL_BEGIN

@interface LiveVideoLayoutTool : NSObject

- (void)layoutVideos:(NSMutableArray *)videos
         inContainer:(UIView *)container;

@end

NS_ASSUME_NONNULL_END
