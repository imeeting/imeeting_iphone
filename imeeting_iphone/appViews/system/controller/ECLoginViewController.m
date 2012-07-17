//
//  ECLoginViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-7.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECLoginViewController.h"
#import "ECLoginUIView.h"
#import "ECRegisterViewController.h"
#import "ECUrlConfig.h"
#import "ECMainPageViewController.h"
#import "UserBean+IMeeting.h"
#import "ECConstants.h"
#import "ECDeviceTokenPoster.h"

@interface ECLoginViewController () {
    NSInteger tryTimes; // used for register token
}
// check if need automatic login
- (void)initLogin;
@end

@implementation ECLoginViewController
@synthesize isForLogin = _isForLogin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isForLogin = YES;
        tryTimes = 3;
        
        [self initLogin];
        self = [self initWithCompatibleView:[[ECLoginUIView alloc] init]];
       
        /*
        UserBean *userBean = [[UserManager shareUserManager] userBean];
        if (userBean.autoLogin && userBean.password) {
            [self.view performSelector:@selector(loginAction)];
        }
         */
        
    }
    return self;
}

- (void)initLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:USERNAME];
    NSString *password = [userDefaults objectForKey:PASSWORD];
    NSNumber *autologin = [userDefaults objectForKey:AUTOLOGIN];
    
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    userBean.name = username;
    userBean.password = password;
    if (password) {
        userBean.rememberPwd = YES;
    } else {
        userBean.rememberPwd = NO;
    }
    userBean.autoLogin = autologin.boolValue;
    
}

- (void)viewWillAppear:(BOOL)animated {
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

#pragma mark - action implementations

- (void)jumpToRegisterView {
    ECRegisterViewController *regController = [[ECRegisterViewController alloc] init];
    [self.navigationController pushViewController:regController animated:YES];
}

- (void)login {
    NSLog(@"do login");
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    
    // validate user account
    NSString *pwd = userBean.password;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userBean.name, @"loginName", pwd, @"loginPwd", nil];
    
    // send request
    [HttpUtil postRequestWithUrl:USER_LOGIN_URL andPostFormat:urlEncoded andParameter:param andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedLogin:) andFailedRespSelector:nil];
}

#pragma mark - Http Request Response Callback Functions

- (void)onFinishedLogin:(ASIHTTPRequest*)pRequest {
    NSLog(@"onFinishedLogin - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSString *result = [jsonData objectForKey:@"result"];
                NSLog(@"result: %@", result);
                
                if([result isEqualToString:@"0"]) {
                    // login successfully

                    // save the account info
                    UserBean *userBean = [[UserManager shareUserManager] userBean];
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:userBean.name forKey:USERNAME];
                    if (userBean.rememberPwd) {
                        [userDefaults setObject:userBean.password forKey:PASSWORD];
                    } else {
                        [userDefaults removeObjectForKey:PASSWORD];
                    }
                    [userDefaults setObject:[NSNumber numberWithBool:userBean.autoLogin] forKey:AUTOLOGIN];
                    
                    NSString *userkey = [jsonData objectForKey:USERKEY];
                    NSLog(@"userkey: %@", userkey);
                    
                    userBean.userKey = userkey;
                    // save user key
                    [userDefaults setObject:userkey forKey:USERKEY];
                    
                    [[ECDeviceTokenPoster shareDeviceTokenPoster] registerToken];
                    
                    // jump to main view
                    if (self.isForLogin) {
                        // it's first login
                        ECMainPageViewController * mpvc = [[ECMainPageViewController alloc] init];
                        [ECMainPageViewController setShareViewController:mpvc];
                        [self.navigationController pushViewController:[ECMainPageViewController shareViewController] animated:YES];                        
                    } else {
                        // it's in account setting
                        [self.navigationController popToViewController:[ECMainPageViewController shareViewController] animated:YES];
                    }
                } else if ([result isEqualToString:@"1"] || [result isEqualToString:@"2"]) {
                    // login failed
                    [[iToast makeText:NSLocalizedString(@"Wrong phone number or password", "")] show];
                } else {
                    goto login_error;
                }
            } else {
                goto login_error;
            }
            break;
        }
        default:
            goto login_error;
            break;
    }
    
    return;
    
login_error:
    [[iToast makeText:NSLocalizedString(@"Error in login, please retry.", "")] show];

}

@end
