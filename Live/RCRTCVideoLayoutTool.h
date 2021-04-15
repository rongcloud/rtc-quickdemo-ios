//
//  RCRTCVideoLayoutTool.h
//  RCRTCQuickDemo
//
//  Created by apple on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCVideoLayoutTool : NSObject

- (void)layoutVideos:(NSMutableArray *)videos
         inContainer:(UIView *)container;

@end

NS_ASSUME_NONNULL_END
