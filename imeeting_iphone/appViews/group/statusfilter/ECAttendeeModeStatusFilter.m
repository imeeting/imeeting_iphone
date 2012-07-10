//
//  ECAttendeeModeStatusFilter.m
//  imeeting_iphone
//
//  Created by star king on 12-7-10.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECAttendeeModeStatusFilter.h"

@implementation ECAttendeeModeStatusFilter

- (NSMutableDictionary *)filterStatusOfNew:(NSDictionary *)newAttendee withOld:(NSDictionary *)oldAttendee {
    NSMutableDictionary *filtered = [NSMutableDictionary dictionaryWithDictionary:newAttendee];
    return filtered;
}
@end
