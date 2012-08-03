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
#import "UIViewController+AuthFailHandler.h"

@interface ECGroupViewController ()
- (void)setGroupIdLabel;

// video view realted methods
- (UIImageView*)currentMyVideoView;
- (UIImageView*)currentFriendVideoView;
- (void)attachMyVideoPreviewLayer;
- (void)detachMyVideoPreviewLayer;
- (void)updateMyVideoOnStatus;
- (void)updateMyVideoOffStatus;
- (void)onNetworkFailed:(ASIHTTPRequest*)request;

// attendee list view related methods
- (void)onFinishedGetAttendeeList:(ASIHTTPRequest*)pRequest;

- (void)startVideoWatch:(NSString*)targetUsername;

- (void)doActionForSelectedMemberInOwnerMode:(NSDictionary*)attendee;
- (void)selectedActionInActionSheet:(UIActionSheet *)pActionSheet clickedButtonAtIndex:(NSInteger)pButtonIndex;
- (void)doActionForSelectedMemberInAttendeeMode:(NSDictionary*)attendee;

#pragma mark - owner mode operations - phone related
- (void)call:(NSString*)targetUsername;
- (void)onFinishedCall:(ASIHTTPRequest*)pRequest;
- (void)hangup:(NSString*)targetUsername;
- (void)onFinishedHangup:(ASIHTTPRequest*)pRequest;
- (void)kickout:(NSString*)targetUsername;
- (void)onFinishedKickout:(ASIHTTPRequest*)pRequest;
//- (void)muteMyself;
//- (void)unmuteMyself;
@end

@implementation ECGroupViewController
@synthesize refreshList = _refreshList;
@synthesize smallVideoViewIsMine = _smallVideoViewIsMine;
- (id)init {
    self = [self initWithCompatibleView:[[ECGroupView alloc] init]];
    if (self) {
        _isFirstLoad = YES;
        _refreshList = YES;
        _smallVideoViewIsMine = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if (_isFirstLoad) {
        _isFirstLoad = NO;
        [self setGroupIdLabel];
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
        // start video capturing
        //ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
        //[videoView onOpenCameraButtonClickAction];
        
        
       
    }
   
    if (_refreshList) {
        //[NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:self withObject:nil];
        [self refreshAttendeeList];
    }

    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ECGroupAttendeeListView *alv = ((ECGroupView*)self.view).attendeeListView;
    [alv setHidden:NO];
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

- (void)setGroupIdLabel {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    ECGroupVideoView *view = ((ECGroupView*)self.view).videoView;
    NSString *labelText = [NSString stringWithFormat:NSLocalizedString(@"Group ID: %@", nil), module.groupId];
    [view setGroupIdText:labelText];
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
        
    /*
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    [self.navigationController pushViewController:csvc animated:NO];
     */
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:0.4f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:csvc animated:NO];
    [UIView commitAnimations];
    
}

- (void)switchToVideoView {
    ECGroupView *groupView = (ECGroupView*)self.view;
    [groupView switchToVideoView];
}

- (void)switchToAttendeeListView {
    ECGroupView *groupView = (ECGroupView*)self.view;
    [groupView switchToAttendeeListView];
}

- (void)switchVideoAndAttendeeListView {
   // [[UIApplication sharedApplication] setStatusBarHidden:NO];
    ECGroupView *groupView = (ECGroupView*)self.view;
    [groupView switchVideoAndAttendeeListView];
}

- (void)attachMyVideoPreviewLayer {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    AVCaptureSession *session = module.videoManager.session;
    if (session) {
        UIView *myVideoView = [self currentMyVideoView];
        if (!_previewLayer) {
            _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
            _previewLayer.frame = myVideoView.bounds;
            _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;    
        }
        [myVideoView.layer addSublayer:_previewLayer];
    }
}

- (void)detachMyVideoPreviewLayer {
    [_previewLayer removeFromSuperlayer];
    _previewLayer = nil;
}

#pragma mark - camera related methods

// switch between front and back camera
- (void)switchCamera {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module.videoManager switchCamera];
}

// start to capture video and upload
- (void)startCaptureVideo {
    [self attachMyVideoPreviewLayer];
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module.videoManager startVideoCapture];
    [self updateMyVideoOnStatus];
}

// close camera, stop video capture
- (void)stopCaptureVideo {
    [self detachMyVideoPreviewLayer];
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module.videoManager stopVideoCapture];
    [self updateMyVideoOffStatus];
}

- (void)onNetworkFailed:(ASIHTTPRequest *)request {
    // do nothing
}

#pragma mark - video related

- (UIImageView*)currentMyVideoView {
    ECGroupView *groupView = (ECGroupView*)self.view;
    if (_smallVideoViewIsMine) {
        return groupView.videoView.smallVideoView;
    } else {
        return groupView.videoView.largeVideoView;
    }
}

