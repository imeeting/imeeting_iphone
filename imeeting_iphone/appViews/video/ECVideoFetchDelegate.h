//
//  ECVideoFetchDelegate.h
//  imeeting_iphone
//
//  Created by star king on 12-6-28.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECVideoFetchDelegate <NSObject>
- (void)onFetchNewImage:(UIImage*)image;
@optional
- (void)onFetchFailed;
- (void)onFetchVideoBeginToPrepare:(NSString*)name;
- (void)onFetchVideoPrepared;
- (void)onFetchEnd;
@end
