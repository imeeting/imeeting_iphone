//
//  ContactsSelectViewController.h
//  IMeeting
//
//  Created by  on 12-6-15.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

MFMessageComposeViewController *mMsgViewController;

@interface ContactsSelectViewController : UIViewController <MFMessageComposeViewControllerDelegate> {
    NSMutableArray *mCurrentInviteArray;
   
}

// if it's appeared in creating new group.
@property (nonatomic) BOOL isAppearedInCreateNewGroup;

// init in meeting contacts list table view in meeting contacts info array
- (void)initInMeetingAttendeesPhoneNumbers:(NSArray *)pPhoneNumbers;


- (void)inviteAttendees:(NSArray*)attendeeArray;
@end
