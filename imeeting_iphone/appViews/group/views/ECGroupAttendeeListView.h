//
//  ECGroupAttendeeListView.h
//  imeeting_iphone
//
//  Created by star king on 12-6-22.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECBaseUIView.h"

@interface AddContactButton : UIControl {
    UIColor *normalBG;
    UIColor *touchDownBG;
    
}
- (void)setTouchDownBGColor;
- (void)setNormalBGColor;
@end

@interface AttendeeCell : UITableViewCell {
    UIImageView *mGuyIcon;
    UILabel *mNameLabel;
    UILabel *mNumberLabel;
    UIImageView *mPhoneStatusIcon;
    UIImageView *mVideoStatusIcon;
    
    UIImage *phoneInTalkingImg;
    UIImage *phoneMutedImg;
    UIImage *videoOnImg;
    UIImage *videoOffImg;
    UIImage *guyIconImg;
}
+ (CGFloat)cellHeight;
- (id)initWithAttendee:(NSDictionary*)attendee;
- (void)updateAttendee:(NSDictionary*)attendee;
@end

@interface ECGroupAttendeeListView : ECBaseUIView <UITableViewDataSource, UITableViewDelegate>{
    UITableView *mAttendeeListTableView;
}

@property (nonatomic, retain) NSMutableArray *attendeeArray;
@end
