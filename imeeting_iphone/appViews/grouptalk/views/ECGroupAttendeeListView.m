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

static CGFloat cellHeight = 56;
static CGFloat guyIconWidth = 40;
static CGFloat guyIconHeight = 40;
static CGFloat nameLabelWidth = 120;
static CGFloat nameLabelHeight = 18;
static CGFloat phoneStatusIconWidth = 12;
static CGFloat phoneStatusIconHeight = 12;
static CGFloat videoStatusIconWidth = 12;
static CGFloat videoStatusIconHeight = 12;
static CGFloat padding = 6;

@implementation AttendeeCell
+ (CGFloat)cellHeight {
    return cellHeight;
}

- (id)initWithAttendee:(NSDictionary *)attendee {
    self = [super init];
    if (self) {
        NSLog(@"initWithAttendee - %@", attendee);
        // init UI
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _guyIconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, (cellHeight - guyIconHeight) / 2, guyIconWidth, guyIconHeight)];
        _guyIconView.contentMode = UIViewContentModeScaleAspectFill;
        _guyIconView.layer.masksToBounds = YES;
        [_guyIconView.layer setCornerRadius:5.0];
        [self.contentView addSubview:_guyIconView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_guyIconView.frame.origin.x + guyIconWidth + padding * 2, _guyIconView.frame.origin.y, nameLabelWidth, nameLabelHeight)];
        _nameLabel.textColor = [UIColor colorWithIntegerRed:122 integerGreen:122 integerBlue:122 alpha:1];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont fontWithName:CHINESE_FONT size:14];
        [self.contentView addSubview:_nameLabel];
        
        _videoStatusIconView = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + padding, videoStatusIconWidth, videoStatusIconHeight)];
        _videoStatusIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_videoStatusIconView];
        
        _videoStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(_videoStatusIconView.frame.origin.x + _videoStatusIconView.frame.size.width + 2, _videoStatusIconView.frame.origin.y, 40, videoStatusIconHeight)];
        _videoStatusLabel.textColor = [UIColor colorWithIntegerRed:163 integerGreen:163 integerBlue:163 alpha:1];
        _videoStatusLabel.font = [UIFont fontWithName:CHINESE_FONT size:12];
        _videoStatusLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_videoStatusLabel];
        
        _phoneStatusIconView = [[UIImageView alloc] initWithFrame:CGRectMake(_videoStatusLabel.frame.origin.x + _videoStatusLabel.frame.size.width + 2, _videoStatusLabel.frame.origin.y, phoneStatusIconWidth, phoneStatusIconHeight)];
        _phoneStatusIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_phoneStatusIconView];
        
        _phoneStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(_phoneStatusIconView.frame.origin.x + _phoneStatusIconView.frame.size.width + 2, _phoneStatusIconView.frame.origin.y, 100, phoneStatusIconHeight)];
        _phoneStatusLabel.textColor = _videoStatusLabel.textColor;
        _phoneStatusLabel.font = _videoStatusLabel.font;
        _phoneStatusLabel.backgroundColor = _videoStatusLabel.backgroundColor;
        [self.contentView addSubview:_phoneStatusLabel];
        
        UIImageView *sepLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, cellHeight - 1, 200, 1)];
        sepLine.contentMode = UIViewContentModeScaleAspectFill;
        sepLine.layer.masksToBounds = YES;
        sepLine.image = [UIImage imageNamed:@"attendee_list_sep_line"];
        [self.contentView addSubview:sepLine];
        
        _videoOnImg = [UIImage imageNamed:@"video_on"];
        _videoOffImg = [UIImage imageNamed:@"video_off"];

        _normalBGColor = [UIColor clearColor];
        _selectedBGColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"attendee_list_selected"]];
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
    
    if ([onlineStatus isEqualToString:ONLINE]) {
        _guyIconView.image = [[AddressBookManager shareAddressBookManager] avatarByPhoneNumber:username];
        
        if ([videoStatus isEqualToString:ON]) {
            NSLog(@"set video on image - username: %@", username);
            _videoStatusIconView.image = _videoOnImg;
            _videoStatusLabel.text = NSLocalizedString(@"Video On", nil);
        } else {
            NSLog(@"set video off image - username: %@", username);
            _videoStatusIconView.image = _videoOffImg;
            _videoStatusLabel.text = NSLocalizedString(@"Video Off", nil);
        }
        
    } else {
        _guyIconView.image = [[AddressBookManager shareAddressBookManager] grayAvatarByPhoneNumber:username];
        _videoStatusIconView.image = nil;
        _videoStatusLabel.text = nil;
    }
    
    // set phone status
    if ([telephoneStatus isEqualToString:TERMINATED]) {
        NSLog(@"set phone terminated status");
        _phoneStatusIconView.image = nil;
        _phoneStatusLabel.text = nil;
    } else if ([telephoneStatus isEqualToString:CALL_WAIT]) {
        NSLog(@"set phone call wait status");

        _phoneStatusIconView.image = [UIImage imageNamed:@"calling"];
        _phoneStatusLabel.text = NSLocalizedString(@"Calling", nil);
    } else if ([telephoneStatus isEqualToString:ESTABLISHED]) {
        NSLog(@"set phone established status");

        _phoneStatusIconView.image = [UIImage imageNamed:@"intalking"];
        _phoneStatusLabel.text = NSLocalizedString(@"Talking", nil);
    } else if ([telephoneStatus isEqualToString:FAILED]) {
        NSLog(@"set phone call failed status");

        _phoneStatusIconView.image = [UIImage imageNamed:@"call_failed"];
        _phoneStatusLabel.text = NSLocalizedString(@"Call Failed", nil);
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.contentView.backgroundColor = _selectedBGColor;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.contentView.backgroundColor = _normalBGColor;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.contentView.backgroundColor = _normalBGColor;
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
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"attendee_list_bg"]];

    int marginTop = 27;
    int marginBottom = 19;
    int padding = 35;
    int attendeeListTableViewWidth = 200;
    int attendeeViewWidth = 220;
    int addMemberButtonWidth = 200;
    int addMemberButtonHeight = 36;

    
    
    _attendeeListTableView = [[UITableView alloc] initWithFrame:CGRectMake((attendeeViewWidth - attendeeListTableViewWidth) / 2, marginTop, attendeeListTableViewWidth, 480 - marginTop - marginBottom - addMemberButtonHeight - padding)];
    _attendeeListTableView.backgroundColor = self.backgroundColor;
    _attendeeListTableView.dataSource = self;
    _attendeeListTableView.delegate = self;
    _attendeeListTableView.backgroundColor = [UIColor clearColor];
    _attendeeListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_attendeeListTableView];
    
    [_attendeeListTableView setViewGestureRecognizerDelegate:self];
    
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0.5 - _attendeeListTableView.frame.size.height, _attendeeListTableView.frame.size.width, _attendeeListTableView.frame.size.height)];
    _refreshHeaderView.delegate = self;
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    [_attendeeListTableView addSubview:_refreshHeaderView];
    
    [_refreshHeaderView refreshLastUpdatedDate];
    
    UIButton *addMemberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addMemberButton.frame = CGRectMake((attendeeViewWidth - addMemberButtonWidth) / 2, 480 - marginBottom - addMemberButtonHeight, addMemberButtonWidth, addMemberButtonHeight);
    [addMemberButton setTitle:NSLocalizedString(@"Add Attendee", nil) forState:UIControlStateNormal];
    [addMemberButton setBackgroundImage:[UIImage imageNamed:@"add_member_button"] forState:UIControlStateNormal];
    addMemberButton.titleLabel.font = [UIFont fontWithName:CHINESE_FONT size:14];
    [addMemberButton addTarget:self action:@selector(addContactAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:addMemberButton];
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

#pragma mark - gesture delegate
- (GestureType)supportedGestureInView:(UIView *)pView {
    return swipe;
}

- (UISwipeGestureRecognizerDirection)swipeDirectionInView:(UIView *)pView {
    return UISwipeGestureRecognizerDirectionLeft;
}

- (void)view:(UIView *)pView swipeAtPoint:(CGPoint)pPoint andDirection:(UISwipeGestureRecognizerDirection)pDirection {
    if (pDirection == UISwipeGestureRecognizerDirectionLeft) {
        [self switchToVideoAction];
    }
}

@end
