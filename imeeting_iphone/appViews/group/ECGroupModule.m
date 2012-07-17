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
#import "ECGroupViewController.h"

@interface ECGroupModule ()
- (void)onNetworkFailed:(ASIHTTPRequest*)request;
- (void)processNotices:(NSDictionary*)noticeData;
- (void)processOneNotice:(NSDictionary*)notice;
@end

@implementation ECGroupModule

@synthesize groupController = _groupController;
@synthesize groupId = _groupId;
@synthesize owner = _owner;
@synthesize audioConfId = _audioConfId;
@synthesize videoManager = _videoManager;
@synthesize ownerMode = _ownerMode;
@synthesize inGroup = _inGroup;

- (id)init {
    self = [super init];
    if (self) {
        self.inGroup = YES;
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

- (void)setGroupId:(NSString *)groupId {
    _groupId = groupId;
    [self.videoManager setGroupId:groupId];
}

- (void)onLeaveGroup {
    self.inGroup = NO;
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
    if (!noticeData || !self.inGroup) {
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
        NSLog(@"processOneNotice - update attendee status");
        // update attendee status
        NSDictionary *attendee = [notice objectForKey:ATTENDEE];
        ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
        [gc updateAttendee:attendee withMyself:YES];
    } else if ([action isEqualToString:ACTION_UPDATE_ATTENDEE_LIST]) {
        NSLog(@"processOneNotice - update attendee list");

        // update attendee list
        ECGroupViewController *gc = (ECGroupViewController*)self.groupController;

       // [NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:gc withObject:nil];
        [gc refreshAttendeeList];
    } else if ([action isEqualToString:ACTION_KICKOUT]) {
        NSLog(@"processOneNotice - kickout attendee");
        
        NSString *accountName = [[UserManager shareUserManager] userBean].name;
        NSString *attendeeName = [notice objectForKey:USERNAME];
        if ([accountName isEqualToString:attendeeName]) {
            // kick myself
            ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
            [gc stopCaptureVideo];
            
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"You have been removed from the group by host", "") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
        } else {
            // update attendee list
            NSString *toastMsg = [NSString stringWithFormat:NSLocalizedString(@"%@ has been removed from the group", nil), attendeeName];
            [[iToast makeText:toastMsg] show];
            
            ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
            [gc refreshAttendeeList];
        }
    }
}

#pragma mark - Delegate of kickout alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
    [gc onLeaveGroup];
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
    if (self.inGroup) {
        ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
        [gc renderOppositVideo:image];
    }
}

- (void)onFetchFailed {
    NSLog(@"onFetchFailed");
    if (self.inGroup) {
        ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
        [gc showVideoLoadFailedInfo];
    }
}

- (void)onFetchVideoBeginToPrepare:(NSString*)name {
    NSLog(@"onFetchVideoBeginToPrepare");
    if (self.inGroup) {
        ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
        [gc setOppositeVideoName:name];
        [gc startVideoLoadingIndicator];
    }
}

- (void)onFetchVideoPrepared {
    NSLog(@"onFetchVideoPrepared");
    if (self.inGroup) {
        ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
        [gc stopVideoLoadingIndicator];
    }
}

- (void)onFetchEnd {
    NSLog(@"onFetchEnd");
    if (self.inGroup) {
        ECGroupViewController *gc = (ECGroupViewController*)self.groupController;
        [gc resetOppositeVideoView];
    }
}

- (BOOL)ownerMode {
    BOOL isOwner = YES;
    NSString *myAccountName = [[UserManager shareUserManager] userBean].name;
    NSString *ownerName = self.owner;
    if ([myAccountName isEqualToString:ownerName]) {
        isOwner = YES;
    } else {
        isOwner = NO;
    }
    return isOwner;
}
@end
