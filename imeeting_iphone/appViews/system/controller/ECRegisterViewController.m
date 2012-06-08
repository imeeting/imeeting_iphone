//
//  ECRegisterViewController.m
//  imeeting_iphone
//
//  Created by star king on 12-6-5.
//  Copyright (c) 2012年 elegant cloud. All rights reserved.
//

#import "ECRegisterViewController.h"
#import "ECRegisterUIView.h"
#import "ECUrlConfig.h"

@interface ECRegisterViewController ()

#pragma mark - private methods
- (void)onFinishedGetPhoneCode:(ASIHTTPRequest*)pRequest;

- (void)onFinishedCheckPhoneCode:(ASIHTTPRequest*)pRequest;

- (void)onFinishedRegister:(ASIHTTPRequest*)pRequest;

- (void)onNetworkFailed:(ASIHTTPRequest*)pRequest;
@end

@implementation ECRegisterViewController

- (id)init
{
    return [self initWithCompatibleView:[[ECRegisterUIView alloc] init]];
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

#pragma mark - button action implementations for ECRegisterUIView
- (void)getValidationCodeByPhoneNumber:(NSString *)phoneNumber {
    NSLog(@"get validation code - number:%@", phoneNumber);
    
    // send request to server to get validation code
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:phoneNumber, @"phone", nil];
    
    [HttpUtil sendFormRequestWithUrl:[ECUrlConfig RetrievePhoneCodeUrl] andPostBody:param andUserInfo:nil andDelegate:self andFinishedRespMethod:@selector(onFinishedGetPhoneCode:) andFailedRespMethod:@selector(onNetworkFailed:) andRequestType:synchronous];
}

- (void)verifyCode:(NSString *)code {
    NSLog(@"verify code");

    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:code, @"code", nil];
    [HttpUtil sendFormRequestWithUrl:[ECUrlConfig CheckPhoneCodeUrl] andPostBody:param andUserInfo:nil andDelegate:self andFinishedRespMethod:@selector(onFinishedCheckPhoneCode:) andFailedRespMethod:@selector(onNetworkFailed:) andRequestType:synchronous];
}

- (void)finishRegisterWithPwds:(NSArray*)pwds {
    NSLog(@"finish register");
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[pwds objectAtIndex:0], @"password", [pwds objectAtIndex:1], @"password1", nil];
    
    [HttpUtil sendFormRequestWithUrl:[ECUrlConfig UserRegisterUrl] andPostBody:param andUserInfo:nil andDelegate:self andFinishedRespMethod:@selector(onFinishedRegister:) andFailedRespMethod:@selector(onNetworkFailed:) andRequestType:synchronous];
}

- (void)jumpToLoginView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - HTTP Request Callback Methods Implementation

- (void)onFinishedGetPhoneCode:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedGetPhoneCode - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;

    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSString *result = [jsonData objectForKey:@"result"];
                NSLog(@"result: %@", result);

                if([result isEqualToString:@"0"]) {
                    // get phone code successfully, jump to step 2
                    [self.view performSelector:@selector(switchToStep2View)];
                } else if ([result isEqualToString:@"2"]) {
                    [iToast showDefaultToast:NSLocalizedString(@"Invalid Phone Number!", "") andDuration:iToastDurationNormal];
                } else if ([result isEqualToString:@"3"]) {
                    [iToast showDefaultToast:NSLocalizedString(@"Existed Phone Number!", "") andDuration:iToastDurationNormal];
                } else {
                    goto get_phone_code_error;
                }
            } else {
                goto get_phone_code_error;
            }
            break;
        }
        default:
            goto get_phone_code_error;
            break;
    }
    
    return;
    
get_phone_code_error:
    [iToast showDefaultToast:NSLocalizedString(@"Error in retrieving validation code, please retry.", "") andDuration:iToastDurationNormal];
}

- (void)onFinishedCheckPhoneCode:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedCheckPhoneCode - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);
    
    int statusCode = pRequest.responseStatusCode;

    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSString *result = [jsonData objectForKey:@"result"];
                NSLog(@"result: %@", result);

                if([result isEqualToString:@"0"]) {
                    // check phone code successfully, jump to step 3 to fill password
                    [self.view performSelector:@selector(switchToStep3View)];
                } else if ([result isEqualToString:@"2"]) {
                    [iToast showDefaultToast:NSLocalizedString(@"Wrong Validation Code!", "") andDuration:iToastDurationNormal];
                } else if ([result isEqualToString:@"6"]) {
                    [iToast showDefaultToast:NSLocalizedString(@"code check session timeout", "") andDuration:iToastDurationNormal];
                    [self.view performSelector:@selector(switchToStep1View)];

                }
            } else {
                goto check_phone_code_error;
            }
            break;
        }
        default:
            goto check_phone_code_error;
            break;
    }
    
    return;
    
check_phone_code_error:
    [iToast showDefaultToast:NSLocalizedString(@"Error in checking validation code, please retry.", "") andDuration:iToastDurationNormal];   
}

- (void)onFinishedRegister:(ASIHTTPRequest *)pRequest {
    NSLog(@"onFinishedRegister - request url = %@, responseStatusCode = %d, responseStatusMsg = %@", pRequest.url, [pRequest responseStatusCode], [pRequest responseStatusMessage]);

    int statusCode = pRequest.responseStatusCode;

    switch (statusCode) {
        case 200: {
            NSDictionary *jsonData = [[[NSString alloc] initWithData:pRequest.responseData encoding:NSUTF8StringEncoding] objectFromJSONString];
            if (jsonData) {
                NSString *result = [jsonData objectForKey:@"result"];
                NSLog(@"result: %@", result);

                if([result isEqualToString:@"0"]) {
                    // register ok, jump to login view
                    [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Register OK", "") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", "") otherButtonTitles:nil, nil] show];

                } else if ([result isEqualToString:@"6"]) {
                    [iToast showDefaultToast:NSLocalizedString(@"register session timeout", "") andDuration:iToastDurationNormal];
                    [self.view performSelector:@selector(switchToStep1View)];
                    
                }
            } else {
                goto finish_register_error;
            }
            break;
        }
        default:
            goto finish_register_error;
            break;
    }
    
    return;

finish_register_error:
    [iToast showDefaultToast:NSLocalizedString(@"Error in finishing register, please retry.", "") andDuration:iToastDurationNormal];   
    
}

- (void)onNetworkFailed:(ASIHTTPRequest *)pRequest {
    NSError *_error = [pRequest error];
    NSLog(@"onNetworkFailed - request url = %@, error: %@, response data:%@", pRequest.url, _error, pRequest.responseData);
    [iToast showDefaultToast:NSLocalizedString(@"network exception", "") andDuration:iToastDurationNormal];

}

#pragma mark - AlertView Delegate Implementation

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self jumpToLoginView];
            break;
            
        default:
            break;
    }
}

@end
