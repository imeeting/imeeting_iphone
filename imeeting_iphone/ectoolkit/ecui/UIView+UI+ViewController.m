//
//  UIView+UI+ViewController.m
//  uiExtension
//
//  Created by  on 12-6-7.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import "UIView+UI+ViewController.h"

#import "UIViewExtensionManager.h"

@implementation UIView (UI)

- (void)setTitle:(NSString *)title{
    [[UIViewExtensionManager shareUIViewExtensionManager] setUIViewExtension:title withType:titleExt forKey:NSStringFromClass(self.class)];
}

- (NSString *)title{
    return [[UIViewExtensionManager shareUIViewExtensionManager] uiViewExtensionForKey:NSStringFromClass(self.class)].title;
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem{
    [[UIViewExtensionManager shareUIViewExtensionManager] setUIViewExtension:leftBarButtonItem withType:leftBarButtonItemExt forKey:NSStringFromClass(self.class)];
}

- (UIBarButtonItem *)leftBarButtonItem{
    return [[UIViewExtensionManager shareUIViewExtensionManager] uiViewExtensionForKey:NSStringFromClass(self.class)].leftBarButtonItem;
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    [[UIViewExtensionManager shareUIViewExtensionManager] setUIViewExtension:rightBarButtonItem withType:rightBarButtonItemExt forKey:NSStringFromClass(self.class)];
}

- (UIBarButtonItem *)rightBarButtonItem{
    return [[UIViewExtensionManager shareUIViewExtensionManager] uiViewExtensionForKey:NSStringFromClass(self.class)].rightBarButtonItem;
}

@end




@implementation UIView (ViewController)

- (void)setViewControllerRef:(UIViewController *)viewControllerRef{
    [[UIViewExtensionManager shareUIViewExtensionManager] setUIViewExtension:viewControllerRef withType:viewControllerRefExt forKey:NSStringFromClass(self.class)];
    
    // update UIView UI
    self.viewControllerRef.title = self.title;
    self.viewControllerRef.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.viewControllerRef.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
}

- (UIViewController *)viewControllerRef{
    return [[UIViewExtensionManager shareUIViewExtensionManager] uiViewExtensionForKey:NSStringFromClass(self.class)].viewControllerRef;
}

- (BOOL)validateViewControllerRef:(UIViewController *)pViewControllerRef andSelector:(SEL)pSelector{
    BOOL ret = NO;
    
    // get self view controller reference
    UIViewController *_viewControllerRef = [[UIViewExtensionManager shareUIViewExtensionManager] uiViewExtensionForKey:NSStringFromClass(self.class)].viewControllerRef;
    
    // validate view controller reference and check selector implemetation
    if (_viewControllerRef && [_viewControllerRef respondsToSelector:pSelector]) {
        ret = YES;
    }
    else {
        NSLog(@"error : %@", _viewControllerRef ? [NSString stringWithFormat:@"%@ view controller %@ cann't implement method %@", NSStringFromClass(self.class), _viewControllerRef, NSStringFromSelector(pSelector)] : [NSString stringWithFormat:@"%@ view controller is nil", self]);
    }
    
    return ret;
}

@end