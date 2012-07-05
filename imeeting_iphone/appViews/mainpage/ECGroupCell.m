//
//  ECGroupCell.m
//  imeeting_iphone
//
//  Created by star king on 12-6-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupCell.h"
#import "ECConstants.h"

static CGFloat TitleLabelHeight = 18;
static CGFloat TitleLabelWidth = 140;
static CGFloat TimeLabelHeight = 16;
static CGFloat TimeLabelWidth = 150;
static CGFloat IconHeight = 50;
static CGFloat IconWidth = 50;
static CGFloat NameLabelHeight = 18;
static CGFloat NameLabelWidth = 50;
static CGFloat MarginTop = 6;
static CGFloat Margin = 12;
static CGFloat Padding = 3;


/*
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
*/

@implementation AttendeeGridView

@synthesize attendeeArray = _attendeeArray;
@synthesize expansible = _expansible;
@synthesize state = _state;

+ (CGFloat)GridViewHeight:(NSArray*)attendeeArray {
    CGFloat h = Padding * 3 + IconHeight + NameLabelHeight;
    if (attendeeArray && attendeeArray.count > 5) {
        h *= 2;
    }
    return h;
}

- (id)initWithAttendees:(NSArray *)attendeeArray {
    self = [super init];
    
    if (self) {
        cellWidth = Padding * 2 + NameLabelWidth;
        cellHeight = Padding * 3 + IconHeight + NameLabelHeight;
        self.attendeeArray = attendeeArray;
        self.expansible = NO;
        self.state = shrinked;
        
        [self initUI];
        

    }
    
    return self;
}

- (void)initUI {
    if (self.attendeeArray) {
        line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth * 5, cellHeight)];
        line2 = [[UIView alloc] initWithFrame:CGRectMake(0, line1.frame.origin.y + line1.frame.size.height, line1.frame.size.width, line1.frame.size.height)];

        
        if (self.attendeeArray.count > 5) {
            self.expansible = YES;
            // only display 10 people as maximum
            
            for (NSUInteger i = 0; i < 5; i++) {
                NSString *name = [self.attendeeArray objectAtIndex:i];
                UIImage *icon = [UIImage imageNamed:@"guy2"];
                UIView *cell = [self makeCellWithName:name Icon:icon];
                CGRect frame = CGRectMake(i * cellWidth, 0, cellWidth, cellHeight);
                cell.frame = frame;
                [line1 addSubview:cell];
                
            }
            
            int len = self.attendeeArray.count > 10 ? 10 : self.attendeeArray.count;
            for (NSUInteger i = 5; i < len; i++) {
                NSString *name = [self.attendeeArray objectAtIndex:i];
                UIImage *icon = [UIImage imageNamed:@"guy"];
                UIView *cell = [self makeCellWithName:name Icon:icon];
                CGRect frame = CGRectMake((i - 5) * cellWidth, 0, cellWidth, cellHeight);
                cell.frame = frame;
                [line2 addSubview:cell];
            }
            
            [self addSubview:line1];
            [self addSubview:line2];
        } else {
            for (NSUInteger i = 0; i < self.attendeeArray.count; i++) {
                NSString *name = [self.attendeeArray objectAtIndex:i];
                UIImage *icon = [UIImage imageNamed:@"guy2"];
                UIView *cell = [self makeCellWithName:name Icon:icon];
                CGRect frame = CGRectMake(i * cellWidth, 0, cellWidth, cellHeight);
                cell.frame = frame;
                [line1 addSubview:cell];
            }
            [self addSubview:line1];
 
        }
    
        [self updateFrame];
    }
    
}

- (void)updateFrame {
    int height = cellHeight;
    if (self.expansible) {
        height = cellHeight * 2;
    }
    self.frame = CGRectMake(0, 0, line1.frame.size.width, height);
}

- (UIView *)makeCellWithName:(NSString *)name Icon:(UIImage *)icon {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(Padding + (NameLabelWidth - IconWidth) / 2, Padding, IconWidth, IconHeight)];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.image = icon;
    iconView.backgroundColor = [UIColor clearColor];
    iconView.layer.masksToBounds = YES;
    [iconView.layer setCornerRadius:5.0];
    [cell addSubview:iconView];
    
    UILabel *nameLabel =[[UILabel alloc] initWithFrame:CGRectMake(Padding, iconView.frame.origin.y + iconView.frame.size.height + Padding, NameLabelWidth, NameLabelHeight)];
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:name] objectAtIndex:0];
    nameLabel.text = displayName;
    [nameLabel setTextAlignment:UITextAlignmentCenter];
    [nameLabel setFont:[UIFont systemFontOfSize:12]];
    nameLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:nameLabel];
    
    return cell;
    
}

// expand the view
//@Deprecated
- (void)expand {
    if (self.state == shrinked) {
        self.state = expanded;
        [self addSubview:line2];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, cellHeight*2);
    }
}

