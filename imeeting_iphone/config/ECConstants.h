//
//  ECConstants.h
//  imeeting_iphone
//
//  Created by star king on 12-6-14.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

static CGFloat StatusBarHeight = 20;
static CGFloat NavigationBarHeight = 44;


// GROUP CONSTANTS
static NSString *GROUP_ID = @"groupId";
static NSString *GROUP_TITLE = @"title";
static NSString *GROUP_ATTENDEES = @"attendees";
static NSString *GROUP_CREATED_TIME = @"created_time";
static NSString *GROUP_STATUS = @"status";

// Attendee Constants
static NSString *USERNAME = @"username";
static NSString *ONLINE_STATUS = @"online_status";
static NSString *VIDEO_STATUS = @"video_status";
static NSString *TELEPHONE_STATUS = @"telephone_status";


// Status Constants
// online status
static NSString *ONLINE = @"online";
static NSString *OFFLINE = @"offline";
// video status
static NSString *ON = @"on";
static NSString *OFF = @"off";
// telephone status
static NSString *IDLE = @"idle";
static NSString *CALLING = @"calling";


// Notify Constants
static NSString *TOPIC = @"topic";
static NSString *SUBSCRIBER_ID = @"subscriber_id";
static NSString *SUBSCRIBE = @"subscribe";
static NSString *NOTICE_LIST = @"notice_list";
static NSString *CMD = @"cmd";
static NSString *NOTICE = @"notice";
static NSString *NOTIFY = @"notify";
static NSString *CACHE = @"cache";