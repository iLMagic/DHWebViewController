//
//  DHWebViewInterctiveTransition.h
//  DHWebViewController
//
//  Created by DH on 2019/4/29.
//  Copyright © 2019年 DH. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DHWebViewInterctiveTransition : UIPercentDrivenInteractiveTransition
- (instancetype)initWithPanGR:(UIScreenEdgePanGestureRecognizer *)panGR;
@end

