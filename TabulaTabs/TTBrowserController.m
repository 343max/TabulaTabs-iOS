//
//  TTBrowserRepresentations.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData-hex.h"
#import "SSKeychain.h"

#import "TTBrowserController.h"

NSString * const TTBrowserControllerPasswordKey = @"ClientPassword";
NSString * const TTBrowserControllerEncryptionKeyKey = @"ClientEncryptionKey";

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
            [restoredBrowsers addObject:browserRepresentation];
        }];
        
        _allBrowsers = [restoredBrowsers copy];
    }
    
    return self;
}

- (TTBrowserRepresentation *)browserWithClientIdentifier:(NSString *)identifier;
{
    __block TTBrowserRepresentation *matchingBrowser;
    
    [self.allBrowsers enumerateObjectsUsingBlock:^(TTBrowserRepresentation *browser, NSUInteger idx, BOOL *stop) {
        if ([browser.client.username isEqualToString:identifier]) {
            matchingBrowser = browser;
            *stop = YES;
        }
    }];
    
    return matchingBrowser;
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

@end
