//
//  ECGroupVideoView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupVideoView.h"

static CGFloat VideoRegionWidth = 320;
static CGFloat VideoRegionHeight = 426;
static CGFloat BottomBarWidth = 320;
static CGFloat BottomBarHeight = 54;
static CGFloat MyVideoViewWidth = 108;
static CGFloat MyVideoViewHeight = 144;
static CGFloat LeaveButtonWidth = 80;
static CGFloat LeaveButtonHeight = 40;
static CGFloat SwitchToAttendeeListButtonWidth = 90;
static CGFloat SwitchToAttendeeListButtonHeight = 30;
static CGFloat SwitchFBCameraButtonWidth = 53;
static CGFloat SwitchFBCameraButtonHeight = 30;
static CGFloat OppositeNameLabelWidth = 100;
static CGFloat OppositeNameLabelHeight = 20;

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
    switchToAttenListButton.frame = CGRectMake(5, padding, SwitchToAttendeeListButtonWidth, SwitchToAttendeeListButtonHeight);
    [switchToAttenListButton addTarget:self action:@selector(onSwitchToAttendeeListViewAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:switchToAttenListButton];
    
    // make switch camera button
    mCameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mCameraSwitchButton.frame = CGRectMake(self.frame.size.width - SwitchFBCameraButtonWidth - 5, padding, SwitchFBCameraButtonWidth, SwitchFBCameraButtonHeight);
    [mCameraSwitchButton setBackgroundImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    [mCameraSwitchButton addTarget:self action:@selector(onSwitchFBCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mCameraSwitchButton];
    [mCameraSwitchButton setHidden:YES];
    
       
}

- (UIView *)makeVideoRegion {
    UIView *videoRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    videoRegion.backgroundColor = [UIColor clearColor];
    
    CGColorRef borderColor = [[UIColor colorWithIntegerRed:0 integerGreen:0 integerBlue:0 alpha:0.8] CGColor];
    
    mOppositeVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    mOppositeVideoView.contentMode = UIViewContentModeScaleAspectFill;
    mOppositeVideoView.backgroundColor = [UIColor colorWithIntegerRed:240 integerGreen:255 integerBlue:255 alpha:1];
    [videoRegion addSubview:mOppositeVideoView];
    
    // make load video indicator
   
    loadVideoIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadVideoIndicator.center = CGPointMake(mOppositeVideoView.center.x, mOppositeVideoView.center.y);

    UILabel *loadVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake((loadVideoIndicator.frame.size.width - 120) / 2, 25, 120, 20)];
    loadVideoLabel.text = NSLocalizedString(@"Loading Video", "");
    loadVideoLabel.font = [UIFont systemFontOfSize:14];
    loadVideoLabel.backgroundColor = [UIColor clearColor];
    loadVideoLabel.textAlignment = UITextAlignmentCenter;
    [loadVideoIndicator addSubview:loadVideoLabel];
    [mOppositeVideoView addSubview:loadVideoIndicator];
    
    // make name label
    mOppositeVideoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((mOppositeVideoView.frame.size.width - OppositeNameLabelWidth) / 2, 15, OppositeNameLabelWidth, OppositeNameLabelHeight)];
    mOppositeVideoNameLabel.font = [UIFont systemFontOfSize:12];
    [mOppositeVideoNameLabel.layer setMasksToBounds:YES];
    [mOppositeVideoNameLabel.layer setCornerRadius:10];
    mOppositeVideoNameLabel.backgroundColor = [UIColor colorWithIntegerRed:156 integerGreen:156 integerBlue:156 alpha:0.5];
    mOppositeVideoNameLabel.textAlignment = UITextAlignmentCenter;
    [mOppositeVideoView addSubview:mOppositeVideoNameLabel];
    [mOppositeVideoNameLabel setHidden:YES];
        
    mMyVideoView = [[UIView alloc] initWithFrame:CGRectMake(VideoRegionWidth - MyVideoViewWidth, VideoRegionHeight - MyVideoViewHeight, MyVideoViewWidth, MyVideoViewHeight)];
    [mMyVideoView.layer setBorderWidth:2];
    [mMyVideoView.layer setBorderColor:borderColor];
    mMyVideoView.backgroundColor = [UIColor colorWithIntegerRed:159 integerGreen:182 integerBlue:205 alpha:1];
    [videoRegion addSubview:mMyVideoView];
    
    
    return videoRegion;
}

- (UIView *)makeBottonBar {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, VideoRegionHeight, BottomBarWidth, BottomBarHeight)];
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
    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Leave Group?", "") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", "") otherButtonTitles:NSLocalizedString(@"Cancel", ""), nil] show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // leave group
            if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(onLeaveGroup)]) {
                [self.viewControllerRef performSelector:@selector(onLeaveGroup)];
            }
            break;
        case 1:
            // stay in group
            break;
        default:
            break;
    }
}


- (void)onSwitchToAttendeeListViewAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchToAttendeeListView)]) {
        [self.viewControllerRef performSelector:@selector(switchToAttendeeListView)];
    }
}

- (void)onOpenCameraButtonClickAction {
    if (isCameraOpen) {
        isCameraOpen = NO;
        // close camera to stop capture video
        [mOpenCameraButton setBackgroundImage:cameraOffImg forState:UIControlStateNormal];
        [mCameraSwitchButton setHidden:YES];
        if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(stopCaptureVideo)]) {
            [self.viewControllerRef performSelector:@selector(stopCaptureVideo)];
        }
    } else {
        isCameraOpen = YES;
        // open camera to capture video
        [mOpenCameraButton setBackgroundImage:cameraOnImg forState:UIControlStateNormal];
        [mCameraSwitchButton setHidden:NO];
        if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(startCaptureVideo)]) {
            //[self.viewControllerRef performSelector:@selector(startCaptureVideo)];
            [NSThread detachNewThreadSelector:@selector(startCaptureVideo) toTarget:self.viewControllerRef withObject:nil];
        }
    }
}

- (void)onSwitchFBCameraAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchCamera)]) {
        [self.viewControllerRef performSelector:@selector(switchCamera)];
    }
}

#pragma mark - video status
- (void)startShowLoadingVideo {
    mOppositeVideoView.image = nil;
    [loadVideoIndicator startAnimating];
}

- (void)stopShowLoadingVideo {
    [loadVideoIndicator stopAnimating];
}

- (void)setOppositeVideoName:(NSString *)name {
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:name] objectAtIndex:0];
    mOppositeVideoNameLabel.text = displayName;
    [mOppositeVideoNameLabel setHidden:NO];
}

- (void)resetOppositeVideoUI {
    [mOppositeVideoNameLabel setHidden:YES];
    [loadVideoIndicator stopAnimating];
    mOppositeVideoView.image = nil;
}

- (void)showVideoLoadFailedInfo {
    [loadVideoIndicator stopAnimating];
    [[iToast makeText:NSLocalizedString(@"Unable to load video", "")] show];
    sleep(1);
    [self resetOppositeVideoUI];
}
@end
