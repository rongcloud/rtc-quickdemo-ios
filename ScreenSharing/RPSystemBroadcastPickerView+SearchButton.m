//
//  RPSystemBroadcastPickerView+SearchButton.m
//  RCRTCQuickDemo
//
//  Created by wangyanxu on 2021/4/28.
//

#import "RPSystemBroadcastPickerView+SearchButton.h"

@implementation RPSystemBroadcastPickerView (SearchButton)

- (UIButton *)findButton {
    
    return [self findButton:self];
    
}

- (UIButton*)findButton:(UIView*)view {
    
    if(!view.subviews.count) {
        
        return nil;
        
    }
    
    if ([view isKindOfClass:[UIButton class]]) {
        return(UIButton*)view;
        
    }
    
    UIButton* btn;
    
    for(UIView* subView in view.subviews) {
        UIView* destinationView = [self findButton:subView];
        if(destinationView) {
            btn = (UIButton*)destinationView;
            break;
            
        }
        
    }
    
    return btn;
    
}





@end
