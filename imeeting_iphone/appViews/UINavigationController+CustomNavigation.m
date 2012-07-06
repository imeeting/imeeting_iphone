//
//  UINavigationController+CustomNavigation.m
//  imeeting_iphone
//
//  Created by star king on 12-6-26.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "UINavigationController+CustomNavigation.h"
#import "CommonToolkit/CommonToolkit.h"

@implementation UINavigationController (CustomNavigation)
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        // set navigationBar tint color
        self.navigationBar.tintColor = [UIColor colorWithIntegerRed:54 integerGreen:54 integerBlue:54 alpha:1];
    }
    return self;
}
@end
