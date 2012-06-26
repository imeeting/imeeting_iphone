//
//  ECGroupModule.m
//  imeeting_iphone
//
//  Created by star king on 12-6-25.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupModule.h"
#import "CommonToolkit/CommonToolkit.h"
#import "ECConstants.h"
#import "ECUrlConfig.h"
#import "ECGroupManager.h"
#import "ECGroupAttendeeListViewController.h"
#import "ECGroupVideoViewController.h"

@interface ECGroupModule ()
- (void)onNetworkFailed:(ASIHTTPRequest*)request;
- (void)processNotices:(NSDictionary*)noticeData;
- (void)processOneNotice:(NSDictionary*)notice;
@end

@implementation ECGroupModule

@synthesize videoController = _videoController;
@synthesize attendeeController = _attendeeController;
@synthesize groupId = _groupId;

- (id)init {
    self = [super init];
    if (self) {
        mSocketIO = [[SocketIO alloc] initWithDelegate:self];
        needConnectToNotifyServer = YES;
    }
    return self;
}

- (void)onLeaveGroup {
    [self stopGetNoticeFromNotifyServer];
    
    // send http request to unjoin the group
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:UNJOIN_GROUP_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:nil andFailedRespSelector:@selector(onNetworkFailed:)];
    
    // remove current module from group manager
    [[ECGroupManager sharedECGroupManager] setCurrentGroupModule:nil];
}

- (void)onNetworkFailed:(ASIHTTPRequest *)request {
    // do nothing
}

- (void)connectToNotifyServer {
    [mSocketIO connectToHost:NOTIFY_SERVER_HOST onPort:80];
}

// process notices from notify server
- (void)processNotices:(NSDictionary*)noticeData {
    if (!noticeData) {
        return;
    }
    
    NSLog(@"process notices");
    
    NSString *cmd = [noticeData objectForKey:CMD];
    NSArray *noticeList = [noticeData objectForKey:NOTICE_LIST];
    NSLog(@"cmd: %@", cmd);
    if (cmd && ([cmd isEqualToString:NOTIFY] || [cmd isEqualToString:CACHE])) {
        NSLog(@"notice list size: %d", noticeList.count);
        if (noticeList && noticeList.count > 0) {
            for (NSDictionary *notice in noticeList) {
                [self processOneNotice:notice];
            }
        }
    }
}

- (void)processOneNotice:(NSDictionary *)notice {
    NSString *action = [notice objectForKey:@"action"];
    if ([action isEqualToString:@"update_status"]) {
        // update attendee status
        NSDictionary *attendee = [notice objectForKey:@"attendee"];
        ECGroupAttendeeListViewController *avc = (ECGroupAttendeeListViewController*)_attendeeController;
        [avc updateAttendee:attendee];
    }
}

#pragma mark - SocketIO delegate implementations
- (void) socketIODidConnect:(SocketIO *)socket {
    // subscribe to notify server
    NSString *groupId = [[ECGroupManager sharedECGroupManager] currentGroupModule].groupId;
    NSString *username = [[UserManager shareUserManager] userBean].name;
    
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:groupId, TOPIC, username, SUBSCRIBER_ID, nil];
    [mSocketIO sendEvent:SUBSCRIBE withData:msg];
}

- (void) socketIODidDisconnect:(SocketIO *)socket {
    if (needConnectToNotifyServer) {
        [self connectToNotifyServer];
    }
}

- (void)stopGetNoticeFromNotifyServer {
    needConnectToNotifyServer = NO;
    [mSocketIO disconnect];
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    if ([packet.name isEqualToString:NOTICE]) {
        NSDictionary *jsonData = [packet.data objectFromJSONString];
        NSArray *args = [jsonData objectForKey:@"args"];
        if (args.count > 0) {
            NSDictionary *noticeData = [args objectAtIndex:0];
            [self processNotices:noticeData];
        }
    }
}

// add by ares
- (void) socketIODidConnectError:(NSString *) errorMsg {
    NSLog(@"socket io connect error");
}


@end
