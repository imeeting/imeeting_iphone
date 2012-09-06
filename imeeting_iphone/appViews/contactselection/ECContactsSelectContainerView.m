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
@synthesize createButton = _createButton;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAppearedInCreatingNewGroup = YES;
          
        _createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _createButton.frame = CGRectMake(0, 0, 53, 28);
        [_createButton setBackgroundImage:[UIImage imageNamed:@"navibutton"] forState:UIControlStateNormal];
        [_createButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
        _createButton.titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:13];
        [_createButton addTarget:self action:@selector(onInviteAttendeeAction) forControlEvents:UIControlEventTouchUpInside];
        self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_createButton];
         
            
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
    
    /*
    int totalNumber = _mMeetingContactsListView.preinMeetingContactsInfoArrayRef.count + _mMeetingContactsListView.inMeetingContactsInfoArrayRef.count;
    if (totalNumber > 5) {
        [[[iToast makeText:NSLocalizedString(@"Only 5 members in all are allowed", nil)] setDuration:iToastDurationLong] show];
        return;
    }
    */
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(inviteAttendees:)]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];        
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
