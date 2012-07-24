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
    
    UIImageView *_oppositeVideoView;
    
    UIButton *_leaveGroupButton;
    UIButton *_openCameraButton;
    UIButton *_cameraSwitchButton;
    
    BOOL _isCameraOpen;
    
    UIImage *_cameraOnImg;
    UIImage *_cameraOffImg;
    
    UILabel *_oppositeVideoNameLabel;
    UIActivityIndicatorView *_loadVideoIndicator;
}

@property (nonatomic,retain) UIView *myVideoView;
@property (nonatomic,retain) UIImageView *oppositeVideoView;

- (void)startShowLoadingVideo;
- (void)stopShowLoadingVideo;
- (void)setOppositeVideoName:(NSString*)name;
- (void)resetOppositeVideoUI;
- (void)showVideoLoadFailedInfo;
- (void)onOpenCameraButtonClickAction;

@end
