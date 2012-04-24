//
//  TTBrowserRepresentations.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData-hex.h"
#import "SSKeychain.h"

#if CONFIGURATION_AdHoc
#import "TestFlight.h"
#endif

#import "NSURL+TabulaTabs.h"

#import "TTAppDelegate.h"

#import "TTBrowserController.h"

NSString * const TTBrowserControllerPasswordKey = @"ClientPassword";
NSString * const TTBrowserControllerEncryptionKeyKey = @"ClientEncryptionKey";

NSString * const TTBrowserControllerBrowserWillBeRemovedNotification = @"TTBrowserControllerBrowserWillBeRemovedNotification";


@interface TTBrowserController ()

@property (strong, nonatomic) NSArray *allBrowsers;

- (void)clientHasInvalidCredentials:(NSNotification *)notifcation;

@end


@implementation TTBrowserController

@synthesize allBrowsers = _allBrowsers;

- (id)initWithClientDictionaries:(NSArray *)clientDictionaries;
{
    self = [super init];
    
    if (self) {
        NSMutableArray *restoredBrowsers = [NSMutableArray arrayWithCapacity:clientDictionaries.count];
        
        [clientDictionaries enumerateObjectsUsingBlock:^(NSDictionary *clientDictionary, NSUInteger idx, BOOL *stop) {
            TTClient *client = [[TTClient alloc] initWithDictionary:clientDictionary];
            client.password = [SSKeychain passwordForService:TTBrowserControllerPasswordKey account:client.username];
            NSData *encryptionKey = [NSData dataWithHexString:[SSKeychain passwordForService:TTBrowserControllerEncryptionKeyKey 
                                                                                     account:client.username]];
            client.encryption = [[TTEncryption alloc] initWithEncryptionKey:encryptionKey];
            
            TTBrowserRepresentation *browserRepresentation = [[TTBrowserRepresentation alloc] init];
            browserRepresentation.client = client;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(clientHasInvalidCredentials:)
                                                         name:TTBrowserRepresentationClientAccessWasRevokedNotification
                                                       object:browserRepresentation];
            [restoredBrowsers addObject:browserRepresentation];
        }];
        
        _allBrowsers = [restoredBrowsers copy];
    }
    
    return self;
}

- (TTBrowserRepresentation *)browserWithClientIdentifier:(NSString *)clientIdentifier;
{
    __block TTBrowserRepresentation *matchingBrowser;
    
    [self.allBrowsers enumerateObjectsUsingBlock:^(TTBrowserRepresentation *browser, NSUInteger idx, BOOL *stop) {
        if ([browser.client.username isEqualToString:clientIdentifier]) {
            matchingBrowser = browser;
            *stop = YES;
        }
    }];
    
    return matchingBrowser;
}

- (TTBrowserRepresentation *)browserWithBrowserIdentifier:(NSInteger)identifier;
{
    __block TTBrowserRepresentation *matchingBrowser;
    
    [self.allBrowsers enumerateObjectsUsingBlock:^(TTBrowserRepresentation *browser, NSUInteger idx, BOOL *stop) {
        if (browser.browser.identifier == identifier) {
            matchingBrowser = browser;
            *stop = YES;
        }
    }];
    
    return matchingBrowser;
}

- (void)addBrowser:(TTBrowserRepresentation *)browserReprensentation;
{
    TTBrowserRepresentation *existingBrowser = [self browserWithBrowserIdentifier:browserReprensentation.browser.identifier];
    if (existingBrowser != nil) {
#if CONFIGURATION_AdHoc
        [TestFlight passCheckpoint:@"Tried to register a browser twice"];
#endif
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Browser is allready there"
                                                        message:@"This browser is allready in your browser list, you don't need to add it twice."
                                                       delegate:nil cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        self.allBrowsers = [self.allBrowsers arrayByAddingObject:browserReprensentation];
    }
}

- (BOOL)removeBrowser:(TTBrowserRepresentation *)browserRepresentation;
{
    if (![self.allBrowsers containsObject:browserRepresentation]) {
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserControllerBrowserWillBeRemovedNotification
                                                        object:browserRepresentation];
    
    NSMutableArray *mutableBrowsers = [[NSMutableArray alloc] initWithArray:self.allBrowsers];
    [mutableBrowsers removeObject:browserRepresentation];
    self.allBrowsers = [mutableBrowsers copy];
    
    return YES;
}

#pragma mark Accessors

- (void)setAllBrowsers:(NSArray *)allBrowsers;
{
    [[NSNotificationCenter defaultCenter] removeObserver:TTBrowserRepresentationClientAccessWasRevokedNotification];
    
    _allBrowsers = allBrowsers;
    
    NSMutableArray *clientDictionaries = [NSMutableArray arrayWithCapacity:_allBrowsers.count];
    [_allBrowsers enumerateObjectsUsingBlock:^(TTBrowserRepresentation *browser, NSUInteger idx, BOOL *stop) {
        TTClient *client = browser.client;
        [clientDictionaries addObject:client.dictionary];
        
        [SSKeychain setPassword:client.password forService:TTBrowserControllerPasswordKey account:client.username];
        [SSKeychain setPassword:client.encryption.encryptionKey.hexString
                     forService:TTBrowserControllerEncryptionKeyKey 
                        account:client.username];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clientHasInvalidCredentials:)
                                                     name:TTBrowserRepresentationClientAccessWasRevokedNotification
                                                   object:browser];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:[clientDictionaries copy] forKey:@"clients"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Helpers

- (void)clientHasInvalidCredentials:(NSNotification *)notifcation;
{
    TTBrowserRepresentation *browser = notifcation.object;
    
    if (![self.allBrowsers containsObject:browser]) {
        return;
    }
    
    [self removeBrowser:browser];
        
    NSString *message = [NSString stringWithFormat:@"The synchronization of the browser \"%@\" to this client was canceled. The browser will be removed from this device. If you want to see the tabs of this browser here again you have to reestablish a connection in the settings.", browser.browser.label];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Synchronization canceled"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];

    [alert show];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (self.allBrowsers.count == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL addBrowserRepresentationFlowURL]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL firstBrowserURL]];
    }

}

@end
