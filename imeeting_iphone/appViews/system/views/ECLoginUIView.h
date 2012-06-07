//
//  ECLoginUIVIEW.h
//  imeeting_iphone
//
//  Created by star king on 12-6-7.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICompatibleView.h"

@interface ECLoginUIView : UICompatibleView <UITextFieldDelegate> {
    UITextField *_mUserNameInput;
    UITextField *_mPwdInput;
    
}

@end
