//
//  UIViewController+AuthFailHandler.m
//  imeeting_iphone
//
//  Created by star king on 12-7-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "UIViewController+AuthFailHandler.h"
#import "ECLoginViewController.h"

@interface AuthFailAlertDelegation : NSObject <UIAlertViewDelegate>
@property (nonatomic, retain) UIViewController *uiViewController;
@end

@implementation AuthFailAlertDelegation
@synthesize uiViewController = _uiViewController;

- (id)initWithUIViewController:(UIViewController*)controller {
    self = [super init];
    if (self) {
        self.uiViewController = controller;
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // jump to login view
    [self.uiViewController.navigationController pushViewController:[[ECLoginViewController alloc] init] animated:YES];
}

@end

@implementation UIViewController (AuthFailHandler)
- (void)onAuthFail:(NSUInteger)statusCode {
    if (statusCode == 400) {
        // invalide request parameters
        NSLog(@"bad request - invalide request parameters");
    } else if (statusCode == 401) {
        // unauthorized
        AuthFailAlertDelegation *afad = [[AuthFailAlertDelegation alloc] initWithUIViewController:self];
        [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"You login session is invalid now", nil) delegate:afad cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
    }
}
@end
