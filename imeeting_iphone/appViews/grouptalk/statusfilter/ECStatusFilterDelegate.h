//
//  ECStatusFilterDelegate.h
//  imeeting_iphone
//
//  validate the transformation of status
//
//  Created by star king on 12-7-10.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECStatusFilterDelegate <NSObject>

- (NSMutableDictionary*)filterStatusOfNew:(NSDictionary*)newAttendee withOld:(NSDictionary*)oldAttendee;

@end
