//
//  BottomBarButton.h
//  imeeting_iphone
//
//  Created by king star on 12-8-21.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomBarButton : UIControl {
    UILabel *_titleLabel;
}
@property (nonatomic, retain) UIImage *pressedBgImg;
- (id)initWithFrame:(CGRect)frame andTitle:(NSString*)title andIcon:(UIImage*)icon;
@end