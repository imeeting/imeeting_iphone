//
//  HttpUtil.h
//  imeeting_iphone
//
//  Created by star king on 12-6-4.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

typedef enum {
    synchronous,
    asynchronous
} ASIHTTPRequestType;


@interface HttpUtil : NSObject

// send normal request
+(void) sendNormalRequestWithUrl:(NSString*) pUrl andUserInfo:(NSDictionary *)pUserInfo andDelegate:(id)delegate andFinishedRespMethod:(SEL)pFinRespMethod andFailedRespMethod:(SEL)pFailRespMethod andRequestType:(ASIHTTPRequestType)pRequestType;

// send form request
+(void) sendFormRequestWithUrl:(NSString*) pUrl andPostBody:(NSMutableDictionary*) pPostBodyDic andUserInfo:(NSDictionary*) pUserInfo andDelegate:(id) delegate andFinishedRespMethod:(SEL) pFinRespMethod andFailedRespMethod:(SEL) pFailRespMethod andRequestType:(ASIHTTPRequestType) pRequestType;

// send sig form request
+(void) sendSigFormRequestWithUrl:(NSString*) pUrl andPostBody:(NSMutableDictionary*) pPostBodyDic andUserInfo:(NSDictionary*) pUserInfo andDelegate:(id) delegate andFinishedRespMethod:(SEL) pFinRespMethod andFailedRespMethod:(SEL) pFailRespMethod andRequestType:(ASIHTTPRequestType) pRequestType;


@end
