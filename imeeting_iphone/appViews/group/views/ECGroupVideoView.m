//
//  ECGroupVideoView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupVideoView.h"

static CGFloat VideoRegionWidth = 320;
static CGFloat VideoRegionHeight = 480;
static CGFloat BottomBarWidth = 320;
static CGFloat BottomBarHeight = 50;
static CGFloat MyVideoViewWidth = 108;
static CGFloat MyVideoViewHeight = 144;
static CGFloat LeaveButtonWidth = 80;
static CGFloat LeaveButtonHeight = 40;
static CGFloat SwitchToAttendeeListButtonWidth = 90;
static CGFloat SwitchToAttendeeListButtonHeight = 30;
static CGFloat SwitchFBCameraButtonWidth = 53;
static CGFloat SwitchFBCameraButtonHeight = 30;


@interface ECGroupVideoView ()
- (void)initUI;
- (UIView*)makeVideoRegion;
- (UIView*)makeBottonBar;
- (void)onLeaveAction;
- (void)onSwitchToAttendeeListViewAction;

- (void)onOpenCameraButtonClickAction;
- (void)onSwitchFBCameraAction;
@end

@implementation ECGroupVideoView
@synthesize myVideoView = mMyVideoView;
@synthesize oppositeVideoView = mOppositeVideoView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        isCameraOpen = NO;
    }
    return self;
}

- (void)initUI {
    NSLog(@"ECGroupVideoView - initUI");
    [self addSubview:[self makeVideoRegion]];
    [self addSubview:[self makeBottonBar]];
    
    CGFloat padding = 10;
    // make switch to attendee list view button
    UIButton *switchToAttenListButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [switchToAttenListButton setTitle:NSLocalizedString(@"Attendee List", "") forState:UIControlStateNormal];
    switchToAttenListButton.frame = CGRectMake(self.frame.size.width - SwitchToAttendeeListButtonWidth - 5, padding, SwitchToAttendeeListButtonWidth, SwitchToAttendeeListButtonHeight);
    [switchToAttenListButton addTarget:self action:@selector(onSwitchToAttendeeListViewAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:switchToAttenListButton];
    
    // make switch camera button
    UIButton *cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraSwitchButton.frame = CGRectMake(5, padding, SwitchFBCameraButtonWidth, SwitchFBCameraButtonHeight);
    [cameraSwitchButton setBackgroundImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    [cameraSwitchButton addTarget:self action:@selector(onSwitchFBCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cameraSwitchButton];
    
}

- (UIView *)makeVideoRegion {
    UIView *videoRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    videoRegion.backgroundColor = [UIColor orangeColor];
    
    CGColorRef borderColor = [[UIColor colorWithIntegerRed:0 integerGreen:0 integerBlue:0 alpha:0.8] CGColor];
    
    mOppositeVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    mOppositeVideoView.contentMode = UIViewContentModeScaleAspectFit;
    [videoRegion addSubview:mOppositeVideoView];
    
    mMyVideoView = [[UIView alloc] initWithFrame:CGRectMake(VideoRegionWidth - MyVideoViewWidth, VideoRegionHeight - BottomBarHeight - MyVideoViewHeight, MyVideoViewWidth, MyVideoViewHeight)];
    [mMyVideoView.layer setBorderWidth:2];
    [mMyVideoView.layer setBorderColor:borderColor];
    mMyVideoView.backgroundColor = [UIColor colorWithIntegerRed:159 integerGreen:182 integerBlue:205 alpha:1];
    [videoRegion addSubview:mMyVideoView];
    
    return videoRegion;
}

- (UIView *)makeBottonBar {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, VideoRegionHeight - BottomBarHeight, BottomBarWidth, BottomBarHeight)];
    bottomBar.backgroundColor = [UIColor colorWithIntegerRed:0 integerGreen:0 integerBlue:0 alpha:0.8];
    CGFloat secWidth = BottomBarWidth / 3;
    
    mLeaveGroupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mLeaveGroupButton setTitle:NSLocalizedString(@"Leave", "") forState:UIControlStateNormal];
    mLeaveGroupButton.frame = CGRectMake(secWidth + (secWidth - LeaveButtonWidth) / 2, (BottomBarHeight - LeaveButtonHeight) / 2, LeaveButtonWidth, LeaveButtonHeight);
    mLeaveGroupButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [mLeaveGroupButton addTarget:self action:@selector(onLeaveAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:mLeaveGroupButton];
    
    cameraOnImg = [UIImage imageNamed:@"camera_on"];
    cameraOffImg = [UIImage imageNamed:@"camera_off"];
    
    mOpenCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ocbW = 40;
    mOpenCameraButton.frame = CGRectMake(secWidth * 2 + (secWidth - ocbW) / 2, (BottomBarHeight - ocbW) / 2, ocbW, ocbW);
    [mOpenCameraButton setBackgroundImage:cameraOffImg forState:UIControlStateNormal];
    [mOpenCameraButton addTarget:self action:@selector(onOpenCameraButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:mOpenCameraButton];
    

    
    return bottomBar;
}

#pragma mark - button actions
- (void)onLeaveAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(onLeaveGroup)]) {
        [self.viewControllerRef performSelector:@selector(onLeaveGroup)];
    }
}

- (void)onSwitchToAttendeeListViewAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(onSwitchToAttendeeListView)]) {
        [self.viewControllerRef performSelector:@selector(onSwitchToAttendeeListView)];
    }
}

- (void)onOpenCameraButtonClickAction {
    if (isCameraOpen) {
        isCameraOpen = NO;
        // close camera to stop capture video
        [mOpenCameraButton setBackgroundImage:cameraOffImg forState:UIControlStateNormal];
        if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(stopCaptureVideo)]) {
            [self.viewControllerRef performSelector:@selector(stopCaptureVideo)];
        }
    } else {
        isCameraOpen = YES;
        // open camera to capture video
        [mOpenCameraButton setBackgroundImage:cameraOnImg forState:UIControlStateNormal];
        if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(startCaptureVideo)]) {
            [self.viewControllerRef performSelector:@selector(startCaptureVideo)];
        }
    }
}

- (void)onSwitchFBCameraAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchCamera)]) {
        [self.viewControllerRef performSelector:@selector(switchCamera)];
    }
}
@end
