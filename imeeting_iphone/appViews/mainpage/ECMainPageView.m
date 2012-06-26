//
//  ECMainPageView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-11.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECMainPageView.h"
#import "ECGroupCell.h"

@implementation ECMainTableView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        mGroupDataSource = [[NSMutableArray alloc] initWithCapacity:20];
        self.hasNext = [[NSNumber alloc] initWithBool:NO];
        self.autoLoadDelegate = self;
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
    NSString *groupId = [groupInfo objectForKey:@"groupId"];
    ECMainPageView *mainPage = (ECMainPageView*)self.superview;
    [mainPage hideGroup:groupId];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *groupInfo = [mGroupDataSource objectAtIndex:indexPath.row];
        [self hideGroup:groupInfo];
        [mGroupDataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationRight];
    }
}

@end

@interface ECMainPageView ()

- (void)initUI;
- (void)hideGroup:(NSString*)groupId;
@end

@implementation ECMainPageView

- (void)initUI {
    
    self.title = NSLocalizedString(@"Talking Group", "");
    self.leftBarButtonItem = nil;
    
    mGroupTableView = [[ECMainTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 64)];
    mGroupTableView.backgroundColor = self.backgroundColor;
    mGroupTableView.dataSource = mGroupTableView;
    mGroupTableView.delegate = mGroupTableView;
    
    [self addSubview:mGroupTableView];
    

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
    [mGroupTableView setReloadingFlag:NO];
    [mGroupTableView reloadData];
}

- (void)appendGroupDataSourceWithArray:(NSArray *)groupArray {
    [mGroupTableView appendGroupDataSourceWithArray:groupArray];
    [mGroupTableView reloadData];
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
        [self.viewControllerRef performSelector:@selector(hideGroup:) withObject:groupId];
    }
}

- (void)itemSelected:(NSDictionary *)group {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(itemSelected:)]) {
        [self.viewControllerRef performSelector:@selector(itemSelected:) withObject:group];
    }
}


@end
