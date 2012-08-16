//
//  ECRegisterUIView.m
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECRegisterUIView.h"
#import "ECConstants.h"

#define TITLE_WIDTH   268
#define TITLE_HEIGHT    40
#define INPUT_WIDTH     261
#define INPUT_HEIGHT    35
#define BUTTON_WIDTH    268
#define BUTTON_HEIGHT   41

@interface ECRegisterUIView ()

- (void)initUI;
- (UIView*)makeStepView;
- (UIView*)makeStepLabel:(NSString*)text preTitle:(NSString*)preTitle;
- (CATransition*)fadeAnimation;
@end


@implementation ECRegisterUIView

#pragma mark - UI Initialization

- (UIView*)makeStepView {
    CGRect stepViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIView *stepView = [[UIView alloc] initWithFrame:stepViewFrame];
    stepView.backgroundColor = [UIColor clearColor];
    return stepView;
}

- (UIView*)makeStepLabel:(NSString*)text preTitle:(NSString*)preTitle {
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - TITLE_WIDTH) / 2, 11, TITLE_WIDTH, TITLE_HEIGHT)];
    labelView.backgroundColor = [UIColor clearColor];
   
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    label1.textAlignment = UITextAlignmentLeft;
    label1.textColor = [UIColor colorWithIntegerRed:93 integerGreen:109 integerBlue:122 alpha:1];
    label1.font = [UIFont fontWithName:CHARACTER_FONT size:26];
    label1.text = preTitle;
    label1.backgroundColor = [UIColor clearColor];
    [labelView addSubview:label1];
    
    UILabel *stepLabel = [self makeLabel:text frame:CGRectMake(labelView.frame.size.width - 200, 14, 200, 22)];
    stepLabel.font = [UIFont fontWithName:CHINESE_FONT size:13];
    stepLabel.textColor = [UIColor colorWithIntegerRed:94 integerGreen:109 integerBlue:122 alpha:1];
    stepLabel.textAlignment = UITextAlignmentRight;
    [labelView addSubview:stepLabel];
    return labelView;
}

- (void)initUI {
    
    _titleView.text = NSLocalizedString(@"register", "register view title");
    self.titleView = _titleView;
    
    self.backgroundImg = [UIImage imageNamed:@"mainpage_bg"];
    
    self.leftBarButtonItem = [self makeBarButtonItem:NSLocalizedString(@"Account Setting", nil) backgroundImg:[UIImage imageNamed:@"back_navi_button_long"] frame:CGRectMake(0, 0, 84, 28) target:self action:@selector(onBackAction)];        
    
    //### user register step 1
    _mStep1View = [self makeStepView];
    
    UIView *step1Label = [self makeStepLabel:NSLocalizedString(@"Step 1", "") preTitle:NSLocalizedString(@"First", nil)];
    [_mStep1View addSubview:step1Label];
    
    // user name input
    _mUserNameInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"phone number", "phone number input") frame:CGRectMake((self.frame.size.width - INPUT_WIDTH) / 2, step1Label.frame.origin.y + step1Label.frame.size.height + 3, INPUT_WIDTH, INPUT_HEIGHT) keyboardType:UIKeyboardTypeNumberPad];
    [_mStep1View addSubview:_mUserNameInput];
    
    UIButton *getValidateCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getValidateCodeButton.frame = CGRectMake((_mStep1View.frame.size.width - BUTTON_WIDTH) / 2, _mUserNameInput.frame.origin.y + _mUserNameInput.frame.size.height + 10, BUTTON_WIDTH, BUTTON_HEIGHT);
    getValidateCodeButton.titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:16.0];
    [getValidateCodeButton setTitle:NSLocalizedString(@"get validate code", "get validate code button string") forState:UIControlStateNormal];
    [getValidateCodeButton setBackgroundImage:[UIImage imageNamed:@"register_normal_button"] forState:UIControlStateNormal];
    [getValidateCodeButton addTarget:self action:@selector(getValidationCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [_mStep1View addSubview:getValidateCodeButton];
    
    UILabel *infoTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(getValidateCodeButton.frame.origin.x, getValidateCodeButton.frame.origin.y + getValidateCodeButton.frame.size.height, getValidateCodeButton.frame.size.width, 60)];
    infoTextLabel.text = NSLocalizedString(@"We won't send junk message to you", nil);
    infoTextLabel.font = [UIFont fontWithName:CHINESE_FONT size:13];
    infoTextLabel.textColor = [UIColor colorWithIntegerRed:93 integerGreen:109 integerBlue:122 alpha:1];
    infoTextLabel.backgroundColor = [UIColor clearColor];
    infoTextLabel.numberOfLines = 0;
    infoTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;
    [_mStep1View addSubview:infoTextLabel];
    
    //### user register step 2
    _mStep2View = [self makeStepView];

    UIView *step2Label = [self makeStepLabel:NSLocalizedString(@"Step 2", "") preTitle:NSLocalizedString(@"Second", nil)];
    [_mStep2View addSubview:step2Label];
    
    _mValidateCodeInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"input code", "input validation code") frame:_mUserNameInput.frame keyboardType:UIKeyboardTypeNumberPad];
    [_mStep2View addSubview:_mValidateCodeInput];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = getValidateCodeButton.frame;
    nextButton.titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:16.0];
    [nextButton setTitle:NSLocalizedString(@"Next", "next step") forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"register_normal_button"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(verifyCodeAction) forControlEvents:UIControlEventTouchUpInside];
    [_mStep2View addSubview:nextButton];
    
    //### user register step 3
    _mStep3View = [self makeStepView];
    
    UIView *step3Label= [self makeStepLabel:NSLocalizedString(@"Step 3", "") preTitle:NSLocalizedString(@"Third", nil)];
    [_mStep3View addSubview:step3Label];
    
    _mPwdInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"input pwd", "") frame:_mValidateCodeInput.frame keyboardType:UIKeyboardTypeDefault];
    _mPwdInput.secureTextEntry = YES;
    [_mStep3View addSubview:_mPwdInput];
    
    _mPwdConfirmInput = [self makeTextFieldWithPlaceholder:NSLocalizedString(@"confirm pwd", "") frame:CGRectMake(_mPwdInput.frame.origin.x, _mPwdInput.frame.origin.y + _mPwdInput.frame.size.height + 5, _mPwdInput.frame.size.width, _mPwdInput.frame.size.height) keyboardType:UIKeyboardTypeDefault];
    _mPwdConfirmInput.secureTextEntry = YES;
    [_mStep3View addSubview:_mPwdConfirmInput];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    finishButton.frame = CGRectMake((_mStep3View.frame.size.width - BUTTON_WIDTH) / 2, _mPwdConfirmInput.frame.origin.y + _mPwdConfirmInput.frame.size.height + 8, BUTTON_WIDTH, BUTTON_HEIGHT);
    finishButton.titleLabel.font = nextButton.titleLabel.font;
    [finishButton setTitle:NSLocalizedString(@"Finish", nil) forState:UIControlStateNormal];
    [finishButton setBackgroundImage:[UIImage imageNamed:@"register_normal_button"] forState:UIControlStateNormal];
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
- (CATransition *)fadeAnimation {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.6f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.type = kCATransitionFade;
    return animation;
}

