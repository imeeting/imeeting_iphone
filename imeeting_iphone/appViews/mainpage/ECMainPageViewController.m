//
//  ECMainPageViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-11.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECMainPageViewController.h"
#import "ECMainPageView.h"
#import "ECUrlConfig.h"
#import "ECConstants.h"
#import "ECGroupManager.h"
#import "ECContactsSelectViewController.h"
#import "ECGroupViewController.h"
#import "UIViewController+AuthFailHandler.h"
#import "ECSettingViewController.h"

static ECMainPageViewController *instance;

@interface ECMainPageViewController () {
    NSDictionary *selectedGroupInfo;
}
- (void)onFinishedGetGroupList:(ASIHTTPRequest*)pRequest;
- (void)onFinishedLoadingMoreGroupList:(ASIHTTPRequest*)pRequest;
- (void)onGetGroupListFailed:(ASIHTTPRequest*)pRequest;
- (void)onLoadingMoreGroupListFailed:(ASIHTTPRequest*)pRequest;
- (void)onFinishedJoinGroup:(ASIHTTPRequest*)pRequest;
- (void)onFinishedHideGroup:(ASIHTTPRequest*)pRequest;
@end

@implementation ECMainPageViewController

+ (ECMainPageViewController *)shareViewController {
    return instance;
}

+ (void)setShareViewController:(ECMainPageViewController *)viewController {
    instance = viewController;
}

- (id)init
{
    self = [self initWithCompatibleView:[[ECMainPageView alloc] init]];
    if (self) {
        mSocketIO = [[SocketIO alloc] initWithDelegate:self];
        needConnectToNotifyServer = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    ECMainPageView *mainPageView = (ECMainPageView*)self.view;
    [mainPageView refreshGroupList];
    [super viewWillAppear:animated];
   
    /*
    // test - find the font name
    NSArray *familyNames = [UIFont familyNames];  
    for( NSString *familyName in familyNames ){  
        NSLog(@"Family: %@", familyName);  
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];  
        for( NSString *fontName in fontNames ){  
            NSLog(@"\tFont: %@", fontName);  
        }  
    }
    */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// get the newest group list from server
- (void)refreshGroupList {
    NSLog(@"ECMainPageViewController - refresh Group List");
    [HttpUtil postSignatureRequestWithUrl:GET_CONF_LIST_URL andPostFormat:urlEncoded andParameter:nil andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedGetGroupList:) andFailedRespSelector:@selector(onGetGroupListFailed:)];
}

- (void)onFinishedGetGroupList:(ASIHTTPRequest *)pRequest {
     NSLog(@"onFinishedGetGroupList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    ECMainPageView *mainPageView = (ECMainPageView*)self.view;

    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSDictionary *pager = [jsonData objectForKey:@"pager"];
                NSNumber *hasNext = [pager objectForKey:@"hasNext"];
                mOffset = [pager objectForKey:@"offset"];
                [self.view performSelector:@selector(setHasNext:) withObject:hasNext];
                
                NSLog(@"has Next: %@, offset: %@", hasNext, mOffset);
                
                NSArray *groupArray = [jsonData objectForKey:@"list"];
                NSLog(@"group array size: %d", groupArray.count);
                [mainPageView setGroupDataSource:groupArray];
            }
            
            break;
        }
        default:
            break;
    }
    [mainPageView stopReloadTableView];
}

- (void)onGetGroupListFailed:(ASIHTTPRequest *)pRequest {
    ECMainPageView *mainPageView = (ECMainPageView*)self.view;
    [mainPageView stopReloadTableView];
}

- (void)loadMoreGroupList {
    NSLog(@"load more group list");
    NSNumber *nextOffset = [NSNumber numberWithInteger:(mOffset.integerValue + 1)];
    NSLog(@"current offset: %d, next offset: %d", mOffset.integerValue, nextOffset.integerValue);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nextOffset, @"offset", nil];
    [HttpUtil postSignatureRequestWithUrl:GET_CONF_LIST_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedLoadingMoreGroupList:) andFailedRespSelector:@selector(onLoadingMoreGroupListFailed:)];
}

- (void)onFinishedLoadingMoreGroupList:(ASIHTTPRequest*)pRequest {
    NSLog(@"onFinishedLoadingMoreGroupList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;

    ECMainPageView *mainPageView = (ECMainPageView*)self.view;

    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSDictionary *pager = [jsonData objectForKey:@"pager"];
                NSNumber *hasNext = [pager objectForKey:@"hasNext"];
                mOffset = [pager objectForKey:@"offset"];
                [self.view performSelector:@selector(setHasNext:) withObject:hasNext];
                
                NSLog(@"has Next: %@, offset: %@", hasNext, mOffset);
                
                NSArray *groupArray = [jsonData objectForKey:@"list"];
                NSLog(@"group array size: %d", groupArray.count);
                [mainPageView appendGroupDataSourceWithArray:groupArray];
            }
            
            break;
        }
        default:
            break;
    }
    [mainPageView stopLoadMoreTableView];
}

- (void)onLoadingMoreGroupListFailed:(ASIHTTPRequest *)pRequest {
    ECMainPageView *mainPageView = (ECMainPageView*)self.view;
    [mainPageView stopLoadMoreTableView];
}

- (void)hideGroup:(NSString *)groupId {
    NSLog(@"hide group: %@", groupId);
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:HIDE_CONF_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedHideGroup:) andFailedRespSelector:nil];
}