- (UIImageView*)currentFriendVideoView {
    ECGroupView *groupView = (ECGroupView*)self.view;
    if (_smallVideoViewIsMine) {
        return groupView.videoView.largeVideoView;
    } else {
        return groupView.videoView.smallVideoView;
    }
}

- (void)setSmallVideoViewIsMine:(BOOL)smallVideoViewIsMine {
    NSLog(@"setSmallVideoViewIsMine");

    _smallVideoViewIsMine = smallVideoViewIsMine;
    
    [self detachMyVideoPreviewLayer];
    [self attachMyVideoPreviewLayer];
    
    //[self currentFriendVideoView].image = nil;
    //[self currentMyVideoView].image = nil;
}

- (void)swapVideoView {
    NSLog(@"swap video view");
    [self setSmallVideoViewIsMine:!_smallVideoViewIsMine];
}

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
    UIImageView *largeView = [self currentFriendVideoView];
    largeView.image = videoImage;
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
    [HttpUtil postSignatureRequestWithUrl:GET_ATTENDEE_LIST_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedGetAttendeeList:) andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)onFinishedGetAttendeeList:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedGetAttendeeList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    ECGroupAttendeeListView *attListView = ((ECGroupView*)self.view).attendeeListView;

    switch (statusCode) {
        case 200: {
            NSString *responseText = [[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding];
            
            NSMutableArray *jsonArray = [responseText objectFromJSONString];
            NSLog(@"json array: %@", jsonArray);

            if (jsonArray) {
                [attListView setAttendeeArray:jsonArray];
                _refreshList = NO;
            }
            
            break;
        }
        default:
            break;
    }
    
    [attListView setReloadingFlag:NO];
}

// update attendee status
- (void)updateAttendee:(NSDictionary *)attendee withMyself:(BOOL)myself {
    NSLog(@"AttendeeListViewController - update attendee");
    
    ECGroupAttendeeListView *attListView = ((ECGroupView*)self.view).attendeeListView;
    [attListView updateAttendee:attendee withMyself:myself];
}

#pragma mark - on member selected action
- (void)onAttendeeSelected:(NSDictionary *)attendee {
    _selectedAttendee = attendee;
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
    if ([phoneStatus isEqualToString:TERMINATED] || [phoneStatus isEqualToString:FAILED] || [phoneStatus isEqualToString:TERMWAIT]) {
        [actions addObject:NSLocalizedString(@"Call", "")];
    } else if ([phoneStatus isEqualToString:CALL_WAIT] || [phoneStatus isEqualToString:ESTABLISHED]) {
        [actions addObject:NSLocalizedString(@"Hang Up", "")];
    }
    
    NSString *accountName = [[UserManager shareUserManager] userBean].name;
    if (![accountName isEqualToString:username]) {
        [actions addObject:NSLocalizedString(@"Kick", "")];
    }
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithContent:actions andTitleFormat:NSLocalizedString(@"Operation on %@", ""), displayName];
    [actionSheet setDestructiveButtonIndex:[actions count] - 1];
    actionSheet.processor = self;
    actionSheet.buttonClickedEventSelector = @selector(selectedActionInActionSheet:clickedButtonAtIndex:);
    ECGroupAttendeeListView *alv = ((ECGroupView*)self.view).attendeeListView;
    [actionSheet showInView:alv];

}

