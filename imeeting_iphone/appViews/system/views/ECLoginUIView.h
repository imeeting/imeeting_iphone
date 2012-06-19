//
//  ECLoginUIVIEW.h
//  imeeting_iphone
//
//  Created by star king on 12-6-7.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECBaseUIView.h"

@interface ECLoginUIView : ECBaseUIView <UITableViewDataSource> {
    UITextField *_mUserNameInput;
    UITextField *_mPwdInput;
    
    UISwitch *_mRememberPwdSwitch;
    UISwitch *_mAutoLoginSwitch;
    
    UIButton *_mLoginButton;
}

@end
