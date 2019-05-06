//
//  DHWebViewInterctiveTransition.m
//  DHWebViewController
//
//  Created by DH on 2019/4/29.
//  Copyright © 2019年 DH. All rights reserved.
//

#import "DHWebViewInterctiveTransition.h"
@interface DHWebViewInterctiveTransition ()
// 保存手势
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, weak) UIScreenEdgePanGestureRecognizer *panGR;

@property (nonatomic, assign) CGPoint beginPoint;
@end
@implementation DHWebViewInterctiveTransition
- (instancetype)initWithPanGR:(UIScreenEdgePanGestureRecognizer *)panGR {
    if (self = [super init]) {
        _panGR = panGR;
        [_panGR addTarget:self action:@selector(grEvent:)];
        //         began事件消息传递
        [self grEvent:panGR];
    }
    return self;
}

- (void)grEvent:(UIScreenEdgePanGestureRecognizer *)gr {
    CGPoint point = [gr locationInView:_transitionContext.containerView];
    //    NSLog(@"当前x坐标为：%f", point.x);
    
    if (gr.state == UIGestureRecognizerStateBegan) {
        _beginPoint = point;
        NSLog(@"起始点：%f", point.x);
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        CGFloat percent = [self calculatePercentWithCurrentPoint:point];
        [self updateInteractiveTransition:percent];
        NSLog(@"比例：%f", percent);
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        CGFloat percent = [self calculatePercentWithCurrentPoint:point];
        if (percent > 0.5) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    } else {
        CGFloat percent = [self calculatePercentWithCurrentPoint:point];
        if (percent > 0.5) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }

}


- (CGFloat)calculatePercentWithCurrentPoint:(CGPoint)point {
    
    UIViewController *fromVC = [_transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGSize size = [_transitionContext initialFrameForViewController:fromVC].size;
    
    CGFloat offset = point.x - _beginPoint.x;
    CGFloat percent = offset / size.width;
    return percent;
}

#pragma mark - UIViewControllerInteractiveTransitioning
- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    _transitionContext = transitionContext;
    [super startInteractiveTransition:transitionContext];
}


- (void)dealloc {
    NSLog(@"%s", __func__);
    [_panGR removeTarget:self action:@selector(grEvent:)];
}


@end
