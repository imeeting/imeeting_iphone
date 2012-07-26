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
    
    self.leftBarButtonItem = nil;
    
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"register", "") style:UIBarButtonItemStyleBordered target:self action:@selector(jumpToRegisterAction)];
    
    // user phone number input
    _userNameInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"phone number", "") frame:CGRectMake(0, 0, 280, 30) keyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [_userNameInput addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    // user password input
    _pwdInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"input pwd", "") frame:CGRectMake(0, 0, 280, 30) keyboardType:UIKeyboardTypeDefault];
    _pwdInput.secureTextEntry = YES;
    [_pwdInput addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];

    
    _rememberPwdSwitch = [[UISwitch alloc] init];
    _rememberPwdSwitch.on = YES;
    
    _autoLoginSwitch = [[UISwitch alloc] init];
    [_autoLoginSwitch addTarget:self action:@selector(switchAutoLoginAction:) forControlEvents:UIControlEventValueChanged];
    
    // login button
    _loginButton = [self makeButtonWithTitle:NSLocalizedString(@"Login", "") frame:CGRectMake(0, 0, 140, 30)];
    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    UITableView *loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    loginTableView.backgroundColor = self.backgroundColor;
    loginTableView.dataSource = self;
    
    [self addSubview:loginTableView];
        
    //##### set user info in the view
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    _userNameInput.text = userBean.name;
    _pwdInput.text = userBean.password;
    _rememberPwdSwitch.on = userBean.rememberPwd;
    _autoLoginSwitch.on = userBean.autoLogin;
    
}

- (void)textFieldValueChanged:(UITextField*)textField {
    NSLog(@"text field value changed");
    _useSavedPwd = NO;
}

#pragma mark - UITextFieldDelegate methods implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
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
    BOOL autoLogin = _autoLoginSwitch.on;
    
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
    ub.autoLogin = autoLogin;
    
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(login)]) {
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
        [hud setLabelText:NSLocalizedString(@"Logining", "")];
        [hud showWhileExecuting:@selector(login) onTarget:self.viewControllerRef withObject:nil animated:YES];
         
    }
}

#pragma mark - UITableView Datasource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

// render table cell UI
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"login cell"];
    
    if (cell == nil) {
        switch (indexPath.row) {
            case 0:
                cell = [[ECUIControlTableViewCell alloc] initWithLabelTip:nil andControl:_userNameInput];
                break;
            case 1:
                cell = [[ECUIControlTableViewCell alloc] initWithLabelTip:nil andControl:_pwdInput];
                break;
            case 2:
                cell = [[ECUIControlTableViewCell alloc] initWithLabelTip:NSLocalizedString(@"Remember Pwd", "") andControl:_rememberPwdSwitch];
                break;
                /*
            case 3:
                cell = [[ECUIControlTableViewCell alloc] initWithLabelTip:NSLocalizedString(@"Auto Login", "") andControl:_autoLoginSwitch];
                break;
                 */
            case 3:
                cell = [[ECUIControlTableViewCell alloc] initWithLabelTip:nil andControl:_loginButton];
                break;
            default:
                break;
        }
    }
    return cell;
}


@end
