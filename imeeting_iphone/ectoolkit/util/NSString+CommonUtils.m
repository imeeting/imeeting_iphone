//
//  NSString+util.m
//  walkwork
//
//  Created by  on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+CommonUtils.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (CommonUtils)

-(NSString*) md5{
    const char *cCharString = [self UTF8String];
    unsigned char result[16];
    
    CC_MD5(cCharString, strlen(cCharString), result);
    
    NSString *ret = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
    
    //NSLog(@"orig string: %@ and md5 = %@", ret, [ret uppercaseString]);
    
    return [ret uppercaseString];
}

-(NSString*) trimWhitespaceAndNewline{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// 根据字符串的字体大小获取字符串的像素长度
- (CGFloat)getStrPixelLenByFontSize:(CGFloat)fontSize
{
    CGSize size = [self sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    return size.width;
}

// 根据字符串的字体大小获取字符串的像素高度
- (CGFloat)getStrPixelHeightByFontSize:(CGFloat)fontSize
{
    CGSize size = [self sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    return size.height;
}

// 获得字符串的段落数组
-(NSArray*)getStrParagraphArray
{
    // string paragraph array
    NSArray *_paragraphArray = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    //NSLog(@"paragraph array = %@ and count = %d", _paragraphArray, [_paragraphArray count]);
    
    return _paragraphArray;
}

- (NSString *)trimPhoneNumberSeparator{
    NSMutableString *_ret = [[NSMutableString alloc] init];
    
    NSArray *_separatedArray = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()- "]];
    
    for(NSString *_string in _separatedArray){
        [_ret appendString:_string];
    }
    
    return _ret;
}


@end
