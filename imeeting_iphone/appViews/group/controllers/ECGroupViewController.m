//
//  ECGroupViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-7-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupViewController.h"
#import "CommonToolkit/CommonToolkit.h"
#import "ECGroupView.h"
#import "ECGroupModule.h"
#import "ECGroupManager.h"
#import "ECUrlConfig.h"
#import "ECConstants.h"
#import "ECContactsSelectViewController.h"
#import "ECOwnerModeStatusFilter.h"
#import "ECAttendeeModeStatusFilter.h"

@interface ECGroupViewController ()
// video view realted methods
- (void)attachVideoPreviewLayer;
- (void)detachVideoPreviewLayer;
- (void)broadcastVideoOnStatus;
- (void)broadcastVideoOffStatus;
- (void)updateMyVideoOnStatus;
- (void)updateMyVideoOffStatus;
- (void)onNetworkFailed:(ASIHTTPRequest*)request;

// attendee list view related methods
- (void)onFinishedGetAttendeeList:(ASIHTTPRequest*)pRequest;

- (void)doActionForSelectedMemberInOwnerMode:(NSDictionary*)attendee;
- (void)selectedActionInActionSheet:(UIActionSheet *)pActionSheet clickedButtonAtIndex:(NSInteger)pButtonIndex;
- (void)doActionForSelectedMemberInAttendeeMode:(NSDictionary*)attendee;
@end

@implementation ECGroupViewController
@synthesize refreshList = _refreshList;

- (id)init {
    self = [self initWithCompatibleView:[[ECGroupView alloc] init]];
    if (self) {
        isFirstLoad = YES;
         _refreshList = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if (isFirstLoad) {
        isFirstLoad = NO;
        ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
        ECGroupAttendeeListView *alv = ((ECGroupView*)self.view).attendeeListView;
        if (module.ownerMode) {
            [alv setOwnerUI];
            alv.statusFilter = [[ECOwnerModeStatusFilter alloc] init];
        } else {
            [alv setAttendeeUI];
            alv.statusFilter = [[ECAttendeeModeStatusFilter alloc] init];
        }
        
        [module.videoManager setupSession];
    }
   
    if (_refreshList) {
        [NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:self withObject:nil];
    }

    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
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

#pragma mark - actions
- (void)onLeaveGroup {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module onLeaveGroup];
    NSLog(@"module onLeaveGroup ok");
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"poped view controller");
}

- (void)addContacts {
    NSMutableArray *phoneNumberArray = [NSMutableArray arrayWithCapacity:10];
    ECGroupAttendeeListView *view = ((ECGroupView*)self.view).attendeeListView;
    for (NSDictionary *attendee in view.attendeeArray) {
        NSString *username = [attendee objectForKey:USERNAME];
        [phoneNumberArray addObject:username];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    ECContactsSelectViewController *csvc = [[ECContactsSelectViewController alloc] init];
    [csvc initInMeetingAttendeesPhoneNumbers:phoneNumberArray];
    csvc.isAppearedInCreateNewGroup = NO;
    
    [self.navigationController pushViewController:csvc animated:YES];
    
}

- (void)switchToVideoView {
   // [[UIApplication sharedApplication] setStatusBarHidden:YES];

    ECGroupView *groupView = (ECGroupView*)self.view;
    [groupView switchToVideoView];
}

- (void)switchToAttendeeListView {
   // [[UIApplication sharedApplication] setStatusBarHidden:NO];
    ECGroupView *groupView = (ECGroupView*)self.view;
    [groupView switchToAttendeeListView];
}

- (void)attachVideoPreviewLayer {
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    AVCaptureSession *session = module.videoManager.session;
    if (session) {
        UIView *myVideoView = videoView.myVideoView;
        if (!mPreviewLayer) {
            mPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
            mPreviewLayer.frame = myVideoView.bounds;
            mPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;    
        }
        [myVideoView.layer addSublayer:mPreviewLayer];
    }
}

- (void)detachVideoPreviewLayer {
    [mPreviewLayer removeFromSuperlayer];
}

#pragma mark - camera related methods

// switch between front and back camera
- (void)switchCamera {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module.videoManager switchCamera];
}

// start to capture video and upload
- (void)startCaptureVideo {
    [self attachVideoPreviewLayer];
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module.videoManager startVideoCapture];
    [self broadcastVideoOnStatus];
    [self updateMyVideoOnStatus];
}

// close camera, stop video capture
- (void)stopCaptureVideo {
    [self broadcastVideoOffStatus];
    [self detachVideoPreviewLayer];
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module.videoManager stopVideoCapture];
    [self updateMyVideoOffStatus];
}

#pragma mark - broadcast status

-  (void)broadcastVideoOnStatus {
    ECGroupModule *module = [[ECGroupManager sharedECGroupManager] currentGroupModule];    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:module.groupId, GROUP_ID, ON, VIDEO_STATUS, nil];
    [HttpUtil postSignatureRequestWithUrl:UPDATE_ATTENDEE_STATUS_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:nil andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)broadcastVideoOffStatus {
    ECGroupModule *module = [[ECGroupManager sharedECGroupManager] currentGroupModule];    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:module.groupId, GROUP_ID, OFF, VIDEO_STATUS, nil];
    [HttpUtil postSignatureRequestWithUrl:UPDATE_ATTENDEE_STATUS_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:nil andFailedRespSelector:@selector(onNetworkFailed:)];
    
}

- (void)onNetworkFailed:(ASIHTTPRequest *)request {
    // do nothing
}

#pragma mark - video related

