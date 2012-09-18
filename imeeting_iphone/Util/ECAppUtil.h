//
//  ECAppUtil.h
//  imeeting_iphone
//
//  Created by king star on 12-8-23.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECAppUtil : NSObject

+ (void)addCallCenterNumberToAddressBook;
+ (NSString*)displayNameFromAttendee:(NSDictionary *)attendee;
@end
