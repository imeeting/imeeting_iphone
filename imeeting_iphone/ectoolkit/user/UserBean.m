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
@synthesize password = _mPassword;
@synthesize userKey = _mUserKey;
@synthesize subscriberId = _mSubscriberId;
@synthesize nodeID = _mNodeID;
@synthesize balance = _mBalance;
@synthesize userType = _mUserType;
@synthesize rememberPwd = _rememberPwd;
@synthesize autoLogin = _autoLogin;

// overwrite method:(NSString*) description
- (NSString*) description{
    // define return string
    NSMutableString *_ret = [[NSMutableString alloc] init];
    
    [_ret appendFormat:@"Name:%@ ", _mName];
    [_ret appendFormat:@"Password:%@ ", _mPassword];
    [_ret appendFormat:@"User key:%@ ", _mUserKey];
    [_ret appendFormat:@"Subscriber ID:%@ ", _mSubscriberId];
    [_ret appendFormat:@"Node ID:%@ ", _mNodeID];
    [_ret appendFormat:@"Balance:%@ ", _mBalance];
    [_ret appendFormat:@"User type:%@ ", _mUserType];
    [_ret appendFormat:@"Remember Pwd:%d", _rememberPwd];
    [_ret appendFormat:@"Auto Login:%d", _autoLogin];
    return _ret;
}

@end