- (void)selectedActionInActionSheet:(UIActionSheet *)pActionSheet clickedButtonAtIndex:(NSInteger)pButtonIndex {
    NSString *buttonTitle = [pActionSheet buttonTitleAtIndex:pButtonIndex];
    NSString *username = [_selectedAttendee objectForKey:USERNAME];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Watch Video", "")]) {
        [self startVideoWatch:username];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Call", "")]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
        [hud showWhileExecuting:@selector(call:) onTarget:self withObject:username animated:YES];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Hang Up", "")]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
        [hud showWhileExecuting:@selector(hangup:) onTarget:self withObject:username animated:YES];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Kick", "")]) {
        NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:username] objectAtIndex:0];
        NSString *alertMsg = [NSString stringWithFormat:NSLocalizedString(@"Remove %@ ?", nil), displayName];
        [[[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            NSString *username = [_selectedAttendee objectForKey:USERNAME];
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
            [hud showWhileExecuting:@selector(kickout:) onTarget:self withObject:username animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)doActionForSelectedMemberInAttendeeMode:(NSDictionary *)attendee {
    NSString *username = [attendee objectForKey:USERNAME];
    NSString *videoStatus = [attendee objectForKey:VIDEO_STATUS];
    NSString *onlineStatus = [attendee objectForKey:ONLINE_STATUS];

    if ([onlineStatus isEqualToString:ONLINE]) {
        if ([videoStatus isEqualToString:ON]) {
            [self startVideoWatch:username];
        } else {
            [[[iToast makeText:NSLocalizedString(@"This attendee's video is off", "")] setDuration:iToastDurationLong] show];
        }
    } else {
        [[[iToast makeText:NSLocalizedString(@"This attendee is offline", "")] setDuration:iToastDurationLong] show];
    }

}

- (void)startVideoWatch:(NSString *)targetUsername {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    if (![targetUsername isEqualToString:[module.videoManager.videoDecode currentVideoUserName]]) {
        [module.videoManager stopVideoFetch];
        sleep(0.5);
        [module.videoManager startVideoFetchWithTargetUsername:targetUsername];
    }
    [self switchToVideoView];
}

#pragma mark - owner operations - phone related
- (void)call:(NSString *)targetUsername {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:targetUsername, @"dstUserName", module.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:CALL_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedCall:) andFailedRespSelector:nil];
}

- (void)onFinishedCall:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedCall - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;

    NSString *username = [_selectedAttendee objectForKey:USERNAME];
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:username] objectAtIndex:0];
    switch (statusCode) {
        case 200: {
            // call command is accepted by server, update UI
            NSDictionary *attendee = [NSDictionary dictionaryWithObjectsAndKeys:username, USERNAME, CALL_WAIT, TELEPHONE_STATUS, nil];
            [self updateAttendee:attendee withMyself:YES];

            break;
        }
        case 403: {
            // call is forbidden
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Call is forbidden for %@", nil), displayName];
            [[[iToast makeText:msg] setDuration:iToastDurationLong] show];
            break;
        }
        case 409: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Call failed, maybe %@ is in calling or talking", nil), displayName];
            [[[iToast makeText:msg] setDuration:iToastDurationLong] show];
            break;
        }
        case 500: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Call Failed", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationLong] show];
            break;
        }
        default:
            [[[iToast makeText:NSLocalizedString(@"Call Failed", "")] setDuration:iToastDurationLong] show];
            break;
    }

}

- (void)hangup:(NSString *)targetUsername {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:targetUsername, @"dstUserName", module.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:HANGUP_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedHangup:) andFailedRespSelector:nil];

}

- (void)onFinishedHangup:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedHangup - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    NSString *username = [_selectedAttendee objectForKey:USERNAME];
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:username] objectAtIndex:0];
    switch (statusCode) {
        case 409: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Hangup failed, maybe %@ is already hung up", nil), displayName];
            [[[iToast makeText:msg] setDuration:iToastDurationLong] show];
        }
        case 200: {
            // hangup command is accepted by server, update UI
            NSDictionary *attendee = [NSDictionary dictionaryWithObjectsAndKeys:username, USERNAME, TERMINATED, TELEPHONE_STATUS, nil];
            [self updateAttendee:attendee withMyself:YES];
            
            break;
        }
        case 403: {
            // hangup is forbidden
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Hanup is forbidden for %@", nil), displayName];
            [[[iToast makeText:msg] setDuration:iToastDurationLong] show];
            break;
        }
        case 500: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Hangup failed", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationLong] show];
            break;
        }
        default:
            [[[iToast makeText:NSLocalizedString(@"Hangup Failed", "")] setDuration:iToastDurationLong] show];
            break;
    }
}

- (void)kickout:(NSString *)targetUsername {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:targetUsername, @"dstUserName", module.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:KICKOUT_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedKickout:) andFailedRespSelector:nil];
}

- (void)onFinishedKickout:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedKickout - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    NSString *username = [_selectedAttendee objectForKey:USERNAME];
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:username] objectAtIndex:0];
    switch (statusCode) {
        case 200: {
            // kickout command is accepted by server, update UI
            // remove attendee from list
            ECGroupAttendeeListView *alv = ((ECGroupView*)self.view).attendeeListView;
            [alv removeSelectedAttendee];            
            break;
        }
        case 403: {
            // kickout is forbidden
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Kickout is forbidden for %@", nil), displayName];
            [[[iToast makeText:msg] setDuration:iToastDurationLong] show];
            break;
        }
        default:
            [[[iToast makeText:NSLocalizedString(@"Kickout Failed", "")] setDuration:iToastDurationLong] show];
            break;
    }

}

#pragma mark - dial button related
- (void)setDialButtonAsDial {
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
   // [videoView setDialButtonAsDial];
    [videoView performSelectorOnMainThread:@selector(setDialButtonAsDial) withObject:nil waitUntilDone:NO];
}

- (void)setDialButtonAsTalking {
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
   // [videoView setDialButtonAsTalking];
    [videoView performSelectorOnMainThread:@selector(setDialButtonAsTalking) withObject:nil waitUntilDone:NO];
}

@end
