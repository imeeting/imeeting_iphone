//
//  ECGroupModule.h
//  imeeting_iphone
//
//  it implements some actions for group and maintains some data
//
//  Created by star king on 12-6-25.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonToolkit/CommonToolkit.h"
#import "ECVideoManager.h"

@interface ECGroupModule : NSObject <SocketIODelegate, ECVideoFetchDelegate> {
    SocketIO *mSocketIO;
    BOOL needConnectToNotifyServer;
    BOOL isLeave;
}

@property (nonatomic, retain) UIViewController *groupController;
@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSString *audioConfId;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) ECVideoManager *videoManager;
@property (nonatomic) BOOL ownerMode;

- (void)connectToNotifyServer;
- (void)stopGetNoticeFromNotifyServer;
- (void)onLeaveGroup;
- (void)notifyWithMsg:(NSDictionary*)msg;
- (void)broadcastAttendeeStatus:(NSDictionary*)attendee;
@end
