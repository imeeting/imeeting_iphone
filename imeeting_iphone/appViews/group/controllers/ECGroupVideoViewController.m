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
- (void)onNetworkFailed:(ASIHTTPRequest*)request;
@end

@implementation ECGroupVideoViewController
@synthesize videoManager = _videoManager;

- (id)init {
    self = [self initWithCompatibleView:[[ECGroupVideoView alloc] init]];
    
    if (self) {
        self.videoManager = [[ECVideoManager alloc] init];
        self.videoManager.liveName = [[UserManager shareUserManager] userBean].name;
        self.videoManager.rtmpUrl = RTMP_SERVER_URL;
        self.videoManager.outImgWidth = 144;
        self.videoManager.outImgHeight = 192;
        [self.videoManager setupSession];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSwitchToAttendeeListView {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [self.navigationController pushViewController:module.attendeeController animated:YES];
}

- (void)attachVideoPreviewLayer {
    ECGroupVideoView *videoView = (ECGroupVideoView*)self.view;
    AVCaptureSession *session = self.videoManager.session;
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
    [self.videoManager switchCamera];
}

// start to capture video and upload
- (void)startCaptureVideo {
    [self attachVideoPreviewLayer];
    [self.videoManager startVideoCapture];
    [self broadcastVideoOnStatus];
}

// close camera, stop video capture
- (void)stopCaptureVideo {
    [self broadcastVideoOffStatus];
    [self detachVideoPreviewLayer];
    [self.videoManager stopVideoCapture];
   
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
@end
