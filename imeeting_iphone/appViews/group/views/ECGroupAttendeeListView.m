//
//  ECGroupAttendeeListView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-22.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupAttendeeListView.h"
#import "ECConstants.h"

@implementation AddContactButton

- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, 60);
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((80 - 46) / 2, (60 - 50) / 2, 46, 50)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *img = [UIImage imageNamed:@"add_contact"];
        imgView.image = img;
        [self addSubview:imgView];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, (60 - 40) / 2, 320, 40)];
        labelView.text = NSLocalizedString(@"Invite Attendee", "");
        labelView.textAlignment = UITextAlignmentCenter;
        labelView.font = [UIFont boldSystemFontOfSize:18];
        labelView.textColor = [UIColor colorWithIntegerRed:105 integerGreen:105 integerBlue:105 alpha:1];
        labelView.backgroundColor = [UIColor clearColor];
        [self addSubview:labelView];
        
        normalBG = [UIColor colorWithPatternImage:[UIImage imageNamed:@"buttonbg"]];
        touchDownBG = [UIColor colorWithPatternImage:[UIImage imageNamed:@"buttonbg2"]];
        self.backgroundColor = normalBG;
        
        [self addTarget:self action:@selector(setTouchDownBGColor) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(setNormalBGColor) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(setNormalBGColor) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

- (void)setTouchDownBGColor {
    self.backgroundColor = touchDownBG;
}

- (void)setNormalBGColor {
    self.backgroundColor = normalBG;
}

@end

static CGFloat cellHeight = 60;
static CGFloat guyIconWidth = 50;
static CGFloat guyIconHeight = 50;
static CGFloat nameLabelWidth = 150;
static CGFloat nameLabelHeight = 30;
static CGFloat numberLabelWidth = 150;
static CGFloat numberLabelHeight = 20;
static CGFloat phoneStatusIconWidth = 30;
static CGFloat phoneStatusIconHeight = 30;
static CGFloat videoStatusIconWidth = 30;
static CGFloat videoStatusIconHeight = 30;
static CGFloat padding = 4;

@implementation AttendeeCell
+ (CGFloat)cellHeight {
    return cellHeight;
}

- (id)initWithAttendee:(NSDictionary *)attendee {
    self = [super init];
    if (self) {
        // init UI
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        mGuyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, (cellHeight - guyIconHeight) / 2, guyIconWidth, guyIconHeight)];
        mGuyIcon.contentMode = UIViewContentModeScaleAspectFit;
        mGuyIcon.backgroundColor = [UIColor clearColor];
        mGuyIcon.layer.masksToBounds = YES;
        mGuyIcon.image = [UIImage imageNamed:@"guydefault"];
        [mGuyIcon.layer setCornerRadius:5.0];
        [self.contentView addSubview:mGuyIcon];
        
        mNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(mGuyIcon.frame.origin.x + guyIconWidth + padding * 2, padding, nameLabelWidth, nameLabelHeight)];
        mNameLabel.textColor = [UIColor blackColor];
        mNameLabel.backgroundColor = [UIColor clearColor];
        mNameLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:mNameLabel];
        
        mNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(mNameLabel.frame.origin.x, mNameLabel.frame.origin.y + mNameLabel.frame.size.height, numberLabelWidth, numberLabelHeight)];
        mNumberLabel.textColor = [UIColor colorWithIntegerRed:105 integerGreen:105 integerBlue:105 alpha:1];
        mNumberLabel.backgroundColor = [UIColor clearColor];
        mNumberLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:mNumberLabel];
        
        mPhoneStatusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(mNameLabel.frame.origin.x + mNameLabel.frame.size.width + padding, (cellHeight - phoneStatusIconHeight) / 2, phoneStatusIconWidth, phoneStatusIconHeight)];
        mPhoneStatusIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:mPhoneStatusIcon];
        
        mVideoStatusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(mPhoneStatusIcon.frame.origin.x + mPhoneStatusIcon.frame.size.width + padding, (cellHeight - videoStatusIconWidth) / 2, videoStatusIconWidth, videoStatusIconHeight)];
        mVideoStatusIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:mVideoStatusIcon];
        
        guyIconImg = [UIImage imageNamed:@"guy2"];
        phoneInTalkingImg = [UIImage imageNamed:@"voice_on"];
        phoneMutedImg = [UIImage imageNamed:@"voice_off"];
        videoOnImg = [UIImage imageNamed:@"video_on"];
        videoOffImg = [UIImage imageNamed:@"video_off"];

        normalBGColor = [UIColor colorWithIntegerRed:232 integerGreen:232 integerBlue:232 alpha:0.9];
        selectedBGColor = [UIColor colorWithIntegerRed:139 integerGreen:119 integerBlue:101 alpha:0.9];
        self.contentView.backgroundColor = normalBGColor;

        [self updateAttendeeStatus:attendee];
    }
    return self;
}