- (void)updateMyVideoOnStatus {
    NSString *username = [[UserManager shareUserManager] userBean].name;
    NSDictionary *me = [NSDictionary dictionaryWithObjectsAndKeys:username, USERNAME, ON, VIDEO_STATUS, nil];
    
    [self updateAttendee:me withMyself:YES];
}

- (void)updateMyVideoOffStatus {
    NSString *username = [[UserManager shareUserManager] userBean].name;
    NSDictionary *me = [NSDictionary dictionaryWithObjectsAndKeys:username, USERNAME, OFF, VIDEO_STATUS, nil];
    
    [self updateAttendee:me withMyself:YES];
}

- (void)renderOppositVideo:(UIImage *)videoImage {
    NSLog(@"render opposite video");
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
    UIImageView *oppositView = videoView.oppositeVideoView;
    oppositView.image = videoImage;
}

- (void)setOppositeVideoName:(NSString *)name {
    ECGroupVideoView *view = ((ECGroupView*)self.view).videoView;
    [view setOppositeVideoName:name];
}

- (void)startVideoLoadingIndicator {
    ECGroupVideoView *view = ((ECGroupView*)self.view).videoView;
    [view startShowLoadingVideo];
}

- (void)stopVideoLoadingIndicator {
    ECGroupVideoView *view = ((ECGroupView*)self.view).videoView;
    [view stopShowLoadingVideo];
}

- (void)resetOppositeVideoView {
    ECGroupVideoView *view = ((ECGroupView*)self.view).videoView;
    [view resetOppositeVideoUI];
}

- (void)showVideoLoadFailedInfo {
    ECGroupVideoView *view = ((ECGroupView*)self.view).videoView;
    [view showVideoLoadFailedInfo];
}

#pragma mark - attendee list view methods
- (void)refreshAttendeeList {
    NSLog(@"refresh attendee list");
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[ECGroupManager sharedECGroupManager].currentGroupModule.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:GET_ATTENDEE_LIST_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedGetAttendeeList:) andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)onFinishedGetAttendeeList:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedGetAttendeeList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSString *responseText = [[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding];
            NSLog(@"json array: %@", responseText);
            
            NSMutableArray *jsonArray = [responseText objectFromJSONString];
            if (jsonArray) {
                ECGroupAttendeeListView *attListView = ((ECGroupView*)self.view).attendeeListView;
                [attListView setAttendeeArray:jsonArray];
                [attListView setReloadingFlag:NO];
                _refreshList = NO;
            }
            
            break;
        }
        default:
            break;
    }
    
    
}

// update attendee status
- (void)updateAttendee:(NSDictionary *)attendee withMyself:(BOOL)myself {
    NSLog(@"AttendeeListViewController - update attendee");
    
    ECGroupAttendeeListView *attListView = ((ECGroupView*)self.view).attendeeListView;
    [attListView updateAttendee:attendee withMyself:myself];
}

#pragma mark - on member selected action
- (void)onAttendeeSelected:(NSDictionary *)attendee {
    mSelectedAttendee = attendee;
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    
    if (module.ownerMode) {
        // owner mode
        [self doActionForSelectedMemberInOwnerMode:attendee];
    } else {
        // normal attendee mode
        [self doActionForSelectedMemberInAttendeeMode:attendee];
    }
}

- (void)doActionForSelectedMemberInOwnerMode:(NSDictionary *)attendee {
    NSString *username = [attendee objectForKey:USERNAME];
    NSString *videoStatus = [attendee objectForKey:VIDEO_STATUS];
    NSString *phoneStatus = [attendee objectForKey:TELEPHONE_STATUS];
    
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:username] objectAtIndex:0];
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:5];
    // generate action items
    if ([videoStatus isEqualToString:ON]) {
        [actions addObject:NSLocalizedString(@"Watch Video", "")];
    }
    if ([phoneStatus isEqualToString:TERMINATED] || [phoneStatus isEqualToString:FAILED]) {
        [actions addObject:NSLocalizedString(@"Call", "")];
    } else if ([phoneStatus isEqualToString:CALL_WAIT] || [phoneStatus isEqualToString:ESTABLISHED]) {
        [actions addObject:NSLocalizedString(@"Hang Up", "")];
    }

    [actions addObject:NSLocalizedString(@"Kick", "")];
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithContent:actions andTitleFormat:NSLocalizedString(@"Operation on %@", ""), displayName];
    [actionSheet setDestructiveButtonIndex:[actions count] - 1];
    actionSheet.processor = self;
    actionSheet.buttonClickedEventSelector = @selector(selectedActionInActionSheet:clickedButtonAtIndex:);
    ECGroupAttendeeListView *alv = ((ECGroupView*)self.view).attendeeListView;
    [actionSheet showInView:alv];

}

- (void)selectedActionInActionSheet:(UIActionSheet *)pActionSheet clickedButtonAtIndex:(NSInteger)pButtonIndex {
    
}

- (void)doActionForSelectedMemberInAttendeeMode:(NSDictionary *)attendee {
    NSString *username = [attendee objectForKey:USERNAME];
    NSString *videoStatus = [attendee objectForKey:VIDEO_STATUS];
    NSString *onlineStatus = [attendee objectForKey:ONLINE_STATUS];

    if ([onlineStatus isEqualToString:ONLINE]) {
        if ([videoStatus isEqualToString:ON]) {
            ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
            [module.videoManager stopVideoFetch];
            [module.videoManager startVideoFetchWithTargetUsername:username];
            [self switchToVideoView];
        } else {
            [[iToast makeText:NSLocalizedString(@"This attendee's video is off", "")] show];
        }
    } else {
        [[iToast makeText:NSLocalizedString(@"This attendee is offline", "")] show];
    }

}



@end
