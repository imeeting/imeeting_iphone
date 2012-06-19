//
//  ECUrlConfig.h
//  imeeting_iphone
//
//  Created by star king on 12-6-8.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECUrlConfig : NSObject

+ (NSString*)ServerAddr;

+ (NSString*)RetrievePhoneCodeUrl;

+ (NSString*)CheckPhoneCodeUrl;

+ (NSString*)UserRegisterUrl;

+ (NSString*)UserLoginUrl;

+ (NSString*)GetGroupListUrl;

@end
