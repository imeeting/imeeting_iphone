//
//  ECGroupManager.m
//  imeeting_iphone
//
//  Created by star king on 12-6-25.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupManager.h"

static ECGroupManager *instance;

@implementation ECGroupManager

@synthesize currentGroupModule = _currentGroup;

+ (ECGroupManager*)sharedECGroupManager {
    if (instance == nil) {
        instance = [[ECGroupManager alloc] init];
    }
    return instance;
}

@end
