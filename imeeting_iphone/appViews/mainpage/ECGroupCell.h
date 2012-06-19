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
static CGFloat NameLabelWidth = 50;
static CGFloat Margin = 4;
static CGFloat Padding = 2;

/*
@interface AttendeeListView : JTListView <JTListViewDelegate, JTListViewDataSource>

@property (nonatomic, retain) NSArray *attendeeArray;

@end
*/

typedef enum {
    expanded,
    shrinked
} AttendeeGridViewState;

@interface AttendeeGridView : UIView {
    UIView *line1;
    UIView *line2;
    CGFloat cellWidth;
    CGFloat cellHeight;
}

@property (nonatomic, retain) NSArray *attendeeArray;
@property (readwrite) BOOL expansible;
@property (readwrite) AttendeeGridViewState state;
+ (CGFloat)GridViewHeight:(NSArray*)attendeeArray ;
- (id)initWithAttendees:(NSArray*)attendeeArray;
- (void)initUI;
- (void)updateFrame;
- (void)expand;
- (void)shrink;
- (UIView*)makeCellWithName:(NSString*)name Icon:(UIImage*)icon;
@end


@interface ECGroupCell : UITableViewCell {
    UILabel *mTitle;
    UILabel *mTime;
  //  AttendeeListView *mAttendeeListView;
    AttendeeGridView *mAttendeeGridView;
    
    UIButton *mExpandButton;
    
    NSString *mStatus;
    
    UIColor *openBackgroundColor;
    UIColor *closeBackgroundColor;
}

+ (CGFloat)cellHeight:(NSDictionary*)groupInfoJson;

- (id)initWithGroupInfo:(NSDictionary*)groupInfoJson;

- (void)updateGridView;

- (void)updateFrame;

- (void)updateTableView;
@end
