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
        UINavigationBar *navBar = self.navigationBar;
                
#define kSCNavBarImageTag 10
        if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            //if iOS 5.0 and later
            [navBar setBackgroundImage:[UIImage imageNamed:@"navigationbar.png"] forBarMetrics:UIBarMetricsDefault];
        }
        else
        {
            UIImageView *imageView = (UIImageView *)[navBar viewWithTag:kSCNavBarImageTag];
            if (imageView == nil)
            {
                imageView = [[UIImageView alloc] initWithImage:
                             [UIImage imageNamed:@"navigationbar.png"]];
                [imageView setTag:kSCNavBarImageTag];
                [navBar insertSubview:imageView atIndex:0];
            }
        }
    }
    return self;
}
@end
