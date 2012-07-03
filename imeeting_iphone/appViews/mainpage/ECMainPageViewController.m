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
#import "ECGroupVideoViewController.h"
#import "ECGroupAttendeeListViewController.h"
#import "ECGroupManager.h"
#import "ContactsSelectViewController.h"

@interface ECMainPageViewController ()
- (void)onFinishedGetGroupList:(ASIHTTPRequest*)pRequest;
- (void)onFinishedLoadingMoreGroupList:(ASIHTTPRequest*)pRequest;
- (void)onFinishedJoinGroup:(ASIHTTPRequest*)pRequest;
- (void)onFinishedCreateGroup:(ASIHTTPRequest*)pRequest;
- (void)joinGroup:(NSString*)groupId;
- (void)setupGroupModuleWithGroupId:(NSString*)groupId;
@end

@implementation ECMainPageViewController


- (id)init
{
    self = [self initWithCompatibleView:[[ECMainPageView alloc] init]];
   
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [self.view performSelector:@selector(refreshGroupList)];
    [super viewWillAppear:animated];
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
    [HttpUtil postSignatureRequestWithUrl:GET_GROUP_LIST_URL andPostFormat:urlEncoded andParameter:nil andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedGetGroupList:) andFailedRespSelector:nil];
}

- (void)onFinishedGetGroupList:(ASIHTTPRequest *)pRequest {
     NSLog(@"onFinishedGetGroupList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
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
                [self.view performSelector:@selector(setGroupDataSource:) withObject:groupArray];
                
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void)loadMoreGroupList {
    NSLog(@"load more group list");
    NSNumber *nextOffset = [NSNumber numberWithInteger:(mOffset.integerValue + 1)];
    NSLog(@"current offset: %d, next offset: %d", mOffset.integerValue, nextOffset.integerValue);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nextOffset, @"offset", nil];
    [HttpUtil postSignatureRequestWithUrl:GET_GROUP_LIST_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedLoadingMoreGroupList:) andFailedRespSelector:nil];
}

- (void)onFinishedLoadingMoreGroupList:(ASIHTTPRequest*)pRequest {
    NSLog(@"onFinishedLoadingMoreGroupList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
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
                [self.view performSelector:@selector(appendGroupDataSourceWithArray:) withObject:groupArray];
                
            }
            
            break;
        }
        default:
            break;
    }

}

- (void)hideGroup:(NSString *)groupId {
    NSLog(@"hide group: %@", groupId);
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:HIDE_GROUP_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:nil andFailedRespSelector:nil];
}

- (void)itemSelected:(NSDictionary *)group {
    NSString *groupId = [group objectForKey:@"groupId"];
    
    [self setupGroupModuleWithGroupId:groupId];
    
    // send http request to join the group
    ECMainPageView *mainPage = (ECMainPageView*)self.view;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:mainPage];
    [hud showWhileExecuting:@selector(joinGroup:) onTarget:self withObject:groupId animated:YES];
}

- (void)setupGroupModuleWithGroupId:(NSString *)groupId {
    ECGroupVideoViewController *gvc = [[ECGroupVideoViewController alloc] init];
    ECGroupAttendeeListViewController *alvc =[[ECGroupAttendeeListViewController alloc] init];
    ECGroupModule *module = [[ECGroupModule alloc] init];
    module.videoController = gvc;
    module.attendeeController = alvc;
    [ECGroupManager sharedECGroupManager].currentGroupModule = module;    
    module.groupId = groupId;
}

- (void)joinGroup:(NSString*)groupId {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:JOIN_GROUP_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedJoinGroup:) andFailedRespSelector:nil];

}

- (void)onFinishedJoinGroup:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedJoinGroup - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            // join group ok
            // switch to group view
            ECGroupModule *module = [[ECGroupManager sharedECGroupManager] currentGroupModule];
            [module connectToNotifyServer];
          
            [NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:module.attendeeController withObject:nil];
          
            UIViewController *videoController = module.videoController;
            [self.navigationController pushViewController:videoController animated:NO];
            return;
        }
        case 403:
            [[iToast makeText:NSLocalizedString(@"you'are prohibited to join the group", "")] show];
            break;
        case 404:
            [[iToast makeText:NSLocalizedString(@"group doesn't exist", "")] show];
            break;
        default:
            [iToast makeText:NSLocalizedString(@"error in join group", "")];
            break;
    }
    
    [[ECGroupManager sharedECGroupManager] setCurrentGroupModule:nil];
}

- (void)createNewGroup {    
    ContactsSelectViewController *csvc = [[ContactsSelectViewController alloc] init];
    csvc.isAppearedInCreateNewGroup = YES;
    [self.navigationController pushViewController:csvc animated:YES];
}

@end
