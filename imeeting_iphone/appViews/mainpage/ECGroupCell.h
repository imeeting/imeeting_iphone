//
//  ECGroupCell.h
//  imeeting_iphone
//
//  Created by star king on 12-6-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"


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
