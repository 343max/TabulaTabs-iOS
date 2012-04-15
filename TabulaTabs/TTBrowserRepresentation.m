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
#import "TTTab.h"
#import "TTBrowser.h"
#import "TTBrowserController.h"

#import "TTBrowserRepresentation.h"

NSString * const TTBrowserRepresentationClientWasUpdatedNotification = @"TTBrowserRepresentationClientWasUpdatedNotification";
NSString * const TTBrowserRepresentationClaimingClientNotification = @"TTBrowserRepresentationClaimingClientNotification";
NSString * const TTBrowserRepresentationClientAccessWasRevokedNotification = @"TTBrowserRepresentationClientAccessWasRevokedNotification";

NSString * const TTBrowserRepresentationBrowserWasUpdatedNotification = @"TTBrowserRepresentationBrowserWasUpdatedNotification";

NSString * const TTBrowserRepresentationTabsWhereUpdatedNotification = @"TTBrowserRepresentationTabsWhereUpdatedNotification";


@interface TTBrowserRepresentation ()

@property (strong) TTBrowser *browser;
@property (strong, nonatomic) NSArray *tabs;
@property (strong, nonatomic, readonly) NSString *archiveFilePath;

- (void)saveToDisk;

@end


@implementation TTBrowserRepresentation

@synthesize client = _client, browser = _browser, tabs = _tabs;
@synthesize tabulatabsURL = _tabulatabsURL;
@synthesize archiveFilePath = _archiveFilePath;

- (void)setClient:(TTClient *)client;
{
    self.tabs = nil;
    self.browser = nil;
    
    _client.connectionDidReceiveAuthentificationChallenge = nil;
    
    _client = client;
    
    __block TTBrowserRepresentation *weakSelf = self; 
    [_client setConnectionDidReceiveAuthentificationChallenge:^(NSURLAuthenticationChallenge *authenticationChallange) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationClientAccessWasRevokedNotification 
                                                            object:weakSelf];
    }];
    
    if (!_client.unclaimed) {
        NSDictionary *archivedData = [NSDictionary dictionaryWithContentsOfFile:self.archiveFilePath];
        
        if (archivedData) {
            NSArray *archivedTabs = [archivedData objectForKey:@"tabs"];
            NSMutableArray *tabs = [NSMutableArray arrayWithCapacity:archivedTabs.count];
            
            [archivedTabs enumerateObjectsUsingBlock:^(NSDictionary *tabDict, NSUInteger idx, BOOL *stop) {
                TTTab *tab = [[TTTab alloc] initWithDictionary:tabDict];
                [tabs addObject:tab];
            }];
            self.tabs = tabs;
            
            self.browser = [[TTBrowser alloc] initWithDictionary:[archivedData objectForKey:@"browser"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationBrowserWasUpdatedNotification
                                                                object:self
                                                              userInfo:nil];
        }
        
        [self loadBrowser];
        [self loadTabs];
    }
}

- (void)setTabs:(NSArray *)tabs;
{
    _tabs = tabs;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationTabsWhereUpdatedNotification
                                                        object:self
                                                      userInfo:nil];
}

- (NSURL *)tabulatabsURL;
{
    return [NSURL tabulatabsURLWithString:[NSString stringWithFormat:@"client/tabs/%@", self.client.username]];
}

- (NSString *)archiveFilePath;
{
    NSString *cacheDirPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [NSString stringWithFormat:@"%@.plist", self.client.username];
    return [cacheDirPath stringByAppendingPathComponent:filename];
}

- (void)saveToDisk;
{
    NSMutableArray *encodedTabs = [NSMutableArray arrayWithCapacity:self.tabs.count];
    
    [self.tabs enumerateObjectsUsingBlock:^(TTTab *tab, NSUInteger idx, BOOL *stop) {
        [encodedTabs addObject:tab.dictionary];
    }];
    
    NSDictionary *dataForArchive = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.browser.dictionary, @"browser",
                                    encodedTabs, @"tabs", nil];
    [dataForArchive writeToFile:self.archiveFilePath atomically:YES];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationClaimingClientNotification object:self];
    
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationClientWasUpdatedNotification object:self];
            [TestFlight passCheckpoint:@"registered a client"];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not add browser"
                                                                message:@"This browser could not be added because the authentication code is to old or allready in use. Please try again with a fresh code."
                                                               delegate:self
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
            [alertView show];
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
        [self saveToDisk];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationBrowserWasUpdatedNotification
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
        
        [self saveToDisk];
    }];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL firstBrowserURL]];
    }
}

@end
