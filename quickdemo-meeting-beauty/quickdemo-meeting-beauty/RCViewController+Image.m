//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "RCViewController+Image.h"

@implementation RCViewController (Image)

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    CGRect rect =  CGRectMake(0, 0, image.size.width , image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
    CGContextRef currentContext =  UIGraphicsGetCurrentContext();
    CGContextClipToRect(currentContext, rect);
    CGContextRotateCTM(currentContext, M_PI);
    CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
    CGContextDrawImage(currentContext, rect, image.CGImage);
    UIImage* drawImage =  UIGraphicsGetImageFromCurrentImageContext();
    
    return drawImage;
}
@end


