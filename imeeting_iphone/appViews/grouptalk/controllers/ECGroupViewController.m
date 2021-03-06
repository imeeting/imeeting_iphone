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
#import "AuthInterceptor.h"
#import "ECAppUtil.h"

@interface ECGroupViewController () {
    MFMessageComposeViewController *mMsgViewController;
    NSTimer *_timer;
}
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
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
       
    }
   
    if (_refreshList) {
        //[NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:self withObject:nil];
        [self refreshAttendeeList];
    }

    if ([MFMessageComposeViewController canSendText]) {
        mMsgViewController = [[MFMessageComposeViewController alloc] init];
        mMsgViewController = nil;       
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
    [_timer invalidate];
    
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
        
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:0.4f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:csvc animated:NO];
    [UIView commitAnimations];
    
}

- (void)sendInviteSMS:(NSMutableArray *)members {
     if ([MFMessageComposeViewController canSendText]) {
         if (members && members.count > 0) {
             mMsgViewController = [[MFMessageComposeViewController alloc] init];
             
             mMsgViewController.recipients = members;
             
             NSString *audioConfId = [[ECGroupManager sharedECGroupManager] currentGroupModule].audioConfId;
             NSString *msgBody = [NSString stringWithFormat:@"请拨打0551-2379997加入多方通话，会议号：%@", audioConfId];
             mMsgViewController.body = msgBody;
             mMsgViewController.messageComposeDelegate = self;
             [self presentModalViewController:mMsgViewController animated:NO];
           
         } else {
             [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"No member to invite", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
         }
     } else {
         [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Your phone doesn't support SMS", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
     }

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    NSLog(@"messageComposeViewController finished - result: %d", result);
    
    [self dismissModalViewControllerAnimated:YES];
    mMsgViewController = nil;
        
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
    HTTP_RETURN_CHECK(request, self);
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
    NSString *onlineStatus = [attendee objectForKey:ONLINE_STATUS];
    NSString *videoStatus = [attendee objectForKey:VIDEO_STATUS];
    NSString *phoneStatus = [attendee objectForKey:TELEPHONE_STATUS];
    
    NSString *accountName = [[UserManager shareUserManager] userBean].name;

    NSString *displayName = [ECAppUtil displayNameFromAttendee:_selectedAttendee];
    
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:5];
    // generate action items
    if ([videoStatus isEqualToString:ON]) {
        [actions addObject:NSLocalizedString(@"Watch Video", "")];
    }
    
    if (![onlineStatus isEqualToString:ONLINE] || [accountName isEqualToString:username]) {
        if ([phoneStatus isEqualToString:TERMINATED] || [phoneStatus isEqualToString:FAILED] || [phoneStatus isEqualToString:TERMWAIT]) {
            [actions addObject:NSLocalizedString(@"Call", "")];
        } else if ([phoneStatus isEqualToString:CALL_WAIT] || [phoneStatus isEqualToString:ESTABLISHED]) {
            [actions addObject:NSLocalizedString(@"Hang Up", "")];
        }
    }
 
    if (![accountName isEqualToString:username]) {
        [actions addObject:NSLocalizedString(@"Send SMS", nil)];
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
        NSString *displayName = [ECAppUtil displayNameFromAttendee:_selectedAttendee];
        NSString *alertMsg = [NSString stringWithFormat:NSLocalizedString(@"Remove %@ ?", nil), displayName];
        [[[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil] show];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Send SMS", nil)]) {
        NSMutableArray *target = [NSMutableArray arrayWithCapacity:1];
        [target addObject:username];
        [self sendInviteSMS:target];
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
        [self setSmallVideoViewIsMine:YES];
        [module.videoManager startVideoFetchWithTargetUsername:targetUsername];
    }
    [self switchToVideoView];
}

#pragma mark - owner operations - phone related
- (void)call:(NSString *)targetUsername {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:targetUsername, @"dstUserName", module.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:CALL_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedCall:) andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)onFinishedCall:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedCall - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);

    int statusCode = pRequest.responseStatusCode;

    NSString *username = [_selectedAttendee objectForKey:USERNAME];
    NSString *displayName = [ECAppUtil displayNameFromAttendee:_selectedAttendee];
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
    [HttpUtil postSignatureRequestWithUrl:HANGUP_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedHangup:) andFailedRespSelector:@selector(onNetworkFailed:)];

}

