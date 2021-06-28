//
//  RCRTCBeautyEngine.h
//  RongBeautyLib
//
//  Created by RongCloud on 2021/5/25.
//

#import <Foundation/Foundation.h>
#import <RongFaceBeautifier/RCRTCBeautyOption.h>
#import <RongFaceBeautifier/RCRTCBeautyFilter.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 美颜引擎类
 */
@interface RCRTCBeautyEngine : NSObject

/*!
 美颜引擎单例

 @remarks RCRTCBeautyEngine
 @since 5.x.x
 */
+ (instancetype)sharedInstance;

/*!
 设置美颜参数
 
 @param enable YES/NO 是否开启美颜 默认关闭
 @param option 美颜配置参数
 @return BOOL 是否设置成功
 */
- (BOOL)setBeautyOption:(BOOL)enable option:(nullable RCRTCBeautyOption *)option;

/*!
 设置滤镜
 
 @param filter 滤镜类型 默认原图
 @return BOOL 是否设置成功
 */
- (BOOL)setBeautyFilter:(RCRTCBeautyFilter)filter;

/*!
 重置美颜和滤镜
 
 @return BOOL 是否重置成功
 @discussion 重置后所有参数恢复默认值
             whitenessLevel = 0
             smoothLevel = 0
             ruddyLevel = 0
             brightLevel = 5
             filter = RCRTCBeautyFilterNone
 */
- (BOOL)reset;

/*!
 获取当前美颜参数

 @return RCRTCBeautyOption 当前美颜参数对象
 */
- (RCRTCBeautyOption *)getCurrentBeautyOption;

/*!
 获取当前滤镜参数

 @return RCRTCBeautyFilter 当前滤镜类型
 */
- (RCRTCBeautyFilter)getCurrentBeautyFilter;

@end

NS_ASSUME_NONNULL_END
