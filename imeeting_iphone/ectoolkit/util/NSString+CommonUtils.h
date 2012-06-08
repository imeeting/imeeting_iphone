//
//  NSString+util.h
//  walkwork
//
//  Created by  on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CommonUtils)

// string md5
-(NSString*) md5;

// trim whitespace and new line character
-(NSString*) trimWhitespaceAndNewline;

// 根据字符串的字体大小获取字符串的像素长度
- (CGFloat)getStrPixelLenByFontSize:(CGFloat)fontSize;
// 根据字符串的字体大小获取字符串的像素高度
- (CGFloat)getStrPixelHeightByFontSize:(CGFloat)fontSize;
// 获得字符串的段落数组
-(NSArray*)getStrParagraphArray;

- (NSString *)trimPhoneNumberSeparator;

@end
