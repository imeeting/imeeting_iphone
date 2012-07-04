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
@synthesize videoManager = _videoManager;

- (id)init {
    self = [super init];
    if (self) {
        isLeave = NO;
        mSocketIO = [[SocketIO alloc] initWithDelegate:self];
        needConnectToNotifyServer = YES;
        self.videoManager = [[ECVideoManager alloc] init];
        self.videoManager.liveName = [[UserManager shareUserManager] userBean].name;
        self.videoManager.rtmpUrl = RTMP_SERVER_URL;
        self.videoManager.outImgWidth = 144;
        self.videoManager.outImgHeight = 192;
        [self.videoManager setVideoFetchDelegate:self];

    }
    return self;
}

- (void)onLeaveGroup {
    isLeave = YES;
    [self.videoManager releaseSession];
    
    [self stopGetNoticeFromNotifyServer];
    // send http request to unjoin the group
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:UNJOIN_GROUP_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:nil andFailedRespSelector:@selector(onNetworkFailed:)];
    
}

- (void)onNetworkFailed:(ASIHTTPRequest *)request {
    // do nothing
}

- (void)connectToNotifyServer {
    NSLog(@"connect to notify server..");
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
    NSString *action = [notice objectForKey:ACTION];
    if ([action isEqualToString:ACTION_UPDATE_STATUS]) {
        // update attendee status
        NSDictionary *attendee = [notice objectForKey:ATTENDEE];
        ECGroupAttendeeListViewController *avc = (ECGroupAttendeeListViewController*)_attendeeController;
        [avc updateAttendee:attendee withMyself:NO];
    } else if ([action isEqualToString:ACTION_UPDATE_ATTENDEE_LIST]) {
        // update attendee list
        ECGroupAttendeeListViewController * alvc = (ECGroupAttendeeListViewController*)_attendeeController;
        [NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:alvc withObject:nil];
    }
}

- (void)updateMyStatus:(NSDictionary *)me {
    ECGroupAttendeeListViewController *avc = (ECGroupAttendeeListViewController*)_attendeeController;
    [avc updateAttendee:me withMyself:YES];
}

#pragma mark - notify methods

- (void)notifyWithMsg:(NSDictionary *)msg {
    if (msg) {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:self.groupId, TOPIC, msg, MSG, nil];
        [mSocketIO sendEvent:NOTIFY withData:data];
    }
}

- (void)broadcastAttendeeStatus:(NSDictionary *)attendee {
    if (attendee) {
        NSMutableDictionary *msg = [[NSMutableDictionary alloc] initWithCapacity:5];
        [msg setObject:self.groupId forKey:GROUP_ID];
        [msg setObject:ACTION_UPDATE_STATUS forKey:ACTION];
        [msg setObject:attendee forKey:ATTENDEE];
        [self notifyWithMsg:msg];
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
    NSLog(@"socket io disconnected");
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

- (void) socketIODidConnectError:(NSString *) errorMsg {
    NSLog(@"socket io connect error");
    if (needConnectToNotifyServer) {
        [self connectToNotifyServer];
    }
}

#pragma mark - video fetch delegate
- (void)onFetchNewImage:(UIImage *)image {
    NSLog(@"Module - onFetchNewImage");
    if (!isLeave) {
        ECGroupVideoViewController *videoCtrl = (ECGroupVideoViewController*)self.videoController;
        [videoCtrl renderOppositVideo:image];
    }
}

- (void)onFetchFailed {
    NSLog(@"onFetchFailed");
    if (!isLeave) {
        ECGroupVideoViewController *videoCtrl = (ECGroupVideoViewController*)self.videoController;
        [videoCtrl showVideoLoadFailedInfo];
    }
}

- (void)onFetchVideoBeginToPrepare:(NSString*)name {
    NSLog(@"onFetchVideoBeginToPrepare");
    if (!isLeave) {
        ECGroupVideoViewController *videoCtrl = (ECGroupVideoViewController*)self.videoController;
        [videoCtrl setOppositeVideoName:name];
        [videoCtrl startVideoLoadingIndicator];
    }
}

- (void)onFetchVideoPrepared {
    NSLog(@"onFetchVideoPrepared");
    if (!isLeave) {
        ECGroupVideoViewController *videoCtrl = (ECGroupVideoViewController*)self.videoController;
        [videoCtrl stopVideoLoadingIndicator];
    }
}

- (void)onFetchEnd {
    NSLog(@"onFetchEnd");
    if (!isLeave) {
        ECGroupVideoViewController *videoCtrl = (ECGroupVideoViewController*)self.videoController;
        [videoCtrl resetOppositeVideoView];
    }
}
@end
