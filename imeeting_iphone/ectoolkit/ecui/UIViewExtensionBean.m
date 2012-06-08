//
//  UIViewExtensionBean.m
//  uiExtension
//
//  Created by  on 12-6-7.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import "UIViewExtensionBean.h"

@implementation UIViewExtensionBean

@synthesize title = _title;
@synthesize leftBarButtonItem = _leftBarButtonItem;
@synthesize rightBarButtonItem = _rightBarButtonItem;

@synthesize viewControllerRef = _viewControllerRef;

- (NSString *)description{
    return [NSString stringWithFormat:@"UIViewExtensionBean description: title = %@, left bar button item = %@, right bar button item = %@ and view controller reference = %@", _title, _leftBarButtonItem, _rightBarButtonItem, _viewControllerRef];
}

@end
