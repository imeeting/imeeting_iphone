//
//  ECAppDelegate.h
//  imeeting_iphone
//
//  Created by star king on 12-6-4.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+CustomNavigation.h"

@class ECRootViewController;

@interface ECAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ECRootViewController *rootViewController;

@end
