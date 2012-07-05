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


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.attendeeListView = [[ECGroupAttendeeListView alloc] init];
        self.videoView = [[ECGroupVideoView alloc] init];
        [self addSubview:self.videoView];
        [self addSubview:self.attendeeListView];
        [self switchToVideoView];
    }
    return self;
}

- (void)setViewControllerRef:(UIViewController *)viewControllerRef {
    self.attendeeListView.viewControllerRef = viewControllerRef;
    self.videoView.viewControllerRef = viewControllerRef;
}

- (void)switchToVideoView {    
    /*
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.attendeeListView cache:YES];
    [self.attendeeListView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
    */
    CATransition *animation = [CATransition animation];
    animation.duration = 0.4f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [self.attendeeListView.layer addAnimation:animation forKey:@"animationID"];
    
    
    [self.attendeeListView setHidden:YES];

}

- (void)switchToAttendeeListView {
    [self.attendeeListView setHidden:NO];
  
    /*
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.attendeeListView cache:YES];
    [self.attendeeListView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
    [UIView commitAnimations];
     */
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.4f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self.attendeeListView.layer addAnimation:animation forKey:@"animationID"];

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
