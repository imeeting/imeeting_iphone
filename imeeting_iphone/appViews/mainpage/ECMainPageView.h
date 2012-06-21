//
//  ECMainPageView.h
//  imeeting_iphone
//
//  Created by star king on 12-6-11.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECBaseUIView.h"


@interface ECMainTableView : ECLoadMoreUITableView <UITableViewDelegate, UITableViewDataSource, AutoLoadDelegate> {
    NSMutableArray *mGroupDataSource;
}

- (void)setGroupDataSource:(NSArray *)groupArray;
- (void)appendGroupDataSourceWithArray:(NSArray *)groupArray;
- (void)hideGroup:(NSDictionary*)groupInfo;
@end


@interface ECMainPageView : ECBaseUIView {
    ECMainTableView *mGroupTableView; // recent conference list table view
    BOOL mFirstLoad;

}

- (void)setHasNext:(NSNumber*)flag;
- (void)setGroupDataSource:(NSArray *)groupArray;
- (void)appendGroupDataSourceWithArray:(NSArray *)groupArray;
- (void)refreshGroupList;
- (void)loadMoreDataSource;
- (void)itemSelected:(NSDictionary*)group;
- (void)hideGroup:(NSString*)groupId;
@end
