//
//  DHWebLoadStatusView.m
//  DHWebViewController
//
//  Created by DH on 2019/4/29.
//  Copyright © 2019年 DH. All rights reserved.
//

#import "DHWebLoadStatusView.h"

@interface DHWebLoadStatusView ()
@property (nonatomic, strong) UIImageView *reloadImgView;
@property (nonatomic, strong) UILabel *desLabel;
@end
@implementation DHWebLoadStatusView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap)];
        [self addGestureRecognizer:gr];
        _reloadImgView = ({
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"image.bundle"];
            UIImage *image = [UIImage imageNamed:@"reload" inBundle:[NSBundle bundleWithPath:path] compatibleWithTraitCollection:nil];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
            imgView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:imgView];
            
            NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:90];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:90];
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:90];

            [self addConstraints:@[centerX, top]];
            [imgView addConstraints:@[height, width]];

            imgView;
        });
        _desLabel = ({
            UILabel *label = [UILabel new];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.text = @"重新加载";
            label.font = [UIFont systemFontOfSize:13];
            label.textColor = [UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1.0];
            [self addSubview:label];
            
            NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.reloadImgView attribute:NSLayoutAttributeBottom   multiplier:1.0 constant:20];
            [self addConstraints:@[centerX, top]];
            
            label;
        });
    }
    return self;
}

- (void)setError:(NSError *)error {
    _error = error;
    if (error) {
        if (error.code == -1009) {
            _desLabel.text = @"网络连接失败，轻触屏幕重新加载";
        } else if (error.code == 404) {
            _desLabel.text = @"找不到网页，轻触屏幕重新加载";
        } else {
            _desLabel.text = @"发生未知错误，轻触屏幕重新加载";
        }
    } else {
        _desLabel.text = @"发生未知错误，轻触屏幕重新加载";
    }
}

- (void)viewDidTap {
    if ([self.delegate respondsToSelector:@selector(loadStatusViewDidTap:)]) {
        [self.delegate loadStatusViewDidTap:self];
    }
}

@end
