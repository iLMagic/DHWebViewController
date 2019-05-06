//
//  DHWebViewController.h
//  DHWebViewController
//
//  Created by DH on 2019/4/26.
//  Copyright © 2019年 DH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface DHWebViewController : UIViewController <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
+ (instancetype)webViewWithURLString:(NSString *)URLString;
+ (instancetype)webViewWithURL:(NSURL *)URL;

@end

