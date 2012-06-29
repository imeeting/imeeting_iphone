//
//  ECGroupAttendeeListViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-22.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupAttendeeListViewController.h"
#import "ECGroupAttendeeListView.h"
#import "ECGroupModule.h"
#import "ECGroupManager.h"
#import "ECConstants.h"
#import "ECUrlConfig.h"

@interface ECGroupAttendeeListViewController ()
- (void)onFinishedGetAttendeeList:(ASIHTTPRequest*)pRequest;
- (void)onNetworkFailed:(ASIHTTPRequest*)request;
@end

@implementation ECGroupAttendeeListViewController

- (id)init {
    self = [self initWithCompatibleView:[[ECGroupAttendeeListView alloc] init]];
    isListLoaded = NO;
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (!isListLoaded) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
        [hud showWhileExecuting:@selector(refreshAttendeeList) onTarget:self withObject:nil animated:YES];
    }
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

- (void)refreshAttendeeList {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[ECGroupManager sharedECGroupManager].currentGroupModule.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:GET_ATTENDEE_LIST_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedGetAttendeeList:) andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)onFinishedGetAttendeeList:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedGetAttendeeList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSMutableArray *jsonArray = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonArray) {
                ECGroupAttendeeListView *attListView = (ECGroupAttendeeListView*)self.view;
                [attListView setAttendeeArray:jsonArray];
                isListLoaded = YES;
            }
            
            break;
        }
        default:
            break;
    }
    
    
}

- (void)onNetworkFailed:(ASIHTTPRequest *)request {
    // do nothing
}

#pragma mark - actions
- (void)switchToVideo {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)leaveGroup {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module onLeaveGroup];
    
    NSArray * controllers = [self.navigationController viewControllers];
    UIViewController * con = [controllers objectAtIndex:1];
    [self.navigationController popToViewController:con animated:YES];
}

- (void)updateAttendee:(NSDictionary *)attendee withMyself:(BOOL)myself {
    NSLog(@"AttendeeListViewController - update attendee");
    
    ECGroupAttendeeListView *attListView = (ECGroupAttendeeListView*)self.view;
    [attListView updateAttendee:attendee withMyself:myself];
}

- (void)onAttendeeSelected:(NSDictionary *)attendee {
    NSString *username = [attendee objectForKey:USERNAME];
    NSString *videoStatus = [attendee objectForKey:VIDEO_STATUS];
    NSString *onlineStatus = [attendee objectForKey:ONLINE_STATUS];
    if ([onlineStatus isEqualToString:ONLINE]) {
        if ([videoStatus isEqualToString:ON]) {
            ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
            [module.videoManager stopVideoFetch];
            [module.videoManager startVideoFetchWithTargetUsername:username];
            [self switchToVideo];
        } else {
            [[iToast makeText:NSLocalizedString(@"This attendee's video is off", "")] show];
        }
    } else {
        [[iToast makeText:NSLocalizedString(@"This attendee is offline", "")] show];
    }
}

@end
