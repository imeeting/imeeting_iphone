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
static CGFloat MyVideoViewWidth = 90;
static CGFloat MyVideoViewHeight = 120;
static CGFloat LeaveButtonWidth = 80;
static CGFloat LeaveButtonHeight = 40;


@interface ECGroupVideoView ()
- (void)initUI;
- (UIView*)makeVideoRegion;
- (UIView*)makeBottonBar;
- (void)onLeaveAction;
@end

@implementation ECGroupVideoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        [self addSubview:_mHud];
    }
    return self;
}

- (void)initUI {
    NSLog(@"ECGroupVideoView - initUI");
    [self addSubview:[self makeVideoRegion]];
    [self addSubview:[self makeBottonBar]];
    
}

- (UIView *)makeVideoRegion {
    UIView *videoRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    videoRegion.backgroundColor = [UIColor whiteColor];
    
    CGColorRef borderColor = [[UIColor colorWithIntegerRed:0 integerGreen:0 integerBlue:0 alpha:0.8] CGColor];
    
    mOppositeVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    mOppositeVideoView.contentMode = UIViewContentModeScaleAspectFit;
    [videoRegion addSubview:mOppositeVideoView];
    
    mMyVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(VideoRegionWidth - MyVideoViewWidth, VideoRegionHeight - BottomBarHeight - MyVideoViewHeight, MyVideoViewWidth, MyVideoViewHeight)];
    mMyVideoView.contentMode = UIViewContentModeScaleAspectFit;
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
    [mLeaveGroupButton addTarget:self action:@selector(onLeaveAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:mLeaveGroupButton];
    
    mOpenCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ocbW = 40;
    mOpenCameraButton.frame = CGRectMake(secWidth * 2 + (secWidth - ocbW) / 2, (BottomBarHeight - ocbW) / 2, ocbW, ocbW);
    UIImage *camera = [UIImage imageNamed:@"camera_off"];
    [mOpenCameraButton setBackgroundImage:camera forState:UIControlStateNormal];
    [bottomBar addSubview:mOpenCameraButton];
    

    
    return bottomBar;
}

#pragma mark - button actions
- (void)onLeaveAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(onLeaveGroup)]) {
        [self.viewControllerRef performSelector:@selector(onLeaveGroup)];
    }
}

@end