- (void)onFinishedHangup:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedHangup - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);

    int statusCode = pRequest.responseStatusCode;
    
    NSString *username = [_selectedAttendee objectForKey:USERNAME];
    NSString *displayName = [ECAppUtil displayNameFromAttendee:_selectedAttendee];
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
    [HttpUtil postSignatureRequestWithUrl:KICKOUT_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedKickout:) andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)onFinishedKickout:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedKickout - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);

    int statusCode = pRequest.responseStatusCode;
    
    NSString *username = [_selectedAttendee objectForKey:USERNAME];
    NSString *displayName = [ECAppUtil displayNameFromAttendee:_selectedAttendee];
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
- (void)callMeIntoTalkingGroup {
    NSString *accountName = [[UserManager shareUserManager] userBean].name;
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:accountName, @"dstUserName", module.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:CALL_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedCallMe:) andFailedRespSelector:@selector(onNetworkFailed:)];

}

- (void)onFinishedCallMe:(ASIHTTPRequest*)pRequest {
    NSLog(@"onFinishedCallMe - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);

    int statusCode = pRequest.responseStatusCode;
    
    NSString *accountName = [[UserManager shareUserManager] userBean].name;
    switch (statusCode) {
        case 200: {
            // call command is accepted by server, update UI
            NSDictionary *attendee = [NSDictionary dictionaryWithObjectsAndKeys:accountName, USERNAME, CALL_WAIT, TELEPHONE_STATUS, nil];
            [self updateAttendee:attendee withMyself:YES];
            [self setDialButtonAsCalling];
            break;
        }
        case 403: {
            // call is forbidden
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Call is forbidden for you", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationNormal] show];
            break;
        }
        case 409: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Call in failed", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationNormal] show];
            break;
        }
        case 500: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Call in failed", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationNormal] show];
            break;
        }
        default:
            [[[iToast makeText:NSLocalizedString(@"Call in failed", "")] setDuration:iToastDurationNormal] show];
            break;
    }

}

- (void)hangMeUpFromTalkingGroup {
    NSString *accountName = [[UserManager shareUserManager] userBean].name;

    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:accountName, @"dstUserName", module.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:HANGUP_ATTENDEE_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedHangMeUp:) andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)onFinishedHangMeUp:(ASIHTTPRequest*)pRequest {
    NSLog(@"onFinishedHangMeUp - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
     NSString *accountName = [[UserManager shareUserManager] userBean].name;
    switch (statusCode) {
        case 409: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Hangup failed, maybe already hung up", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationNormal] show];
        }
        case 200: {
            // hangup command is accepted by server, update UI
            NSDictionary *attendee = [NSDictionary dictionaryWithObjectsAndKeys:accountName, USERNAME, TERMINATED, TELEPHONE_STATUS, nil];
            [self updateAttendee:attendee withMyself:YES];
            
            break;
        }
        case 403: {
            // hangup is forbidden
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Hangup is forbidden", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationNormal] show];
            break;
        }
        case 500: {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Hangup Talking failed", nil)];
            [[[iToast makeText:msg] setDuration:iToastDurationNormal] show];
            break;
        }
        default:
            [[[iToast makeText:NSLocalizedString(@"Hangup Talking failed", "")] setDuration:iToastDurationNormal] show];
            break;
    }

}

- (void)setDialButtonAsDial {
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
    [videoView performSelectorOnMainThread:@selector(setDialButtonAsDial) withObject:nil waitUntilDone:NO];
}

- (void)setDialButtonAsHangUp {
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
    [videoView performSelectorOnMainThread:@selector(setDialButtonAsHangUp) withObject:nil waitUntilDone:NO];
}

- (void)setDialButtonAsCalling {
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
    [videoView performSelectorOnMainThread:@selector(setDialButtonAsCalling) withObject:nil waitUntilDone:NO];
}

- (void)updateDialButtonStatus:(NSDictionary *)attendee {
    ECGroupVideoView *videoView = ((ECGroupView*)self.view).videoView;
    [videoView performSelectorOnMainThread:@selector(updateDialButtonStatus:) withObject:attendee waitUntilDone:NO];
}

- (void)sendHeartBeat {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:module.groupId, GROUP_ID, nil];
    [HttpUtil postSignatureRequestWithUrl:HEART_BEAT_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:nil andFailedRespSelector:@selector(onNetworkFailed:)];
}
@end
