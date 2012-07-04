//
//  TTDevelopmentHelpers.m
//  TabulaTabs
//
//  Created by Max Winde on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData-hex.h"
#import "TTEncryption.h"
#import "TTClient.h"
#import "TTBrowser.h"

#import "AsyncTests.h"

#import "TTAppDelegate.h"
#import "TTDevelopmentHelpers.h"

@implementation TTDevelopmentHelpers

+ (void)runAsynchronTests;
{
    AsyncTests* tests = [[AsyncTests alloc] init];
    [tests runTests];
}

+ (void)registerFakeClient;
{
    NSString *encryptionKey = @"be804aea39ab5aa6a8062848b0c815a31f9663fa54518cc64ecc65d8aaf72534";
    TTEncryption *encryption = [[TTEncryption alloc] initWithEncryptionKey:[NSData dataWithHexString:encryptionKey]];
    TTBrowser *browser = [[TTBrowser alloc] initWithEncryption:encryption];
    browser.username = @"b_237";
    browser.password = @"0f66015043b53c0e75cd4ab0526c4e4c";
    
    NSString *claimingPassword = [TTClient generatePassword];
    [browser createClientWitClaimingPassword:claimingPassword callback:^(NSString *clientUsername, id response) {
        NSLog(@"starting claiming…");
        NSURL *registrationURL = [TTBrowser registrationURLForUsername:clientUsername claimingPassword:claimingPassword encryptionKey:encryption.encryptionKey];
        [appDelegate handleInternalURL:registrationURL];
    }];
}

@end
