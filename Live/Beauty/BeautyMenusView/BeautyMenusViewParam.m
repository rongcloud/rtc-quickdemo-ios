//
//  BeautyMenusViewParam.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/7.
//

#import "BeautyMenusViewParam.h"

@implementation BeautyMenusViewParam

- (instancetype)initWithType:(BeautyMenusType)type
                       value:(NSInteger)value
                       title:(NSString *)title
                       image:(NSString *)image
               selectedImage:(NSString *)selectedImage {
    self = [super init];
    if (self) {
        _type = type;
        _value = value;
        _title = title;
        _image = image;
        _selectedImage = selectedImage;
    }
    return self;
}

@end
