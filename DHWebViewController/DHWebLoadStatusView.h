//
//  DHWebLoadStatusView.h
//  DHWebViewController
//
//  Created by DH on 2019/4/29.
//  Copyright © 2019年 DH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DHWebLoadStatusViewDelegate;
@interface DHWebLoadStatusView : UIView
// 接收一个error对象
@property (nonatomic, strong) NSError *error;
@property (nonatomic, weak) id <DHWebLoadStatusViewDelegate> delegate;
@end

@protocol DHWebLoadStatusViewDelegate <NSObject>
- (void)loadStatusViewDidTap:(DHWebLoadStatusView *)statusView;
@end
