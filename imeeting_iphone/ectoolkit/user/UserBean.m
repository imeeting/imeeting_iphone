//
//  UserBean.m
//  walkwork
//
//  Created by ares on 11-11-1.
//  Copyright 2011年 __Nanjing futuo__. All rights reserved.
//

#import "UserBean.h"

@implementation UserBean

@synthesize name = _mName;
@synthesize passwordMd5 = _mPasswordMd5;
@synthesize userKey = _mUserKey;
@synthesize subscriberId = _mSubscriberId;
@synthesize nodeID = _mNodeID;
@synthesize balance = _mBalance;
@synthesize userType = _mUserType;

// overwrite method:(NSString*) description
- (NSString*) description{
    // define return string
    NSMutableString *_ret = [[NSMutableString alloc] init];
    
    [_ret appendFormat:@"Name:%@ ", _mName];
    [_ret appendFormat:@"Password MD5:%@ ", _mPasswordMd5];
    [_ret appendFormat:@"User key:%@ ", _mUserKey];
    [_ret appendFormat:@"Subscriber ID:%@ ", _mSubscriberId];
    [_ret appendFormat:@"Node ID:%@ ", _mNodeID];
    [_ret appendFormat:@"Balance:%@ ", _mBalance];
    [_ret appendFormat:@"User type:%@ ", _mUserType];
    
    return _ret;
}

@end