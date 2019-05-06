//
//  DHWebViewController.m
//  DHWebViewController
//
//  Created by DH on 2019/4/26.
//  Copyright © 2019年 DH. All rights reserved.
//

#import "DHWebViewController.h"
#import <Masonry/Masonry.h>
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

@interface DHWebViewController () <DHWebLoadStatusViewDelegate>
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) DHWebLoadStatusView *statusView;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;
@property (nonatomic, assign) DHWebViewVCLoadStyle loadStyle;
@end

@implementation DHWebViewController

+ (instancetype)webViewWithURLString:(NSString *)URLString {
    DHWebViewController *vc = [self new];
    vc.URL = [NSURL URLWithString:URLString];
    return vc;
}

+ (instancetype)webViewWithURL:(NSURL *)URL {
    DHWebViewController *vc = [self new];
    vc.URL = URL;
    return vc;
}



- (void)viewDidLoad {
    [super viewDidLoad];
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
        view.delegate = self;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            } else {
                make.top.equalTo(self.view);
                make.left.equalTo(self.view);
                make.right.equalTo(self.view);
            }
            make.bottom.equalTo(self.view);
        }];
        view;
    });
    
    _webView = ({
        WKWebView *view = [[WKWebView alloc] init];
        view.navigationDelegate = self;
        view.allowsBackForwardNavigationGestures = YES;
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.statusView);
        }];
        view;
    });

    _progressView = ({
        UIProgressView *p = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//        p.backgroundColor = [UIColor clearColor];
        p.trackTintColor = [UIColor clearColor];
        p.progressTintColor = [UIColor colorWithRed:20/255.0 green:185/255.0 blue:15/255.0 alpha:1.0];
        [self.view addSubview:p];
        [p mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.webView);
            make.height.offset(2);
        }];
        p;
    });
    
    // kvo 监听网页加载进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    // kvo 监听网页title
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    // kvo 监听
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];

    [self loadWithURL:_URL];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
    [self.webView removeObserver:self forKeyPath:@"title" context:nil];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%@", navigationResponse.response.URL);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.webView.backForwardList.currentItem) {
        NSLog(@"内部网页跳转失败：%@", error);
        // toast提示
    } else {
        NSLog(@"入口网页加载失败：%@", error);
        [self loadError:error];
    }
}

#pragma mark - DHWebLoadStatusViewDelegate
- (void)loadStatusViewDidTap:(DHWebLoadStatusView *)statusView {
//    [self reloadWebView];
    [self loadWithURL:_URL];
}


/// load
- (void)loadWithURL:(NSURL *)URL {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
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
