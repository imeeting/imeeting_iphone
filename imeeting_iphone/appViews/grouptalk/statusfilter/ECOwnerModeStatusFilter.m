//
//  ECOwnerModeStatusFilter.m
//  imeeting_iphone
//
//  Created by star king on 12-7-10.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECOwnerModeStatusFilter.h"
#import "ECConstants.h"

@interface ECOwnerModeStatusFilter ()
- (NSString*)checkNewPhoneStatus:(NSString*)newPhoneStatus withOld:(NSString*)oldPhoneStatus;
- (void)alert:(NSString*)newPhoneStatus old:(NSString*)oldPhoneStatus;
@end

@implementation ECOwnerModeStatusFilter 
- (NSMutableDictionary*)filterStatusOfNew:(NSDictionary*)newAttendee withOld:(NSDictionary*)oldAttendee {
    NSLog(@"filterStatus");
    NSMutableDictionary *filtered = [NSMutableDictionary dictionaryWithDictionary:newAttendee];
    NSString *newPhoneStatus = [filtered objectForKey:TELEPHONE_STATUS];
    NSString *oldPhoneStatus = [oldAttendee objectForKey:TELEPHONE_STATUS];
    NSLog(@"new attendee: %@, old attendee: %@", newAttendee, oldAttendee);
    if (newPhoneStatus && oldPhoneStatus) {
        // filter the phone status
        NSString *checkPhoneStatus = [self checkNewPhoneStatus:newPhoneStatus withOld:oldPhoneStatus];
        [filtered setObject:checkPhoneStatus forKey:TELEPHONE_STATUS];
    }
    NSLog(@"filtered attendee: %@", filtered);
    return filtered;
}

- (NSString *)checkNewPhoneStatus:(NSString *)newPhoneStatus withOld:(NSString *)oldPhoneStatus {
    NSString *checkedStatus = oldPhoneStatus;
    if ([oldPhoneStatus isEqualToString:TERMINATED]) {
        if ([newPhoneStatus isEqualToString:CALL_WAIT] || [newPhoneStatus isEqualToString:TERMINATED]) {
            checkedStatus = newPhoneStatus;
        } else {
            [self alert:newPhoneStatus old:oldPhoneStatus];
        }
    } else if ([oldPhoneStatus isEqualToString:CALL_WAIT]) {
        if ([newPhoneStatus isEqualToString:ESTABLISHED] || [newPhoneStatus isEqualToString:TERMINATED] || [newPhoneStatus isEqualToString:FAILED] || [newPhoneStatus isEqualToString:CALL_WAIT]) {
            checkedStatus = newPhoneStatus;
        } else {
            [self alert:newPhoneStatus old:oldPhoneStatus];
        }
    } else if ([oldPhoneStatus isEqualToString:ESTABLISHED]) {
        if ([newPhoneStatus isEqualToString:TERMINATED] || [newPhoneStatus isEqualToString:ESTABLISHED]) {
            checkedStatus = newPhoneStatus;
        } else {
            [self alert:newPhoneStatus old:oldPhoneStatus];
        }
    } else if ([oldPhoneStatus isEqualToString:FAILED]) {
        if ([newPhoneStatus isEqualToString:CALL_WAIT] || [newPhoneStatus isEqualToString:FAILED]) {
            checkedStatus = newPhoneStatus;
        } else {
            [self alert:newPhoneStatus old:oldPhoneStatus];
        }
    }
    
    return checkedStatus;
}

- (void)alert:(NSString *)newPhoneStatus old:(NSString *)oldPhoneStatus {
    NSString *msg = [NSString stringWithFormat:@"Invalid status transformation from %@ to %@", oldPhoneStatus, newPhoneStatus];
   // [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]; 
    NSLog(@"%@", msg);
}
@end
