//
//  ECUrlConfig.h
//  imeeting_iphone
//
//  Created by star king on 12-6-8.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ADDR                 @"http://www.walkwork.net/imeeting"
//#define SERVER_ADDR                 @"http://192.168.1.10:8080/imeeting"
#define RETRIEVE_PHONE_CODE_URL     [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/getPhoneCode"]
#define CHECK_PHONE_CODE_URL        [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/checkPhoneCode"]
#define USER_REGISTER_URL           [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/regUser"]
#define USER_LOGIN_URL              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/login"]
#define GET_GROUP_LIST_URL          [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/list"]
#define CREATE_GROUP_URL            [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/create"]
#define HIDE_GROUP_URL              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/hide"]
#define JOIN_GROUP_URL              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/join"]
#define UNJOIN_GROUP_URL            [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/unjoin"]
#define GET_ATTENDEE_LIST_URL       [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/attendeeList"]
#define UPDATE_ATTENDEE_STATUS_URL  [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/updateAttendeeStatus"]
#define INVITE_ATTENDEE_LIST_URL    [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/group/invite"]


#define NOTIFY_SERVER_HOST          @"msg.walkwork.net"
#define RTMP_SERVER_URL             @"rtmp://122.96.24.173/quick_server"