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

@interface ECGroupViewController : UIViewController {
    AVCaptureVideoPreviewLayer *mPreviewLayer;
    
    BOOL isFirstLoad; // inidcate if the controller loads first.

}

@property (nonatomic) BOOL refreshList;

//###### video view related methods
- (void)onLeaveGroup;
- (void)switchToAttendeeListView;
- (void)switchCamera;
- (void)startCaptureVideo;
- (void)stopCaptureVideo;
// render the video of selected guy
- (void)renderOppositVideo:(UIImage*)videoImage;
- (void)setOppositeVideoName:(NSString*)name;
- (void)startVideoLoadingIndicator;
- (void)stopVideoLoadingIndicator;
- (void)resetOppositeVideoView;
- (void)showVideoLoadFailedInfo;

// attendee list view related methods
- (void)switchToVideoView;
- (void)refreshAttendeeList;
- (void)updateAttendee:(NSDictionary*)attendee withMyself:(BOOL)myself;
- (void)onAttendeeSelected:(NSDictionary*)attendee;
- (void)addContacts;
@end
