//
//  ECLoginUIVIEW.m
//  imeeting_iphone
//
//  Created by star king on 12-6-7.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECLoginUIView.h"
#import "NSString+util.h"
#import "iToast.h"

@interface ECLoginUIView ()
- (void)initUI;
@end

@implementation ECLoginUIView

- (id)init {
    self = [super init];
    if (self) {
        // init UI
        [self initUI];
    }
    return self;
}

#pragma mark - UI Initialization

- (void)initUI {
    self.frame = CGRectMake(0, 0, 320, 480);
    self.title = NSLocalizedString(@"Login", "");
    
}


#pragma mark - UITextFieldDelegate methods implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

@end
