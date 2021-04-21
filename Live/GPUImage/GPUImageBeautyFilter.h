//
//  GPUImageBeautyFilter.h
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//


#import <GPUImage/GPUImage.h>


@interface GPUImageBeautyFilter : GPUImageFilter {
}

/**
 *美颜程度
 */
@property (nonatomic, assign) CGFloat beautyLevel;

/**
 *美白程度
 */
@property (nonatomic, assign) CGFloat brightLevel;

/**
 * 色调强度
 */
@property (nonatomic, assign) CGFloat toneLevel;

@end
