//
//  ECDeviceTokenPoster.h
//  imeeting_iphone
//  
//  Post device token to server to save
//
//  Created by star king on 12-7-17.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonToolkit/CommonToolkit.h"

@interface ECDeviceTokenPoster : NSObject {
    NSInteger tryTimes;
}
@property (nonatomic, retain) NSString *deviceToken;
+ (ECDeviceTokenPoster*)shareDeviceTokenPoster;
- (void)onFinishedRegToken:(ASIHTTPRequest *)pRequest;
- (void)onRegTokenFailed:(ASIHTTPRequest *)pRequest;
- (void)registerToken;
@end
