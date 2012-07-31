//
//  ECGroupView.m
//  imeeting_iphone
//
//  Created by star king on 12-7-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupView.h"

@implementation ECGroupView
@synthesize attendeeListView = _attendeeListView;
@synthesize videoView = _videoView;
@synthesize inVideoViewFlag = _inVideoViewFlag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _inVideoViewFlag = YES;
        self.attendeeListView = [[ECGroupAttendeeListView alloc] init];
        self.attendeeListView.frame = CGRectMake(-220, 0, 220, 480);
        self.videoView = [[ECGroupVideoView alloc] init];
        [self addSubview:self.videoView];
        [self addSubview:self.attendeeListView];
    }
    return self;
}

- (void)setViewControllerRef:(UIViewController *)viewControllerRef {
    self.attendeeListView.viewControllerRef = viewControllerRef;
    self.videoView.viewControllerRef = viewControllerRef;
}

- (void)switchVideoAndAttendeeListView {
    if (_inVideoViewFlag) {
        [self switchToAttendeeListView];
    } else {
        [self switchToVideoView];
    }
}

- (void)switchToVideoView {    
    if (!_inVideoViewFlag) {
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromRight forView:self.attendeeListView cache:YES];
        [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromRight forView:self.videoView cache:YES];
        
        [self.attendeeListView setCenter:CGPointMake(self.attendeeListView.center.x - self.attendeeListView.frame.size.width, self.attendeeListView.center.y)];
        [self.videoView setCenter:CGPointMake(self.videoView.center.x - self.attendeeListView.frame.size.width, self.videoView.center.y)];
        [UIView commitAnimations];
    }
    
    _inVideoViewFlag = YES;
}

- (void)switchToAttendeeListView {  
    if (_inVideoViewFlag) {
        [UIView beginAnimations:@"animationID" context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:NO];
        [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromLeft forView:self.attendeeListView cache:YES];
        [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromLeft forView:self.videoView cache:YES];
        
        [self.attendeeListView setCenter:CGPointMake(self.attendeeListView.center.x + self.attendeeListView.frame.size.width, self.attendeeListView.center.y)];
        [self.videoView setCenter:CGPointMake(self.videoView.center.x + self.attendeeListView.frame.size.width, self.videoView.center.y)];
        [UIView commitAnimations];
    }
    
    _inVideoViewFlag = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
