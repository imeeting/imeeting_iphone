//
//  ECRegisterViewController.h
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"

@interface ECRegisterViewController : UIViewController <UIAlertViewDelegate>

/*
 * send phone number to server to retrieve validation code
 */ 
- (void)getValidationCodeByPhoneNumber:(NSString*)phoneNumber;

/**
 * send validation code to server to verify
 */
- (void)verifyCode:(NSString*)code;

/*
 * finish register
 */
- (void)finishRegisterWithPwds:(NSArray*)pwds;

@end
