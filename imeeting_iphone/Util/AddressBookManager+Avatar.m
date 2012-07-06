//
//  AddressBookManager+Avatar.m
//  imeeting_iphone
//
//  Created by star king on 12-7-6.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "AddressBookManager+Avatar.h"
#import "CommonToolkit/UIImage+Extension.h"

static NSMutableDictionary *avatarCache;
static NSMutableDictionary *grayAvatarCache;
@implementation AddressBookManager (Avatar)
- (UIImage *)avatarByPhoneNumber:(NSString *)phoneNumber {
    if (avatarCache == nil) {
        avatarCache = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    
    UIImage *avatar = [avatarCache objectForKey:phoneNumber];
    if (avatar) {
        return avatar;
    } else {
        ContactBean *contact = [[AddressBookManager shareAddressBookManager] defaultContactByPhoneNumber:phoneNumber];
        static UIImage *defaultAvatar = nil;
        if (defaultAvatar == nil) {
            defaultAvatar = [UIImage imageNamed:@"default_avatar"];
        }
        avatar = defaultAvatar;
        if (contact && contact.photo) {
            avatar = [UIImage imageWithData:contact.photo];
        }
        [avatarCache setObject:avatar forKey:phoneNumber];
        return avatar;
    }
}

- (UIImage *)grayAvatarByPhoneNumber:(NSString *)phoneNumber {
    if (grayAvatarCache == nil) {
        grayAvatarCache = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    UIImage *grayAvatar = [grayAvatarCache objectForKey:phoneNumber];
    if (grayAvatar) {
        return grayAvatar;
    } else {
        UIImage *avatar = [self avatarByPhoneNumber:phoneNumber];
        grayAvatar = [avatar grayImage];
        [grayAvatarCache setObject:grayAvatar forKey:phoneNumber];
        return grayAvatar;
    }
    
}
@end
