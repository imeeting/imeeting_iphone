//
//  UserManager.m
//  walkwork
//
//  Created by ares on 11-11-1.
//  Copyright 2011年 __Nanjing futuo__. All rights reserved.
//

#import "UserManager.h"

#import "NSString+CommonUtils.h"

static UserManager *shareUserManager = nil;

@implementation UserManager

@synthesize userBean = _mUserBean;

+(UserManager *) shareSingleton {
    @synchronized(self){
        if(nil == shareUserManager) {
            shareUserManager = [super alloc];
            shareUserManager.userBean = [[UserBean alloc] init];
        }
    }
    
    return shareUserManager;
}

+(id) allocWithZone:(NSZone *)zone {
    @synchronized(self){
        if(nil == shareUserManager){
            shareUserManager = [super allocWithZone:zone];
            return shareUserManager;
        }
    }
    
    return shareUserManager;
}

-(id) copyWithZone:(NSZone *)zone {
    return self;
}

// set user name and password
-(UserBean *) setUser:(NSString *)pName andPwd:(NSString *)pPwd {
    if(nil == _mUserBean){
        _mUserBean = [[UserBean alloc] init];
    }
    
    // set user bean
    _mUserBean.name = pName;
    _mUserBean.password = pPwd;
    
    return _mUserBean;
}

-(UserBean *) setUserkey:(NSString *)pUserkey {
    if (nil == _mUserBean) {
        _mUserBean = [[UserBean alloc] init];
    }
    
    // set user key
    _mUserBean.userKey = pUserkey;
    return _mUserBean;
}


-(void) removeUser {
    _mUserBean = nil;
}

@end
