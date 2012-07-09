//
//  ContactsProcessSoftKeyboard.m
//  IMeeting
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 richitec. All rights reserved.
//

#import "ContactsProcessSoftKeyboard.h"

// contacts process softKeyboard contents
#define CONTACTSPROCESS_SOFTKEYBOARD_CONTENTS    [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"1", @"2", @"3", nil], [NSNumber numberWithInteger:0], [NSArray arrayWithObjects:@"4", @"5", @"6", nil], [NSNumber numberWithInteger:1], [NSArray arrayWithObjects:@"7", @"8", @"9", nil], [NSNumber numberWithInteger:2], [NSArray arrayWithObjects:@"add", @"0", @"del", nil], [NSNumber numberWithInteger:3], nil]

@interface ECKeyButton : UIButton

@end

@implementation ECKeyButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.superview touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.superview touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end


@interface ContactsProcessSoftKeyboard () {
    NSMutableDictionary *buttonImgCache;
}
- (UIImage*)buttonImgAt:(NSIndexPath*)indexPath;
@end

@implementation ContactsProcessSoftKeyboard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // set background color
        self.backgroundColor = CONTACTSPROCESS_SOFTKEYBOARD_BACKGROUND_COLOR;
        
        buttonImgCache = [[NSMutableDictionary alloc] initWithCapacity:12];
        
        // set margin size
        self.padding = 1.0;
        
        // set dataSource
        self.dataSource = self;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)numberOfRowsInSoftKeyboard:(UISoftKeyboard *)pSoftKeyboard{
    // return the number of rows
    return 4;
}

- (NSInteger)softKeyboard:(UISoftKeyboard *)pSoftKeyboard numberOfCellsInRow:(NSInteger)pRow{
    // return the number of cell in the row    
    return 3;
}

- (UISoftKeyboardCell *)softKeyboard:(UISoftKeyboard *)pSoftKeyboard cellForRowAtIndexPath:(NSIndexPath *)pIndexPath{
    UISoftKeyboardCell *_cell = [[UISoftKeyboardCell alloc] init];
    
    // Configure the cell...
    _cell.backgroundColor = CONTACTSPROCESS_SOFTKEYBOARD_FRONT_COLOR;
    _cell.pressedBackgroundColor = [UIColor blueColor];
    
    @autoreleasepool {
        // create and init softKeyboard front view
        /*
        UILabel *_label = [[UILabel alloc] init];
        _label.text = [[CONTACTSPROCESS_SOFTKEYBOARD_CONTENTS objectForKey:[NSNumber numberWithInteger:pIndexPath.skb_row]] objectAtIndex:pIndexPath.skb_cell];
        _label.textAlignment = UITextAlignmentCenter;
        
        _cell.frontView = _label;
         */
     
        ECKeyButton *keyButton = [ECKeyButton buttonWithType:UIButtonTypeCustom];
        [keyButton setBackgroundImage:[self buttonImgAt:pIndexPath] forState:UIControlStateNormal];
        keyButton.showsTouchWhenHighlighted = YES;
        _cell.frontView = keyButton;
        _cell.coreData = [NSNumber numberWithString:[[CONTACTSPROCESS_SOFTKEYBOARD_CONTENTS objectForKey:[NSNumber numberWithInteger:pIndexPath.skb_row]] objectAtIndex:pIndexPath.skb_cell]];
    }
    
    return _cell;
}



- (UIImage *)buttonImgAt:(NSIndexPath *)indexPath {
    NSNumber *keyPos = [NSNumber numberWithInt:indexPath.skb_row * 3 + indexPath.skb_cell];
    UIImage *buttonImg = [buttonImgCache objectForKey:keyPos];
    if (buttonImg) {
        NSLog(@"get key image from cache");
        return buttonImg;
    } else {
        NSLog(@"get new key image");

        switch (keyPos.intValue) {
            case 0:
                buttonImg = [UIImage imageNamed:@"k1"];
                break;
            case 1:
                buttonImg = [UIImage imageNamed:@"k2"];
                break;
            case 2:
                buttonImg = [UIImage imageNamed:@"k3"];
                break;
            case 3:
                buttonImg = [UIImage imageNamed:@"k4"];
                break;
            case 4:
                buttonImg = [UIImage imageNamed:@"k5"];
                break;
            case 5:
                buttonImg = [UIImage imageNamed:@"k6"];
                break;
            case 6:
                buttonImg = [UIImage imageNamed:@"k7"];
                break;
            case 7:
                buttonImg = [UIImage imageNamed:@"k8"];
                break;
            case 8:
                buttonImg = [UIImage imageNamed:@"k9"];
                break;
            case 9:
                buttonImg = [UIImage imageNamed:@"add"];
                break;
            case 10:
                buttonImg = [UIImage imageNamed:@"k0"];
                break;
            case 11:
                buttonImg = [UIImage imageNamed:@"del"];
                break;
            default:
                break;
        }
        [buttonImgCache setObject:buttonImg forKey:keyPos];
        return buttonImg;
    }
}

@end
