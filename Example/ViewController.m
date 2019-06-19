//
//  ViewController.m
//  DHWebViewController
//
//  Created by DH on 2019/4/26.
//  Copyright © 2019年 DH. All rights reserved.
//

#import "ViewController.h"
#import "DHWebViewController.h"
#import "DHWebViewTransitionDelegate.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) DHWebViewTransitionDelegate *transitionDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DHWebViewController";
    // https://robot.odrcloud.cn/h5.html
    _textField.text = @"https://robot.odrcloud.cn/h5.html";
//    _textField.text = @"https://www.baidu.com";
}

- (IBAction)jumpH5:(id)sender {
//    _transitionDelegate = [DHWebViewTransitionDelegate new];
    DHWebViewController *vc = [DHWebViewController webViewWithURLString:_textField.text];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    nav.transitioningDelegate = _transitionDelegate;
//    nav.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:nav animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
