//
//  ECRegisterUIView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECRegisterUIView.h"

@interface ECRegisterUIView ()

- (void)initUI;
- (UIView*)makeStepView;
- (UILabel*)makeStepLabel:(NSString*)text;
@end


@implementation ECRegisterUIView

#pragma mark - UI Initialization

- (UIView*)makeStepView {
    UIColor *stepViewBgColor = self.backgroundColor;
    CGRect stepViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIView *stepView = [[UIView alloc] initWithFrame:stepViewFrame];
    stepView.backgroundColor = stepViewBgColor;
    return stepView;
}

- (UILabel*)makeStepLabel:(NSString*)text {
    UILabel *stepLabel = [self makeLabel:text frame:CGRectMake(20, 5, 300, 30)];
    return stepLabel;
}

- (void)initUI {
    
    self.title = NSLocalizedString(@"register", "register view title");
    self.leftBarButtonItem = nil; // use default
        
    //### user register step 1
    _mStep1View = [self makeStepView];
    
    UILabel *step1Label = [self makeStepLabel:NSLocalizedString(@"Step 1", "")];

    [_mStep1View addSubview:step1Label];
    
    // user name input
    _mUserNameInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"phone number", "phone number input") frame:CGRectMake(20, step1Label.frame.origin.y + step1Label.frame.size.height + 10, _mStep1View.frame.size.width - 20*2, 30) keyboardType:UIKeyboardTypePhonePad];
           
    [_mStep1View addSubview:_mUserNameInput];
    
    UIButton *getValidateCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    getValidateCodeButton.frame = CGRectMake((_mStep1View.frame.size.width - 140) / 2, _mUserNameInput.frame.origin.y + _mUserNameInput.frame.size.height + 20, 140, 30);
    getValidateCodeButton.backgroundColor = [UIColor clearColor];
    [getValidateCodeButton setTitle:NSLocalizedString(@"get validate code", "get validate code button string") forState:UIControlStateNormal];
    getValidateCodeButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [getValidateCodeButton addTarget:self action:@selector(getValidationCodeAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_mStep1View addSubview:getValidateCodeButton];
    
    //### user register step 2
    _mStep2View = [self makeStepView];
    
    UILabel *step2Label = [self makeStepLabel:NSLocalizedString(@"Step 2", "")];
    
    [_mStep2View addSubview:step2Label];
    
    _mValidateCodeInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"input code", "input validation code") frame:CGRectMake(20, step2Label.frame.origin.y + step2Label.frame.size.height + 10, _mStep2View.frame.size.width - 20*2, 30) keyboardType:UIKeyboardTypeNumberPad];
    
    [_mStep2View addSubview:_mValidateCodeInput];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nextButton.frame = CGRectMake((_mStep2View.frame.size.width - 140) /2 , _mValidateCodeInput.frame.origin.y + _mValidateCodeInput.frame.size.height + 20, 140, 30);
    nextButton.backgroundColor = [UIColor clearColor];
    [nextButton setTitle:NSLocalizedString(@"Next", "next step") forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [nextButton addTarget:self action:@selector(verifyCodeAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_mStep2View addSubview:nextButton];
    
    //### user register step 3
    _mStep3View = [self makeStepView];
    
    UILabel *step3Label= [self makeStepLabel:NSLocalizedString(@"Step 3", "")];
    
    [_mStep3View addSubview:step3Label];
    
    _mPwdInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"input pwd", "") frame:CGRectMake(20, step3Label.frame.origin.y + step3Label.frame.size.height + 10, _mStep3View.frame.size.width - 20*2, 30) keyboardType:UIKeyboardTypeDefault];
    _mPwdInput.secureTextEntry = YES;
    
    [_mStep3View addSubview:_mPwdInput];
    
    _mPwdConfirmInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"confirm pwd", "") frame:CGRectMake(20, _mPwdInput.frame.origin.y + _mPwdInput.frame.size.height + 10, _mStep3View.frame.size.width - 20*2, 30) keyboardType:UIKeyboardTypeDefault];
    _mPwdConfirmInput.secureTextEntry = YES;
    
    [_mStep3View addSubview:_mPwdConfirmInput];
    
    UIButton *finishButton = [self makeButtonWithTitle:NSLocalizedString(@"Finish", "") frame:CGRectMake((_mStep3View.frame.size.width - 140) / 2, _mPwdConfirmInput.frame.origin.y + _mPwdConfirmInput.frame.size.height + 20, 140, 30)];
    [finishButton addTarget:self action:@selector(finishRegistrationAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_mStep3View addSubview:finishButton];
    
    // display step 1 view
    [self addSubview:_mStep1View];
    [self addSubview:_mStep2View];
    [self addSubview:_mStep3View];
    
    [self switchToStep1View];
}



