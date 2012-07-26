//
//  ContactsListTableViewCell.m
//  IMeeting
//
//  Created by  on 12-6-15.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import "ContactsListTableViewCell.h"

// tableViewCell margin
#define MARGIN  6.0
// tableViewCell photo image view margin
#define PHOTOIMAGEVIEW_MARGIN    6.0
// tableViewCell padding
#define PADDING 2.0

// photo image view height
#define PHOTOIMGVIEW_HEIGHT  24.0
// full name label height
#define DISPLAYNAMELABEL_HEIGHT 20.0
// phone numbers label default height
#define PHONENUMBERSLABEL_DEFAULTHEIGHT   18.0


@implementation ContactsListTableViewCell

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
        _mCheckButton.frame = CGRectMake(MARGIN + PHOTOIMAGEVIEW_MARGIN, MARGIN + PHOTOIMAGEVIEW_MARGIN, PHOTOIMGVIEW_HEIGHT, PHOTOIMGVIEW_HEIGHT);
        [self.contentView addSubview:_mCheckButton];
        
        _mDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mCheckButton.frame.origin.x + _mCheckButton.frame.size.width + PADDING + PHOTOIMAGEVIEW_MARGIN + MARGIN, MARGIN, self.frame.size.width / 2 - MARGIN - (_mCheckButton.frame.size.width + PADDING), DISPLAYNAMELABEL_HEIGHT)];
        _mDisplayNameLabel.textColor = [UIColor colorWithIntegerRed:122 integerGreen:122 integerBlue:122 alpha:1];
        _mDisplayNameLabel.font = [UIFont fontWithName:@"Arial" size:15];
        _mDisplayNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_mDisplayNameLabel];
        
        _mPhoneNumbersLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mDisplayNameLabel.frame.origin.x, _mDisplayNameLabel.frame.origin.y + _mDisplayNameLabel.frame.size.height + PADDING, _mDisplayNameLabel.frame.size.width, PHONENUMBERSLABEL_DEFAULTHEIGHT)];
        _mPhoneNumbersLabel.textColor = [UIColor colorWithIntegerRed:181 integerGreen:181 integerBlue:181 alpha:1];
        _mPhoneNumbersLabel.font = [UIFont fontWithName:@"Arial" size:14];
        _mPhoneNumbersLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_mPhoneNumbersLabel];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"left_region_selected"]];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setPhotoImg:(UIImage *)photoImg{
    // set photo image
    _photoImg = photoImg;
    
    // check photo image
    if (photoImg) {
        // set photo image view image
        [_mCheckButton setImage:photoImg forState:UIControlStateNormal];
        [_mCheckButton setImage:photoImg forState:UIControlStateHighlighted];
    }
    else {
        // recover photo image view default photo image
        [_mCheckButton setImage:CONTACT_DEFAULT_PHOTO forState:UIControlStateNormal];
        [_mCheckButton setImage:CONTACT_DEFAULT_PHOTO forState:UIControlStateHighlighted];
    }
}

- (void)setDisplayName:(NSString *)displayName{
    // set display name text
    _displayName = displayName;
    
    // set full name label text
    _mDisplayNameLabel.text = displayName;
}

- (void)setPhoneNumbersArray:(NSArray *)phoneNumbersArray{
    // set phone number array
    _phoneNumbersArray = phoneNumbersArray;
    
    // set phone number label number of lines
    _mPhoneNumbersLabel.numberOfLines = ([phoneNumbersArray count] == 0) ? 1 : [phoneNumbersArray count];
    
    // update phone number label frame
    _mPhoneNumbersLabel.frame = CGRectMake(_mDisplayNameLabel.frame.origin.x, _mDisplayNameLabel.frame.origin.y + _mDisplayNameLabel.frame.size.height + PADDING, _mDisplayNameLabel.frame.size.width, PHONENUMBERSLABEL_DEFAULTHEIGHT * _mPhoneNumbersLabel.numberOfLines);
    
    // set phone number label text
    _mPhoneNumbersLabel.text = [phoneNumbersArray getContactPhoneNumbersDisplayTextWithStyle:vertical];

    CGFloat sepY = _mPhoneNumbersLabel.frame.origin.y + phoneNumbersArray.count * PHONENUMBERSLABEL_DEFAULTHEIGHT + MARGIN;
    CGRect frame = CGRectMake(0, sepY, self.frame.size.width, 1);
    if (!_mSeparateLine) { 
        _mSeparateLine = [[UIImageView alloc] initWithFrame:frame];
        _mSeparateLine.contentMode = UIViewContentModeScaleAspectFit;
        _mSeparateLine.image = [UIImage imageNamed:@"left_sep_line"];
        [self.contentView addSubview:_mSeparateLine];
    } else {
        _mSeparateLine.frame = frame;
    }
}

- (void)addImgButtonTarget:(id)pTarget andActionSelector:(SEL)pSelector{
    // add photo image button target and action selector
    [_mCheckButton addTarget:pTarget action:pSelector forControlEvents:UIControlEventTouchDown];
}

+ (CGFloat)cellHeightWithContact:(ContactBean *)pContact{
    // set contacts list TableViewCell default height
    CGFloat _ret = MARGIN + DISPLAYNAMELABEL_HEIGHT + PADDING + PHONENUMBERSLABEL_DEFAULTHEIGHT + MARGIN + 1;
    // check phone numbers
    if (pContact.phoneNumbers && [pContact.phoneNumbers count] > 1) {
        _ret += ([pContact.phoneNumbers count] - 1) * PHONENUMBERSLABEL_DEFAULTHEIGHT;
    }
    
    return _ret;
}

@end


