//
//  ECRootViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-4.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECRootViewController.h"
#import "ECLoginViewController.h"

@interface ECRootViewController ()

@end

@implementation ECRootViewController

- (id)initWithUIViewController {
    return [super initWithRootViewController:[[ECLoginViewController alloc] init]];
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
