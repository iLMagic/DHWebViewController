//
//  DHWebViewController.m
//  DHWebViewController
//
//  Created by DH on 2019/4/26.
//  Copyright © 2019年 DH. All rights reserved.
//

#import "DHWebViewController.h"
#import "DHWebLoadStatusView.h"
#import "DHWebViewTransitionDelegate.h"
#import <WebKit/WebKit.h>
/**
 vc的加载方式

 - DHWebViewVCLoadStyleNothing: 默认为根控制器，
 */
typedef NS_ENUM(NSInteger, DHWebViewVCLoadStyle) {
    DHWebViewVCLoadStyleNothing = 0, /// root vc
    DHWebViewVCLoadStyleBePushed, /// 被push出来的
    DHWebViewVCLoadStyleBePresented // 被present出来的
};

@protocol DHBackButtonHandlerProtocol <NSObject>
@optional
- (BOOL)dh_navigationShouldPopOnBackButton;
@end


@interface DHWebViewController () <DHWebLoadStatusViewDelegate, DHBackButtonHandlerProtocol>
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) DHWebLoadStatusView *statusView;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, assign) DHWebViewVCLoadStyle loadStyle;
@property (nonatomic, copy) void(^viewDidLoadhandler)(void);

@end

@implementation DHWebViewController

+ (instancetype)webViewWithURLString:(NSString *)URLString {
    DHWebViewController *vc = [self new];
    vc.URL = [NSURL URLWithString:URLString];
    __weak typeof(vc) weakVC = vc;
    vc.viewDidLoadhandler = ^{
        [weakVC loadWithURL:weakVC.URL];
    };
    return vc;
}

+ (instancetype)webViewWithURL:(NSURL *)URL {
    DHWebViewController *vc = [self new];
    vc.URL = URL;
    __weak typeof(vc) weakVC = vc;
    vc.viewDidLoadhandler = ^{
        [weakVC loadWithURL:weakVC.URL];
    };

    return vc;
}

- (BOOL)dh_navigationShouldPopOnBackButton {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        return NO;
    } else {
        return YES;
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self judgeLoadStyle];
   
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"image.bundle"];
    UIImage *backImage = [UIImage imageNamed:@"back" inBundle:[NSBundle bundleWithPath:path] compatibleWithTraitCollection:nil];
    UIImage *closeImage = [UIImage imageNamed:@"close" inBundle:[NSBundle bundleWithPath:path] compatibleWithTraitCollection:nil];

    
    _backItem = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(backItemDidClick)];
    _closeItem = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStyleDone target:self action:@selector(closeItemDidClick)];


    if (_loadStyle == DHWebViewVCLoadStyleBePresented) {
        self.navigationItem.leftBarButtonItems = @[_backItem];
    } else if (_loadStyle == DHWebViewVCLoadStyleBePushed) {
        self.navigationItem.leftItemsSupplementBackButton = YES;
    } else {
        
    }

    _statusView = ({
        DHWebLoadStatusView *view = [DHWebLoadStatusView new];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.delegate = self;
        [self.view addSubview:view];
        if (@available(iOS 11.0, *)) {
            [view.layoutMarginsGuide.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:self.view.safeAreaLayoutGuide.leadingAnchor multiplier:1.0f].active = YES;
            [self.view.safeAreaLayoutGuide.rightAnchor constraintEqualToSystemSpacingAfterAnchor:view.layoutMarginsGuide.rightAnchor multiplier:1.0f].active = YES;
            [view.layoutMarginsGuide.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.safeAreaLayoutGuide.topAnchor multiplier:1.0f].active = YES;
            [self.view.bottomAnchor constraintEqualToSystemSpacingBelowAnchor:view.layoutMarginsGuide.bottomAnchor multiplier:1.0f].active = YES;
        } else {
        
            NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTopMargin multiplier:1.0 constant:0];
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            [self.view addConstraints:@[left, right, top, bottom]];
        }
        view;
    });
    
    _webView = ({
        WKWebView *view = [[WKWebView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.navigationDelegate = self;
        view.UIDelegate = self;
        view.allowsBackForwardNavigationGestures = YES;
        [self.view addSubview:view];

        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.statusView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.statusView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.statusView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.statusView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.view addConstraints:@[left, right, top, bottom]];

        view;
    });

    _progressView = ({
        UIProgressView *p = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        p.translatesAutoresizingMaskIntoConstraints = NO;
        p.trackTintColor = [UIColor clearColor];
        p.progressTintColor = [UIColor colorWithRed:20/255.0 green:185/255.0 blue:15/255.0 alpha:1.0];
        [self.view addSubview:p];
        
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:p attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:p attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:p attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.webView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:p attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:2.5f];
        [self.view addConstraints:@[left, right, top]];
        [p addConstraint:height];
        p;
    });

    // kvo 监听网页加载进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    // kvo 监听网页title
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    // kvo 监听
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];

    if (self.viewDidLoadhandler) {
        self.viewDidLoadhandler();
    }
    // 添加手势
