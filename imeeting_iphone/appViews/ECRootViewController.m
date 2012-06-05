//
//  ECRootViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-4.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECRootViewController.h"
#import "ECRegisterViewController.h"

@interface ECRootViewController ()

@end

@implementation ECRootViewController

- (id)initWithUIViewController {
    return [super initWithRootViewController:[[ECRegisterViewController alloc] init]];
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

@end
