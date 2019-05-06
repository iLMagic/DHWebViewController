//
//  DHWebViewTransitionDelegate.m
//  DHWebViewController
//
//  Created by DH on 2019/4/29.
//  Copyright © 2019年 DH. All rights reserved.
//

#import "DHWebViewTransitionDelegate.h"
#import "DHWebViewAnimator.h"
#import "DHWebViewInterctiveTransition.h"

@implementation DHWebViewTransitionDelegate 
#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    DHWebViewAnimator *d = [DHWebViewAnimator new];
    d.isPresent = YES;
    return d;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    DHWebViewAnimator *d = [DHWebViewAnimator new];
    d.isPresent = NO;
    return d;
}


- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {

    return [[DHWebViewInterctiveTransition alloc] initWithPanGR:_panGR];
}

@end