- (void)onFinishedHideGroup:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedJoinGroup - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            // hide group ok
            ECMainPageView *mainView = (ECMainPageView*)self.view;
            [mainView removeSelectedGroupFromUI];
            break;
        }
        default:
            [[[iToast makeText:NSLocalizedString(@"error in hide group", "")] setDuration:iToastDurationLong] show];
            ECMainPageView *mainView = (ECMainPageView*)self.view;
            [mainView reloadTableViewData];
            break;
    }

}

- (void)itemSelected:(NSDictionary *)group {
    selectedGroupInfo = group;
    NSString *groupId = [group objectForKey:GROUP_ID];
    
    [self setupGroupModuleWithGroupId:groupId];
    
    // send http request to join the group
    ECMainPageView *mainPage = (ECMainPageView*)self.view;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:mainPage];
    [hud showWhileExecuting:@selector(joinGroup:) onTarget:self withObject:groupId animated:YES];
}

- (void)setupGroupModuleWithGroupId:(NSString *)groupId {
    ECGroupViewController *gvc = [[ECGroupViewController alloc] init];
    ECGroupModule *module = [[ECGroupModule alloc] init];
    module.groupController = gvc;
    [ECGroupManager sharedECGroupManager].currentGroupModule = module;    
    module.groupId = groupId;
}

- (void)joinGroup:(NSString*)groupId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:JOIN_CONF_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedJoinGroup:) andFailedRespSelector:nil];

}

- (void)onFinishedJoinGroup:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedJoinGroup - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            // join group ok
            selectedGroupInfo = nil;
            // switch to group view
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            NSLog(@"json data: %@", jsonData);
            if (jsonData) {
                ECGroupModule *module = [[ECGroupManager sharedECGroupManager] currentGroupModule];
                module.audioConfId = [jsonData objectForKey:AUDIO_CONF_ID];
                module.owner = [jsonData objectForKey:OWNER];
                
                [module connectToNotifyServer];
                
                [self.navigationController pushViewController:module.groupController animated:YES];
                
                return;
            } else {
                [[[iToast makeText:NSLocalizedString(@"error in join group", "")] setDuration:iToastDurationLong] show];
            }
            break;
        }
        case 403:
            [[[iToast makeText:NSLocalizedString(@"you'are prohibited to join the group", "")] setDuration:iToastDurationLong] show];
            break;
        case 404: {
            // conference donesn't exist, start to create a new one
            ECContactsSelectViewController *csvc = [[ECContactsSelectViewController alloc] init];
            csvc.isAppearedInCreateNewGroup = YES;
            
            NSString *accountName = [UserManager shareUserManager].userBean.name;
            NSMutableArray *inConferenceAttendeeArray = [NSMutableArray arrayWithCapacity:1];
            [inConferenceAttendeeArray addObject:accountName];
            [csvc initInMeetingAttendeesPhoneNumbers:inConferenceAttendeeArray];
            
            // set pre-in conference attendees
            NSLog(@"selected group: %@", selectedGroupInfo);
            if (selectedGroupInfo) {
                NSArray *attendees = [selectedGroupInfo objectForKey:GROUP_ATTENDEES];
                if (attendees) {
                    NSMutableArray *preInConferenceAttendeeArray = [NSMutableArray arrayWithCapacity:5];
                    for (NSString *name in attendees) {
                        if (![accountName isEqualToString:name]) {
                            [preInConferenceAttendeeArray addObject:name];
                        }
                    }
                    NSLog(@"pre in attendees: %@", preInConferenceAttendeeArray);
                    [csvc initPreinMeetingAttendeesPhoneNumbers:preInConferenceAttendeeArray];
                }
                selectedGroupInfo = nil;
            }
            [self.navigationController pushViewController:csvc animated:YES];
            return;
        }
        default:
            [[[iToast makeText:NSLocalizedString(@"error in join group", "")] setDuration:iToastDurationLong] show];
            break;
    }
    selectedGroupInfo = nil;
    [[ECGroupManager sharedECGroupManager] setCurrentGroupModule:nil];
}

- (void)createNewGroup {    
    ECContactsSelectViewController *csvc = [[ECContactsSelectViewController alloc] init];
    csvc.isAppearedInCreateNewGroup = YES;
    
    NSMutableArray *attendeeArray = [NSMutableArray arrayWithCapacity:1];
    [attendeeArray addObject:[UserManager shareUserManager].userBean.name];
    [csvc initInMeetingAttendeesPhoneNumbers:attendeeArray];
    [self.navigationController pushViewController:csvc animated:YES];
}

- (void)showSettingView {
    [self.navigationController pushViewController:[[ECSettingViewController alloc] init] animated:YES];
}

#pragma mark - socket io
- (void)connectToNotifyServer {
    NSLog(@"connect to notify server..");
    [mSocketIO connectToHost:NOTIFY_SERVER_HOST onPort:80];
}

- (void)stopGetNoticeFromNotifyServer {
    needConnectToNotifyServer = NO;
    [mSocketIO disconnect];
}

- (void) socketIODidConnect:(SocketIO *)socket {
    // subscribe to notify server to get user related notifications
    NSString *username = [[UserManager shareUserManager] userBean].name;
    
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:username, TOPIC, username, SUBSCRIBER_ID, nil];
    [mSocketIO sendEvent:SUBSCRIBE withData:msg];
}

- (void) socketIODidDisconnect:(SocketIO *)socket {
    NSLog(@"socket io disconnected");
    if (needConnectToNotifyServer) {
        [self connectToNotifyServer];
    }
}

- (void) socketIODidConnectError:(NSString *) errorMsg {
    NSLog(@"socket io connect error");
    if (needConnectToNotifyServer) {
        [self connectToNotifyServer];
    }
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
    NSLog(@"main page - process one notice, action: %@", action);
}



@end