//    UIScreenEdgePanGestureRecognizer *panGR = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGREvent:)];
//    panGR.edges = UIRectEdgeLeft;
//    [self.view addGestureRecognizer:panGR];
}

- (void)panGREvent:(UIScreenEdgePanGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        if ([self.navigationController.transitioningDelegate isKindOfClass:[DHWebViewTransitionDelegate class]]) {
            DHWebViewTransitionDelegate *delegate =  (id)self.navigationController.transitioningDelegate;
            delegate.panGR = gr;
            [self dismissViewControllerAnimated:YES completion:nil];
        } else if ([self.transitioningDelegate isKindOfClass:[DHWebViewTransitionDelegate class]]) {
            DHWebViewTransitionDelegate *delegate =  (id)self.transitioningDelegate;
            delegate.panGR = gr;
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        // 加载完成
        if (self.webView.estimatedProgress  >= 1.0f ) {
            
            [UIView animateWithDuration:0.25f animations:^{
                self.progressView.alpha = 0.0f;
                self.progressView.progress = 0.0f;
            }];
            
        } else {
            self.progressView.alpha = 1.0f;
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        if (_loadStyle == DHWebViewVCLoadStyleBePresented) {
            // 被prsent出来的控制器
            if (self.webView.canGoBack) {
                self.navigationItem.leftBarButtonItems = @[_backItem, _closeItem];
            } else {
                self.navigationItem.leftBarButtonItems = @[_backItem];
            }
        } else if (_loadStyle == DHWebViewVCLoadStyleBePushed){
            if (self.webView.canGoBack) {
                self.navigationItem.leftBarButtonItem = _closeItem;
            } else {
                self.navigationItem.leftBarButtonItem = nil;
            }
        } else {
            if (self.webView.canGoBack) {
                self.navigationItem.leftBarButtonItem = _backItem;
            } else {
                self.navigationItem.leftBarButtonItem = nil;
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)backItemDidClick {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self closeItemDidClick];
    }
}

- (void)closeItemDidClick {
    if (_loadStyle == DHWebViewVCLoadStyleBePushed) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (!self.webView.backForwardList.currentItem) {
//        NSLog(@"入口网页加载失败：%@", error);
        [self loadError:error];
    } else {
//        NSLog(@"内部网页跳转失败：%@", error);
    }
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        if (navigationAction.request) {
            DHWebViewController *vc = [DHWebViewController webViewWithURL:navigationAction.request.URL];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    return nil;
}


#pragma mark - DHWebLoadStatusViewDelegate
- (void)loadStatusViewDidTap:(DHWebLoadStatusView *)statusView {
//    [self reloadWebView];
    [self loadWithURL:_URL];
}


/// load
- (void)loadWithURL:(NSURL *)URL {
    // 如果属性url为空，保存一下
    if (!_URL) {
        _URL = URL;
    }
    // 去掉缓存
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0f];
    [self.webView loadRequest:request];
    self.webView.hidden = NO;
    self.statusView.hidden = YES;
}

- (void)loadError:(NSError *)error {
    self.webView.hidden = YES;
    self.statusView.hidden = NO;
    self.statusView.error = error;
}



- (void)judgeLoadStyle {
    // 判断当前vc是push还是present出来
    if (self.presentingViewController) {
        _loadStyle = DHWebViewVCLoadStyleBePresented;
        // present
    } else {
        if (self.navigationController) {
            if (self.navigationController.childViewControllers.count == 1) {
                // root vc (no push no present)
                _loadStyle = DHWebViewVCLoadStyleNothing;
            } else {
                // push
                _loadStyle = DHWebViewVCLoadStyleBePushed;
            }
        } else {
            // root vc (no push no present)
            _loadStyle = DHWebViewVCLoadStyleNothing;
        }
    }
}

@end


@implementation UINavigationController (DHShouldPopOnBackButton)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    DHWebViewController *vc = (id)[self topViewController];
    if([vc respondsToSelector:@selector(dh_navigationShouldPopOnBackButton)]) {
        shouldPop = [vc dh_navigationShouldPopOnBackButton];
    }
    
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        for(UIView *subview in [navigationBar subviews]) {
            if(0. < subview.alpha && subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    
    return NO;
}

@end
