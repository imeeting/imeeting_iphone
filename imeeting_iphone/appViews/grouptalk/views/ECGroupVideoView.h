//
//  ECGroupVideoView.h
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECBaseUIView.h"

@interface ECGroupVideoView : ECBaseUIView <UIAlertViewDelegate> {
    UIButton *_cameraSwitchButton;
    
    BOOL _isCameraOpen;
    
    UILabel *_groupIdLabel;
    UIActivityIndicatorView *_loadVideoIndicator;
}

@property (nonatomic,retain) UIImageView *smallVideoView;
@property (nonatomic,retain) UIImageView *largeVideoView;

- (void)startShowLoadingVideo;
- (void)stopShowLoadingVideo;
- (void)setGroupIdText:(NSString*)name;
- (void)resetOppositeVideoUI;
- (void)showVideoLoadFailedInfo;
- (void)onOpenCameraButtonClickAction;

- (void)setDialButtonAsDial;
- (void)setDialButtonAsTalking;
- (void)setDialButtonAsHangUp;
@end
