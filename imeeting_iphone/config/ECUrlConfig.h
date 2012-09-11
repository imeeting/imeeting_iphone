//
//  ECUrlConfig.h
//  imeeting_iphone
//
//  Created by star king on 12-6-8.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ADDR                 @"http://www.wetalking.net/imeeting"
//#define SERVER_ADDR                 @"http://192.168.1.136:8080/imeeting"
#define RETRIEVE_PHONE_CODE_URL     [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/getPhoneCode"]
#define CHECK_PHONE_CODE_URL        [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/checkPhoneCode"]
#define USER_REGISTER_URL           [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/regUser"]
#define USER_LOGIN_URL              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/login"]
#define USER_REG_TOKEN              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/user/regToken"]

#define GET_CONF_LIST_URL          [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/list"]
#define CREATE_CONF_URL            [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/create"]
#define HIDE_CONF_URL              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/hide"]
#define JOIN_CONF_URL              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/join"]
#define UNJOIN_CONF_URL            [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/unjoin"]
#define GET_ATTENDEE_LIST_URL       [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/attendeeList"]
#define UPDATE_ATTENDEE_STATUS_URL  [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/updateAttendeeStatus"]
#define INVITE_ATTENDEE_LIST_URL    [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/invite"]
#define CALL_ATTENDEE_URL           [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/call"]
#define HANGUP_ATTENDEE_URL         [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/hangup"]
#define KICKOUT_ATTENDEE_URL        [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/kickout"]
#define HEART_BEAT_URL              [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/conference/heartbeat"]

#define ADDRESSBOOK_UPLOAD_URL      [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/addressbook/upload"]

#define HELP_PAGE_URL               [NSString stringWithFormat:@"%@%@", SERVER_ADDR, @"/help"]

#define NOTIFY_SERVER_HOST          @"msg.wetalking.net"
#define NOTIFY_SERVER_PORT          80
#define RTMP_SERVER_URL             @"rtmp://rtmp.wetalking.net/quick_server"
