//
//  ECMainPageViewController.h
//  imeeting_iphone
//
//  Created by star king on 12-6-11.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"

@interface ECMainPageViewController : UIViewController {
    NSNumber *mOffset;
}


- (void)refreshGroupList;
- (void)loadMoreGroupList;
- (void)hideGroup:(NSString*)groupId;
@end
