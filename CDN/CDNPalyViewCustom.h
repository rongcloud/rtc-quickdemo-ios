//
//  CDNPalyViewCustom.h
//  RCRTCQuickDemo
//
//  Created by wangyanxu on 2022/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDNPalyViewCustom : UIImageView

- (void)addSampleBufferDisplayLayer;
- (void)dispatchPixelBuffer:(CVPixelBufferRef) pixelBuffer;

@end

NS_ASSUME_NONNULL_END
