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
        
        mGuyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(padding, (cellHeight - guyIconHeight) / 2, guyIconWidth, guyIconHeight)];
        mGuyIcon.contentMode = UIViewContentModeScaleAspectFit;
        mGuyIcon.backgroundColor = [UIColor clearColor];
        mGuyIcon.layer.masksToBounds = YES;
        mGuyIcon.image = [UIImage imageNamed:@"guydefault"];
        [mGuyIcon.layer setCornerRadius:5.0];
        [self addSubview:mGuyIcon];
        
        mNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(mGuyIcon.frame.origin.x + guyIconWidth + padding, 0, nameLabelWidth, nameLabelHeight)];
        mNameLabel.textColor = [UIColor blackColor];
        mNameLabel.backgroundColor = [UIColor clearColor];
        mNameLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:mNameLabel];
        
        mNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(mNameLabel.frame.origin.x, mNameLabel.frame.origin.y + mNameLabel.frame.size.height + padding, numberLabelWidth, numberLabelHeight)];
        mNumberLabel.textColor = [UIColor colorWithIntegerRed:105 integerGreen:105 integerBlue:105 alpha:1];
        mNumberLabel.backgroundColor = [UIColor clearColor];
        mNumberLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:mNumberLabel];
        
        mPhoneStatusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(mNameLabel.frame.origin.x + mNameLabel.frame.size.width + padding, (cellHeight - phoneStatusIconHeight) / 2, phoneStatusIconWidth, phoneStatusIconHeight)];
        mPhoneStatusIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:mPhoneStatusIcon];
        
        mVideoStatusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(mPhoneStatusIcon.frame.origin.x + mPhoneStatusIcon.frame.size.width + padding, (cellHeight - videoStatusIconWidth) / 2, videoStatusIconWidth, videoStatusIconHeight)];
        mVideoStatusIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:mVideoStatusIcon];
        
        guyIconImg = [UIImage imageNamed:@"guy2"];
        phoneInTalkingImg = [UIImage imageNamed:@"voice_on"];
        phoneMutedImg = [UIImage imageNamed:@"voice_off"];
        videoOnImg = [UIImage imageNamed:@"camera"];
        videoOffImg = [videoOnImg grayImage];
        
        [self updateAttendee:attendee];
    }
    return self;
}

- (void)updateAttendee:(NSDictionary *)attendee {
    NSString *username = [attendee objectForKey:USERNAME];
    NSString *onlineStatus = [attendee objectForKey:ONLINE_STATUS];
    NSString *videoStatus = [attendee objectForKey:VIDEO_STATUS];
    NSString *telephoneStatus = [attendee objectForKey:TELEPHONE_STATUS];
    
    if ([onlineStatus isEqualToString:ONLINE]) {
        mGuyIcon.image = guyIconImg;        
    } else {
        mGuyIcon.image = [guyIconImg grayImage];
    }
    
    // for test UI
    mVideoStatusIcon.image = videoOnImg;
    mPhoneStatusIcon.image = phoneMutedImg;
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
        [self addSubview:_mHud];

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
    
    
    mAttendeeListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480 - acb.frame.size.height)];
    mAttendeeListTableView.backgroundColor = self.backgroundColor;
    mAttendeeListTableView.dataSource = self;
    mAttendeeListTableView.delegate = self;
    [self addSubview:mAttendeeListTableView];
    
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
}

- (void)setAttendeeArray:(NSMutableArray *)attendeeArray {
    _attendeeArray = attendeeArray;
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
}

@end
