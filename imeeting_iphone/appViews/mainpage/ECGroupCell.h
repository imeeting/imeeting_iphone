//
//  ECGroupCell.h
//  imeeting_iphone
//
//  Created by star king on 12-6-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"

static CGFloat TitleLabelHeight = 18;
static CGFloat TitleLabelWidth = 150;
static CGFloat TimeLabelHeight = 16;
static CGFloat TimeLabelWidth = 150;
static CGFloat IconHeight = 40;
static CGFloat IconWidth = 40;
static CGFloat NameLabelHeight = 18;
static CGFloat NameLabelWidth = 60;
static CGFloat MarginTop = 4;
static CGFloat MarginBotton = 4;
static CGFloat MarginLeft = 4;
static CGFloat MarginRight = 4;


@interface AttendeeListView : JTListView <JTListViewDelegate, JTListViewDataSource>

@property (nonatomic, retain) NSArray *attendeeArray;

@end


@interface ECGroupCell : UITableViewCell {
    UILabel *mTitle;
    UILabel *mTime;
    AttendeeListView *mAttendeeListView;
    
    NSString *mStatus;
    
    UIColor *openBackgroundColor;
    UIColor *closeBackgroundColor;
}

+ (CGFloat)cellHeight;

- (id)initWithGroupInfo:(NSDictionary*)groupInfoJson;

@end
