//
//  BeautyMenusDividerView.m
//  RCRTCQuickDemo
//
//  Created by RongCloud on 2021/6/2.
//

#import "BeautyMenusDividerView.h"

@implementation BeautyMenusDividerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, height);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:40/255.0 green:30/255.0 blue:142/255.0 alpha:1.0].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 8.0, 0.0);
    CGFloat lengths[] = {20,8};
    CGContextSetLineDash(context, 0, lengths,2);
    CGContextAddLineToPoint(context, width - 8.0,0);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}


@end
