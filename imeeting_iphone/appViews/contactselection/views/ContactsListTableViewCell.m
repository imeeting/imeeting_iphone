//
//  ContactsListTableViewCell.m
//  IMeeting
//
//  Created by  on 12-6-15.
//  Copyright (c) 2012 richitec. All rights reserved.
//

#import "ContactsListTableViewCell.h"
#import "ECConstants.h"

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

// matching text color
#define MATCHINGTEXTCOLOR   [UIColor blueColor]

@implementation ContactsListTableViewCell

@synthesize photoImg = _photoImg;
@synthesize displayName = _displayName;
@synthesize fullNames = _mFullNames;
@synthesize phoneNumbersArray = _phoneNumbersArray;

@synthesize phoneNumberMatchingIndexs = _mPhoneNumberMatchingIndexs;
@synthesize nameMatchingIndexs = _mNameMatchingIndexs;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // init contentView subViews
        _mCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mCheckButton.frame = CGRectMake(MARGIN + PHOTOIMAGEVIEW_MARGIN, MARGIN + PHOTOIMAGEVIEW_MARGIN, PHOTOIMGVIEW_HEIGHT, PHOTOIMGVIEW_HEIGHT);
        [self.contentView addSubview:_mCheckButton];
        
        _mDisplayNameLabel = [[UIAttributedLabel alloc] initWithFrame:CGRectMake(_mCheckButton.frame.origin.x + _mCheckButton.frame.size.width + PADDING + PHOTOIMAGEVIEW_MARGIN + MARGIN, MARGIN, self.frame.size.width / 2 - MARGIN - (_mCheckButton.frame.size.width + PADDING), DISPLAYNAMELABEL_HEIGHT)];
        _mDisplayNameLabel.textColor = [UIColor colorWithIntegerRed:122 integerGreen:122 integerBlue:122 alpha:1];
        _mDisplayNameLabel.font = [UIFont fontWithName:CHINESE_FONT size:15];
        _mDisplayNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_mDisplayNameLabel];
        
        _mPhoneNumbersLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mDisplayNameLabel.frame.origin.x, _mDisplayNameLabel.frame.origin.y + _mDisplayNameLabel.frame.size.height + PADDING, _mDisplayNameLabel.frame.size.width, PHONENUMBERSLABEL_DEFAULTHEIGHT)];
        _mPhoneNumbersLabel.textColor = [UIColor colorWithIntegerRed:181 integerGreen:181 integerBlue:181 alpha:1];
        _mPhoneNumbersLabel.font = [UIFont fontWithName:CHARACTER_FONT size:14];
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
        self.contentView.backgroundImg = [UIImage imageNamed:@"left_region_selected"];
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
    
    // set display name label text
    NSMutableAttributedString *_attributedDisplayName = [NSMutableAttributedString attributedStringWithString:displayName];
    [_attributedDisplayName setFont:_mDisplayNameLabel.font];
    // set display name attributed label attributed text
    _mDisplayNameLabel.attributedText = _attributedDisplayName;
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
    
    CGFloat sepY = _mPhoneNumbersLabel.frame.origin.y + (phoneNumbersArray.count == 0 ? 1 : phoneNumbersArray.count) * PHONENUMBERSLABEL_DEFAULTHEIGHT + MARGIN;
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

