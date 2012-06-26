//
//  ECGroupVideoViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-20.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECGroupVideoViewController.h"
#import "ECGroupVideoView.h"
#import "ECGroupAttendeeListViewController.h"
#import "ECGroupModule.h"
#import "ECGroupManager.h"

@interface ECGroupVideoViewController ()

@end

@implementation ECGroupVideoViewController

- (id)init {
    self = [self initWithCompatibleView:[[ECGroupVideoView alloc] init]];
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
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

#pragma mark - actions
- (void)onLeaveGroup {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [module onLeaveGroup];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSwitchToAttendeeListView {
    ECGroupModule *module = [ECGroupManager sharedECGroupManager].currentGroupModule;
    [self.navigationController pushViewController:module.attendeeController animated:YES];
}
@end