// shrink the view
//@Depreacted
- (void)shrink {
    if (self.state == expanded) {
        self.state = shrinked;
        [line2 removeFromSuperview];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, cellHeight);
    }
}


@end

@interface ECGroupCell ()

- (void)refreshCellBgColor;

@end

@implementation ECGroupCell

+ (CGFloat)cellHeight:(NSDictionary*)groupInfoJson {
    CGFloat cellHeight = MarginTop + TitleLabelHeight;
    if (groupInfoJson) {
        NSArray *attendees = [groupInfoJson objectForKey:GROUP_ATTENDEES];
        CGFloat attendeeGridHeight = [AttendeeGridView GridViewHeight:attendees];
        cellHeight += attendeeGridHeight;
    }
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
            
            mTitle = [[UILabel alloc] initWithFrame:CGRectMake(Margin, MarginTop, TitleLabelWidth, TitleLabelHeight)];
            mTitle.text = title;
            mTitle.font = [UIFont systemFontOfSize:18];
            mTitle.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:mTitle];
            
            mTime = [[UILabel alloc] initWithFrame:CGRectMake(mTitle.frame.origin.x + mTitle.frame.size.width + Margin, MarginTop + (TitleLabelHeight - TimeLabelHeight), TimeLabelWidth, TimeLabelHeight)];
            if (createdTime) {
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:createdTime.doubleValue];
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *time = [formater stringFromDate:date];
                mTime.text = time;
            }
            mTime.font = [UIFont systemFontOfSize:12];
            mTime.textColor = [UIColor colorWithIntegerRed:205 integerGreen:133 integerBlue:63 alpha:1];
            mTime.backgroundColor = [UIColor clearColor];
            [mTime setTextAlignment:UITextAlignmentRight];
            [self.contentView addSubview:mTime];
        
            /*
            mAttendeeListView = [[AttendeeListView alloc] init];
            mAttendeeListView.frame = CGRectMake(0, mTitle.frame.origin.y + mTitle.frame.size.height, self.frame.size.width, MarginTop + IconHeight + MarginBotton + NameLabelHeight + MarginBotton);
            [mAttendeeListView setAttendeeArray:attendees];
            [mAttendeeListView reloadData];
            [self.contentView addSubview:mAttendeeListView];
            */
            
            mAttendeeGridView = [[AttendeeGridView alloc] initWithAttendees:attendees];
            mAttendeeGridView.frame = CGRectMake(Margin, mTitle.frame.origin.y + mTitle.frame.size.height, mAttendeeGridView.frame.size.width, mAttendeeGridView.frame.size.height);
            [self.contentView addSubview:mAttendeeGridView];
            
            /*
            if (mAttendeeGridView.expansible) {
                // add expand button
                mExpandButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [mExpandButton setTitle:@"EXP" forState:UIControlStateNormal];
                if (mAttendeeGridView.state == shrinked) {
                    [mExpandButton setTitle:@"EXP" forState:UIControlStateNormal];
                } else {
                    [mExpandButton setTitle:@"SHK" forState:UIControlStateNormal];

                }
                mExpandButton.titleLabel.font = [UIFont systemFontOfSize:14];
                mExpandButton.frame = CGRectMake(mAttendeeGridView.frame.origin.x + mAttendeeGridView.frame.size.width + Padding, mAttendeeGridView.frame.origin.y + (mAttendeeGridView.frame.size.height - 40)/2, 45, 40);
                mExpandButton.titleLabel.textColor = [UIColor grayColor];
                [mExpandButton addTarget:self action:@selector(updateGridView) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:mExpandButton];
            }
            */
            
            [self refreshCellBgColor];
            
            [self updateFrame];
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

//@Deprecated
- (void)updateGridView {
    if (mAttendeeGridView.expansible) {
        if (mAttendeeGridView.state == shrinked) {
            // expand the grid view
            [mExpandButton setTitle:@"SHK" forState:UIControlStateNormal];

            [mAttendeeGridView expand];
        } else {
            // shrink the grid view
            [mExpandButton setTitle:@"EXP" forState:UIControlStateNormal];

            [mAttendeeGridView shrink];            
        }
        [self updateFrame];
     //   [self updateTableView];
    }
}

- (void)updateFrame {
    CGRect frame = self.frame;
    frame.size.height = Margin + TitleLabelHeight + mAttendeeGridView.frame.size.height;
    self.frame = frame; 
}

//@Deprecated
- (void)updateTableView {
    
    UITableView *tableView = (UITableView*)self.superview;
    
    NSIndexPath *path = [tableView indexPathForCell:self];
  
    NSLog(@"update row: %d", path.row);
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:path, nil] withRowAnimation:UITableViewRowAnimationBottom];
    
}

@end
