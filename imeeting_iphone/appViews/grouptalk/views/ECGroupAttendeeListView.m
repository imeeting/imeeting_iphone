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
static CGFloat nameLabelWidth = 160;
static CGFloat nameLabelHeight = 30;
static CGFloat numberLabelWidth = 150;
static CGFloat numberLabelHeight = 20;
static CGFloat phoneStatusIconWidth = 20;
static CGFloat phoneStatusIconHeight = 20;
static CGFloat videoStatusIconWidth = 20;
static CGFloat videoStatusIconHeight = 20;
static CGFloat padding = 4;

@implementation AttendeeCell
+ (CGFloat)cellHeight {
    return cellHeight;
}

- (id)initWithAttendee:(NSDictionary *)attendee {
    self = [super init];
    if (self) {
        NSLog(@"initWithAttendee - %@", attendee);
        // init UI
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        _guyIconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (cellHeight - guyIconHeight) / 2, guyIconWidth, guyIconHeight)];
        _guyIconView.contentMode = UIViewContentModeScaleAspectFill;
       // mGuyIcon.backgroundColor = [UIColor clearColor];
        _guyIconView.layer.masksToBounds = YES;
        [_guyIconView.layer setCornerRadius:5.0];
        [self.contentView addSubview:_guyIconView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_guyIconView.frame.origin.x + guyIconWidth + padding * 2, padding, nameLabelWidth, nameLabelHeight)];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:_nameLabel];
        
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height, numberLabelWidth, numberLabelHeight)];
        _numberLabel.textColor = [UIColor colorWithIntegerRed:105 integerGreen:105 integerBlue:105 alpha:1];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_numberLabel];
        
        _phoneStatusIconView = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x + _nameLabel.frame.size.width + padding*4, (cellHeight - phoneStatusIconHeight) / 2, phoneStatusIconWidth, phoneStatusIconHeight)];
        _phoneStatusIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_phoneStatusIconView];
        
        _videoStatusIconView = [[UIImageView alloc] initWithFrame:CGRectMake(_phoneStatusIconView.frame.origin.x + _phoneStatusIconView.frame.size.width + padding*2, (cellHeight - videoStatusIconWidth) / 2, videoStatusIconWidth, videoStatusIconHeight)];
        _videoStatusIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_videoStatusIconView];
        
        _videoOnImg = [UIImage imageNamed:@"video_on"];
       // videoOffImg = [UIImage imageNamed:@"video_off"];

        _normalBGColor = [UIColor colorWithIntegerRed:232 integerGreen:232 integerBlue:232 alpha:0.9];
        _selectedBGColor = [UIColor colorWithIntegerRed:139 integerGreen:119 integerBlue:101 alpha:0.9];
        self.contentView.backgroundColor = _normalBGColor;

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
    
    _nameLabel.text = displayName;
    _numberLabel.text = username;
    
    
    if ([onlineStatus isEqualToString:ONLINE]) {
        _guyIconView.image = [[AddressBookManager shareAddressBookManager] avatarByPhoneNumber:username];
        
        if ([videoStatus isEqualToString:ON]) {
            NSLog(@"set video on image - username: %@", username);
            _videoStatusIconView.image = _videoOnImg;
        } else {
            NSLog(@"set video off image - username: %@", username);
            _videoStatusIconView.image = nil;
        }
        
    } else {
        _guyIconView.image = [[AddressBookManager shareAddressBookManager] grayAvatarByPhoneNumber:username];
        _videoStatusIconView.image = nil;
    }
    
    // set phone status
    if ([telephoneStatus isEqualToString:TERMINATED]) {
        NSLog(@"set phone terminated status");
        _phoneStatusIconView.image = nil;
    } else if ([telephoneStatus isEqualToString:CALL_WAIT]) {
        NSLog(@"set phone call wait status");

        _phoneStatusIconView.image = [UIImage imageNamed:@"voice_talkconnect"];
    } else if ([telephoneStatus isEqualToString:ESTABLISHED]) {
        NSLog(@"set phone established status");

        _phoneStatusIconView.image = [UIImage imageNamed:@"voice_talking"];
    } else if ([telephoneStatus isEqualToString:FAILED]) {
        NSLog(@"set phone call failed status");

        _phoneStatusIconView.image = [UIImage imageNamed:@"voice_talkfail"];
    }

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = _selectedBGColor;
    } else {
        self.contentView.backgroundColor = _normalBGColor;
    }
}

