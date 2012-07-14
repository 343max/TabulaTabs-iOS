//
//  TTClient.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "NSData-hex.h"
#import "MWURLConnection.h"
#import "TTWindow.h"
#import "TTTab.h"

#import "TTClient.h"

NSString * const TTClientCorruptDataNotification = @"TTClientCorruptDataNotification";

@implementation TTClient

const int kPasswordByteLength = 16;

+ (NSString *)generatePassword;
{
	uint8_t * symmetricKey = NULL;
    symmetricKey = malloc(kPasswordByteLength * sizeof(uint8_t));
	memset((void *)symmetricKey, 0x0, kPasswordByteLength);	

	OSStatus sanityCheck = noErr;
	sanityCheck = SecRandomCopyBytes(kSecRandomDefault, kPasswordByteLength, symmetricKey);
	NSAssert(sanityCheck == noErr, @"Problem generating the symmetric key, OSStatus == %d.", sanityCheck);
    
    NSData *data = [[NSData alloc] initWithBytes:(const void *)symmetricKey length:kPasswordByteLength];
    return [data hexString];
}

- (id)init;
{
    self = [super init];
    
    if (self) {
        _unclaimed = YES;
    }
    
    return self;
}

- (id)initWithEncryption:(TTEncryption *)encryption;
{
    self = [super initWithEncryption:encryption];
    
    if (self) {
        _unclaimed = YES;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary;
{
    self = [self init];
    
    if (self) {
        self.dictionary = aDictionary;
        _unclaimed = NO;
    }
    
    return self;
}

- (void)setDictionary:(NSDictionary *)aDictionary;
{
    self.userAgent = [aDictionary objectForKey:@"useragent"];
    self.label = [aDictionary objectForKey:@"label"];
    self.clientDescription = [aDictionary objectForKey:@"description"];
    self.iconURL = [NSURL URLWithString:[aDictionary objectForKey:@"iconURL"]];
    self.username = [aDictionary objectForKey:@"username"];
    self.identifier = [aDictionary objectForKey:@"identifier"];
}

- (NSDictionary *)dictionary;
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.userAgent) [dict setObject:self.userAgent forKey:@"useragent"];
    if (self.label) [dict setObject:self.label forKey:@"label"];
    if (self.clientDescription) [dict setObject:self.clientDescription forKey:@"description"];
    if (self.iconURL) [dict setObject:self.iconURL.absoluteString forKey:@"iconURL"];
    if (self.username) [dict setObject:self.username forKey:@"username"];
    if (self.identifier) [dict setObject:self.identifier forKey:@"identifier"];
    
    return [dict copy];
}

- (void)claimClient:(NSString *)claimingPassword finalPassword:(NSString *)finalPassword callback:(void (^)(BOOL success, id response))callback;
{
    self.password = claimingPassword;
    
    NSMutableDictionary *params = [[self.encryption encrypt:self.dictionary] mutableCopy];
    [params setObject:finalPassword forKey:@"password"];
    [params setObject:self.userAgent forKey:@"useragent"];
    
    [self setConnectionDidReceiveAuthentificationChallenge:^(NSURLAuthenticationChallenge *challenge) {
        callback(NO, nil);
    }];
    
    [self sendJsonRequest:@"browsers/clients/claim.json" method:@"PUT" jsonParameters:params callback:^(id response) {
        NSLog(@"response: %@", response);
        BOOL success = [[response objectForKey:@"success"] boolValue];
        if (success) {
            _unclaimed = NO;
            self.password = finalPassword;
            
            id identifier = [response objectForKey:@"id"];
            if ([identifier isKindOfClass:[NSString class]]) {
                self.identifier = identifier;
            } else if([identifier respondsToSelector:@selector(stringValue)]) {
                self.identifier = [identifier stringValue];
            }
        } else {
            self.password = nil;
        }
        
        callback(success, response);
    }];
}

+ (NSArray *)decryptWindowsAndTabs:(id)response encryption:(TTEncryption *)encryption;
{
    NSMutableDictionary *windows = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *encryptedTab in response) {
        NSDictionary *decryptedTabData = [encryption decrypt:encryptedTab];
        
        if (decryptedTabData == nil) {
            return nil;
        }
        
        TTTab *tab = [[TTTab alloc] initWithDictionary:decryptedTabData];
        
        if (tab == nil) {
            continue;
        }
        
        tab.identifier = [encryptedTab objectForKey:@"identifier"];
        
        TTWindow *window = [windows objectForKey:tab.windowId];
        if (window == nil) {
            window = [[TTWindow alloc] init];
            window.identifier = tab.windowId;
            window.focused = tab.windowFocused;
            [windows setObject:window forKey:window.identifier];
        }
        window.tabs = [window.tabs arrayByAddingObject:tab];
    }

    return [windows allValues];
}

- (void)loadWindowsAndTabs:(void (^)(NSArray *, id))callback;
{
    [self sendJsonGetRequest:@"browsers/tabs.json?client_version=2" callback:^(id response) {
        NSArray *windows = [TTClient decryptWindowsAndTabs:response encryption:self.encryption];
        
        if (windows == nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTClientCorruptDataNotification object:self];
        } else {
            callback(windows, response);            
        }
    }];
}

- (void)destroy:(void (^)(BOOL, id))callback;
{
    NSString *identifier = self.identifier;
    if (identifier == nil) {
        identifier = @"0";
    }
    
    MWURLConnection *connection = [self prepareJsonConnection:[NSString stringWithFormat:@"browsers/clients/%@.json", identifier]
                                                                        method:@"DELETE"
                                                                jsonParameters:nil callback:^(id response) {
                                                                    NSLog(@"response: %@", response);
                                                                    BOOL success = [[response objectForKey:@"success"] boolValue];
                                                                    callback(success, response);
                                                                }];
    
    [connection setConnectionDidReceiveAuthentificationChallenge:^(NSURLAuthenticationChallenge *challenge) {
        callback(NO, nil);
    }];
    
    [connection setConnectionDidFailWithErrorBlock:^(NSError *error) {
        callback(NO, error);
    }];
    
    [connection start];
}

@end


















