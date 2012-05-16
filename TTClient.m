//
//  TTClient.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "NSData-hex.h"
#import "TTWindow.h"
#import "TTTab.h"

#import "TTClient.h"

@implementation TTClient

@synthesize userAgent = _userAgent;
@synthesize label = _label;
@synthesize clientDescription = _clientDescription;
@synthesize iconURL = _iconURL;
@synthesize keychainIdentifier = _keychainIdentifier;
@synthesize identifier = _identifier;

@synthesize unclaimed = _unclaimed;
@synthesize dictionary = _dictionary;

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

- (void)loadWindowsAndTabs:(void (^)(NSArray *, id))callback;
{
    [self sendJsonGetRequest:@"browsers/tabs.json" callback:^(id response) {
        NSMutableDictionary *windows = [[NSMutableDictionary alloc] init];
        
        [response enumerateObjectsUsingBlock:^(NSDictionary *encryptedTab, NSUInteger idx, BOOL *stop) {
            TTTab *tab = [[TTTab alloc] initWithDictionary:[self.encryption decrypt:encryptedTab]];
            
            if (!tab) {
                return;
            }
            
            tab.identifier = [encryptedTab objectForKey:@"identifier"];
            
            TTWindow *window = [windows objectForKey:tab.windowId];
            if (!window) {
                window = [[TTWindow alloc] init];
                window.identifier = tab.windowId;
                window.focused = tab.windowFocused;
                [windows setObject:window forKey:window.identifier];
            }
            window.tabs = [window.tabs arrayByAddingObject:tab];
        }];
        
        callback([windows allValues], response);
    }];
}

@end
