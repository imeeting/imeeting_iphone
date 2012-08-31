//
//  ECSettingView.m
//  imeeting_iphone
//
//  Created by star king on 12-7-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECSettingView.h"
#import "CommonToolkit/CommonToolkit.h"
#import "ECConstants.h"

#define SETTING_CELL_WIDTH      268

#define SETTING_TITLE_ARRAY     [NSArray arrayWithObjects:NSLocalizedString(@"Set Account", nil), NSLocalizedString(@"Upload Addressbook", nil), NSLocalizedString(@"Help", nil), NSLocalizedString(@"About", nil), nil]

/*
@interface SettingButton : UIButton
@end

@implementation SettingButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.titleLabel.textColor = [UIColor colorWithIntegerRed:146 integerGreen:146 integerBlue:146 alpha:1];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    self.titleLabel.textColor = [UIColor colorWithIntegerRed:146 integerGreen:146 integerBlue:146 alpha:1];
}
@end
*/
@interface SettingItemCell : UITableViewCell {
    UIImageView *bgView;
    UILabel *titleLabel;
    
    UIColor *normalTextColor;
    UIColor *selectedTextColor;
}
+ (CGFloat)cellHeight;
@end

@implementation SettingItemCell

+ (CGFloat)cellHeight {
    return 52;
}

- (id)initWithTitle:(NSString*)title {
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        normalTextColor = [UIColor colorWithIntegerRed:146 integerGreen:146 integerBlue:146 alpha:1];
        
        
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 268, [SettingItemCell cellHeight])];
        bgView.contentMode = UIViewContentModeScaleAspectFit;
        bgView.layer.masksToBounds = YES;
        bgView.image = [UIImage imageNamed:@"setting_cell_normal"];
        [self.contentView addSubview:bgView];
        
        selectedTextColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 268, [SettingItemCell cellHeight])];
        titleLabel.textColor = normalTextColor;
        titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:16];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
         
        /*
        SettingButton *bt = [SettingButton buttonWithType:UIButtonTypeCustom];
      //  bt.tableViewCell = self;
        bt.frame = CGRectMake(0, 0, 268, [SettingItemCell cellHeight]);
        [bt setBackgroundImage:[UIImage imageNamed:@"setting_cell_normal"] forState:UIControlStateNormal];
        [bt setTitle:title forState:UIControlStateNormal];
        [bt setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
        bt.titleLabel.font = [UIFont fontWithName:CHINESE_BOLD_FONT size:16];
        bt.titleLabel.textColor = normalTextColor;
        [self.contentView addSubview:bt];
         */
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    bgView.image = [UIImage imageNamed:@"setting_cell_selected"];
    titleLabel.textColor = selectedTextColor;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    bgView.image = [UIImage imageNamed:@"setting_cell_normal"];
    titleLabel.textColor = normalTextColor;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    bgView.image = [UIImage imageNamed:@"setting_cell_normal"];
    titleLabel.textColor = normalTextColor;

}

@end

@interface ECSettingView ()
- (void)initUI;
- (void)showAccountSettingView;
- (void)showAboutView;
- (void)showHelpView;
@end

@implementation ECSettingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    _titleView.text = NSLocalizedString(@"Setting", "");
    self.titleView = _titleView;
    
    self.leftBarButtonItem = [self makeBarButtonItem:NSLocalizedString(@"Talking Group", nil) backgroundImg:[UIImage imageNamed:@"back_navi_button_long"] frame:CGRectMake(0, 0, 84, 28) target:self action:@selector(onBackAction)];
    
    self.backgroundImg = [UIImage imageNamed:@"mainpage_bg"];
    
    UITableView *settingTableView = [[UITableView alloc] initWithFrame:CGRectMake((self.frame.size.width - SETTING_CELL_WIDTH) / 2, 0, SETTING_CELL_WIDTH, 340)style:UITableViewStylePlain];
    settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    settingTableView.backgroundColor = [UIColor clearColor];
    settingTableView.dataSource = self;
    settingTableView.delegate = self;
    [self addSubview:settingTableView];
}

#pragma mark - table view datasource delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *gap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SETTING_CELL_WIDTH, 30)];
    gap.backgroundColor = [UIColor clearColor];
    return gap;
}
 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SettingItemCell cellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SETTING_TITLE_ARRAY count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setting cell"];
    
    if (cell == nil) {
        NSString *title = [SETTING_TITLE_ARRAY objectAtIndex:indexPath.row];
        cell = [[SettingItemCell alloc] initWithTitle:title];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self showAccountSettingView];
            break;
        case 1:
            [self uploadAddressbook];
            break;
        case 2:
            [self showHelpView];
            break;
        case 3:
            [self showAboutView];
            break;
        default:
            break;
    }
}

#pragma mark - actions

- (void)showAccountSettingView {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(showAccountSettingView)]) {
        [self.viewControllerRef performSelector:@selector(showAccountSettingView)];
    }
}

- (void)showAboutView {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(showAboutView)]) {
        [self.viewControllerRef performSelector:@selector(showAboutView)];
    }
}

- (void)showHelpView {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(showHelpView)]) {
        [self.viewControllerRef performSelector:@selector(showHelpView)];
    }
}

- (void)uploadAddressbook {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(uploadAddressbook)]) {
        [self.viewControllerRef performSelector:@selector(uploadAddressbook)];
    }
}

@end
