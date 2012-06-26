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

@interface ECLoginViewController ()
// check if need automatic login
- (void)initLogin;
@end

@implementation ECLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self initLogin];
        self = [self initWithCompatibleView:[[ECLoginUIView alloc] init]];
        
        UserBean *userBean = [[UserManager shareUserManager] userBean];
        if (userBean.autoLogin && userBean.password) {
            [self.view performSelector:@selector(loginAction)];
        }
        
    }
    return self;
}

- (void)initLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:@"username"];
    NSString *password = [userDefaults objectForKey:@"password"];
    NSNumber *autologin = [userDefaults objectForKey:@"autologin"];
    
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
                    [userDefaults setObject:userBean.name forKey:@"username"];
                    if (userBean.rememberPwd) {
                        [userDefaults setObject:userBean.password forKey:@"password"];
                    } else {
                        [userDefaults removeObjectForKey:@"password"];
                    }
                    [userDefaults setObject:[NSNumber numberWithBool:userBean.autoLogin] forKey:@"autologin"];
                    
                    NSString *userkey = [jsonData objectForKey:@"userkey"];
                    NSLog(@"userkey: %@", userkey);
                    
                    userBean.userKey = userkey;
                    
                    // jump to main view
                    [self.navigationController pushViewController:[[ECMainPageViewController alloc] init] animated:YES];
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
