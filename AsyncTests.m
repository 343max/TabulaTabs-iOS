//
//  AsyncTests.m
//  TabulaTabs
//
//  Created by Max Winde on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTTab.h"
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
            
            TTTab* tab1 = [[TTTab alloc] init];
            tab1.title = @"Tab1";
            tab1.URL = [NSURL URLWithString:@"http://tab1.de/"];
            tab1.favIconURL = [NSURL URLWithString:@"http://tab1.de/favicon.ico"];
            tab1.selected = YES;
            tab1.identifier = @"1";
            tab1.windowId = @"1";
            tab1.index = 0;
            
            NSLog(@"tab1: %@", [tab1 dictionary]);
            
            TTTab* tab2 = [[TTTab alloc] init];
            tab2.title = @"Tab2";
            tab2.URL = [NSURL URLWithString:@"http://tab2.de/"];
            tab2.favIconURL = [NSURL URLWithString:@"http://tab2.de/favicon.ico"];
            tab2.selected = NO;
            tab2.identifier = @"2";
            tab2.windowId = @"2";
            tab2.index = 1;
            
            [browser saveTabs:[NSArray arrayWithObjects:tab1, tab1, nil] callback:^(id response) {
                NSLog(@"response: %@", response);
            }];
        }];
        
    }];
}

@end
