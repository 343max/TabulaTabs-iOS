//
//  TTBrowserRepresentation.m
//  TabulaTabs
//
//  Created by Max Winde on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#if CONFIGURATION_AdHoc
#import "TestFlight.h"
#endif

#import "NSURL+TabulaTabs.h"
#import "TTAppDelegate.h"

#import "TTClient.h"
#import "TTTab.h"
#import "TTWindow.h"
#import "TTBrowser.h"
#import "TTBrowserController.h"

#import "TTBrowserRepresentation.h"

NSString * const TTBrowserRepresentationClientWasUpdatedNotification = @"TTBrowserRepresentationClientWasUpdatedNotification";
NSString * const TTBrowserRepresentationClaimingClientNotification = @"TTBrowserRepresentationClaimingClientNotification";
NSString * const TTBrowserRepresentationClientAccessWasRevokedNotification = @"TTBrowserRepresentationClientAccessWasRevokedNotification";

NSString * const TTBrowserRepresentationBrowserWasUpdatedNotification = @"TTBrowserRepresentationBrowserWasUpdatedNotification";

NSString * const TTBrowserRepresentationWindowsWhereUpdatedNotification = @"TTBrowserRepresentationWindowsWhereUpdatedNotification";


@interface TTBrowserRepresentation ()

@property (strong, nonatomic) TTBrowser *browser;
@property (strong, nonatomic) NSArray *windows;
@property (strong, nonatomic, readonly) NSString *archiveFilePath;

- (void)saveToDisk;
- (void)browserDataIsCorrupt:(NSNotification *)notifcation;

@end


@implementation TTBrowserRepresentation

@synthesize client = _client, browser = _browser, windows = _windows;
@synthesize tabulatabsURL = _tabulatabsURL;
@synthesize archiveFilePath = _archiveFilePath;

- (void)setClient:(TTClient *)client;
{
    self.windows = nil;
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
            NSArray *archivedWindows = [archivedData objectForKey:@"windows"];
            NSMutableArray *windows = [NSMutableArray arrayWithCapacity:archivedWindows.count];
            
            [archivedWindows enumerateObjectsUsingBlock:^(NSDictionary *windowDict, NSUInteger idx, BOOL *stop) {
                TTWindow *window = [[TTWindow alloc] initWithDictionary:windowDict];
                [windows addObject:window];
            }];
            self.windows = [windows copy];
            
            self.browser = [[TTBrowser alloc] initWithDictionary:[archivedData objectForKey:@"browser"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationBrowserWasUpdatedNotification
                                                                object:self
                                                              userInfo:nil];
        }
        
        [self loadBrowser];
        [self loadWindowsAndTabs];
    }
}

- (TTBrowser *)browser;
{
    return _browser;
}

- (void)setWindows:(NSArray *)windows;
{
    _windows = windows;
    [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationWindowsWhereUpdatedNotification
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
    NSMutableArray *encodedWindows = [NSMutableArray arrayWithCapacity:self.windows.count];
    
    [self.windows enumerateObjectsUsingBlock:^(TTWindow *window, NSUInteger idx, BOOL *stop) {
        [encodedWindows addObject:window.dictionary];
    }];
    
    NSDictionary *dataForArchive = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.browser.dictionary, @"browser",
                                    encodedWindows, @"windows", nil];
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
        _client.iconURL = [NSURL URLWithString:@"http://apiv0.tabulatabs.com/icons/iPad.png"];
    } else {
        _client.iconURL = [NSURL URLWithString:@"http://apiv0.tabulatabs.com/icons/iPhone.png"];
    }
    
    [_client claimClient:claimingPassword finalPassword:[TTClient generatePassword] callback:^(BOOL success, id response) {
        if (success) {
            [self loadBrowserCompletion:^(id response) {
                 [appDelegate.browserController addBrowser:self];
            }];
            [self loadWindowsAndTabs];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationClientWasUpdatedNotification object:self];
#if CONFIGURATION_AdHoc
            [TestFlight passCheckpoint:@"registered a client"];
#endif
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not add browser", @"Alert View Title")
                                                                message:NSLocalizedString(@"browser_could_not_be_added", @"Alert view message")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"Alert view - okay")
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
    TTBrowser *browser = [[TTBrowser alloc] initWithEncryption:self.client.encryption];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserDataIsCorrupt:)
                                                 name:TTBrowserCorruptDataNotification
                                               object:browser];

    [browser load:self.client.username password:self.client.password callback:^(id response) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:TTBrowserCorruptDataNotification
                                                      object:browser];
        
        self.browser = browser;
        [self saveToDisk];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserRepresentationBrowserWasUpdatedNotification
                                                            object:self
                                                          userInfo:nil];
        if (callback) {
            callback(response);
        }
    }];    
}

- (void)loadWindowsAndTabs;
{
    [self.client loadWindowsAndTabs:^(NSArray *loadedWindows, id response) {
        self.windows = loadedWindows;
        
        [self saveToDisk];
    }];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0) {
        [appDelegate handleInternalURL:[NSURL firstBrowserURL]];
    }
}

#pragma mark Helpers

- (void)browserDataIsCorrupt:(NSNotification *)notifcation;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:TTBrowserCorruptDataNotification 
                                                  object:notifcation.object];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Browser_data_corrput_title", nil)
                                                        message:NSLocalizedString(@"Browser_data_corrupt_message", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
}

@end
