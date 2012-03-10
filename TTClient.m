//
//  TTClient.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "NSData-hex.h"
#import "TTTab.h"

#import "TTClient.h"

@implementation TTClient

@synthesize userAgent, label, clientDescription, iconURL, keychainIdentifier;
@synthesize dictionary;

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

- (id)initWithDictionary:(NSDictionary *)aDictionary;
{
    self = [super init];
    
    if (self) {
        self.dictionary = aDictionary;
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
}

- (NSDictionary *)dictionary;
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.userAgent) [dict setObject:self.userAgent forKey:@"useragent"];
    if (self.label) [dict setObject:self.label forKey:@"label"];
    if (self.clientDescription) [dict setObject:self.clientDescription forKey:@"description"];
    if (self.iconURL) [dict setObject:self.iconURL.absoluteString forKey:@"iconURL"];
    if (self.username) [dict setObject:self.username forKey:@"username"];
    
    return [dict copy];
}

- (void)claimClient:(NSString *)claimingPassword finalPassword:(NSString *)finalPassword callback:(void (^)(BOOL success, id response))callback;
{
    self.password = claimingPassword;
    
    NSMutableDictionary *params = [[self.encryption encrypt:self.dictionary] mutableCopy];
    [params setObject:finalPassword forKey:@"password"];
    
    [self sendJsonRequest:@"browsers/clients/claim.json" method:@"PUT" jsonParameters:params callback:^(id response) {
        NSLog(@"response: %@", response);
        BOOL success = [[response objectForKey:@"success"] boolValue];
        if (success) {
            self.password = finalPassword;
        } else {
            self.password = nil;
        }
        
        callback(success, response);
    }];
}

- (void)loadTabs:(void (^)(NSArray *, id))callback;
{
    [self sendJsonGetRequest:@"browsers/tabs.json" callback:^(id response) {
        NSMutableArray *tabs = [[NSMutableArray alloc] initWithCapacity:[response count]];
        
        [response enumerateObjectsUsingBlock:^(NSDictionary *encryptedTab, NSUInteger idx, BOOL *stop) {
            TTTab *tab = [[TTTab alloc] initWithDictionary:[self.encryption decrypt:encryptedTab]];
            tab.identifier = [encryptedTab objectForKey:@"identifier"];
            [tabs addObject:tab];
        }];
        
        callback([tabs copy], response);
    }];
}

@end
