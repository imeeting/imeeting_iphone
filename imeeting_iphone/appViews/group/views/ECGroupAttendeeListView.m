//
//  ECGroupAttendeeListView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-22.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupAttendeeListView.h"
#import "ECConstants.h"
#import "AddressBookManager+Avatar.h"

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
        mGuyIcon.contentMode = UIViewContentModeScaleAspectFill;
       // mGuyIcon.backgroundColor = [UIColor clearColor];
        mGuyIcon.layer.masksToBounds = YES;
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
    
    NSString *displayName = [[[AddressBookManager shareAddressBookManager] contactsDisplayNameArrayWithPhoneNumber:username] objectAtIndex:0];
    
    mNameLabel.text = displayName;
    mNumberLabel.text = username;
    
    
    if ([onlineStatus isEqualToString:ONLINE]) {
        mGuyIcon.image = [[AddressBookManager shareAddressBookManager] avatarByPhoneNumber:username];
        
        if ([videoStatus isEqualToString:ON]) {
            NSLog(@"set video on image");
            mVideoStatusIcon.image = videoOnImg;
        } else {
            NSLog(@"set video off image");
            mVideoStatusIcon.image = videoOffImg;
        }
        
    } else {
        mGuyIcon.image = [[AddressBookManager shareAddressBookManager] grayAvatarByPhoneNumber:username];
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
- (void)addContactAction;
@end

@implementation ECGroupAttendeeListView

@synthesize attendeeArray = _attendeeArray;
@synthesize statusFilter = _statusFilter;

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
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, NavigationBarHeight)];
    toolbar.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", "") style:UIBarButtonItemStyleBordered target:self action:@selector(switchToVideoAction)];
    toolbar.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContactAction)];
    toolbar.rightBarButtonItem.tintColor = [UIColor colorWithIntegerRed:107 integerGreen:147 integerBlue:35 alpha:1];
    [toolbar.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
    
    toolbar.tintColor = [UIColor colorWithIntegerRed:54 integerGreen:54 integerBlue:54 alpha:1];

    title = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Attendee List", "") style:UIBarButtonItemStylePlain target:nil action:nil];
  //  NSArray *toolButtonArray = [NSArray arrayWithObjects:toolbar.leftBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], title, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], toolbar.rightBarButtonItem, nil];
   // [toolbar setItems:toolButtonArray];
    [self addSubview:toolbar];
    
    
    mAttendeeListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, 320, 480 - toolbar.frame.size.height - StatusBarHeight)];
    mAttendeeListTableView.backgroundColor = self.backgroundColor;
    mAttendeeListTableView.dataSource = self;
    mAttendeeListTableView.delegate = self;
    [self addSubview:mAttendeeListTableView];
    
    
    mRefreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0.5 - mAttendeeListTableView.frame.size.height, mAttendeeListTableView.frame.size.width, mAttendeeListTableView.frame.size.height)];
    mRefreshHeaderView.delegate = self;
    [mAttendeeListTableView addSubview:mRefreshHeaderView];
    
    [mRefreshHeaderView refreshLastUpdatedDate];
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
            
            if (self.statusFilter) {
                NSMutableDictionary *filteredAttendee = [self.statusFilter filterStatusOfNew:attendee withOld:foundAttendee];
                [foundAttendee setValuesForKeysWithDictionary:filteredAttendee];
            } else {
                [foundAttendee setValuesForKeysWithDictionary:attendee];                
            }
            
            [mAttendeeListTableView reloadData];
        }
    }
}

- (void)setReloadingFlag:(BOOL)flag {
    _reloading = flag;
    if (!_reloading) {
        [mRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mAttendeeListTableView];
    }
}

#pragma mark - button actions
- (void)switchToVideoAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(switchToVideoView)]) {
        [self.viewControllerRef performSelector:@selector(switchToVideoView)];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // leave group
            if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(leaveGroup)]) {
                [self.viewControllerRef performSelector:@selector(leaveGroup)];
            }
            break;
        case 1:
            // stay in group
            break;
        default:
            break;
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

#pragma mark - EGORefreshTableHeaderDelegate methods implemetation
-(void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
    // egoRefreshTableHeader did trigger refresh
    NSLog(@"begin to reload data.");
    
    // update reloading flag
    _reloading = YES;
    // init table dataSource
    [NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:self.viewControllerRef withObject:nil];
}

-(BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return  _reloading;
}

-(NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view{
    return [NSDate date];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [mRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [mRefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - set UI

- (void)setAttendeeUI {
    NSArray *toolButtonArray = [NSArray arrayWithObjects:toolbar.leftBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], title, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil];
    [toolbar setItems:toolButtonArray];
    
}

- (void)setOwnerUI {
    NSArray *toolButtonArray = [NSArray arrayWithObjects:toolbar.leftBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], title, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], toolbar.rightBarButtonItem, nil];
    [toolbar setItems:toolButtonArray];
}
@end
