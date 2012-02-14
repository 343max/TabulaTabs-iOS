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
#import "TTClient.h"

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
            NSAssert([browser.userAgent isEqualToString:newBrowser.userAgent], @"useragent not set correctly");
            NSAssert([browser.iconURL.absoluteString isEqualToString:newBrowser.iconURL.absoluteString], @"iconURL not set correctly");
            NSAssert([browser.label isEqualToString:newBrowser.label], @"label not set correctly");
            NSAssert([browser.description isEqualToString:newBrowser.description], @"description not set correctly");
        }];
        
        TTTab* tab1 = [[TTTab alloc] init];
        tab1.title = @"Tab1";
        tab1.URL = [NSURL URLWithString:@"http://tab1.de/"];
        tab1.favIconURL = [NSURL URLWithString:@"http://tab1.de/favicon.ico"];
        tab1.selected = YES;
        tab1.identifier = @"1";
        tab1.windowId = @"1";
        tab1.index = 0;
        
        TTTab* tab2 = [[TTTab alloc] init];
        tab2.title = @"Tab2";
        tab2.URL = [NSURL URLWithString:@"http://tab2.de/"];
        tab2.favIconURL = [NSURL URLWithString:@"http://tab2.de/favicon.ico"];
        tab2.selected = NO;
        tab2.identifier = @"2";
        tab2.windowId = @"2";
        tab2.index = 1;

        NSLog(@"trying to save tabs");
        [browser saveTabs:[NSArray arrayWithObjects:tab1, tab2, nil] callback:^(id response) {
            NSAssert([[response objectForKey:@"success"] boolValue], @"could not save tabs");
            NSString *claimingPassword = [TTEncryption generatePassword];
            
            NSLog(@"trying to createClient");
            [browser createClient:claimingPassword callback:^(NSString *clientUsername, id response) {
                NSAssert(clientUsername, @"could not create client");
                
                TTClient *client = [[TTClient alloc] initWithEncryption:encryption];
                client.username = clientUsername;
                
                NSLog(@"trying to claim client");
                [client claimClient:claimingPassword finalPassword:[TTEncryption generatePassword] callback:^(id response) {
                    NSAssert([[response objectForKey:@"success"] boolValue], @"could not save tabs");
                    
                    NSLog(@"trying to load tabs");
                    [client loadTabs:^(NSArray *tabs, id response) {
                        NSAssert(tabs.count == 2, @"Wrong tab count loaded");
                        
                        TTTab* loadedTab1 = [tabs objectAtIndex:0];
                        NSAssert([tab1.title isEqualToString:loadedTab1.title], @"Tab 1 title is incorrect");
                        NSAssert([tab1.URL.absoluteString isEqualToString:loadedTab1.URL.absoluteString], @"Tab 1 URL is incorrect");
                        NSAssert([tab1.favIconURL.absoluteString isEqualToString:loadedTab1.favIconURL.absoluteString], @"Tab 1 favIconURL is incorrect");
                        NSAssert(tab1.selected == loadedTab1.selected, @"Tab 1 title is incorrect");
                        NSAssert([tab1.identifier isEqualToString:loadedTab1.identifier], @"Tab 1 identifier is incorrect");
                        NSAssert([tab1.windowId isEqualToString:loadedTab1.windowId], @"Tab 1 windowId is incorrect");
                        NSAssert(tab1.index == loadedTab1.index, @"Tab 1 index is incorrect");

                        TTTab* loadedTab2 = [tabs objectAtIndex:1];
                        NSAssert([tab2.title isEqualToString:loadedTab2.title], @"Tab 2 title is incorrect");
                        NSAssert([tab2.URL.absoluteString isEqualToString:loadedTab2.URL.absoluteString], @"Tab 2 URL is incorrect");
                        NSAssert([tab2.favIconURL.absoluteString isEqualToString:loadedTab2.favIconURL.absoluteString], @"Tab 2 favIconURL is incorrect");
                        NSAssert(tab2.selected == loadedTab2.selected, @"Tab 2 title is incorrect");
                        NSAssert([tab2.identifier isEqualToString:loadedTab2.identifier], @"Tab 2 identifier is incorrect");
                        NSAssert([tab2.windowId isEqualToString:loadedTab2.windowId], @"Tab 2 windowId is incorrect");
                        NSAssert(tab2.index == loadedTab2.index, @"Tab 2 index is incorrect");
                        
                        NSLog(@"all tests passed successfully");
                    }];
                }];
            }];
       }];

    }];
}

@end
