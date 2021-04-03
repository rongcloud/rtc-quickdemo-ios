//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCViewController.h"
#import <CoreMedia/CoreMedia.h>
NS_ASSUME_NONNULL_BEGIN

@interface RCViewController (Image)
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

NS_ASSUME_NONNULL_END
