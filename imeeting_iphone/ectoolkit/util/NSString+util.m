//
//  NSString+util.m
//  walkwork
//
//  Created by  on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+util.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (util)

-(NSString*) md5{
    const char *cCharString = [self UTF8String];
    unsigned char result[16];
    
    CC_MD5(cCharString, strlen(cCharString), result);
    
    NSString *ret = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
    
    //NSLog(@"orig string: %@ and md5 = %@", ret, [ret uppercaseString]);
    
    return [ret uppercaseString];
}

-(NSString*) trimWhitespaceAndNewlineCharacter{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
