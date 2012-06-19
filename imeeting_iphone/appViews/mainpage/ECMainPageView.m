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


- (id)init {
    self = [super init];
    if (self) {
        mGroupDataSource = [[NSMutableArray alloc] initWithCapacity:20];
        self.hasNext = [[NSNumber alloc] initWithBool:NO];
    }
    return self;
}

- (void)refreshDataSource {
    UIView *superView = self.superview;
    if (superView && [superView respondsToSelector:@selector(refreshGroupList)]) {
        [superView performSelector:@selector(refreshGroupList)];
    }
}

- (void)loadMoreDataSource {
    UIView *superView = self.superview;
    if (superView && [superView respondsToSelector:@selector(loadMoreDataSource)]) {
        [superView performSelector:@selector(loadMoreDataSource)];
    } 
}

- (void)setGroupDataSource:(NSArray *)groupArray {
    mGroupDataSource = [[NSMutableArray alloc] initWithArray:groupArray];
}

- (void)appendGroupDataSourceWithArray:(NSArray *)groupArray {
    [mGroupDataSource addObjectsFromArray:groupArray];
}

- (NSInteger)dataCount {
    return mGroupDataSource.count;
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
    return [ECGroupCell cellHeight];
}

// row selected action
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select %d", indexPath.row);
}



@end

@interface ECMainPageView ()

- (void)initUI;

@end

@implementation ECMainPageView

- (void)initUI {
    
    self.title = NSLocalizedString(@"Talking Group", "");
    self.leftBarButtonItem = nil;
    
    mGroupTableView = [[ECMainTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480 - 64)];
    mGroupTableView.backgroundColor = self.backgroundColor;
    mGroupTableView.dataSource = mGroupTableView;
    mGroupTableView.delegate = mGroupTableView;
    
    [self addSubview:mGroupTableView];
    

}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        
        [self addSubview:_mHud];
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
            _mHud.labelText = nil;
            [_mHud showWhileExecuting:@selector(refreshGroupList) onTarget:self.viewControllerRef withObject:nil animated:YES];
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





@end
