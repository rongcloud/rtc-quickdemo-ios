//
//  VideoLayoutTool.h
//  ios-live-quick-start
//
//  Created by huan xu on 2020/11/2.
//  Copyright © 2020 huan xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StreamVideo.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoLayoutTool : NSObject

- (void)layoutVideos:(NSMutableArray *)videos
         inContainer:(UIView *)container;

@end

NS_ASSUME_NONNULL_END
