//
//  ECContactsSelectContainerView.h
//  imeeting_iphone
//
//  Created by star king on 12-7-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactsSelectContainerView.h"

@interface ECContactsSelectContainerView : ContactsSelectContainerView

@property (nonatomic) BOOL isAppearedInCreatingNewGroup;
@property (nonatomic, readonly) UIButton *createButton;

@end
