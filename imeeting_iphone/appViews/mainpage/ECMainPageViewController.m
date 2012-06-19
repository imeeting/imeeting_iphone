//
//  ECMainPageViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-11.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECMainPageViewController.h"
#import "ECMainPageView.h"
#import "ECUrlConfig.h"

@interface ECMainPageViewController ()
- (void)onFinishedGetGroupList:(ASIHTTPRequest*)pRequest;
- (void)onFinishedLoadingMoreGroupList:(ASIHTTPRequest*)pRequest;
@end

@implementation ECMainPageViewController


- (id)init
{
    self = [self initWithCompatibleView:[[ECMainPageView alloc] init]];
   
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [self.view performSelector:@selector(refreshGroupList)];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// get the newest group list from server
- (void)refreshGroupList {
    NSLog(@"ECMainPageViewController - refresh Group List");
    [HttpUtil postSignatureRequestWithUrl:[ECUrlConfig GetGroupListUrl] andPostFormat:urlEncoded andParameter:nil andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedGetGroupList:) andFailedRespSelector:nil];
}

- (void)onFinishedGetGroupList:(ASIHTTPRequest *)pRequest {
     NSLog(@"onFinishedGetGroupList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSDictionary *pager = [jsonData objectForKey:@"pager"];
                NSNumber *hasNext = [pager objectForKey:@"hasNext"];
                mOffset = [pager objectForKey:@"offset"];
                [self.view performSelector:@selector(setHasNext:) withObject:hasNext];
                
                NSLog(@"has Next: %@, offset: %@", hasNext, mOffset);
                
                NSArray *groupArray = [jsonData objectForKey:@"list"];
                NSLog(@"group array size: %d", groupArray.count);
                [self.view performSelector:@selector(setGroupDataSource:) withObject:groupArray];
                
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void)loadMoreGroupList {
    NSLog(@"load more group list");
    NSNumber *nextOffset = [NSNumber numberWithInteger:(mOffset.integerValue + 1)];
    NSLog(@"current offset: %d, next offset: %d", mOffset.integerValue, nextOffset.integerValue);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:nextOffset, @"offset", nil];
    [HttpUtil postSignatureRequestWithUrl:[ECUrlConfig GetGroupListUrl] andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:asynchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedLoadingMoreGroupList:) andFailedRespSelector:nil];
}

- (void)onFinishedLoadingMoreGroupList:(ASIHTTPRequest*)pRequest {
    NSLog(@"onFinishedLoadingMoreGroupList - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSDictionary *pager = [jsonData objectForKey:@"pager"];
                NSNumber *hasNext = [pager objectForKey:@"hasNext"];
                mOffset = [pager objectForKey:@"offset"];
                [self.view performSelector:@selector(setHasNext:) withObject:hasNext];
                
                NSLog(@"has Next: %@, offset: %@", hasNext, mOffset);
                
                NSArray *groupArray = [jsonData objectForKey:@"list"];
                NSLog(@"group array size: %d", groupArray.count);
                [self.view performSelector:@selector(appendGroupDataSourceWithArray:) withObject:groupArray];
                
            }
            
            break;
        }
        default:
            break;
    }

}

@end