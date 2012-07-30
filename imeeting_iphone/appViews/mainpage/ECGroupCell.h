//
//  ECGroupCell.h
//  imeeting_iphone
//
//  Created by star king on 12-6-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"



@interface AttendeeGridView : UIView {
    UIView *line1;
    UIView *line2;
    CGFloat cellWidth;
    CGFloat cellHeight;
}

@property (nonatomic, retain) NSArray *attendeeArray;
+ (CGFloat)GridViewHeight:(NSArray*)attendeeArray ;
- (id)initWithAttendees:(NSArray*)attendeeArray;
- (void)initUI;
- (void)updateFrame;
- (UIView*)makeCellWithName:(NSString*)name Icon:(UIImage*)icon;
@end


@interface ECGroupCell : UITableViewCell {
    UIView * _myContentView;
    UIView *_containerView;
    
    UILabel *_mTitle;
    UILabel *mTime;
    AttendeeGridView *_mAttendeeGridView;
    
    UIButton *mExpandButton;
    
    NSString *_mStatus;
    
    UIColor *_statusOpenColor;
    UIColor *_statusCloseColor;
}

+ (CGFloat)cellHeight:(NSDictionary*)groupInfoJson;

- (id)initWithGroupInfo:(NSDictionary*)groupInfoJson;

- (void)updateFrame;
@end
