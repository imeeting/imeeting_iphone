//
//  ECMainPageView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-11.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECMainPageView.h"
#import "ECGroupCell.h"
#import "ECConstants.h"
#import "CommonToolkit/CommonToolkit.h"

#define GROUP_TABLEVIEW_WIDTH       312
#define CREATE_GROUP_BUTTON_WIDTH   312
#define CREATE_GROUP_BUTTON_HEIGHT  36

@implementation ECMainTableView
@synthesize currentDeletedIndexPath = _currentDeletedIndexPath;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        mGroupDataSource = [[NSMutableArray alloc] initWithCapacity:20];
        self.hasNext = [[NSNumber alloc] initWithBool:NO];
        self.autoLoadDelegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        mRefreshHeaderView.backgroundColor = [UIColor clearColor];
        self.tableFooterView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)refreshDataSource {
    ECMainPageView *mainPage = (ECMainPageView*)self.superview;

    [mainPage refreshGroupList];
}

- (void)loadMoreDataSource {
    ECMainPageView *mainPage = (ECMainPageView*)self.superview;
    [mainPage loadMoreDataSource];
}

- (void)setGroupDataSource:(NSArray *)groupArray {
    mGroupDataSource = [[NSMutableArray alloc] initWithArray:groupArray];
}

- (void)appendGroupDataSourceWithArray:(NSArray *)groupArray {
    [mGroupDataSource addObjectsFromArray:groupArray];
}

#pragma mark - TableView datasource implementations

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger ret = [mGroupDataSource count];
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *GroupCell = @"Group_Cell";
    
    ECGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCell];
    if (cell == nil) {
        NSDictionary *groupInfo = [mGroupDataSource objectAtIndex:indexPath.row];
        cell = [[ECGroupCell alloc] initWithGroupInfo:groupInfo];
    }
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - TableView Delegate implementations

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ECGroupCell cellHeight:[mGroupDataSource objectAtIndex:indexPath.row]];
}

// row selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select %d", indexPath.row);
    NSDictionary *group = [mGroupDataSource objectAtIndex:indexPath.row];
    ECMainPageView *mainPage = (ECMainPageView*)self.superview;
    [mainPage itemSelected:group];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)hideGroup:(NSDictionary *)groupInfo {
    NSString *groupId = [groupInfo objectForKey:GROUP_ID];
    ECMainPageView *mainPage = (ECMainPageView*)self.superview;
    [mainPage hideGroup:groupId];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.currentDeletedIndexPath = indexPath;
        NSDictionary *groupInfo = [mGroupDataSource objectAtIndex:indexPath.row];
        [self hideGroup:groupInfo];
    }
}

- (void)removeGroupFromUI:(NSIndexPath *)indexPath {
    [mGroupDataSource removeObjectAtIndex:indexPath.row];
    [self deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationTop];
}

@end

@interface ECMainPageView ()

- (void)initUI;
- (void)hideGroup:(NSString*)groupId;
- (void)onCreateNewGroupAction;
- (void)onSystemSettingAction;
@end

@implementation ECMainPageView

- (void)initUI {
    
    _titleView.text = NSLocalizedString(@"Talking Group", "");
    self.titleView = _titleView;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.frame = CGRectMake(screenBounds.origin.x, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height - [CommonUtils appStatusBarHeight] - [CommonUtils appNavigationBarHeight]);
    
    self.leftBarButtonItem = [self makeBarButtonItem:NSLocalizedString(@"Setting", nil) backgroundImg:[UIImage imageNamed:@"navibutton"] frame:CGRectMake(0, 0, 53, 28) target:self action:@selector(onSystemSettingAction)];    
    
    mGroupTableView = [[ECMainTableView alloc] initWithFrame:CGRectMake((self.frame.size.width - GROUP_TABLEVIEW_WIDTH) / 2 - 2, 6, self.frame.size.width, self.frame.size.height - CREATE_GROUP_BUTTON_HEIGHT - 14)];
    mGroupTableView.backgroundColor = [UIColor clearColor];
    mGroupTableView.dataSource = mGroupTableView;
    mGroupTableView.delegate = mGroupTableView;
    
    [self addSubview:mGroupTableView];
    
    
    UIButton *createGroupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createGroupButton.frame = CGRectMake((self.frame.size.width - CREATE_GROUP_BUTTON_WIDTH) / 2, self.frame.size.height - CREATE_GROUP_BUTTON_HEIGHT - 4, CREATE_GROUP_BUTTON_WIDTH, CREATE_GROUP_BUTTON_HEIGHT);
    [createGroupButton setBackgroundImage:[UIImage imageNamed:@"create_group_button_bg"] forState:UIControlStateNormal];
    [createGroupButton setTitle:NSLocalizedString(@"Create Group Talk", nil) forState:UIControlStateNormal];
    [createGroupButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
    [createGroupButton addTarget:self action:@selector(onCreateNewGroupAction) forControlEvents:UIControlEventTouchUpInside];
    createGroupButton.titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:16];
    [self addSubview:createGroupButton];
    
    self.backgroundImg = [UIImage imageNamed:@"mainpage_bg"];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        mFirstLoad = YES;
    }
    return self;
}

- (void)setGroupDataSource:(NSArray *)groupArray {
    NSLog(@"ECMainPageView - setGroupDataSource");
    [mGroupTableView setGroupDataSource:groupArray];
    [mGroupTableView reloadData];
}

- (void)stopReloadTableView {
    [mGroupTableView setReloadingFlag:NO];
}

- (void)appendGroupDataSourceWithArray:(NSArray *)groupArray {
    [mGroupTableView appendGroupDataSourceWithArray:groupArray];
    [mGroupTableView reloadData];
}

- (void)stopLoadMoreTableView {
    [mGroupTableView setAppendingDataFlag:NO];    
}

- (void)refreshGroupList {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(refreshGroupList)]) {
        if (mFirstLoad) {
            mFirstLoad = NO;
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
            hud.labelText = nil;
            [hud showWhileExecuting:@selector(refreshGroupList) onTarget:self.viewControllerRef withObject:nil animated:YES];
        } else {
            [NSThread detachNewThreadSelector:@selector(refreshGroupList) toTarget:self.viewControllerRef withObject:nil];
        }
    }
}

- (void)loadMoreDataSource {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(loadMoreGroupList)]) {
        [NSThread detachNewThreadSelector:@selector(loadMoreGroupList) toTarget:self.viewControllerRef withObject:nil];
    }
}

- (void)setHasNext:(NSNumber*)flag {
    mGroupTableView.hasNext = flag;
}

- (void)hideGroup:(NSString*)groupId {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(hideGroup:)]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
        [hud showWhileExecuting:@selector(hideGroup:) onTarget:self.viewControllerRef withObject:groupId animated:YES];
    }
}

- (void)itemSelected:(NSDictionary *)group {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(itemSelected:)]) {
        [self.viewControllerRef performSelector:@selector(itemSelected:) withObject:group];
    }
}

- (void)removeSelectedGroupFromUI {
    NSIndexPath *indexPath = [mGroupTableView currentDeletedIndexPath];
    [mGroupTableView removeGroupFromUI:indexPath];
}

- (void)reloadTableViewData {
    [mGroupTableView reloadData];
}

#pragma mark - button action
- (void)onCreateNewGroupAction {
    NSLog(@"create group");
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(createNewGroup)]) {
        [self.viewControllerRef performSelector:@selector(createNewGroup)];
    }
}

- (void)onSystemSettingAction {
    NSLog(@"system setting");
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(showSettingView)]) {
        [self.viewControllerRef performSelector:@selector(showSettingView)];
    }
}
@end
