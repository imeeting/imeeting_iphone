//
//  ECAppDelegate.m
//  imeeting_iphone
//
//  Created by star king on 12-6-4.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECAppDelegate.h"
#import "CommonToolkit/CommonToolkit.h"
#import "ECLoginViewController.h"
#import "ECConstants.h"
#import "UserBean+IMeeting.h"
#import "ECMainPageViewController.h"

@interface ECAppDelegate ()
- (void)loadAccount;
- (BOOL)isNeedLogin;
- (BOOL)isAccountValid;
@end

@implementation ECAppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self loadAccount];
    
    // register push notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeNewsstandContentAvailability | UIRemoteNotificationTypeSound];
    
    // load address book
    [[AddressBookManager shareAddressBookManager] traversalAddressBook];
    
    // Override point for customization after application launch.
    BOOL needLogin = [self isNeedLogin];
    if (needLogin) {
        self.window.rootViewController = [[AppRootViewController alloc] initWithPresentViewController:[[ECLoginViewController alloc] init] andMode:navigationController];
    } else {
        ECMainPageViewController *mpvc = [[ECMainPageViewController alloc] init];
        [ECMainPageViewController setShareViewController:mpvc];
        self.window.rootViewController = [[AppRootViewController alloc] initWithPresentViewController:mpvc andMode:navigationController];
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"device token: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get device token - error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

#pragma mark - account operations

- (void)loadAccount {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:USERNAME];
    NSString *password = [userDefaults objectForKey:PASSWORD];
    NSNumber *autologin = [userDefaults objectForKey:AUTOLOGIN];
    NSString *userkey = [userDefaults objectForKey:USERKEY];
    
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    userBean.name = username;
    userBean.password = password;
    if (password) {
        userBean.rememberPwd = YES;
    } else {
        userBean.rememberPwd = NO;
    }
    userBean.autoLogin = autologin.boolValue;
    userBean.userKey = userkey;
}

- (BOOL)isNeedLogin {
    BOOL flag = NO;
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    if (!userBean.name || !userBean.password || !userBean.userKey || !userBean.autoLogin) {
        flag = YES;
    }
    
    return flag;
}

- (BOOL)isAccountValid {
    BOOL flag = YES;
    UserBean *userBean = [[UserManager shareUserManager] userBean];
    if (!userBean.name || !userBean.password || !userBean.userKey) {
        flag = NO;
    }
    return flag;

}
@end
