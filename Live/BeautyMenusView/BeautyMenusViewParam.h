//
//  BeautyMenusViewParam.h
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BeautyMenusType) {
    BeautyMenusType_Filter, //滤镜
    BeautyMenusType_Whiteness, //美白
    BeautyMenusType_Ruddy, //红润
    BeautyMenusType_Smooth, //磨皮
    BeautyMenusType_Bright //亮度
};

@interface BeautyMenusViewParam : NSObject

- (instancetype)initWithType:(BeautyMenusType)type
                       value:(NSInteger)value
                       title:(NSString *)title
                       image:(NSString *)image
               selectedImage:(NSString *)selectedImage;

@property (nonatomic, assign) BeautyMenusType type;
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *selectedImage;

@end

NS_ASSUME_NONNULL_END
