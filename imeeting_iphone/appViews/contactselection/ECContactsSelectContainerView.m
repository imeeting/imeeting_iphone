//
//  ECContactsSelectContainerView.m
//  imeeting_iphone
//
//  Created by star king on 12-7-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECContactsSelectContainerView.h"
#import "ECConstants.h"

@interface ECContactsSelectContainerView ()
- (void)onInviteAttendeeAction;

@end

@implementation ECContactsSelectContainerView
@synthesize isAppearedInCreatingNewGroup = _isAppearedInCreatingNewGroup;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAppearedInCreatingNewGroup = YES;
          
        UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        createButton.frame = CGRectMake(0, 0, 53, 28);
        [createButton setBackgroundImage:[UIImage imageNamed:@"navibutton"] forState:UIControlStateNormal];
        [createButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
        createButton.titleLabel.font = [UIFont fontWithName:CHINESE_FONT size:12];
        [createButton addTarget:self action:@selector(onInviteAttendeeAction) forControlEvents:UIControlEventTouchUpInside];
        self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:createButton];
         
            
    }
    
    return self;
}

- (void)onInviteAttendeeAction {
    NSArray *selectedAttendeeArray = [self preinMeetingContactsInfoArray];
    NSLog(@"selected attendee count: %d", selectedAttendeeArray.count);
    
    if (!self.isAppearedInCreatingNewGroup) {
        if (selectedAttendeeArray.count <= 0) {
            [[[iToast makeText:NSLocalizedString(@"no attendee selected", "")] setDuration:iToastDurationLong] show];
            return;
        }
    }
    
    int totalNumber = _mMeetingContactsListView.preinMeetingContactsInfoArrayRef.count + _mMeetingContactsListView.inMeetingContactsInfoArrayRef.count;
    if (totalNumber > 5) {
        [[[iToast makeText:NSLocalizedString(@"Only 5 members in all are allowed", nil)] setDuration:iToastDurationLong] show];
        return;
    }
    
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(inviteAttendees:)]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
        
        if (self.isAppearedInCreatingNewGroup) {
            hud.labelText = NSLocalizedString(@"finishing creating group", "");
        } else {
            hud.labelText = NSLocalizedString(@"inviting attendees", "");
        }
        [hud showWhileExecuting:@selector(inviteAttendees:) onTarget:self.viewControllerRef withObject:selectedAttendeeArray animated:YES];
    }
}


- (void)goBack {
    if (_isAppearedInCreatingNewGroup) {
        [self.viewControllerRef.navigationController popViewControllerAnimated:YES];        
    } else {
        if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(goBackToGroupView)]) {
            [self.viewControllerRef performSelector:@selector(goBackToGroupView)];
        }
    }
}


@end
