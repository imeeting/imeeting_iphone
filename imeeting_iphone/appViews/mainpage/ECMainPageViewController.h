//
//  ECMainPageViewController.h
//  imeeting_iphone
//
//  Created by star king on 12-6-11.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"

@interface ECMainPageViewController : UIViewController <SocketIODelegate> {
    NSNumber *mOffset;
    SocketIO *mSocketIO;
    BOOL needConnectToNotifyServer;
}
+ (ECMainPageViewController*)shareViewController;
+ (void)setShareViewController:(ECMainPageViewController*)viewController;

- (void)refreshGroupList;
- (void)loadMoreGroupList;
- (void)hideGroup:(NSString*)groupId;
- (void)createNewGroup;
- (void)itemSelected:(NSDictionary*)group;
- (void)connectToNotifyServer;
- (void)stopGetNoticeFromNotifyServer;
- (void)showSettingView;
- (void)joinGroup:(NSString*)groupId;
- (void)setupGroupModuleWithGroupId:(NSString*)groupId;

@end
