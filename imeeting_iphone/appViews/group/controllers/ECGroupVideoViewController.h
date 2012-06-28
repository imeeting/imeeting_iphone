//
//  ECGroupVideoViewController.h
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import "ECVideoManager.h"

@interface ECGroupVideoViewController : UIViewController {
    AVCaptureVideoPreviewLayer *mPreviewLayer;
    
    BOOL isFirstLoad; // inidcate if the controller loads first.
}

@property (nonatomic, retain) ECVideoManager *videoManager;

- (void)onLeaveGroup;
- (void)onSwitchToAttendeeListView;
- (void)switchCamera;
- (void)startCaptureVideo;
- (void)stopCaptureVideo;

@end
