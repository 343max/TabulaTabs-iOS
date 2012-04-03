//
//  TTBrowserRepresentation.m
//  TabulaTabs
//
//  Created by Max Winde on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestFlight.h"

#import "NSURL+TabulaTabs.h"
#import "TTAppDelegate.h"

#import "TTClient.h"
#import "TTBrowserController.h"

#import "TTBrowserRepresentation.h"

NSString * const TTBrowserReprensentationClientWasUpdatedNotification = @"TTBrowserReprensentationClientWasUpdatedNotification";
NSString * const TTBrowserReprensentationClaimingClientNotification = @"TTBrowserReprensentationClaimingClientNotification";

NSString * const TTBrowserReprensentationBrowserWasUpdatedNotification = @"TTBrowserReprensentationBrowserWasUpdatedNotification";

NSString * const TTBrowserReprensentationTabsWhereUpdatedNotification = @"TTBrowserReprensentationTabsWhereUpdatedNotification";


@interface TTBrowserRepresentation ()

@property (strong) TTBrowser *browser;
@property (strong) NSArray *tabs;

@end


@implementation TTBrowserRepresentation

@synthesize client = _client, browser = _browser, tabs = _tabs;
@synthesize tabulatabsURL = _tabulatabsURL;

- (void)setClient:(TTClient *)client;
{
    self.tabs = nil;
    self.browser = nil;
    
    _client = client;
    
    if (!_client.unclaimed) {
        [self loadBrowser];
        [self loadTabs];
    }
}

- (NSURL *)tabulatabsURL;
{
    return [NSURL tabulatabsURLWithString:[NSString stringWithFormat:@"client/tabs/%@", self.client.username]];
}

- (TTClient *)claimURL:(NSURL *)url;
{
    if ([url.host isEqualToString:@"client"] && url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:1] isEqualToString:@"claim"]) {
        TTEncryption *encryption = [TTEncryption encryptionWithHexKey:[url.pathComponents objectAtIndex:4]];
        self.client = [[TTClient alloc] initWithEncryption:encryption];
        self.client.username = [url.pathComponents objectAtIndex:2];
        
        [self claimClient:self.client claimingPassword:[url.pathComponents objectAtIndex:3]];
        
        return self.client;
    } else {
        return nil;
    }
}

- (void)claimClient:(TTClient *)client claimingPassword:(NSString *)claimingPassword;
{
    self.client = client;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserReprensentationClaimingClientNotification object:self];
    
    _client.userAgent = [NSString stringWithFormat:@"TabulaTabs iOS (%@ %@ %@)", [UIDevice currentDevice].model, [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    _client.label = [UIDevice currentDevice].name;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _client.iconURL = [NSURL URLWithString:@"https://tabulatabs.heroku.com/icons/iPad.png"];
    } else {
        _client.iconURL = [NSURL URLWithString:@"https://tabulatabs.heroku.com/icons/iPhone.png"];
    }
    
    [_client claimClient:claimingPassword finalPassword:[TTClient generatePassword] callback:^(BOOL success, id response) {
        if (success) {
            [self loadBrowserCompletion:^(id response) {
                 [appDelegate.browserController addBrowser:self];
            }];
            [self loadTabs];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserReprensentationClientWasUpdatedNotification object:self];
            [TestFlight passCheckpoint:@"registered a client"];
        } else {
            // todo
//            [appDelegate showPanelType:MKInfoPanelTypeError title:@"Could not add browser" subtitle:@"This browser could not be added. The URL might be out of date or claimed otherwise. For seccurity reasons you should click the \"Start Over\" link in your browser"];
        }
    }];
}

- (void)loadBrowser;
{
    [self loadBrowserCompletion:nil];
}

- (void)loadBrowserCompletion:(void (^)(id))callback;
{
    self.browser = [[TTBrowser alloc] initWithEncryption:self.client.encryption];
    
    [self.browser load:self.client.username password:self.client.password callback:^(id response) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserReprensentationBrowserWasUpdatedNotification
                                                            object:self
                                                          userInfo:nil];
        if (callback) {
            callback(response);
        }
    }];    
}

- (void)loadTabs;
{
    [self.client loadTabs:^(NSArray *loadedTabs, id response) {
        self.tabs = loadedTabs;
        [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserReprensentationTabsWhereUpdatedNotification
                                                            object:self
                                                          userInfo:nil];
    }];
}

@end
