//
//  ECLoginUIVIEW.h
//  imeeting_iphone
//
//  Created by star king on 12-6-7.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECBaseUIView.h"

@interface ECLoginUIView : ECBaseUIView {
    UITextField *_userNameInput;
    UITextField *_pwdInput;
    
    UISwitch *_rememberPwdSwitch;
    
    UIButton *_loginButton;
    BOOL _useSavedPwd; // YES: use stored password to login, NO: use inputed password to login
}

@end
