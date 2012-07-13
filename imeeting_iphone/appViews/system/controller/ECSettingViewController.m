//
//  ECSettingViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-7-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECSettingViewController.h"
#import "CommonToolkit/CommonToolkit.h"
#import "ECSettingView.h"
#import "ECLoginViewController.h"

@interface ECSettingViewController ()

@end

@implementation ECSettingViewController

- (id)init {
    self = [self initWithCompatibleView:[[ECSettingView alloc] init]];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

#pragma mark - actions

- (void)showAccountSettingView {
    ECLoginViewController *loginViewController = [[ECLoginViewController alloc] init];
    loginViewController.isForLogin = NO;
    [self.navigationController pushViewController:loginViewController animated:YES];
}
@end
