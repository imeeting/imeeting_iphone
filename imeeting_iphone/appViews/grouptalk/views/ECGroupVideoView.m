//
//  ECGroupVideoView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupVideoView.h"
#import "ECConstants.h"
#import "ECGroupModule.h"
#import "ECGroupManager.h"

static CGFloat VideoRegionWidth = 320;
static CGFloat VideoRegionHeight = 480;
static CGFloat BottomBarWidth = 320;
static CGFloat BottomBarHeight = 74;
static CGFloat SmallVideoViewWidth = 114;
static CGFloat SmallVideoViewHeight = 152;
static CGFloat SwitchFBCameraButtonWidth = 53;
static CGFloat SwitchFBCameraButtonHeight = 30;
static CGFloat GroupIdLabelWidth = 120;
static CGFloat GroupIdLabelHeight = 20;


@interface BottomBarButton : UIControl {
    UILabel *_titleLabel;
}
- (id)initWithFrame:(CGRect)frame andTitle:(NSString*)title andIcon:(UIImage*)icon;
@end

@implementation BottomBarButton

- (id)initWithFrame:(CGRect)frame andTitle:(NSString*)title andIcon:(UIImage*)icon {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 24) / 2, 16, 24, 24)];
        iconView.contentMode = UIViewContentModeScaleToFill;
        iconView.image = icon;
        [self addSubview:iconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - 60) / 2, iconView.frame.origin.y + iconView.frame.size.height + 2, 60, 22)];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:CHINESE_FONT size:12];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];

    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_button_pressed"]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.backgroundColor = [UIColor clearColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.backgroundColor = [UIColor clearColor];
}
@end

@interface ECGroupVideoView () {
    BottomBarButton *_cameraButton;
}
- (void)initUI;
- (UIView*)makeVideoRegion;
- (UIView*)makeBottomBar;
- (UIImageView*)makeBottomBarSepLine:(CGRect)frame;
- (void)onLeaveAction;
- (void)onSwitchVideoAndAttendeeListViewAction;
- (void)onSwitchToAttendeeListViewAction;
- (void)onSwitchToVideoViewAction;
- (void)onSwitchFBCameraAction;
- (void)onDialAction;
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
        NSLog(@"call swap video");
        [self.videoView.viewControllerRef performSelector:@selector(swapVideoView)];
    }
}

@end

@interface LargeVideoViewGesture : NSObject <UIViewGestureRecognizerDelegate>
@property (nonatomic, retain) ECGroupVideoView *videoView;
@end

@implementation LargeVideoViewGesture
@synthesize videoView = _videoView;
- (GestureType)supportedGestureInView:(UIView *)pView {
    return swipe;
}

- (UISwipeGestureRecognizerDirection)swipeDirectionInView:(UIView *)pView {
    return UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
}

- (void)view:(UIView *)pView swipeAtPoint:(CGPoint)pPoint andDirection:(UISwipeGestureRecognizerDirection)pDirection {
    switch (pDirection) {
        case UISwipeGestureRecognizerDirectionLeft: {
            [self.videoView onSwitchToVideoViewAction];
            break;
        }
        case UISwipeGestureRecognizerDirectionRight:
            [self.videoView onSwitchToAttendeeListViewAction];
            break;
        default:
            break;
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
    [self addSubview:[self makeBottomBar]];
    
    CGFloat padding = 10;
    
    // make switch camera button
    _cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraSwitchButton.frame = CGRectMake(self.frame.size.width - SwitchFBCameraButtonWidth - 5, padding, SwitchFBCameraButtonWidth, SwitchFBCameraButtonHeight);
    [_cameraSwitchButton setBackgroundImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    [_cameraSwitchButton addTarget:self action:@selector(onSwitchFBCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cameraSwitchButton];
    [_cameraSwitchButton setHidden:YES];
    
    // make group id label
    _groupIdLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - GroupIdLabelWidth) / 2, 15, GroupIdLabelWidth, GroupIdLabelHeight)];
    _groupIdLabel.font = [UIFont fontWithName:CHARACTER_FONT size:12];
    [_groupIdLabel.layer setMasksToBounds:YES];
    [_groupIdLabel.layer setCornerRadius:5];
    _groupIdLabel.backgroundColor = [UIColor colorWithIntegerRed:156 integerGreen:156 integerBlue:156 alpha:0.5];
    _groupIdLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:_groupIdLabel];

    
}

- (UIView *)makeVideoRegion {
    UIView *videoRegion = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    videoRegion.backgroundColor = [UIColor clearColor];
    
    CGColorRef borderColor = [[UIColor colorWithIntegerRed:0 integerGreen:0 integerBlue:0 alpha:1] CGColor];
    
    _largeVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VideoRegionWidth, VideoRegionHeight)];
    _largeVideoView.contentMode = UIViewContentModeScaleAspectFill;
    _largeVideoView.backgroundColor = [UIColor whiteColor];
    LargeVideoViewGesture *largeVideoViewGesture = [[LargeVideoViewGesture alloc] init];
    largeVideoViewGesture.videoView = self;
    _largeVideoView.userInteractionEnabled = YES;
    [_largeVideoView setViewGestureRecognizerDelegate:largeVideoViewGesture];
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
    
            
    _smallVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(VideoRegionWidth - SmallVideoViewWidth - 8, VideoRegionHeight - SmallVideoViewHeight - BottomBarHeight - 8, SmallVideoViewWidth, SmallVideoViewHeight)];
    _smallVideoView.layer.masksToBounds = YES;
    [_smallVideoView.layer setCornerRadius:8];
    [_smallVideoView.layer setBorderWidth:1];
    [_smallVideoView.layer setBorderColor:borderColor];
    _smallVideoView.backgroundColor = [UIColor colorWithIntegerRed:159 integerGreen:182 integerBlue:205 alpha:1];
    _smallVideoView.userInteractionEnabled = YES;
    SmallVideoViewGesture *smallVideoGesture = [[SmallVideoViewGesture alloc] init];
    smallVideoGesture.videoView = self;
    [_smallVideoView setViewGestureRecognizerDelegate:smallVideoGesture];
    [videoRegion addSubview:_smallVideoView];
    
    return videoRegion;
}

