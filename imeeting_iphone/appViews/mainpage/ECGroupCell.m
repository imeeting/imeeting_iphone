//
//  ECGroupCell.m
//  imeeting_iphone
//
//  Created by star king on 12-6-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupCell.h"
#import "ECConstants.h"
#import "AddressBookManager+Avatar.h"

static CGFloat TitleLabelHeight = 18;
static CGFloat TitleLabelWidth = 140;
static CGFloat TimeLabelHeight = 16;
static CGFloat TimeLabelWidth = 150;
static CGFloat IconHeight = 40;
static CGFloat IconWidth = 40;
static CGFloat NameLabelHeight = 18;
static CGFloat NameLabelWidth = 50;
static CGFloat Margin = 12;
static CGFloat Padding = 2;


@implementation AttendeeGridView

@synthesize attendeeArray = _attendeeArray;

+ (CGFloat)GridViewHeight:(NSArray*)attendeeArray {
    CGFloat h = Padding + IconHeight + NameLabelHeight;
    return h;
}

- (id)initWithAttendees:(NSArray *)attendeeArray {
    self = [super init];
    
    if (self) {
        cellWidth = Padding * 2 + NameLabelWidth;
        cellHeight = Padding * 3 + IconHeight + NameLabelHeight;
        self.attendeeArray = attendeeArray;
        [self initUI];
        
    }
    
    return self;
}

- (void)initUI {
    if (self.attendeeArray) {
        line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth * 5, cellHeight)];
        line1.backgroundColor = [UIColor clearColor];
        
        if (self.attendeeArray.count > 5) {
            // only display 5 people as maximum
            
            for (NSUInteger i = 0; i < 5; i++) {
                NSString *name = [self.attendeeArray objectAtIndex:i];
                
                UIImage *avatar = [[AddressBookManager shareAddressBookManager] avatarByPhoneNumber:name];
                NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:name] objectAtIndex:0];

                UIView *cell = [self makeCellWithName:displayName Icon:avatar];
                CGRect frame = CGRectMake(i * cellWidth, 0, cellWidth, cellHeight);
                cell.frame = frame;
                [line1 addSubview:cell];
                
            }
            [self addSubview:line1];
        } else {
            for (NSUInteger i = 0; i < self.attendeeArray.count; i++) {
                NSString *name = [self.attendeeArray objectAtIndex:i];
                
                UIImage *avatar = [[AddressBookManager shareAddressBookManager] avatarByPhoneNumber:name];                
                
                NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:name] objectAtIndex:0];
                
                UIView *cell = [self makeCellWithName:displayName Icon:avatar];
                CGRect frame = CGRectMake(i * cellWidth, 0, cellWidth, cellHeight);
                cell.frame = frame;
                [line1 addSubview:cell];
            }
            [self addSubview:line1];
 
        }
    
        [self updateFrame];
    }
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)updateFrame {
    int height = cellHeight;
    self.frame = CGRectMake(0, 0, line1.frame.size.width, height);
}

- (UIView *)makeCellWithName:(NSString *)name Icon:(UIImage *)icon {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(Padding + (NameLabelWidth - IconWidth) / 2, 0, IconWidth, IconHeight)];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.image = icon;
    iconView.layer.masksToBounds = YES;
   // [iconView.layer setCornerRadius:5.0];
    [cell addSubview:iconView];
    
    UILabel *nameLabel =[[UILabel alloc] initWithFrame:CGRectMake(Padding, iconView.frame.origin.y + iconView.frame.size.height, NameLabelWidth, NameLabelHeight)];
    nameLabel.text = name;
    [nameLabel setTextAlignment:UITextAlignmentCenter];
    [nameLabel setFont:[UIFont fontWithName:CHINESE_FONT size:12]];
    nameLabel.textColor = [UIColor colorWithIntegerRed:110 integerGreen:106 integerBlue:106 alpha:1];
    nameLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:nameLabel];
    
    return cell;
    
}


@end

@interface ECGroupCell ()

- (void)refreshTitleColor;

@end

@implementation ECGroupCell

+ (CGFloat)cellHeight:(NSDictionary*)groupInfoJson {
    return 127;
}

- (id)initWithGroupInfo:(NSDictionary *)groupInfoJson {
    self = [super init];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        _myContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [ECGroupCell cellHeight:groupInfoJson])];
        _myContentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"group_cell_bg"]];
        [self.contentView addSubview:_myContentView];
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(4, 0, 307, 113)];
        _containerView.backgroundColor = [UIColor clearColor];
        [_myContentView addSubview:_containerView];
        if (groupInfoJson) {
            NSString *title = [groupInfoJson objectForKey:GROUP_TITLE];
            NSNumber *createdTime = [groupInfoJson objectForKey:GROUP_CREATED_TIME];
            NSArray *attendees = [groupInfoJson objectForKey:GROUP_ATTENDEES];
            _mStatus = [groupInfoJson objectForKey:GROUP_STATUS];
            
            _mTitle = [[UILabel alloc] initWithFrame:CGRectMake(13, 16, TitleLabelWidth, TitleLabelHeight)];
            _mTitle.text = title;
            _mTitle.font = [UIFont fontWithName:CHINESE_FONT size:16];
            _mTitle.textColor = [UIColor colorWithIntegerRed:191 integerGreen:173 integerBlue:137 alpha:1];
            _mTitle.backgroundColor = [UIColor clearColor];
            [_containerView addSubview:_mTitle];
            
            mTime = [[UILabel alloc] initWithFrame:CGRectMake(145, 18, TimeLabelWidth, TimeLabelHeight)];
            if (createdTime) {
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:createdTime.doubleValue];
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *time = [formater stringFromDate:date];
                mTime.text = time;
            }
            mTime.font = [UIFont fontWithName:CHARACTER_FONT size:12];
            mTime.textColor = [UIColor colorWithIntegerRed:207 integerGreen:193 integerBlue:179 alpha:1];
            mTime.backgroundColor = [UIColor clearColor];
            [mTime setTextAlignment:UITextAlignmentRight];
            [_containerView addSubview:mTime];
                    
            _mAttendeeGridView = [[AttendeeGridView alloc] initWithAttendees:attendees];
            _mAttendeeGridView.frame = CGRectMake(Margin, _mTitle.frame.origin.y + _mTitle.frame.size.height + 8, _mAttendeeGridView.frame.size.width, _mAttendeeGridView.frame.size.height);
            [_containerView addSubview:_mAttendeeGridView];
                        
            [self refreshTitleColor];
            
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
        
        _statusOpenColor = [UIColor colorWithIntegerRed:143 integerGreen:188 integerBlue:143 alpha:1];
        _statusCloseColor = [UIColor colorWithIntegerRed:191 integerGreen:173 integerBlue:137 alpha:1];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        _containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"group_selected_cell_bg"]];
    } else {
        _containerView.backgroundColor = [UIColor clearColor];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"group_selected_cell_bg"]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _containerView.backgroundColor = [UIColor clearColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    _containerView.backgroundColor = [UIColor clearColor];
}

- (void)refreshTitleColor {
    if (_mStatus && [_mStatus isEqualToString:@"OPEN"]) {
        _mTitle.textColor = _statusOpenColor;
    } else {
        _mTitle.textColor = _statusCloseColor;
    }
}

- (void)updateFrame {
    CGRect frame = self.frame;
    frame.size.height = [ECGroupCell cellHeight:nil];
    self.frame = frame; 
}

@end
