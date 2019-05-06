//
//  DHWebViewTransitionDelegate.h
//  DHWebViewController
//
//  Created by DH on 2019/4/29.
//  Copyright © 2019年 DH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHWebViewTransitionDelegate : NSObject <UIViewControllerTransitioningDelegate>
@property (nonatomic, weak) UIScreenEdgePanGestureRecognizer *panGR;
@end