- (void)setPhoneNumberMatchingIndexs:(NSArray *)phoneNumberMatchingIndexs{
    // set phone number matching index array
    _mPhoneNumberMatchingIndexs = phoneNumberMatchingIndexs;
    
    // process phone numbers matching index array
    if (phoneNumberMatchingIndexs) {
        // set phone number attributed label parent view
        if (_mPhoneNumbersAttributedLabelParentView) {
            for (UIView *_view in _mPhoneNumbersAttributedLabelParentView.subviews) {
                [_view removeFromSuperview];
            }
            [_mPhoneNumbersAttributedLabelParentView removeFromSuperview];
        }
        _mPhoneNumbersAttributedLabelParentView = [[UIView alloc] initWithFrame:_mPhoneNumbersLabel.frame];
        
        // process each phone number
        for (NSInteger _index = 0; _index < [_phoneNumbersArray count]; _index++) {
            // generate attributed string with phone number
            NSMutableAttributedString *_attributedPhoneNumber = [NSMutableAttributedString attributedStringWithString:[_phoneNumbersArray objectAtIndex:_index]];
            // set font
            [_attributedPhoneNumber setFont:[UIFont systemFontOfSize:14.0]];
            // set attributed phone number text color
            [_attributedPhoneNumber setTextColor:[UIColor lightGrayColor]];
            if ([phoneNumberMatchingIndexs objectAtIndex:_index] && [[phoneNumberMatchingIndexs objectAtIndex:_index] count] > 0) {
                for (NSNumber *__index in [phoneNumberMatchingIndexs objectAtIndex:_index]) {
                    [_attributedPhoneNumber setTextColor:MATCHINGTEXTCOLOR range:NSMakeRange(__index.integerValue, 1)];
                }
            }
            
            // generate each phone number attributed label and add to phone number attributed label parent view
            @autoreleasepool {
                UIAttributedLabel *_phoneNumberAttributedLabel = [[UIAttributedLabel alloc] initWithFrame:CGRectMake(0.0, _index * PHONENUMBERSLABEL_DEFAULTHEIGHT, _mPhoneNumbersLabel.frame.size.width, PHONENUMBERSLABEL_DEFAULTHEIGHT)];
                _phoneNumberAttributedLabel.backgroundColor = [UIColor clearColor];
                // set phone number attributed label attributed text
                _phoneNumberAttributedLabel.attributedText = _attributedPhoneNumber;
                // add to phone number attributed label parent view
                [_mPhoneNumbersAttributedLabelParentView addSubview:_phoneNumberAttributedLabel];
            }
        }
        
        // hide phone number label and add phone number attributed label parent view to cell content view
        _mPhoneNumbersLabel.hidden = YES;
        [self.contentView addSubview:_mPhoneNumbersAttributedLabelParentView];
    }
    else {
        // show phone number label and remove phone number attributed label parent view
        _mPhoneNumbersLabel.hidden = NO;
        for (UIView *_view in _mPhoneNumbersAttributedLabelParentView.subviews) {
            [_view removeFromSuperview];
        }
        [_mPhoneNumbersAttributedLabelParentView removeFromSuperview];
    }
}

- (void)setNameMatchingIndexs:(NSArray *)nameMatchingIndexs{
    // set name matching index array
    _mNameMatchingIndexs = nameMatchingIndexs;
    
    // process name matching index array
    if (nameMatchingIndexs) {
        // generate attributed string with display name
        NSMutableAttributedString *_attributedDisplayName = [NSMutableAttributedString attributedStringWithString:_displayName];
        // set font
        [_attributedDisplayName setFont:_mDisplayNameLabel.font];
        // set attributed display name text color
        /*
        for (NSNumber *_index in nameMatchingIndexs) {
            [_attributedDisplayName setTextColor:MATCHINGTEXTCOLOR range:[_mDisplayName rangeOfString:[[_mDisplayName nameArraySeparatedByCharacter] objectAtIndex:_index.integerValue]]];
        }
         */
        for (NSDictionary *_indexDic in nameMatchingIndexs) {
            // get matching name character index
            NSInteger _nameMatchingCharIndex = 0;
            for (NSInteger _index = 0; _index < [_mFullNames count]; _index++) {
                if (_index < ((NSNumber *)[_indexDic.allKeys objectAtIndex:0]).integerValue && [[_mFullNames objectAtIndex:_index] isEqualToString:[[_displayName nameArraySeparatedByCharacter] objectAtIndex:((NSNumber *)[_indexDic.allKeys objectAtIndex:0]).integerValue]]) {
                    _nameMatchingCharIndex += 1;
                }
            }
            
            // get range of name matching
            NSRange _range = NSRangeFromString([[_displayName rangesOfString:[[_displayName nameArraySeparatedByCharacter] objectAtIndex:((NSNumber *)[_indexDic.allKeys objectAtIndex:0]).integerValue]] objectAtIndex:_nameMatchingCharIndex]);
            
            [_attributedDisplayName setTextColor:MATCHINGTEXTCOLOR range:NSMakeRange(_range.location, NAME_CHARACTER_FULLMATCHING.integerValue == ((NSNumber *)[_indexDic.allValues objectAtIndex:0]).integerValue ? _range.length : ((NSNumber *)[_indexDic.allValues objectAtIndex:0]).integerValue)];
        }
        
        // set display name label attributed text
        _mDisplayNameLabel.attributedText = _attributedDisplayName;
    }
    else {
        // reset display name label text
        self.displayName = _displayName;
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


