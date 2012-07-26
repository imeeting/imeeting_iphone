//
//  ECMeetingContactsListCell.h
//  imeeting_iphone
//
//  Created by star king on 12-7-26.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"

#define CONTACT_PREINMEETING_PHOTO [UIImage imageNamed:@"left_arrow.png"]

@interface ECMeetingContactsListCell : UITableViewCell {
    // contact check button
    UIButton *_mCheckButton;
    // contact display name label
    UILabel *_mDisplayNameLabel;

}

// contact photo imageView photo image
@property (nonatomic, retain) UIImage *photoImg;
// contact diaplay name label text
@property (nonatomic, retain) NSString *displayName;
// contact phone numbers array
@property (nonatomic, retain) NSArray *phoneNumbersArray;

// add target/action for UIControlEventTouchDown event
- (void)addImgButtonTarget:(id)pTarget andActionSelector:(SEL)pSelector;

// get the height of the contacts list tableViewCell with contactBean object
+ (CGFloat)cellHeightWithContact:(ContactBean *)pContact;

@end
