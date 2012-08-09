//
//  ECLoginUIVIEW.m
//  imeeting_iphone
//
//  Created by star king on 12-6-7.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECLoginUIView.h"
#import "CommonToolkit/CommonToolkit.h"
#import "UserBean+IMeeting.h"
#import "ECConstants.h"

#define LOGIN_FORM_WIDTH    312
#define LOGIN_FORM_HEIGHT   291
#define INPUT_FIELD_WIDTH   266
#define INPUT_FIELD_HEIGHT  35
#define LOGIN_BUTTON_WIDTH  268
#define LOGIN_BUTTON_HEIGHT 41
#define SWITCH_WDITH        50
#define SWITCH_HEIGHT       30
#define PWD_MASK            @"#@1d~`*)"

@interface ECLoginUIView ()
- (void)initUI;
- (void)loginAction;
- (void)textFieldValueChanged:(UITextField*)textField;
@end

@implementation ECLoginUIView

- (id)init {
    self = [super init];
    if (self) {
        // init UI
        _useSavedPwd = YES;
        [self initUI];

    }
    return self;
}

#pragma mark - UI Initialization

- (void)initUI {
    _titleView.text = NSLocalizedString(@"Account Setting", "");
    self.titleView = _titleView;
    
    self.leftBarButtonItem = [self makeBarButtonItem:NSLocalizedString(@"Setting", nil) backgroundImg:[UIImage imageNamed:@"back_navi_button"] frame:CGRectMake(0, 0, 53, 28) target:self action:@selector(onBackAction)];
    
    self.rightBarButtonItem = [self makeBarButtonItem:NSLocalizedString(@"register", "") backgroundImg:[UIImage imageNamed:@"navibutton"] frame:CGRectMake(0, 0, 53, 28) target:self action:@selector(jumpToRegisterAction)];
    
    self.backgroundImg = [UIImage imageNamed:@"mainpage_bg"];
    
    UIView *loginFormView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - LOGIN_FORM_WIDTH) / 2 - 2, 50, LOGIN_FORM_WIDTH, LOGIN_FORM_HEIGHT)];
    loginFormView.backgroundImg = [UIImage imageNamed:@"login_form_bg"];
    [self addSubview:loginFormView];
    
    // user phone number input
    _userNameInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"phone number", "") frame:CGRectMake((loginFormView.frame.size.width - INPUT_FIELD_WIDTH) / 2, 30, INPUT_FIELD_WIDTH, INPUT_FIELD_HEIGHT) keyboardType:UIKeyboardTypeNumberPad];
    [_userNameInput addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [loginFormView addSubview:_userNameInput];
    
    // user password input
    _pwdInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"input pwd", "") frame:CGRectMake(_userNameInput.frame.origin.x, _userNameInput.frame.origin.y + _userNameInput.frame.size.height + 15, INPUT_FIELD_WIDTH, INPUT_FIELD_HEIGHT) keyboardType:UIKeyboardTypeDefault];
    _pwdInput.secureTextEntry = YES;
    [_pwdInput addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [loginFormView addSubview:_pwdInput];
    
    UILabel *rememberPwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(_pwdInput.frame.origin.x + 2, _pwdInput.frame.origin.y + _pwdInput.frame.size.height + 15, 100, SWITCH_HEIGHT)];
    rememberPwdLabel.textColor = [UIColor colorWithIntegerRed:133 integerGreen:133 integerBlue:133 alpha:1];
    rememberPwdLabel.font = [UIFont fontWithName:CHINESE_FONT size:15];
    rememberPwdLabel.text = NSLocalizedString(@"Remember Pwd", nil);
    rememberPwdLabel.backgroundColor = [UIColor clearColor];
    _rememberPwdSwitch = [[UISwitch alloc] initWithFrame:CGRectMake((loginFormView.frame.size.width - SWITCH_WDITH) / 2, _pwdInput.frame.origin.y + _pwdInput.frame.size.height + 17, SWITCH_WDITH, SWITCH_HEIGHT)];
    _rememberPwdSwitch.on = YES;
    [loginFormView addSubview:rememberPwdLabel];
    [loginFormView addSubview:_rememberPwdSwitch];
        
    // login button
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginButton.frame = CGRectMake((loginFormView.frame.size.width - LOGIN_BUTTON_WIDTH) / 2, _rememberPwdSwitch.frame.origin.y + _rememberPwdSwitch.frame.size.height + 15, LOGIN_BUTTON_WIDTH, LOGIN_BUTTON_HEIGHT);
    [_loginButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
    [_loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:16];
    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [loginFormView addSubview:_loginButton];

     
    //##### set user info in the view
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    _userNameInput.text = userBean.name;
    if (userBean.password == nil || [userBean.password isEqualToString:@""]) {
        _pwdInput.text = nil;
    } else {
        _pwdInput.text = PWD_MASK;
    }
    _rememberPwdSwitch.on = userBean.rememberPwd;
}

- (void)textFieldValueChanged:(UITextField*)textField {
    NSLog(@"text field value changed");
    _useSavedPwd = NO;
}

#pragma mark - Switch Actions
- (void)switchAutoLoginAction:(UISwitch*)pSwitch {
    if(pSwitch.on) {
        [_rememberPwdSwitch setOn:YES animated:YES];
        _rememberPwdSwitch.enabled = NO;
    } else {
        _rememberPwdSwitch.enabled = YES;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:pSwitch.on] forKey:@"autologin"];

}

#pragma mark - Button Actions

- (void)jumpToRegisterAction {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(jumpToRegisterView)]) {
        [self.viewControllerRef performSelector:@selector(jumpToRegisterView)];
    }
    
}

- (void)loginAction {
    NSString *phoneNumber = [_userNameInput.text trimWhitespaceAndNewline];
    NSString *pwd = [_pwdInput.text trimWhitespaceAndNewline];
    BOOL rememberPwd = _rememberPwdSwitch.on;
    
    [_userNameInput resignFirstResponder];
    [_pwdInput resignFirstResponder];
    
    if (!phoneNumber || [phoneNumber isEqualToString:@""]) {
        NSLog(@"phone number is null");
        [[[iToast makeText:NSLocalizedString(@"please input phone number first", "")] setDuration:iToastDurationLong] show];
        return;
    }
    
    if (!pwd || [pwd isEqualToString:@""]) {
        [[[iToast makeText:NSLocalizedString(@"please input password", "")] setDuration:iToastDurationLong] show];
        return;
        
    }
    
    UserBean *ub = [[UserManager shareUserManager] userBean];
    if (!_useSavedPwd) {
        [[UserManager shareUserManager] setUser:phoneNumber andPassword:pwd];
    }
    ub.rememberPwd = rememberPwd;
        
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(login)]) {
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
        [hud setLabelText:NSLocalizedString(@"Logining", "")];
        [hud showWhileExecuting:@selector(login) onTarget:self.viewControllerRef withObject:nil animated:YES];
         
    }
}

@end
