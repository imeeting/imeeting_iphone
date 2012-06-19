//
//  ECGroupCell.m
//  imeeting_iphone
//
//  Created by star king on 12-6-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupCell.h"
#import "ECConstants.h"

@implementation AttendeeListView

@synthesize attendeeArray = _attendeeArray;


- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)setAttendeeArray:(NSArray *)attendeeArray {
    if (!attendeeArray) {
        _attendeeArray = [[NSArray alloc] init];
    } else {
        _attendeeArray = attendeeArray;
    }
}

#pragma mark - JTListViewDataSource

- (NSUInteger)numberOfItemsInListView:(JTListView *)listView {
    return _attendeeArray.count;
}

- (UIView*)listView:(JTListView *)listView viewForItemAtIndex:(NSUInteger)index {
    UIView *view = [listView dequeueReusableView];
    if (!view) {
        view = [[UIView alloc] init];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(MarginLeft + (NameLabelWidth - IconWidth) / 2, MarginTop, IconWidth, IconHeight)];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.image = [UIImage imageNamed:@"fashionChannel"];
        iconView.backgroundColor = [UIColor clearColor];
        [view addSubview:iconView];
        
        UILabel *nameLabel =[[UILabel alloc] initWithFrame:CGRectMake(MarginLeft, iconView.frame.origin.y + iconView.frame.size.height + MarginBotton, NameLabelWidth, NameLabelHeight)];
        nameLabel.text = [_attendeeArray objectAtIndex:index];
        [nameLabel setTextAlignment:UITextAlignmentCenter];
        [nameLabel setFont:[UIFont systemFontOfSize:12]];
        nameLabel.backgroundColor = [UIColor clearColor];
        [view addSubview:nameLabel];
    }
    return view; 
}

#pragma mark - JTListViewDelegate

- (CGFloat)listView:(JTListView *)listView widthForItemAtIndex:(NSUInteger)index
{
    return (CGFloat)(MarginLeft + NameLabelWidth + MarginRight);
}

- (CGFloat)listView:(JTListView *)listView heightForItemAtIndex:(NSUInteger)index
{
    return (CGFloat)(MarginTop + IconHeight + MarginBotton + NameLabelHeight);
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITableViewCell *cell = (UITableViewCell*)self.superview.superview;
    [cell touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITableViewCell *cell = (UITableViewCell*)self.superview.superview;
    [cell touchesEnded:touches withEvent:event];
}

@end


@interface ECGroupCell ()

- (void)refreshCellBgColor;

@end

@implementation ECGroupCell

+ (CGFloat)cellHeight {
    CGFloat cellHeight = MarginTop + TitleLabelHeight + MarginTop + IconHeight + MarginBotton + NameLabelHeight + MarginBotton;
    return cellHeight;
}

- (id)initWithGroupInfo:(NSDictionary *)groupInfoJson {
    self = [super init];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        if (groupInfoJson) {
            NSString *title = [groupInfoJson objectForKey:GROUP_TITLE];
            NSNumber *createdTime = [groupInfoJson objectForKey:GROUP_CREATED_TIME];
            NSArray *attendees = [groupInfoJson objectForKey:GROUP_ATTENDEES];
            mStatus = [groupInfoJson objectForKey:GROUP_STATUS];
            
            mTitle = [[UILabel alloc] initWithFrame:CGRectMake(MarginLeft, MarginTop, TitleLabelWidth, TitleLabelHeight)];
            mTitle.text = title;
            mTitle.font = [UIFont systemFontOfSize:18];
            mTitle.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:mTitle];
            
            mTime = [[UILabel alloc] initWithFrame:CGRectMake(mTitle.frame.origin.x + mTitle.frame.size.width + MarginRight, MarginTop + (TitleLabelHeight - TimeLabelHeight), TimeLabelWidth, TimeLabelHeight)];
            if (createdTime) {
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:createdTime.doubleValue];
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *time = [formater stringFromDate:date];
                mTime.text = time;
            }
            mTime.font = [UIFont systemFontOfSize:14];
            mTime.textColor = [UIColor colorWithIntegerRed:205 integerGreen:133 integerBlue:63 alpha:1];
            mTime.backgroundColor = [UIColor clearColor];
            [mTime setTextAlignment:UITextAlignmentRight];
            [self.contentView addSubview:mTime];
        
            mAttendeeListView = [[AttendeeListView alloc] init];
            mAttendeeListView.frame = CGRectMake(0, mTitle.frame.origin.y + mTitle.frame.size.height, self.frame.size.width, MarginTop + IconHeight + MarginBotton + NameLabelHeight + MarginBotton);
            [mAttendeeListView setAttendeeArray:attendees];
            [mAttendeeListView reloadData];
            [self.contentView addSubview:mAttendeeListView];
            
            [self refreshCellBgColor];
            
        }
    }
    
    return self;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        openBackgroundColor = [UIColor colorWithIntegerRed:154 integerGreen:255 integerBlue:154 alpha:0.9];
        closeBackgroundColor = [UIColor colorWithIntegerRed:207 integerGreen:207 integerBlue:207 alpha:0.9];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

- (void)refreshCellBgColor {
    if (mStatus && [mStatus isEqualToString:@"OPEN"]) {
        self.backgroundColor = openBackgroundColor;
    } else {
        self.backgroundColor = closeBackgroundColor;
    }
}

@end
