//
//  ECGroupAttendeeListViewController.h
//  imeeting_iphone
//
//  Created by star king on 12-6-22.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECGroupAttendeeListViewController : UIViewController {
    BOOL isListLoaded;
}

- (void)switchToVideo;
- (void)leaveGroup;
- (void)refreshAttendeeList;
- (void)updateAttendee:(NSDictionary*)attendee withMyself:(BOOL)myself;
@end
