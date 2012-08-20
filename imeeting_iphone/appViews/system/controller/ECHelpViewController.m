//
//  ECHelpViewController.m
//  imeeting_iphone
//
//  Created by king star on 12-8-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECHelpViewController.h"
#import "ECHelpView.h"
#import "CommonToolkit/CommonToolkit.h"
#import "ECUrlConfig.h"

@interface ECHelpViewController ()

@end

@implementation ECHelpViewController

- (id)init {
    return [self initWithCompatibleView:[[ECHelpView alloc] init]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIWebView *webView = (UIWebView*)self.view;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:HELP_PAGE_URL]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    UIWebView *webView = (UIWebView*)self.view;
    if ([webView isLoading]) {
        [webView stopLoading];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
