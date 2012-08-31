//
//  ECSettingViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-7-13.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECSettingViewController.h"
#import "CommonToolkit/CommonToolkit.h"
#import "ECSettingView.h"
#import "ECLoginViewController.h"
#import "ECAboutViewController.h"
#import "ECHelpViewController.h"
#import "ECConstants.h"

@interface ECSettingViewController ()

@end

@implementation ECSettingViewController

- (id)init {
    self = [self initWithCompatibleView:[[ECSettingView alloc] init]];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - actions

- (void)showAccountSettingView {
    ECLoginViewController *loginViewController = [[ECLoginViewController alloc] init];
    loginViewController.isForLogin = NO;
    [self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)showAboutView {
    [self.navigationController pushViewController:[[ECAboutViewController alloc] init] animated:YES];
}

- (void)showHelpView {
    [self.navigationController pushViewController:[[ECHelpViewController alloc] init] animated:YES];
}

- (void)uploadAddressbook {
    RIButtonItem *cancelItem = [RIButtonItem item];
    cancelItem.label = NSLocalizedString(@"Cancel", nil);
    RIButtonItem *uploadItem = [RIButtonItem item];
    uploadItem.label = NSLocalizedString(@"Upload", nil);
    uploadItem.action = ^{
        NSArray *groups = [[AddressBookManager shareAddressBookManager] allGroupsInfoArray];
               
        NSArray *contacts = [[AddressBookManager shareAddressBookManager] allContactsInfoArray];
        NSMutableArray *allContacts = [NSMutableArray arrayWithCapacity:10];
        for (ContactBean * contact in contacts) {
            NSLog(@"contact: %@", contact);
            NSDictionary *contactDic = [NSDictionary dictionaryWithObjectsAndKeys:contact.displayName, AB_CONTACT_NAME, contact.namePhonetics, AB_CONTACT_PHONETIC_ARRAY, contact.groups, AB_CONTACT_GROUP_ARRAY, contact.phoneNumbers, AB_CONTACT_PHONE_ARRAY, nil];
            [allContacts addObject:contactDic];
        }

        NSString *groupsJsonString = [groups JSONString];
        NSString *contactsJsonString = [allContacts JSONString];
        
        // todo: post groups and contacts to server via http
        
    };
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Upload Addressbook", nil) message:NSLocalizedString(@"Upload Addressbook?", nil) cancelButtonItem:cancelItem otherButtonItems:uploadItem, nil] show];
}
@end
