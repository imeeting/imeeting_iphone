//
//  ECLoginViewController.h
//  imeeting_iphone
//
//  Created by star king on 12-6-7.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"

@interface ECLoginViewController : UIViewController

@property (nonatomic) BOOL isForLogin; // indicate whether the login view is for login or account setting

- (void)jumpToRegisterView;

- (void)login;

@end
