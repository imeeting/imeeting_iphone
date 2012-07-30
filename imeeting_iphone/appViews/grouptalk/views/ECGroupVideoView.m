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
static CGFloat BottomBarHeight = 74;
static CGFloat SmallVideoViewWidth = 114;
static CGFloat SmallVideoViewHeight = 152;
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

- (void)onSwitchFBCameraAction;
@end

@interface SmallVideoViewGesture : NSObject <UIViewGestureRecognizerDelegate>
@property (nonatomic, retain) ECGroupVideoView *videoView;
@end

@implementation SmallVideoViewGesture
@synthesize videoView = _videoView;

- (GestureType)supportedGestureInView:(UIView *)pView {
    return tap | pan;
}

- (TapCountMode)tapCountModeInView:(UIView *)pView {
    return once;
}

- (TapFingerMode)tapFingerModeInView:(UIView *)pView {
    return single;
}

- (void)view:(UIView *)pView tapAtPoint:(CGPoint)pPoint andFingerMode:(TapFingerMode)pFingerMode andCountMode:(TapCountMode)pCountMode {
    NSLog(@"tap");
    if (pFingerMode == single && pCountMode == once) {
        // swap the video in small video view and large video view
        [self.videoView.viewControllerRef performSelector:@selector(swapVideoView)];
    }
}

@end


@implementation ECGroupVideoView
@synthesize smallVideoView = _smallVideoView;
@synthesize largeVideoView = _largeVideoView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.frame = CGRectMake(screenBounds.origin.x, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
        
        [self initUI];
        _isCameraOpen = NO;
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
    _cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraSwitchButton.frame = CGRectMake(self.frame.size.width - SwitchFBCameraButtonWidth - 5, padding, SwitchFBCameraButtonWidth, SwitchFBCameraButtonHeight);
    [_cameraSwitchButton setBackgroundImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    [_cameraSwitchButton addTarget:self action:@selector(onSwitchFBCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cameraSwitchButton];
    [_cameraSwitchButton setHidden:YES];
    
    // make name label
    _oppositeVideoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - OppositeNameLabelWidth) / 2, 15, OppositeNameLabelWidth, OppositeNameLabelHeight)];
    _oppositeVideoNameLabel.font = [UIFont systemFontOfSize:12];
    [_oppositeVideoNameLabel.layer setMasksToBounds:YES];
    [_oppositeVideoNameLabel.layer setCornerRadius:10];
    _oppositeVideoNameLabel.backgroundColor = [UIColor colorWithIntegerRed:156 integerGreen:156 integerBlue:156 alpha:0.5];
    _oppositeVideoNameLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:_oppositeVideoNameLabel];
    [_oppositeVideoNameLabel setHidden:YES];

    
}

- (UIView *)makeVideoRegion {
    UIView *videoRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    videoRegion.backgroundColor = [UIColor clearColor];
    
    CGColorRef borderColor = [[UIColor colorWithIntegerRed:0 integerGreen:0 integerBlue:0 alpha:1] CGColor];
    
    _largeVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    _largeVideoView.contentMode = UIViewContentModeScaleAspectFill;
    _largeVideoView.backgroundColor = [UIColor colorWithIntegerRed:240 integerGreen:255 integerBlue:255 alpha:1];
    [videoRegion addSubview:_largeVideoView];
    
    // make load video indicator
   
    _loadVideoIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadVideoIndicator.center = CGPointMake(_largeVideoView.center.x, _largeVideoView.center.y);

    UILabel *loadVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake((_loadVideoIndicator.frame.size.width - 120) / 2, 25, 120, 20)];
    loadVideoLabel.text = NSLocalizedString(@"Loading Video", "");
    loadVideoLabel.font = [UIFont systemFontOfSize:14];
    loadVideoLabel.backgroundColor = [UIColor clearColor];
    loadVideoLabel.textAlignment = UITextAlignmentCenter;
    [_loadVideoIndicator addSubview:loadVideoLabel];
    [_largeVideoView addSubview:_loadVideoIndicator];
    
            
    _smallVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(VideoRegionWidth - SmallVideoViewWidth, VideoRegionHeight - SmallVideoViewHeight - BottomBarHeight, SmallVideoViewWidth, SmallVideoViewHeight)];
    _smallVideoView.layer.masksToBounds = YES;
    [_smallVideoView.layer setBorderWidth:1];
    [_smallVideoView.layer setBorderColor:borderColor];
    _smallVideoView.backgroundColor = [UIColor colorWithIntegerRed:159 integerGreen:182 integerBlue:205 alpha:1];
    _smallVideoView.userInteractionEnabled = YES;
    [_smallVideoView setViewGestureRecognizerDelegate:[[SmallVideoViewGesture alloc] init]];
    [videoRegion addSubview:_smallVideoView];
    
    return videoRegion;
}

