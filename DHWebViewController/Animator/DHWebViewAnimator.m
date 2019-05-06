//
//  DHWebViewAnimator.m
//  DHWebViewController
//
//  Created by DH on 2019/4/29.
//  Copyright © 2019年 DH. All rights reserved.
//

#import "DHWebViewAnimator.h"

@implementation DHWebViewAnimator
#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

// // 在present的时候，dismiss的时候都会调用这个方法
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    if (!fromView) {
        fromView = fromVC.view;
    }
    if (!toView) {
        toView = toVC.view;
    }
    UIView *containerView = transitionContext.containerView;
    //    containerView.backgroundColor = [UIColor clearColor];
    
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toVC];
    //    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromVC];
    CGRect fromViewInitFrame = [transitionContext initialFrameForViewController:fromVC];
    
    BOOL isPresent = _isPresent;
    
    if (isPresent) {
        // 获取toView的宽度，高度。
        CGFloat w = toViewFinalFrame.size.width;
        CGFloat h = toViewFinalFrame.size.height;
        // 计算初始view的frame
        CGFloat x = CGRectGetMaxX(fromViewInitFrame);
        CGFloat y = 0;
        toView.frame = CGRectMake(x, y, w, h);
        
        // toView最后加入，在最上层
        [containerView addSubview:toView];
        
        toView.layer.masksToBounds = NO;
        toView.layer.shadowOffset = CGSizeMake(-1, 0);
        toView.layer.shadowOpacity = 0.3;
        toView.layer.shadowColor = [UIColor blackColor].CGColor;
    } else {
        
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (isPresent) {
            toView.frame = toViewFinalFrame;
            CGFloat offset = -CGRectGetWidth(fromViewInitFrame) * 0.5;
            fromView.frame = CGRectOffset(fromView.frame, offset, 0);
        } else {
            CGFloat w = fromViewInitFrame.size.width;
            CGFloat h = fromViewInitFrame.size.height;
            CGFloat x = CGRectGetMaxX(toViewFinalFrame);
            CGFloat y = fromViewInitFrame.origin.y;
            fromView.frame = CGRectMake(x, y, w, h);
            
            CGFloat offset = CGRectGetWidth(toView.frame) * 0.5;
            toView.frame = CGRectOffset(toView.frame, offset, 0);
            
        }
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

@end
