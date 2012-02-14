//
//  AsyncTests.m
//  TabulaTabs
//
//  Created by Max Winde on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTEncryption.h"
#import "TTRestfulClient.h"
#import "TTBrowser.h"

#import "AsyncTests.h"

@implementation AsyncTests

- (void)runTests;
{
    TTEncryption *encryption = [[TTEncryption alloc] initWithEncryptionKey:[TTEncryption generateEncryptionKey]]; 
    TTBrowser *browser = [[TTBrowser alloc] initWithEncryption:encryption];
    
    browser.userAgent = @"Tabulatabs iOS Test Browser";
    browser.label = @"TTT: TestTabulatabsBrowser";
    browser.description = @"my Testbrowser";
    browser.iconURL = [NSURL URLWithString:@"http://tabulatabs.com/iPhone.png"];
    
    NSLog(@"trying to register browser");
    [browser registerWithPassword:[TTEncryption generatePassword] callback:^(id response) {
        NSAssert(browser.username, @"Could not successfully register browser");
        
        TTBrowser *newBrowser = [[TTBrowser alloc] initWithEncryption:encryption];
        newBrowser.username = browser.username;
        newBrowser.password = browser.password;
        
        NSLog(@"trying to load browser");
        [newBrowser load:^(id response) {
            NSLog(@"response: %@", response);
            
            NSAssert([browser.userAgent isEqualToString:newBrowser.userAgent], @"useragent not set correctly");
            NSAssert([browser.iconURL.absoluteString isEqualToString:newBrowser.iconURL.absoluteString], @"iconURL not set correctly");
            NSAssert([browser.label isEqualToString:newBrowser.label], @"label not set correctly");
            NSAssert([browser.description isEqualToString:newBrowser.description], @"description not set correctly");
            
        }];
        
    }];
}

@end
