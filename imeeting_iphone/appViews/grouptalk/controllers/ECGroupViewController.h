//
//  ECGroupViewController.h
//  imeeting_iphone
//
//  Created by star king on 12-7-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import "ECVideoManager.h"

@interface ECGroupViewController : UIViewController <UIAlertViewDelegate> {
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    BOOL _isFirstLoad; // inidcate if the controller loads first.

    NSDictionary *_selectedAttendee;
}

@property (nonatomic) BOOL refreshList;
@property (nonatomic) BOOL smallVideoViewIsMine; // indicate if the video view is swapped, YES: small video view displays my video, NO: small view displays friend's 

// dial button related
- (void)setDialButtonAsDial;
- (void)setDialButtonAsTalking;
//###### video view related methods
- (void)onLeaveGroup;
- (void)switchCamera;
- (void)startCaptureVideo;
- (void)stopCaptureVideo;
- (void)swapVideoView; // swap my video and friend video view
// render the video of selected guy
- (void)renderOppositVideo:(UIImage*)videoImage;
- (void)startVideoLoadingIndicator;
- (void)stopVideoLoadingIndicator;
- (void)resetOppositeVideoView;
- (void)showVideoLoadFailedInfo;

// attendee list view related methods
- (void)refreshAttendeeList;
- (void)updateAttendee:(NSDictionary*)attendee withMyself:(BOOL)myself;
- (void)onAttendeeSelected:(NSDictionary*)attendee;
- (void)addContacts;

- (void)switchVideoAndAttendeeListView;
- (void)switchToAttendeeListView;
- (void)switchToVideoView;
@end
