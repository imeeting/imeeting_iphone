//
//  UIViewExtensionManager.m
//  uiExtension
//
//  Created by  on 12-6-7.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import "UIViewExtensionManager.h"

#import "NSString+CommonUtils.h"

// static singleton UIViewExtensionManager reference
static UIViewExtensionManager *singletonUIViewExtensionManagerRef;

// UIViewExtensionManager extension
@interface UIViewExtensionManager ()

// validate UIView extension bean dictionary key
- (BOOL)validateUIViewExtensionBeanDicKey:(NSString *)pKey;

@end




@implementation UIViewExtensionManager

- (id)init{
    self = [super init];
    if (self) {
        // init UIView extension bean dictionary
        _mUIViewExtensionBeanDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (UIViewExtensionManager *)shareUIViewExtensionManager{
    @synchronized(self){
        if (nil == singletonUIViewExtensionManagerRef) {
            singletonUIViewExtensionManagerRef = [[self alloc] init];
        }
    }
    
    return singletonUIViewExtensionManagerRef;
}

- (void)setUIViewExtension:(id)pExtension withType:(UIViewExtensionType)pType forKey:(NSString *)pKey{
    if ([self validateUIViewExtensionBeanDicKey:pKey]) {
        // get UIView extension bean dictionary UIViewExtensionBean object
        UIViewExtensionBean *_uiViewExtensionBean = [self uiViewExtensionForKey:pKey];
        
        // check UIViewExtensionBean object
        _uiViewExtensionBean = (nil == _uiViewExtensionBean) ? [[UIViewExtensionBean alloc] init] : _uiViewExtensionBean;
        
        // update UIViewExtensionBean member and add in UIView extension bean dictionary
        switch (pType) {
            case titleExt:
                [_uiViewExtensionBean setTitle:pExtension];
                break;
            
            case leftBarButtonItemExt:
                [_uiViewExtensionBean setLeftBarButtonItem:pExtension];
                break;
                
            case rightBarButtonItemExt:
                [_uiViewExtensionBean setRightBarButtonItem:pExtension];
                break;
                
            case viewControllerRefExt:
                [_uiViewExtensionBean setViewControllerRef:pExtension];
                break;
        }
        [_mUIViewExtensionBeanDic setObject:_uiViewExtensionBean forKey:pKey];
    }
    else {
        NSLog(@"error : set UIView extension = %@ with type = %d for key = %@ error", pExtension, pType, pKey);
    }
}

- (UIViewExtensionBean *)uiViewExtensionForKey:(NSString *)pKey{
    UIViewExtensionBean *ret;
    
    if ([self validateUIViewExtensionBeanDicKey:pKey]) {
        ret = [_mUIViewExtensionBeanDic objectForKey:pKey];
    }
    else {
        NSLog(@"error : get UIViewExtensionBean object for key = %@ error", pKey);
    }
    
    return ret;
}

- (BOOL)validateUIViewExtensionBeanDicKey:(NSString *)pKey{
    BOOL ret = YES;
    
    if (!pKey || [[pKey trimWhitespaceAndNewline] isEqualToString:@""]) {
        NSLog(@"error : key = %@ is invalid", pKey);
        
        ret = NO;
    }
    
    return ret;
}

@end
