//
//  ECConstants.h
//  imeeting_iphone
//
//  Created by star king on 12-6-14.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CHINESE_FONT            @"ArialMT"
#define CHINESE_BOLD_FONT       @"Arial-BoldMT"
#define CHARACTER_FONT          @"ArialMT"
#define CHARACTER_BOLD_FONT     @"Arial-BoldMT"

#define CALL_CENTER_NUM         @"05512379997"

//#define MAX_MEMBER_LIMIT        5

static CGFloat StatusBarHeight = 20;
static CGFloat NavigationBarHeight = 44;

// IOS push notification device token
static NSString *TOKEN = @"token";

// Account CONSTANTS
static NSString *PASSWORD = @"password";
static NSString *USERKEY = @"userkey";
static NSString *AUTOLOGIN = @"autologin";

// GROUP CONSTANTS
static NSString *GROUP_ID = @"conferenceId";
static NSString *GROUP_TITLE = @"title";
static NSString *GROUP_ATTENDEES = @"attendees";
static NSString *GROUP_CREATED_TIME = @"created_time";
static NSString *GROUP_STATUS = @"status";
static NSString *AUDIO_CONF_ID = @"audioConfId";
static NSString *OWNER = @"owner";

// Attendee Constants
static NSString *ATTENDEE = @"attendee";
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
static NSString *CALL_WAIT = @"CallWait";
static NSString *ESTABLISHED = @"Established";
static NSString *FAILED = @"Failed";
static NSString *TERMINATED = @"Terminated";
static NSString *TERMWAIT = @"TermWait";

// Notify Constants
static NSString *TOPIC = @"topic";
static NSString *MSG = @"msg";
static NSString *SUBSCRIBER_ID = @"subscriber_id";
static NSString *SUBSCRIBE = @"subscribe";
static NSString *NOTICE_LIST = @"notice_list";
static NSString *CMD = @"cmd";
static NSString *NOTICE = @"notice";
static NSString *NOTIFY = @"notify";
static NSString *CACHE = @"cache";

// Action Constants
static NSString *ACTION = @"action";
static NSString *ACTION_UPDATE_STATUS = @"update_status";
static NSString *ACTION_UPDATE_ATTENDEE_LIST = @"update_attendee_list";
static NSString *ACTION_KICKOUT = @"kickout";
static NSString *ACTION_INVITED = @"invited";

// Cloud AddressBook Constants
static NSString *AB_OWNER = @"owner";
static NSString *AB_GROUP_ID = @"group_id";
static NSString *AB_GROUP_NAME = @"group_name";
static NSString *AB_CONTACT_DISPLAY_NAME = @"display_name";
static NSString *AB_CONTACT_NAMES = @"name_array";
static NSString *AB_CONTACT_SEARCH_NAME = @"search_name";
static NSString *AB_CONTACT_PHONETIC_ARRAY = @"phonetic_array";
static NSString *AB_CONTACT_PHONE_ARRAY = @"phone_array";
static NSString *AB_CONTACT_GROUP_ARRAY = @"group_array";
