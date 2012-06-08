//
//  HttpUtil.m
//  imeeting_iphone
//
//  Created by star king on 12-6-4.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "HttpUtil.h"
#import "UserManager.h"
#import "NSString+CommonUtils.h"

@implementation HttpUtil

+(void) sendNormalRequestWithUrl:(NSString*) pUrl andUserInfo:(NSDictionary *)pUserInfo andDelegate:(id)delegate andFinishedRespMethod:(SEL)pFinRespMethod andFailedRespMethod:(SEL)pFailRespMethod andRequestType:(ASIHTTPRequestType)pRequestType {
    // judge request url
    if(pUrl == nil){
        NSLog(@"sendNormalRequestWithUrl - request url is nil.");
        
        return;
    }
    
    // create ASIHTTPRequest
    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:pUrl]];
    
    // set timeout seconds
    [_request setTimeOutSeconds:10.0];
    
    // set user infomation
    _request.userInfo = pUserInfo;
    
    // set delegate
    [_request setDelegate:delegate];
    
    // set response methods
    if(pFinRespMethod && [delegate respondsToSelector:pFinRespMethod]){
        _request.didFinishSelector = pFinRespMethod;
    }
    if(pFailRespMethod && [delegate respondsToSelector:pFailRespMethod]){
        _request.didFailSelector = pFailRespMethod;
    }
    
    // start send request
    switch (pRequestType) {
        case asynchronous:
            [_request startAsynchronous];
            break;
            
        case synchronous:
            [_request startSynchronous];
            break;
    }
}

+(void) sendFormRequestWithUrl:(NSString*) pUrl andPostBody:(NSMutableDictionary*) pPostBodyDic andUserInfo:(NSDictionary*) pUserInfo andDelegate:(id) delegate andFinishedRespMethod:(SEL) pFinRespMethod andFailedRespMethod:(SEL) pFailRespMethod andRequestType:(ASIHTTPRequestType) pRequestType {
    // judge request url
    if(pUrl == nil){
        NSLog(@"sendFormRequestWithUrl - request url is nil.");
        
        return;
    }
    
    // synchronous request
    ASIFormDataRequest *_request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:pUrl]];
    
    // set timeout seconds
    [_request setTimeOutSeconds:10.0];
    
    //  set post value
    [pPostBodyDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        // set request post value
        [_request addPostValue:obj forKey:key];
    }];
    
    // set user infomation
    _request.userInfo = pUserInfo;
    
    // set delegate
    _request.delegate = delegate;
    
    // set response methods
    if(pFinRespMethod && [delegate respondsToSelector:pFinRespMethod]){
        _request.didFinishSelector = pFinRespMethod;
    }
    if(pFailRespMethod && [delegate respondsToSelector:pFailRespMethod]){
        _request.didFailSelector = pFailRespMethod;
    }
    
    // start send request
    switch (pRequestType) {
        case asynchronous:
            [_request startAsynchronous];
            break;
            
        case synchronous:
            [_request startSynchronous];
            break;
    }
}

// send sig form request with url
+(void) sendSigFormRequestWithUrl:(NSString*) pUrl andPostBody:(NSMutableDictionary*) pPostBodyDic andUserInfo:(NSDictionary*) pUserInfo andDelegate:(id) delegate andFinishedRespMethod:(SEL) pFinRespMethod andFailedRespMethod:(SEL) pFailRespMethod andRequestType:(ASIHTTPRequestType) pRequestType {
    // judge request param
    if(pUrl == nil){
        NSLog(@"sendSigFormRequestWithUrl - request url is nil.");
        
        return;
    }
    
    // synchronous request
    ASIFormDataRequest *_request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:pUrl]];
    
    // set timeout seconds
    [_request setTimeOutSeconds:10.0];
    
    //  set post value
    NSMutableArray *_postBodyDataArray = [[NSMutableArray alloc] init];
    [pPostBodyDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        // set request post value
        [_request addPostValue:obj forKey:key];
        
        // init post body data array
        [_postBodyDataArray addObject:[[NSString alloc] initWithFormat:@"%@=%@", key, obj]];
    }];
    
    // post request signature
    NSLog(@"post body data array = %@", _postBodyDataArray);
    // postBody data array sort
    NSMutableArray *_sortedArray = [[NSMutableArray alloc] initWithArray:[_postBodyDataArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    NSLog(@"sorted post body data array = %@", _sortedArray);
    
    // append userKey
    if([[[UserManager shareSingleton] userBean] userKey]){
        [_sortedArray addObject:[[[UserManager shareSingleton] userBean] userKey]];
    }
    NSLog(@"after append user key sorted post body data array = %@", _sortedArray);
    
    // generate signature
    NSMutableString *_sortedArrayString = [[NSMutableString alloc] init];
    for(NSString *_str in _sortedArray){
        [_sortedArrayString appendString:_str];
    }
    NSString *_signature = [_sortedArrayString md5];
    NSLog(@"the signature is %@", _signature);
    
    // add signature to postBody data
    [_request addPostValue:_signature forKey:@"sig"];
    
    // set user infomation
    _request.userInfo = pUserInfo;
    
    // set delegate
    _request.delegate = delegate;
    
    // set response methods
    if(pFinRespMethod && [delegate respondsToSelector:pFinRespMethod]){
        _request.didFinishSelector = pFinRespMethod;
    }
    if(pFailRespMethod && [self respondsToSelector:pFailRespMethod]){
        _request.didFailSelector = pFailRespMethod;
    }
    
    // start send request
    switch (pRequestType) {
        case asynchronous:
            [_request startAsynchronous];
            break;
            
        case synchronous:
            [_request startSynchronous];
            break;
    }
}


@end
