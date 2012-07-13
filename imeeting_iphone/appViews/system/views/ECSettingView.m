//
//  ECSettingView.m
//  imeeting_iphone
//
//  Created by star king on 12-7-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECSettingView.h"
#import "CommonToolkit/CommonToolkit.h"

@interface ECSettingView ()
- (void)initUI;
- (void)showAccountSettingView;
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
    self.title = NSLocalizedString(@"Setting", "");
    
    accountSettingButton = [self makeButtonWithTitle:NSLocalizedString(@"Set Account", nil) frame:CGRectMake(0, 0, 300, 45)];
    [accountSettingButton addTarget:self action:@selector(showAccountSettingView) forControlEvents:UIControlEventTouchUpInside];
    
    UITableView *settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStyleGrouped];
    settingTableView.backgroundColor = self.backgroundColor;
    settingTableView.dataSource = self;
    
    [self addSubview:settingTableView];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - table view datasource delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"Account", nil);
            break;
            
        default:
            break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 1;
    switch (section) {
        case 0:
            rows = 1;
            break;
            
        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setting cell"];
    
    if (cell == nil) {
        switch (indexPath.row) {
            case 0:
                cell = [[ECUIControlTableViewCell alloc] initWithControls:[NSArray arrayWithObject:accountSettingButton]];
                break;
            default:
                break;
        }
    }
    return cell;
}

#pragma mark - actions

- (void)showAccountSettingView {
    if ([self validateViewControllerRef:self.viewControllerRef andSelector:@selector(showAccountSettingView)]) {
        [self.viewControllerRef performSelector:@selector(showAccountSettingView)];
    }
}

@end
