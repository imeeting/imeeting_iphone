//
//  ECDeviceTokenPoster.m
//  imeeting_iphone
//
//  Created by star king on 12-7-17.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECDeviceTokenPoster.h"
#import "ECConstants.h"
#import "ECUrlConfig.h"

static ECDeviceTokenPoster *instance;

@implementation ECDeviceTokenPoster
@synthesize deviceToken = _deviceToken;

+ (ECDeviceTokenPoster*)shareDeviceTokenPoster {
    if (instance == nil) {
        instance = [[ECDeviceTokenPoster alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        tryTimes = 3;
    }
    return self;
}

- (void)registerToken {
    if (tryTimes > 0) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        if (self.deviceToken) {
            [params setObject:self.deviceToken forKey:TOKEN];
            [params setObject:[UserManager shareUserManager].userBean.name forKey:USERNAME]; 
            [HttpUtil postRequestWithUrl:USER_REG_TOKEN andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedRegToken:) andFailedRespSelector:@selector(onRegTokenFailed:)];
        }
    }
}

- (void)onFinishedRegToken:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedRegToken - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSString *result = [jsonData objectForKey:@"result"];
                NSLog(@"result: %@", result);
                
                if ([result isEqualToString:@"0"]) {
                    // reg token successfully
                    NSLog(@"register token successfully");
                } else {
                    // reg token failed, re do it
                    tryTimes--;
                    sleep(2);
                    [self registerToken];
                }
            }
            break;
        }
        default:
            tryTimes--;
            sleep(2);
            [self registerToken];
            break;
    }
}

- (void)onRegTokenFailed:(ASIHTTPRequest *)pRequest {
    tryTimes--;
    sleep(2);
    [self registerToken];
}
@end
