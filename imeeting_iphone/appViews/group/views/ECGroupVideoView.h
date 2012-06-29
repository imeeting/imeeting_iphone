//
//  ECGroupVideoView.h
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECBaseUIView.h"

@interface ECGroupVideoView : ECBaseUIView {
    
    UIImageView *mOppositeVideoView;
    
    UIButton *mLeaveGroupButton;
    UIButton *mOpenCameraButton;
    UIButton *mCameraSwitchButton;
    
    BOOL isCameraOpen;
    
    UIImage *cameraOnImg;
    UIImage *cameraOffImg;
    
    UILabel *mOppositeVideoNameLabel;
    UIActivityIndicatorView *loadVideoIndicator;
}

@property (nonatomic,retain) UIView *myVideoView;
@property (nonatomic,retain) UIImageView *oppositeVideoView;

- (void)startShowLoadingVideo;
- (void)stopShowLoadingVideo;
- (void)setOppositeVideoName:(NSString*)name;
- (void)resetOppositeVideoUI;
- (void)showVideoLoadFailedInfo;
@end