- (void)updateAttendeeStatus:(NSDictionary *)attendee {
    NSString *username = [attendee objectForKey:USERNAME];
    NSString *onlineStatus = [attendee objectForKey:ONLINE_STATUS];
    NSString *videoStatus = [attendee objectForKey:VIDEO_STATUS];
    NSString *telephoneStatus = [attendee objectForKey:TELEPHONE_STATUS];
    
    mNameLabel.text = @"Username";
    mNumberLabel.text = username;
    
    if ([onlineStatus isEqualToString:ONLINE]) {
        mGuyIcon.image = guyIconImg;
        
        if ([videoStatus isEqualToString:ON]) {
            NSLog(@"set video on image");
            mVideoStatusIcon.image = videoOnImg;
        } else {
            NSLog(@"set video off image");
            mVideoStatusIcon.image = videoOffImg;
        }
        
    } else {
        mGuyIcon.image = [guyIconImg grayImage];
    }
    
   
    
    // for test UI
//    mPhoneStatusIcon.image = phoneInTalkingImg;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = selectedBGColor;
    } else {
        self.contentView.backgroundColor = normalBGColor;
    }
}

@end

@interface ECGroupAttendeeListView ()
- (void)initUI;
- (void)switchToVideoAction;
- (void)leaveGroupAction;
- (void)addContactAction;
@end

@implementation ECGroupAttendeeListView

@synthesize attendeeArray = _attendeeArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _attendeeArray = [[NSMutableArray alloc] initWithCapacity:10];
        [self initUI];

    }
    return self;
}

- (void)initUI {
    self.title = NSLocalizedString(@"Attendee List", "");
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Video", "") style:UIBarButtonItemStyleBordered target:self action:@selector(switchToVideoAction)];
    self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Leave", "") style:UIBarButtonItemStyleBordered target:self action:@selector(leaveGroupAction)];
    
    
    AddContactButton *acb = [[AddContactButton alloc] init];
    acb.frame = CGRectMake(0, 480 - StatusBarHeight - NavigationBarHeight - acb.frame.size.height, acb.frame.size.width, acb.frame.size.height);
    [acb addTarget:self action:@selector(addContactAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:acb];
    
    
    mAttendeeListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480 - acb.frame.size.height - NavigationBarHeight - StatusBarHeight)];
    mAttendeeListTableView.backgroundColor = self.backgroundColor;
    mAttendeeListTableView.dataSource = self;
    mAttendeeListTableView.delegate = self;
    [self addSubview:mAttendeeListTableView];
    
}

- (void)updateAttendee:(NSDictionary *)attendee withMyself:(BOOL)myself {
    NSLog(@"AttendeeListView - update attendee");
    
    NSString *username = [attendee objectForKey:USERNAME];
    NSString *accountName = [[UserManager shareUserManager] userBean].name;

    BOOL update = YES;
    if ([username isEqualToString:accountName] && !myself) {
        update = NO;
    }
    
    if (update) {
        NSUInteger i = 0;
        for (i = 0; i < _attendeeArray.count; i++) {
            NSDictionary *att = [_attendeeArray objectAtIndex:i];
            NSString *tempName = [att objectForKey:USERNAME];
            if ([tempName isEqualToString:username]) {
                break;
            }
        }
        if (i < _attendeeArray.count) {
            NSLog(@"refresh attendee at index %d", i);
            NSMutableDictionary *foundAttendee = [_attendeeArray objectAtIndex:i];
            [foundAttendee setValuesForKeysWithDictionary:attendee];
            [mAttendeeListTableView reloadData];
        }
    }
}

#pragma mark - button actions
- (void)switchToVideoAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchToVideo)]) {
        [self.viewControllerRef performSelector:@selector(switchToVideo)];
    }
}

- (void)leaveGroupAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(leaveGroup)]) {
        [self.viewControllerRef performSelector:@selector(leaveGroup)];
    }
}

- (void)addContactAction {
    NSLog(@"add contact");
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(addContacts)]) {
        [self.viewControllerRef performSelector:@selector(addContacts)];
    }
}

- (void)setAttendeeArray:(NSMutableArray *)attendeeArray {
    [_attendeeArray removeAllObjects];
    for (NSDictionary *att in attendeeArray) {
        NSMutableDictionary *newAtt = [[NSMutableDictionary alloc] initWithDictionary:att];
        [_attendeeArray addObject:newAtt];
    }
     NSLog(@"attendee size: %d", _attendeeArray.count);
    [mAttendeeListTableView reloadData];
}

- (void)appendAttendee:(NSDictionary *)attendee {
    if (!attendee) {
        return;
    }
    NSMutableDictionary *newAtt = [[NSMutableDictionary alloc] initWithDictionary:attendee];
    [_attendeeArray addObject:newAtt];
    [mAttendeeListTableView reloadData];
}

#pragma mark - data source implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _attendeeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellName = @"Attendee_Cell";
    
    AttendeeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellName];
    if (cell == nil) {
        NSDictionary *attendee = [_attendeeArray objectAtIndex:indexPath.row];
        cell = [[AttendeeCell alloc] initWithAttendee:attendee];
    }
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


#pragma mark - UITableView delegate implementation
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AttendeeCell cellHeight];
}

// row selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *attendee = [_attendeeArray objectAtIndex:indexPath.row];
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(onAttendeeSelected:)]) {
        [self.viewControllerRef performSelector:@selector(onAttendeeSelected:) withObject:attendee];
    }
}

@end