- (UIView *)makeBottomBar {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - BottomBarHeight, BottomBarWidth, BottomBarHeight)];
    bottomBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_bar"]];
    CGFloat secWidth = BottomBarWidth / 4;
    
    BottomBarButton *memberListButton = [[BottomBarButton alloc] initWithFrame:CGRectMake(0, 0, secWidth - 1, BottomBarHeight) andTitle:NSLocalizedString(@"Member List", nil) andIcon:[UIImage imageNamed:@"memberlist"]];
    [memberListButton addTarget:self action:@selector(onSwitchVideoAndAttendeeListViewAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:memberListButton];
        
    UIImageView *sepLine = [self makeBottomBarSepLine:CGRectMake(memberListButton.frame.origin.x + memberListButton.frame.size.width, 1, 2, BottomBarHeight - 1)];
    [bottomBar addSubview:sepLine];
    
    BottomBarButton *dialButton = [[BottomBarButton alloc] initWithFrame:CGRectMake(sepLine.frame.origin.x + sepLine.frame.size.width, 0, secWidth - 2, BottomBarHeight) andTitle:NSLocalizedString(@"Dial", nil) andIcon:[UIImage imageNamed:@"dial"]];
    [dialButton addTarget:self action:@selector(onDialAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:dialButton];

    sepLine = [self makeBottomBarSepLine:CGRectMake(dialButton.frame.origin.x + dialButton.frame.size.width, 1, 2, BottomBarHeight - 1)];
    [bottomBar addSubview:sepLine];    
    
    _cameraButton = [[BottomBarButton alloc] initWithFrame:CGRectMake(sepLine.frame.origin.x + sepLine.frame.size.width, 0, secWidth - 2, BottomBarHeight) andTitle:NSLocalizedString(@"Open Video", nil) andIcon:[UIImage imageNamed:@"camera"]];
    [_cameraButton addTarget:self action:@selector(onOpenCameraButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:_cameraButton];
    
    sepLine = [self makeBottomBarSepLine:CGRectMake(_cameraButton.frame.origin.x + _cameraButton.frame.size.width, 1, 2, BottomBarHeight - 1)];
    [bottomBar addSubview:sepLine];
    
    BottomBarButton *leaveGroupButton = [[BottomBarButton alloc] initWithFrame:CGRectMake(sepLine.frame.origin.x + sepLine.frame.size.width, 0, secWidth - 1, BottomBarHeight) andTitle:NSLocalizedString(@"Leave Group", nil) andIcon:[UIImage imageNamed:@"leave"]];
    [leaveGroupButton addTarget:self action:@selector(onLeaveAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:leaveGroupButton];
    
    return bottomBar;
}

- (UIImageView *)makeBottomBarSepLine:(CGRect)frame {
    UIImageView *sepLine = [[UIImageView alloc] initWithFrame:frame];
    sepLine.layer.masksToBounds = YES;
    sepLine.contentMode = UIViewContentModeScaleAspectFill;
    sepLine.image = [UIImage imageNamed:@"bottom_sep_line"];
    return sepLine;
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


- (void)onSwitchVideoAndAttendeeListViewAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchVideoAndAttendeeListView)]) {
        [self.viewControllerRef performSelector:@selector(switchVideoAndAttendeeListView)];
    }
}

- (void)onSwitchToAttendeeListViewAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchToAttendeeListView)]) {
        [self.viewControllerRef performSelector:@selector(switchToAttendeeListView)];
    }
}

- (void)onSwitchToVideoViewAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchToVideoView)]) {
        [self.viewControllerRef performSelector:@selector(switchToVideoView)];
    }
}

- (void)onOpenCameraButtonClickAction {
    if (_isCameraOpen) {
        _isCameraOpen = NO;
        // close camera to stop capture video
        [_cameraButton setTitle:NSLocalizedString(@"Open Video", nil)];
        [_cameraSwitchButton setHidden:YES];
        if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(stopCaptureVideo)]) {
            [self.viewControllerRef performSelector:@selector(stopCaptureVideo)];
        }
    } else {
        _isCameraOpen = YES;
        // open camera to capture video
        [_cameraButton setTitle:NSLocalizedString(@"Close Video", nil)];
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

- (void)onDialAction {
    NSString *phoneUrl = [NSString stringWithFormat:@"telprompt://%@", CALL_CENTER_NUM];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneUrl]];
}

#pragma mark - video status
- (void)startShowLoadingVideo {
    _largeVideoView.image = nil;
    [_loadVideoIndicator startAnimating];
}

- (void)stopShowLoadingVideo {
    [_loadVideoIndicator stopAnimating];
}

- (void)setGroupIdText:(NSString *)name {
    _groupIdLabel.text = name;
}

- (void)resetOppositeVideoUI {
    [_loadVideoIndicator stopAnimating];
    _largeVideoView.image = nil;
    _smallVideoView.image = nil;
}

- (void)showVideoLoadFailedInfo {
    [_loadVideoIndicator stopAnimating];
    [[[iToast makeText:NSLocalizedString(@"Unable to load video", "")] setDuration:iToastDurationLong] show];
    sleep(2);
    [self resetOppositeVideoUI];
}
@end
