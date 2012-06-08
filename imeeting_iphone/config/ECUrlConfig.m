//
//  ECUrlConfig.m
//  imeeting_iphone
//
//  Created by star king on 12-6-8.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECUrlConfig.h"


@implementation ECUrlConfig

+ (NSString*)ServerAddr {
    static NSString *serverAddr = @"http://192.168.1.13/imeeting";
    return serverAddr;
}

+ (NSString*)RetrievePhoneCodeUrl {
    NSString *retrievePhoneCodeUrl = [NSString stringWithFormat:@"%@%@", [ECUrlConfig ServerAddr], @"/user/getPhoneCode"];
    return retrievePhoneCodeUrl;
}

+ (NSString*)CheckPhoneCodeUrl {
    return [NSString stringWithFormat:@"%@%@", [ECUrlConfig ServerAddr], @"/user/checkPhoneCode"];
}

+ (NSString*)UserRegisterUrl {
    return [NSString stringWithFormat:@"%@%@", [ECUrlConfig ServerAddr], @"/user/regUser"];
}

+ (NSString*)UserLoginUrl {
    return [NSString stringWithFormat:@"%@%@", [ECUrlConfig ServerAddr], @"/user/login"];
}

@end