- (UIView *)makeBottonBar {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - BottomBarHeight, BottomBarWidth, BottomBarHeight)];
    bottomBar.backgroundColor = [UIColor colorWithIntegerRed:0 integerGreen:0 integerBlue:0 alpha:0.5];
    CGFloat secWidth = BottomBarWidth / 3;
    
    _leaveGroupButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_leaveGroupButton setTitle:NSLocalizedString(@"Leave", "") forState:UIControlStateNormal];
    _leaveGroupButton.frame = CGRectMake(secWidth + (secWidth - LeaveButtonWidth) / 2, (BottomBarHeight - LeaveButtonHeight) / 2, LeaveButtonWidth, LeaveButtonHeight);
    _leaveGroupButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_leaveGroupButton addTarget:self action:@selector(onLeaveAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_leaveGroupButton];
    
    _cameraOnImg = [UIImage imageNamed:@"camera_on"];
    _cameraOffImg = [UIImage imageNamed:@"camera_off"];
    
    _openCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat ocbW = 40;
    _openCameraButton.frame = CGRectMake(secWidth * 2 + (secWidth - ocbW) / 2, (BottomBarHeight - ocbW) / 2, ocbW, ocbW);
    [_openCameraButton setBackgroundImage:_cameraOffImg forState:UIControlStateNormal];
    [_openCameraButton addTarget:self action:@selector(onOpenCameraButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_openCameraButton];
    

    
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
    if (_isCameraOpen) {
        _isCameraOpen = NO;
        // close camera to stop capture video
        [_openCameraButton setBackgroundImage:_cameraOffImg forState:UIControlStateNormal];
        [_cameraSwitchButton setHidden:YES];
        if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(stopCaptureVideo)]) {
            [self.viewControllerRef performSelector:@selector(stopCaptureVideo)];
        }
    } else {
        _isCameraOpen = YES;
        // open camera to capture video
        [_openCameraButton setBackgroundImage:_cameraOnImg forState:UIControlStateNormal];
        [_cameraSwitchButton setHidden:NO];
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
    _largeVideoView.image = nil;
    [_loadVideoIndicator startAnimating];
}

- (void)stopShowLoadingVideo {
    [_loadVideoIndicator stopAnimating];
}

- (void)setOppositeVideoName:(NSString *)name {
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:name] objectAtIndex:0];
    _oppositeVideoNameLabel.text = displayName;
    [_oppositeVideoNameLabel setHidden:NO];
}

- (void)resetOppositeVideoUI {
    [_oppositeVideoNameLabel setHidden:YES];
    [_loadVideoIndicator stopAnimating];
    _largeVideoView.image = nil;
}

- (void)showVideoLoadFailedInfo {
    [_loadVideoIndicator stopAnimating];
    [[[iToast makeText:NSLocalizedString(@"Unable to load video", "")] setDuration:iToastDurationLong] show];
    sleep(2);
    [self resetOppositeVideoUI];
}
@end
