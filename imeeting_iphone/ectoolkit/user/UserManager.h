//
//  UserManager.h
//  walkwork
//
//  Created by ares on 11-11-1.
//  Copyright 2011年 __Nanjing futuo__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserBean.h"

@interface UserManager : NSObject {
    // user bean: user infomation
    UserBean *_mUserBean;
}

@property (nonatomic, retain) UserBean *userBean;

// Singleton
+(UserManager *) shareSingleton;

// add an user and remove one
-(UserBean *) setUser:(NSString *)pName andPwd:(NSString *)pPassword;
-(UserBean *) setUserkey:(NSString *)pUserkey;
-(void) removeUser;

@end
