//
//  ECAboutUIView.m
//  imeeting_iphone
//
//  Created by king star on 12-8-16.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECAboutUIView.h"
#import "ECConstants.h"

@interface ECAboutUIView ()
- (void)initUI;
@end

@implementation ECAboutUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _titleView.text = NSLocalizedString(@"About", "");
    self.titleView = _titleView;

    self.leftBarButtonItem = [self makeBarButtonItem:NSLocalizedString(@"Setting", nil) backgroundImg:[UIImage imageNamed:@"back_navi_button"] frame:CGRectMake(0, 0, 53, 28) target:self action:@selector(onBackAction)];
    
    self.backgroundImg = [UIImage imageNamed:@"mainpage_bg"];
    
    // get UIScreen bounds
    CGRect _screenBounds = [[UIScreen mainScreen] bounds];
    
    // update contacts select container view frame
    self.frame = CGRectMake(_screenBounds.origin.x, _screenBounds.origin.y, _screenBounds.size.width, _screenBounds.size.height - /*statusBar height*/[[UIDevice currentDevice] statusBarHeight] - /*navigationBar height*/[[UIDevice currentDevice] navigationBarHeight]);
    
    UILabel *aboutText = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 300) / 2 , 10, 300, self.frame.size.height - 10 * 2)];
    aboutText.textAlignment = UITextAlignmentCenter;
    aboutText.numberOfLines = 0;
    aboutText.lineBreakMode = UILineBreakModeCharacterWrap;
    aboutText.text = NSLocalizedString(@"about paragraph", nil);
    aboutText.font = [UIFont fontWithName:CHINESE_FONT size:15];
    aboutText.textColor = [UIColor colorWithIntegerRed:60 integerGreen:60 integerBlue:60 alpha:1];
    aboutText.backgroundColor = [UIColor clearColor];
    [self addSubview:aboutText];
}

@end
