//
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "VideoLayoutTool.h"
#import <Masonry/Masonry.h>

@implementation VideoLayoutTool

- (void)layoutVideos:(NSMutableArray *)videos
         inContainer:(UIView *)container {
    for (StreamVideo *video in videos) {
        [video.canvesView removeFromSuperview];
    }
    NSArray *allViews = [self viewListFromVideos:videos maxCount:4 ignorVideo:nil];
    [self layoutGridViews:allViews inContainerView:container];

}

- (StreamVideo *)responseViewOfGesture:(UIGestureRecognizer *)gesture
                            WithVideos:(NSArray<StreamVideo *> *)videos
                       inContainerView:(UIView *)container {
    CGPoint location = [gesture locationInView:container];
    for (StreamVideo *video in videos) {
        CGRect rect = video.canvesView.frame;
        if (CGRectContainsPoint(rect, location)) {
            return video;
        }
    }
    return nil;
}


- (NSArray<UIView *> *)viewListFromVideos:(NSArray *)videos
                                 maxCount:(NSUInteger)maxCount
                               ignorVideo:(StreamVideo *)ignorVideo {
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (StreamVideo *v in videos) {
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


- (void)layoutFullScreenView:(UIView *)view inContainerView:(UIView *)contianer {
    [contianer addSubview:view];
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)layoutGridViews:(NSArray<UIView *> *)allViews inContainerView:(UIView *)container {
    NSUInteger viewCount = allViews.count;
    if (viewCount == 1) {
        [self layoutFullScreenView:allViews.lastObject inContainerView:container];
    } else if (viewCount == 2) {
        UIView *firstView = allViews.firstObject;
        UIView *lastView = allViews.lastObject;
        [container addSubview:firstView];
        [container addSubview:lastView];

        [firstView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.height / 2);
        }];
        [lastView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.equalTo(firstView.mas_bottom);
            make.height.equalTo(firstView);
        }];
    } else if (viewCount == 3) {
        UIView *firstView = allViews.firstObject;
        UIView *secondView = allViews[1];
        UIView *lastView = allViews.lastObject;
        [container addSubview:firstView];
        [container addSubview:secondView];
        [container addSubview:lastView];

        [firstView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.height / 2);
            make.width.mas_equalTo(UIScreen.mainScreen.bounds.size.width / 2);
        }];
        [secondView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.mas_equalTo(0);
            make.height.width.equalTo(firstView);
        }];
        [lastView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.equalTo(firstView);
        }];
    } else if (viewCount >= 4) {
        UIView *firstView = allViews.firstObject;
        UIView *secondView = allViews[1];
        UIView *thirdView = allViews[2];
        UIView *lastView = allViews.lastObject;
        [container addSubview:firstView];
        [container addSubview:secondView];
        [container addSubview:thirdView];
        [container addSubview:lastView];

        [firstView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.height.mas_equalTo(UIScreen.mainScreen.bounds.size.height / 2);
            make.width.mas_equalTo(UIScreen.mainScreen.bounds.size.width / 2);
        }];
        [secondView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.top.mas_equalTo(0);
            make.height.width.equalTo(firstView);
        }];
        [thirdView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(0);
            make.height.width.equalTo(firstView);
        }];
        [lastView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(0);
            make.height.width.equalTo(firstView);
        }];
    }
}

@end
