//
//  ECBaseUIView.h
//  imeeting_iphone
//
//  Created by star king on 12-6-8.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonToolkit/CommonToolkit.h"


@interface ECBaseUIView : UIView <UITextFieldDelegate> {
    MBProgressHUD *_mHud;
}

- (void)showHudWhileExcuting:(SEL)selector onTarget:(id)target withObject:(NSObject *)object hudText:(NSString*)text animated:(BOOL)aninmated;
- (UITextField*)makeTextFieldWithPlaceholder:(NSString*)placeholder frame:(CGRect)frame keyboardType:(UIKeyboardType)keyboardType;
- (UIButton*)makeButtonWithTitle:(NSString*)title frame:(CGRect)frame;
- (UILabel*)makeLabel:(NSString*)text frame:(CGRect)frame;
@end
