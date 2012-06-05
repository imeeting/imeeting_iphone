//
//  UIColor+ECUIColor.m
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "UIColor+ECUIColor.h"

@implementation UIColor (ECUIColor)

+ (UIColor*)colorWithRGB:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

@end
