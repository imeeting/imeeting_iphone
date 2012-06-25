//
//  ECGroupModule.h
//  imeeting_iphone
//
//  it implements some actions for group and maintains some data
//
//  Created by star king on 12-6-25.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECGroupModule : NSObject

@property (nonatomic, retain) UIViewController *videoController;
@property (nonatomic, retain) UIViewController *attendeeController;
@property (nonatomic, retain) NSString *groupId;

- (void)onLeaveGroup;

@end
