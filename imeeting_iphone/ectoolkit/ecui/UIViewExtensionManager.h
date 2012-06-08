//
//  UIViewExtensionManager.h
//  uiExtension
//
//  Created by  on 12-6-7.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIViewExtensionBean.h"

@interface UIViewExtensionManager : NSObject {
    /*  UIView extension bean dictionary
     key = UIView class name(NSString)
     value = UIView extension bean(UIViewExtensionBean)
     */
    NSMutableDictionary *_mUIViewExtensionBeanDic;
}

// share singleton UIViewExtensionManager
+ (UIViewExtensionManager *)shareUIViewExtensionManager;

// set UIView extension with type for key
- (void)setUIViewExtension:(id)pExtension withType:(UIViewExtensionType)pType forKey:(NSString *)pKey;

// get UIViewExtensionBean for key
- (UIViewExtensionBean *)uiViewExtensionForKey:(NSString *)pKey;

@end
