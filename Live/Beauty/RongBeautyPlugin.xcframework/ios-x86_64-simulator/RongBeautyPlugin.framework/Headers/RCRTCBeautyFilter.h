//
//  RCRTCBeautyFilter.h
//  RongBeautyPlugin
//
//  Created by RongCloud on 2021/5/27.
//

#ifndef RCRTCBeautyFilter_h
#define RCRTCBeautyFilter_h

#import <Foundation/Foundation.h>

/**
 滤镜类型
 */
typedef NS_ENUM(NSInteger, RCRTCBeautyFilter) {
    /*!
     原图
     */
    RCRTCBeautyFilterNone,
    /*!
     唯美
     */
    RCRTCBeautyFilterEsthetic,
    /*!
     清新
     */
    RCRTCBeautyFilterFresh,
    /*!
     浪漫
     */
    RCRTCBeautyFilterRomantic
};

#endif /* RCRTCBeautyFilter_h */
