//
//  UIViewController+AuthFailHandler.h
//  imeeting_iphone
//
//  Created by star king on 12-7-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AuthFailHandler)
- (void)onAuthFail:(NSUInteger)statusCode;
@end
