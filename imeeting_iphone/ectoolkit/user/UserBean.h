//
//  User.h
//  walkwork
//
//  Created by ares on 11-11-1.
//  Copyright 2011年 __Nanjing futuo__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBean : NSObject {
    // name
    NSString *_mName;
    // password md5
    NSString *_mPassword;
    // user key
    NSString *_mUserKey;
    // subscribe id
    NSString *_mSubscriberId;
    // node id
    NSString *_mNodeID;
    // balance
    NSString *_mBalance;
    // user type
    NSString *_mUserType;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *userKey;
@property (nonatomic, retain) NSString *subscriberId;
@property (nonatomic, retain) NSString *nodeID;
@property (nonatomic, retain) NSString *balance;
@property (nonatomic, retain) NSString *userType;
@property (nonatomic) BOOL rememberPwd;
@property (nonatomic) BOOL autoLogin;

@end