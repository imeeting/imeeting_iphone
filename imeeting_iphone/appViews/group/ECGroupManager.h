//
//  ECGroupManager.h
//  imeeting_iphone
//
//  Created by star king on 12-6-25.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECGroupModule.h"

@interface ECGroupManager : NSObject

@property (nonatomic, retain) ECGroupModule *currentGroupModule;

+ (ECGroupManager*)sharedECGroupManager;



@end
