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
@end

@implementation ECGroupAttendeeListViewController

- (id)init {
    self = [self initWithCompatibleView:[[ECGroupAttendeeListView alloc] init]];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshAttendeeList];
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
    [HttpUtil postSignatureRequestWithUrl:GET_ATTENDEE_LIST_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedGetAttendeeList:) andFailedRespSelector:nil];
}

- (void)onFinishedGetAttendeeList:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedGetAttendeeList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSMutableArray *jsonArray = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonArray) {
                NSLog(@"attendee size: %d", jsonArray.count);
                ECGroupAttendeeListView *attListView = (ECGroupAttendeeListView*)self.view;
                [attListView setAttendeeArray:jsonArray];
            }
            
            break;
        }
        default:
            break;
    }
    

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

@end