@end

@interface ECGroupAttendeeListView () 
- (void)initUI;
- (void)switchToVideoAction;
- (void)addContactAction;

@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@end

@implementation ECGroupAttendeeListView

@synthesize attendeeArray = _attendeeArray;
@synthesize statusFilter = _statusFilter;
@synthesize selectedIndexPath = _selectedIndexPath;

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
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, NavigationBarHeight)];
    _toolbar.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", "") style:UIBarButtonItemStyleBordered target:self action:@selector(switchToVideoAction)];
    _toolbar.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContactAction)];
    _toolbar.rightBarButtonItem.tintColor = [UIColor colorWithIntegerRed:107 integerGreen:147 integerBlue:35 alpha:1];
    [_toolbar.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
    
    _toolbar.tintColor = [UIColor colorWithIntegerRed:54 integerGreen:54 integerBlue:54 alpha:1];

    _title = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Attendee List", "") style:UIBarButtonItemStylePlain target:nil action:nil];
    [self addSubview:_toolbar];
    
    
    _attendeeListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _toolbar.frame.size.height, 320, 480 - _toolbar.frame.size.height)];
    _attendeeListTableView.backgroundColor = self.backgroundColor;
    _attendeeListTableView.dataSource = self;
    _attendeeListTableView.delegate = self;
    [self addSubview:_attendeeListTableView];
    
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0.5 - _attendeeListTableView.frame.size.height, _attendeeListTableView.frame.size.width, _attendeeListTableView.frame.size.height)];
    _refreshHeaderView.delegate = self;
    [_attendeeListTableView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
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
            AttendeeCell *cell = (AttendeeCell*)[_attendeeListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            [cell updateAttendeeStatus:foundAttendee];
        }
    }
}

- (void)setReloadingFlag:(BOOL)flag {
    _reloading = flag;
    if (!_reloading) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_attendeeListTableView];
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

    [_attendeeListTableView reloadData];
}

- (void)appendAttendee:(NSDictionary *)attendee {
    if (!attendee) {
        return;
    }
    NSMutableDictionary *newAtt = [[NSMutableDictionary alloc] initWithDictionary:attendee];
    [_attendeeArray addObject:newAtt];
    [_attendeeListTableView reloadData];
}

- (void)removeSelectedAttendee {
    [_attendeeArray removeObjectAtIndex:self.selectedIndexPath.row];
    [_attendeeListTableView deleteRowAtIndexPath:self.selectedIndexPath withRowAnimation:UITableViewRowAnimationTop];
    
}

#pragma mark - data source implementation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _attendeeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"tableview - cell for row: %d", indexPath.row);
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
    self.selectedIndexPath = indexPath;
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
    //[NSThread detachNewThreadSelector:@selector(refreshAttendeeList) toTarget:self.viewControllerRef withObject:nil];
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(refreshAttendeeList)]) {
        [self.viewControllerRef performSelector:@selector(refreshAttendeeList)];
    }
}

-(BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return  _reloading;
}

-(NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view{
    return [NSDate date];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - set UI

- (void)setAttendeeUI {
    NSArray *toolButtonArray = [NSArray arrayWithObjects:_toolbar.leftBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], _title, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil];
    [_toolbar setItems:toolButtonArray];
    
}

- (void)setOwnerUI {
    NSArray *toolButtonArray = [NSArray arrayWithObjects:_toolbar.leftBarButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], _title, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], _toolbar.rightBarButtonItem, nil];
    [_toolbar setItems:toolButtonArray];
}
@end
