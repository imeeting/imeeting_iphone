//
//  ECRegisterUIView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECRegisterUIView.h"
#import "UIColor+ECUIColor.h"

@interface ECRegisterUIView ()

- (void)initUI;

@end


@implementation ECRegisterUIView

- (void)initUI {
    _mViewController.title = NSLocalizedString(@"register", "register view title");
    _mViewController.navigationItem.leftBarButtonItem = nil; // use default
    
    // set background color
    self.backgroundColor = [UIColor whiteColor];
    
    UIColor *stepViewBgColor = [UIColor colorWithRGB: 205 green: 175 blue: 149 alpha:0.9];
    
    //### user register step 1
    _mStep1View = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _mStep1View.backgroundColor = stepViewBgColor;
    // user name input
    _mUserNameInput = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, _mStep1View.frame.size.width - 5*2, 30)];
    _mUserNameInput.textColor = [UIColor blackColor];
    // set style
    _mUserNameInput.borderStyle = UITextBorderStyleRoundedRect;
    // auto correction
    _mUserNameInput.autocorrectionType = UITextAutocorrectionTypeYes;
    // default display text
    _mUserNameInput.placeholder = NSLocalizedString(@"phone number", "phone number input");
    // set font
    _mUserNameInput.font = [UIFont systemFontOfSize:14.0];
    _mUserNameInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    // set keyboard done button
    _mUserNameInput.returnKeyType = UIReturnKeyDone;
    _mUserNameInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    // keyboard type
    _mUserNameInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    // set delegate
    _mUserNameInput.delegate = self;
           
    [_mStep1View addSubview:_mUserNameInput];
    
    
    
    
    [self addSubview:_mStep1View];
    
}


- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*) viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        _mViewController = viewController;
        [self initUI];
    }
    return self;
}


#pragma mark - UITextFieldDelegate methods implementation
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}


@end
