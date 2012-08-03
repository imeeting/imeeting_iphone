//
//  ECMeetingContactsListCell.m
//  imeeting_iphone
//
//  Created by star king on 12-7-26.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECMeetingContactsListCell.h"
#import "ECConstants.h"

// tableViewCell margin
#define MARGIN  6.0
// tableViewCell padding
#define PADDING 1.0

#define PHOTOIMGVIEW_WIDTH   10.0
// photo image view height
#define PHOTOIMGVIEW_HEIGHT  13.0
// full name label height
#define DISPLAYNAMELABEL_HEIGHT 22.0

#define INMEETING_CONTACT_TABLEVIEW_WIDTH   105

@implementation ECMeetingContactsListCell
@synthesize photoImg = _photoImg;
@synthesize displayName = _displayName;
@synthesize phoneNumbersArray = _phoneNumbersArray;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {                
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // init contentView subViews
        _mCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mCheckButton.frame = CGRectMake(10, MARGIN + (DISPLAYNAMELABEL_HEIGHT - PHOTOIMGVIEW_HEIGHT) / 2, PHOTOIMGVIEW_WIDTH, PHOTOIMGVIEW_HEIGHT);
        [self.contentView addSubview:_mCheckButton];
        
        _mDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mCheckButton.frame.origin.x + _mCheckButton.frame.size.width + 8, MARGIN, INMEETING_CONTACT_TABLEVIEW_WIDTH - _mCheckButton.frame.origin.x - _mCheckButton.frame.size.width, DISPLAYNAMELABEL_HEIGHT)];
        _mDisplayNameLabel.textColor = [UIColor colorWithIntegerRed:74 integerGreen:74 integerBlue:74 alpha:1];
        _mDisplayNameLabel.font = [UIFont fontWithName:CHINESE_FONT size:16];
        _mDisplayNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_mDisplayNameLabel];

        CGFloat sepY = _mDisplayNameLabel.frame.origin.y + _mDisplayNameLabel.frame.size.height + MARGIN + PADDING * 2;
        UIImageView *separateLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, sepY, self.frame.size.width, PADDING)];
        separateLine.contentMode = UIViewContentModeTopLeft;
        separateLine.image = [UIImage imageNamed:@"right_sep_line"];
        [self.contentView addSubview:separateLine];


    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    /*
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"right_region_selected"]];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
     */
}

- (void)setPhotoImg:(UIImage *)photoImg{
    _photoImg = photoImg;
    // set photo image view image
    [_mCheckButton setImage:photoImg forState:UIControlStateNormal];
    [_mCheckButton setImage:photoImg forState:UIControlStateHighlighted];
}

- (void)setDisplayName:(NSString *)displayName{
    // set display name text
    _displayName = displayName;
    
    // set full name label text
    _mDisplayNameLabel.text = displayName;
}

- (void)addImgButtonTarget:(id)pTarget andActionSelector:(SEL)pSelector{
    // add photo image button target and action selector
    [_mCheckButton addTarget:pTarget action:pSelector forControlEvents:UIControlEventTouchDown];
}

+ (CGFloat)cellHeightWithContact:(ContactBean *)pContact{
    CGFloat _ret = MARGIN + DISPLAYNAMELABEL_HEIGHT + MARGIN + PADDING * 3;
       
    return _ret;
}



@end
