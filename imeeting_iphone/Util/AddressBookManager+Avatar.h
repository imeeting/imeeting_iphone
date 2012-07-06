//
//  AddressBookManager+Avatar.h
//  imeeting_iphone
//
//  Created by star king on 12-7-6.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "CommonToolkit/AddressBookManager.h"

@interface AddressBookManager (Avatar)
- (UIImage*)avatarByPhoneNumber:(NSString*)phoneNumber;
- (UIImage*)grayAvatarByPhoneNumber:(NSString*)phoneNumber;
@end
