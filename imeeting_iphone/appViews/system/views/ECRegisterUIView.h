//
//  ECRegisterUIView.h
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECBaseUIView.h"

@interface ECRegisterUIView : ECBaseUIView {    
    UITextField *_mUserNameInput;
    UITextField *_mPwdInput;
    UITextField *_mPwdConfirmInput;
    UITextField *_mValidateCodeInput;
    
    UIView *_mStep1View; // view for getting phone code
    UIView *_mStep2View; // view for verifying phone code
    UIView *_mStep3View; // view for inputing password
    
    MBProgressHUD *_mHud;
}



- (void)switchToStep1View;
- (void)switchToStep2View;
- (void)switchToStep3View;


@end
