//
//  AuthInterceptor.h
//  imeeting_iphone
//
//  Created by king star on 12-8-17.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//
#import "CommonToolkit/CommonToolkit.h"
#import "ECLoginViewController.h"

#define HTTP_RETURN_CHECK(request, viewCtrl)   if (request.responseStatusCode == 401) { \
                                         NSLog(@"account needs re-login!");     \
                                        RIButtonItem *cancelItem = [RIButtonItem item];     \
                                        cancelItem.label = NSLocalizedString(@"Cancel", nil);      \
                                        RIButtonItem *loginItem = [RIButtonItem item];      \
                                        loginItem.label = NSLocalizedString(@"Login", nil);     \
                                        loginItem.action = ^{   \
                                        ECLoginViewController *loginCtrl = [[ECLoginViewController alloc] init];    \
                                        loginCtrl.isForLogin = YES; \
                                        [viewCtrl.navigationController pushViewController:loginCtrl animated:YES];};   \
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil \
                                            message:NSLocalizedString(@"Your account need login" , nil) \
                                            cancelButtonItem:cancelItem \
                                            otherButtonItems:loginItem, nil];   \
                                        [alertView show];   \
                                         return;  \
                                     } else {   \
                                        [[[iToast makeText:NSLocalizedString(@"network exception", "")] setDuration:iToastDurationNormal] show];    \
                                        return; \
                                     }


