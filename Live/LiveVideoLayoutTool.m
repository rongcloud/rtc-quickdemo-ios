//
//  LiveVideoLayoutTool.m
//  RCRTCQuickDemo
//
//  Copyright © 2021 RongCloud. All rights reserved.
//

#import "LiveVideoLayoutTool.h"
#import "LiveStreamVideo.h"

@interface LiveVideoLayoutTool()

@property (nonatomic, strong)NSMutableArray<NSLayoutConstraint *> *layoutConstraints;

@end

@implementation LiveVideoLayoutTool

- (NSMutableArray<NSLayoutConstraint *> *)layoutConstraints {
    if (!_layoutConstraints) {
        _layoutConstraints = [[NSMutableArray<NSLayoutConstraint *> alloc] init];
    }
    return _layoutConstraints;
}

- (void)layoutVideos:(NSMutableArray *)videos
         inContainer:(UIView *)container {
    
    if (!videos.count) return;
    
    [NSLayoutConstraint deactivateConstraints:self.layoutConstraints];
    [self.layoutConstraints removeAllObjects];
    
    for (LiveStreamVideo *video in videos) {
        [video.canvesView removeFromSuperview];
    }
    
    NSArray *allViews = [self viewListFromVideos:videos maxCount:4 ignorVideo:nil];
    [self.layoutConstraints addObjectsFromArray:[self layoutGridViews:allViews inContainerView:container]];
    
    if (self.layoutConstraints.count) {
        [NSLayoutConstraint activateConstraints:self.layoutConstraints];
    }
}

- (NSArray<UIView *> *)viewListFromVideos:(NSArray *)videos
                                 maxCount:(NSUInteger)maxCount
                               ignorVideo:(LiveStreamVideo *)ignorVideo {
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (LiveStreamVideo *v in videos) {
        if (v == ignorVideo) {
            continue;
        }
        [views addObject:v.canvesView];
        if (views.count >= maxCount) {
            break;
        }
    }
    return [views copy];
}


- (NSArray<NSLayoutConstraint *> *)layoutFullScreenView:(UIView *)view inContainerView:(UIView *)contianer {
    
    NSMutableArray *layouts = [[NSMutableArray alloc] init];
    [contianer addSubview:view];
    
    NSArray<NSLayoutConstraint *> *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": view}];
    
    NSArray<NSLayoutConstraint *> *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": view}];
    
    [layouts addObjectsFromArray:constraintsH];
    [layouts addObjectsFromArray:constraintsV];
    
    return layouts.copy;
}


- (NSArray<NSLayoutConstraint *> *)layoutGridViews:(NSArray<UIView *> *)allViews inContainerView:(UIView *)container {
    
    NSMutableArray *layouts = [[NSMutableArray alloc] init];
    NSUInteger viewCount = allViews.count;
    if (viewCount == 1) {
        [layouts addObjectsFromArray:[self layoutFullScreenView:allViews.firstObject inContainerView:container]];
    } else if (viewCount == 2) {
        UIView *firstView = allViews.firstObject;
        UIView *lastView = allViews.lastObject;
        [container addSubview:firstView];
        [container addSubview:lastView];
        
        NSArray<NSLayoutConstraint *> *h1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1]-1-[view2]|" options:0 metrics:nil views:@{@"view1": firstView, @"view2": lastView}];
        
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        NSLayoutConstraint *equalW = [NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:firstView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        
        NSLayoutConstraint *equalH = [NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:firstView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        
        [layouts addObjectsFromArray:h1];
        [layouts addObjectsFromArray:@[left,top,bottom,equalW,equalH]];
        
    } else if (viewCount == 3) {
        UIView *firstView = allViews.firstObject;
        UIView *secondView = allViews[1];
        UIView *lastView = allViews.lastObject;
        [container addSubview:firstView];
        [container addSubview:secondView];
        [container addSubview:lastView];
        
        NSArray<NSLayoutConstraint *> *h1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1]-1-[view2]|" options:0 metrics:nil views:@{@"view1": firstView, @"view2": secondView}];
        NSArray<NSLayoutConstraint *> *v1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1]-1-[view2]|" options:0 metrics:nil views:@{@"view1": firstView, @"view2": lastView}];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:secondView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *equalWidth1 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:secondView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *equalWidth2 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *equalHeight1 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:secondView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        NSLayoutConstraint *equalHeight2 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        
        [layouts addObjectsFromArray:h1];
        [layouts addObjectsFromArray:v1];
        [layouts addObjectsFromArray:@[left, top, equalWidth1, equalWidth2, equalHeight1, equalHeight2]];
        
    } else if (viewCount >= 4) {
        UIView *firstView = allViews.firstObject;
        UIView *secondView = allViews[1];
        UIView *thirdView = allViews[2];
        UIView *lastView = allViews.lastObject;
        [container addSubview:firstView];
        [container addSubview:secondView];
        [container addSubview:thirdView];
        [container addSubview:lastView];
        
        NSArray<NSLayoutConstraint *> *h1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1]-1-[view2]|" options:0 metrics:nil views:@{@"view1": firstView, @"view2": secondView}];
        NSArray<NSLayoutConstraint *> *h2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1]-1-[view2]|" options:0 metrics:nil views:@{@"view1": thirdView, @"view2": lastView}];
        NSArray<NSLayoutConstraint *> *v1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1]-1-[view2]|" options:0 metrics:nil views:@{@"view1": firstView, @"view2": thirdView}];
        NSArray<NSLayoutConstraint *> *v2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1]-1-[view2]|" options:0 metrics:nil views:@{@"view1": secondView, @"view2": lastView}];
        
        NSLayoutConstraint *equalWidth1 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:secondView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *equalWidth2 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:thirdView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint *equalHeight1 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:secondView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        NSLayoutConstraint *equalHeight2 = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:thirdView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        
        [layouts addObjectsFromArray:h1];
        [layouts addObjectsFromArray:h2];
        [layouts addObjectsFromArray:v1];
        [layouts addObjectsFromArray:v2];
        [layouts addObjectsFromArray:@[equalWidth1, equalWidth2, equalHeight1, equalHeight2]];
    }
    
    return [layouts copy];
}




@end

