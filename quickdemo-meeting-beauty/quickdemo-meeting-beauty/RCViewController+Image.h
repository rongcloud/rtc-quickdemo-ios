//
//  RCViewController+Image.h
//  quickdemo-meeting-beauty
//
//  Created by RongCloud on 2021/1/5.
//

#import "RCViewController.h"
#import <CoreMedia/CoreMedia.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCViewController (Image)
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
