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
#import "ECUrlConfig.h"
#import "AuthInterceptor.h"

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
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithSuperView:self.view];
        hud.labelText = NSLocalizedString(@"Uploading AddressBook", nil);
        [hud showWhileExecuting:@selector(doAddressBookUploadPost) onTarget:self withObject:nil animated:YES];
    };
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Upload Addressbook", nil) message:NSLocalizedString(@"Upload Addressbook?", nil) cancelButtonItem:cancelItem otherButtonItems:uploadItem, nil] show];
}

- (void)doAddressBookUploadPost {
    NSString *accountName = [UserManager shareUserManager].userBean.name;
    
    NSArray *groups = [[AddressBookManager shareAddressBookManager] allGroupsInfoArray];
    NSMutableArray *allGroups = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *groupInfo in groups) {
        NSMutableDictionary *groupDic = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
        [groupDic setObject:accountName forKey:AB_OWNER];
        [allGroups addObject:groupDic];
    }
    
    NSArray *contacts = [[AddressBookManager shareAddressBookManager] allContactsInfoArray];
    NSMutableArray *allContacts = [NSMutableArray arrayWithCapacity:10];
    
    for (ContactBean * contact in contacts) {
        NSLog(@"contact: %@", contact);
        NSDictionary *contactDic = [NSDictionary dictionaryWithObjectsAndKeys:accountName, AB_OWNER, contact.displayName, AB_CONTACT_NAME, contact.namePhonetics, AB_CONTACT_PHONETIC_ARRAY, contact.phoneNumbers, AB_CONTACT_PHONE_ARRAY, contact.groups, AB_CONTACT_GROUP_ARRAY, nil];
        [allContacts addObject:contactDic];
    }
    
    NSString *groupsJsonString = [allGroups JSONString];
    NSString *contactsJsonString = [allContacts JSONString];
    
    // todo: post groups and contacts to server via http
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:contactsJsonString, @"contacts", groupsJsonString, @"groups", nil];
    [HttpUtil postSignatureRequestWithUrl:ADDRESSBOOK_UPLOAD_URL andPostFormat:urlEncoded andParameter:params andUserInfo:nil andRequestType:synchronous andProcessor:self andFinishedRespSelector:@selector(onFinishedUploadAddressBook:) andFailedRespSelector:@selector(onNetworkFailed:)];
}

- (void)onFinishedUploadAddressBook:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedUploadAddressBook - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;
    
    switch (statusCode) {
        case 200:
            // upload ok
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"AddressBook Upload OK", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
            break;
            
        default:
            // upload failed
             [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"AddressBook Upload Failed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
            break;
    }

}

- (void)onNetworkFailed:(ASIHTTPRequest *)pRequest {
    HTTP_RETURN_CHECK(pRequest, self);
}
@end
