//
//  TTBrowserRepresentations.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData-hex.h"
#import "SSKeychain.h"
#import "TestFlight.h"

#import "TTAppDelegate.h"

#import "TTBrowserController.h"

NSString * const TTBrowserControllerPasswordKey = @"ClientPassword";
NSString * const TTBrowserControllerEncryptionKeyKey = @"ClientEncryptionKey";


@interface TTBrowserController ()

@property (strong, nonatomic) NSArray *allBrowsers;

@end


@implementation TTBrowserController

@synthesize currentBrowser = _currentBrowser;
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
        [TestFlight passCheckpoint:@"Tried to register a browser twice"];
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
    
    NSMutableArray *mutableBrowsers = [[NSMutableArray alloc] initWithArray:self.allBrowsers];
    [mutableBrowsers removeObject:browserRepresentation];
    self.allBrowsers = [mutableBrowsers copy];
    
    return YES;
}

#pragma mark Accessors

- (void)setAllBrowsers:(NSArray *)allBrowsers;
{
    _allBrowsers = allBrowsers;
    
    NSMutableArray *clientDictionaries = [NSMutableArray arrayWithCapacity:_allBrowsers.count];
    [_allBrowsers enumerateObjectsUsingBlock:^(TTBrowserRepresentation *browser, NSUInteger idx, BOOL *stop) {
        TTClient *client = browser.client;
        [clientDictionaries addObject:client.dictionary];
        
        [SSKeychain setPassword:client.password forService:TTBrowserControllerPasswordKey account:client.username];
        [SSKeychain setPassword:client.encryption.encryptionKey.hexString
                     forService:TTBrowserControllerEncryptionKeyKey 
                        account:client.username];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:[clientDictionaries copy] forKey:@"clients"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCurrentBrowser:(TTBrowserRepresentation *)currentBrowser;
{
    _currentBrowser = currentBrowser;
    
    appDelegate.currentURL = currentBrowser.tabulatabsURL;
}

@end