- (id)init
{
    self = [super init];
    if (self) {
        [self initUI];
     //   [self addSubview:_mHud];

    }
    return self;
}


#pragma mark - UI Related Operations
- (void)switchToStep1View {
    [_mStep1View setHidden:NO];
    [_mStep2View setHidden:YES];
    [_mStep3View setHidden:YES];    
}

- (void)switchToStep2View {
    NSLog(@"switch to step2 view");
    _mValidateCodeInput.text = nil;
    [_mStep1View setHidden:YES];
    [_mStep2View setHidden:NO];
    [_mStep3View setHidden:YES];
}

- (void)switchToStep3View {
    _mPwdInput.text = nil;
    _mPwdConfirmInput.text = nil;
    [_mStep1View setHidden:YES];
    [_mStep2View setHidden:YES];
    [_mStep3View setHidden:NO];
}



#pragma mark - Button actions
- (void)getValidationCodeAction {
    NSString *phoneNumber = [_mUserNameInput.text trimWhitespaceAndNewline];
    
    [_mUserNameInput resignFirstResponder];
    
    // check user input phone number
    if(!phoneNumber || [phoneNumber isEqualToString:@""]) {
        NSLog(@"user input phone number is nil.");
                
        [[[iToast makeText:NSLocalizedString(@"please input phone number first", "")] setDuration:iToastDurationLong] show];
        return;
    }

    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(getValidationCodeByPhoneNumber:)]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
        hud.labelText = NSLocalizedString(@"Retrieving Validation Code..", "");
        [hud showWhileExecuting:@selector(getValidationCodeByPhoneNumber:) onTarget:self.viewControllerRef withObject:phoneNumber animated:YES];
    }
}

- (void)verifyCodeAction {
    NSString *code = [_mValidateCodeInput.text trimWhitespaceAndNewline];
    
    [_mValidateCodeInput resignFirstResponder];
    
    // check phone code
    if (!code || [code isEqualToString:@""]) {
        NSLog(@"user input code is nil");
        [[[iToast makeText:NSLocalizedString(@"please input code", "")] setDuration:iToastDurationLong] show];
        return;
    }
    
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(verifyCode:)]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
        hud.labelText = NSLocalizedString(@"Checking Validation Code..", "");
        [hud showWhileExecuting:@selector(verifyCode:) onTarget:self.viewControllerRef withObject:code animated:YES];
    }
    
}

- (void)finishRegistrationAction {
    NSString *pwd1 = [_mPwdInput.text trimWhitespaceAndNewline];
    NSString *pwd2 = [_mPwdConfirmInput.text trimWhitespaceAndNewline];
    
    [_mPwdInput resignFirstResponder];
    [_mPwdConfirmInput resignFirstResponder];
    
    // check passwords
    if (!pwd1 || [pwd1 isEqualToString:@""]) {
        [[[iToast makeText:NSLocalizedString(@"please input password", "")] setDuration:iToastDurationLong] show];
        return;
    }
    
    if (!pwd2 || [pwd2 isEqualToString:@""]) {
        [[[iToast makeText:NSLocalizedString(@"please input confirm password", "")] setDuration:iToastDurationLong] show];
        return;
    }
    
    if (![pwd1 isEqualToString:pwd2]) {
        [[[iToast makeText:NSLocalizedString(@"pwd1 is different to pwd2", "")] setDuration:iToastDurationLong] show];
        return;
    }
    
    
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(finishRegisterWithPwds:)]) {
        NSArray *pwds = [[NSArray alloc] initWithObjects:pwd1, pwd2, nil];
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self];
        hud.labelText = NSLocalizedString(@"finishing register..", "");
        [hud showWhileExecuting:@selector(finishRegisterWithPwds:) onTarget:self.viewControllerRef withObject:pwds animated:YES];
    }
    
}
@end
