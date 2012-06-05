//
//  ECRegisterViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECRegisterViewController.h"
#import "ECRegisterUIView.h"

@interface ECRegisterViewController ()

@end

@implementation ECRegisterViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view = [[ECRegisterUIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) viewController:self];
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

@end
