//
//  IntroductionViewController.m
//  first
//
//  Created by HS on 16/8/2.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "IntroductionViewController.h"

@interface IntroductionViewController ()<UIWebViewDelegate>
{
    UIImageView *loading;
    UILabel *loadingLabel;
}
@end

@implementation IntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"杭水简介";
    if (!_webView) {
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight+30)];
        _webView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.rabbitpre.com/m/jyyyI3E"]]];
        [self.view addSubview:_webView];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_webView) {
        
        [_webView removeFromSuperview];
        _webView = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //刷新控件
    loading                     = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    loading.center              = self.view.center;
    loadingLabel                = [[UILabel alloc] init];
    loadingLabel.text           = @"加载中...";
    loadingLabel.textAlignment  = NSTextAlignmentCenter;
    
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新1"];
    [loading setImage:image];
    [self.view addSubview:loading];
    [self.view addSubview:loadingLabel];
    [loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(loading.centerY).with.offset(55);
        make.centerX.equalTo(loading.centerX);
        make.size.equalTo(CGSizeMake(100, 50));
    }];
}

/**
 *  加载失败
 *
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [loading removeFromSuperview];
    [SCToastView showInView:self.view text:@"加载失败！请重试" duration:2.0f autoHide:YES];
}

/**
 *  加载完去除
 *
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loading removeFromSuperview];
    [loadingLabel removeFromSuperview];
}


@end
