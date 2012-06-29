//
//  ECGroupVideoViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupVideoViewController.h"
#import "ECGroupVideoView.h"
#import "ECGroupAttendeeListViewController.h"
#import "ECGroupModule.h"
#import "ECGroupManager.h"
#import "CommonToolkit/AVCamUtilities.h"
#import "ECUrlConfig.h"
#import "ECConstants.h"

@interface ECGroupVideoViewController ()
- (void)attachVideoPreviewLayer;
- (void)detachVideoPreviewLayer;
- (void)broadcastVideoOnStatus;
- (void)broadcastVideoOffStatus;
- (void)updateMyVideoOnStatus;
- (void)updateMyVideoOffStatus;
- (void)onNetworkFailed:(ASIHTTPRequest*)request;
@end

@implementation ECGroupVideoViewController

- (id)init {
    self = [self initWithCompatibleView:[[ECGroupVideoView alloc] init]];
    
    if (self) {
        isFirstLoad = YES;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if (isFirstLoad) {
        isFirstLoad = NO;
        ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
        [module.videoManager setupSession];
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

#pragma mark - actions
- (void)onLeaveGroup {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module onLeaveGroup];
    NSLog(@"module onLeaveGroup ok");
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"poped view controller");
}

- (void)onSwitchToAttendeeListView {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [self.navigationController pushViewController:module.attendeeController animated:YES];
}

- (void)attachVideoPreviewLayer {
    ECGroupVideoView *videoView = (ECGroupVideoView*)self.view;
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

- (void)updateMyVideoOnStatus {
    NSString *username = [[UserManager shareUserManager] userBean].name;
    NSDictionary *me = [NSDictionary dictionaryWithObjectsAndKeys:username, USERNAME, ON, VIDEO_STATUS, nil];
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module updateMyStatus:me];
}

- (void)updateMyVideoOffStatus {
    NSString *username = [[UserManager shareUserManager] userBean].name;
    NSDictionary *me = [NSDictionary dictionaryWithObjectsAndKeys:username, USERNAME, OFF, VIDEO_STATUS, nil];
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module updateMyStatus:me];
}

- (void)renderOppositVideo:(UIImage *)videoImage {
    NSLog(@"render opposite video");
    ECGroupVideoView *videoView = (ECGroupVideoView*)self.view;
    UIImageView *oppositView = videoView.oppositeVideoView;
    oppositView.image = videoImage;
}

- (void)setOppositeVideoName:(NSString *)name {
    ECGroupVideoView *view = (ECGroupVideoView*)self.view;
    [view setOppositeVideoName:name];
}

- (void)startVideoLoadingIndicator {
    ECGroupVideoView *view = (ECGroupVideoView*)self.view;
    [view startShowLoadingVideo];
}

- (void)stopVideoLoadingIndicator {
    ECGroupVideoView *view = (ECGroupVideoView*)self.view;
    [view stopShowLoadingVideo];
}

- (void)resetOppositeVideoView {
    ECGroupVideoView *view = (ECGroupVideoView*)self.view;
    [view resetOppositeVideoUI];
}

- (void)showVideoLoadFailedInfo {
    ECGroupVideoView *view = (ECGroupVideoView*)self.view;
    [view showVideoLoadFailedInfo];
}
@end
