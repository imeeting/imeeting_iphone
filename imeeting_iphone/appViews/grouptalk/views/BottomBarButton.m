//
//  BottomBarButton.m
//  imeeting_iphone
//
//  Created by king star on 12-8-21.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "BottomBarButton.h"
#import "ECConstants.h"
#import "CommonToolkit/CommonToolkit.h"

@implementation BottomBarButton
@synthesize pressedBgImg = _pressedBgImg;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString*)title andIcon:(UIImage*)icon {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 24) / 2, 16, 24, 24)];
        iconView.contentMode = UIViewContentModeScaleToFill;
        iconView.image = icon;
        [self addSubview:iconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width - 60) / 2, iconView.frame.origin.y + iconView.frame.size.height + 2, 60, 22)];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:CHINESE_FONT size:12];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (NSString*)title {
    return _titleLabel.text;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_pressedBgImg) {
        self.backgroundImg = _pressedBgImg;
    } else {
        self.backgroundImg = [UIImage imageNamed:@"bottom_button_pressed"];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.backgroundColor = [UIColor clearColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.backgroundColor = [UIColor clearColor];
}
@end

