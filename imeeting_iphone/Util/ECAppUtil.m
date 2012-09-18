//
//  ECAppUtil.m
//  imeeting_iphone
//
//  Created by king star on 12-8-23.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECAppUtil.h"
#import "ECConstants.h"
#import "CommonToolkit/CommonToolkit.h"

@implementation ECAppUtil

+ (void)addCallCenterNumberToAddressBook {
    NSString *name = NSLocalizedString(@"call center", nil);
    NSString *number = CALL_CENTER_NUM;
    
}

+ (NSString *)displayNameFromAttendee:(NSDictionary *)attendee {
    NSString *userName = [attendee objectForKey:USERNAME];
    NSString *nickname = [attendee objectForKey:NICKNAME];
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:userName] objectAtIndex:0];
    if ([userName isEqualToString:displayName] && nickname && ![nickname isEqualToString:@""]) {
        displayName = nickname;
    }
    return displayName;
}
@end
