//
//  ECGroupView.h
//  imeeting_iphone
//
//  Created by star king on 12-7-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECGroupAttendeeListView.h"
#import "ECGroupVideoView.h"

@interface ECGroupView : UIView

@property (nonatomic, retain) ECGroupAttendeeListView *attendeeListView;
@property (nonatomic, retain) ECGroupVideoView *videoView;
@property (nonatomic) BOOL inVideoViewFlag;
- (void)switchToVideoView;
- (void)switchToAttendeeListView;
- (void)switchVideoAndAttendeeListView;
@end
