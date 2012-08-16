//
//  ECAboutViewController.m
//  imeeting_iphone
//
//  Created by king star on 12-8-16.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECAboutViewController.h"
#import "ECAboutUIView.h"

@interface ECAboutViewController ()

@end

@implementation ECAboutViewController

- (id)init
{
    return [self initWithCompatibleView:[[ECAboutUIView alloc] init]];
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