- (void)switchToStep1View {
    CATransition *animation = [self fadeAnimation];
    [_mStep1View.layer addAnimation:animation forKey:nil];
    
    [_mStep1View setHidden:NO];
    [_mStep2View setHidden:YES];
    [_mStep3View setHidden:YES];  
    [_mUserNameInput becomeFirstResponder];
}

- (void)switchToStep2View {
    NSLog(@"switch to step2 view");
    _mValidateCodeInput.text = nil;
    
    CATransition *animation = [self fadeAnimation];
    [_mStep2View.layer addAnimation:animation forKey:nil];
    
    [_mStep1View setHidden:YES];
    [_mStep2View setHidden:NO];
    [_mStep3View setHidden:YES];
    [_mValidateCodeInput becomeFirstResponder];
}

- (void)switchToStep3View {
    _mPwdInput.text = nil;
    _mPwdConfirmInput.text = nil;
    
    CATransition *animation = [self fadeAnimation];
    [_mStep3View.layer addAnimation:animation forKey:nil];
    
    [_mStep1View setHidden:YES];
    [_mStep2View setHidden:YES];
    [_mStep3View setHidden:NO];
    [_mPwdInput becomeFirstResponder];
}



#pragma mark - Button actions
- (void)getValidationCodeAction {
    NSString *phoneNumber = [_mUserNameInput.text trimWhitespaceAndNewline];
    
    [_mUserNameInput resignFirstResponder];
    
    // check user input phone number
    if(!phoneNumber || [phoneNumber isEqualToString:@""]) {
        NSLog(@"user input phone number is nil.");
                
        [[[iToast makeText:NSLocalizedString(@"please input phone number first", "")] setDuration:iToastDurationNormal] show];
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
        [[[iToast makeText:NSLocalizedString(@"please input code", "")] setDuration:iToastDurationNormal] show];
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
        [[[iToast makeText:NSLocalizedString(@"please input password", "")] setDuration:iToastDurationNormal] show];
        return;
    }
    
    if (!pwd2 || [pwd2 isEqualToString:@""]) {
        [[[iToast makeText:NSLocalizedString(@"please input confirm password", "")] setDuration:iToastDurationNormal] show];
        return;
    }
    
    if (![pwd1 isEqualToString:pwd2]) {
        [[[iToast makeText:NSLocalizedString(@"pwd1 is different to pwd2", "")] setDuration:iToastDurationNormal] show];
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
