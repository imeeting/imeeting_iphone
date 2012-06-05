//
//  NSString+util.h
//  walkwork
//
//  Created by  on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (util)

// string md5
-(NSString*) md5;

// trim whitespace and new line character
-(NSString*) trimWhitespaceAndNewlineCharacter;

@end
