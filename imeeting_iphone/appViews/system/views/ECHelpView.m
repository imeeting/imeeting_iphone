//
//  ECHelpView.m
//  imeeting_iphone
//
//  Created by king star on 12-8-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECHelpView.h"
#import "ECConstants.h"

@implementation ECHelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // get UIScreen bounds
        CGRect _screenBounds = [[UIScreen mainScreen] bounds];
        
        // update contacts select container view frame
        self.frame = CGRectMake(_screenBounds.origin.x, _screenBounds.origin.y, _screenBounds.size.width, _screenBounds.size.height - /*statusBar height*/[[UIDevice currentDevice] statusBarHeight] - /*navigationBar height*/[[UIDevice currentDevice] navigationBarHeight]);

        self.delegate = self;
        
        self.leftBarButtonItem = [self makeBarButtonItem:NSLocalizedString(@"Setting", nil) backgroundImg:[UIImage imageNamed:@"back_navi_button"] frame:CGRectMake(0, 0, 53, 28) target:self action:@selector(onBackAction)];
        self.backgroundImg = [UIImage imageNamed:@"mainpage_bg"];
        
    }
    return self;
}


- (UIBarButtonItem *)makeBarButtonItem:(NSString *)title backgroundImg:(UIImage *)image frame:(CGRect)frame target:(id)target action:(SEL)action {
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame = frame;
    barButton.titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:13];
    [barButton setTitle:title forState:UIControlStateNormal];
    [barButton setBackgroundImage:image forState:UIControlStateNormal];
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView: barButton];
}

- (void)onBackAction {
    if (self.viewControllerRef) {
        [self.viewControllerRef.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // starting the load, show the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // finished loading, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // load error, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self animated:YES];
    
    // report the error inside the webview
    NSString* errorString = [NSString stringWithFormat:
                             @"<html><center><font size=+5 color='gray'>%@<br>%@</font></center></html>", NSLocalizedString(@"help page retrieve error", nil),
                             error.localizedDescription];
    [self loadHTMLString:errorString baseURL:nil];
}
@end
