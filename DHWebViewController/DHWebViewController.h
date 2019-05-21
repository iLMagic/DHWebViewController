//
//  DHWebViewController.h
//  DHWebViewController
//
//  Created by DH on 2019/4/26.
//  Copyright © 2019年 DH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/**
 支持push
 */
@interface DHWebViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
+ (instancetype)webViewWithURLString:(NSString *)URLString;
+ (instancetype)webViewWithURL:(NSURL *)URL;

/**
 使用方式：继承此控制器
 
 vc = [UIViewController new]
 需要在子类的viewdidLoad实现此方法

 @param URL 传入url
 */
- (void)loadWithURL:(NSURL *)URL;
/**
 内部实现了WKNavigationDelegate，并实现了此方法，子类需要调用super

 @param webView webView
 @param navigation navigation
 @param error error
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;


/**
 内部实现了WKUIDelegate，并实现了此方法，子类需要调用super

 @param webView webView
 @param configuration configuration
 @param navigationAction navigationAction
 @param windowFeatures windowFeatures
 @return nil
 */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;
@end

