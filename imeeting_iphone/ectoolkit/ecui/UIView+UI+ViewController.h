//
//  UIView+UI+ViewController.h
//  uiExtension
//
//  Created by  on 12-6-7.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import <UIKit/UIKit.h>

// UIView UI category
@interface UIView (UI)

// title
@property (nonatomic, retain) NSString *title;

// navigation bar left button item
@property (nonatomic, retain) UIBarButtonItem *leftBarButtonItem;

// navigation bar right button item
@property (nonatomic, retain) UIBarButtonItem *rightBarButtonItem;

@end




// UIView view controller category
@interface UIView (ViewController)

// view controller reference
@property (nonatomic, retain) UIViewController *viewControllerRef;

// validate view controller reference and check selector
- (BOOL)validateViewControllerRef:(UIViewController*) pViewControllerRef andSelector:(SEL) pSelector;

@end