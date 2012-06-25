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

@interface ECGroupModule ()
- (void)onNetworkFailed:(ASIHTTPRequest*)request;
@end

@implementation ECGroupModule

@synthesize videoController = _videoController;
@synthesize attendeeController = _attendeeController;
@synthesize groupId = _groupId;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)onLeaveGroup {
    // send http request to unjoin the group
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:UNJOIN_GROUP_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:nil andFailedRespSelector:@selector(onNetworkFailed:)];
    
    // remove current module from group manager
    [[ECGroupManager sharedECGroupManager] setCurrentGroupModule:nil];
}

- (void)onNetworkFailed:(ASIHTTPRequest *)request {
    // do nothing
}

@end
