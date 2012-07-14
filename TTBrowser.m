//
//  TTBrowserController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData-hex.h"

#import "TTEncryption.h"
#import "TTBrowser.h"
#import "TTTab.h"

NSString * const TTBrowserCorruptDataNotification = @"TTBrowserCorruptDataNotification";

@implementation TTBrowser

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    
    if (self) {
        self.identifier = [[dictionary objectForKey:@"identifier"] integerValue];
        self.userAgent = [dictionary objectForKey:@"userAgent"];
        self.label = [dictionary objectForKey:@"label"];
        self.browserDescription = [dictionary objectForKey:@"browserDescription"];
        self.iconURL = [NSURL URLWithString:[dictionary objectForKey:@"iconURL"]];
    }
    
    return self;
}

- (NSDictionary *)dictionary;
{
    return @{@"identifier": @(self.identifier),
            @"userAgent": self.userAgent,
            @"label": self.label,
            @"browserDescription": self.browserDescription,
            @"iconURL": self.iconURL.absoluteString};
}

+ (NSURL *)registrationURLForUsername:(NSString *)username claimingPassword:(NSString *)claimingPassword encryptionKey:(NSData *)encryptionKey;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"tabulatabs://client/claim/%@/%@/%@", 
                                 username, claimingPassword, encryptionKey.hexString]];
}

- (void)registerWithPassword:(NSString *)password callback:(void (^)(id response))callback;
{
    NSDictionary *payload = @{@"label": self.label,
                                           @"description": self.browserDescription,
                                           @"iconURL": self.iconURL.absoluteString};
    NSMutableDictionary *jsonParams = [[self.encryption encrypt:payload] mutableCopy];
    
    [jsonParams setObject:password forKey:@"password"];
    [jsonParams setObject:self.userAgent forKey:@"useragent"];
    
    [self sendJsonRequest:@"browsers.json" method:@"POST" jsonParameters:jsonParams callback:^(NSDictionary* response) {
        NSNumber *identifier = [response objectForKey:@"id"];
        self.identifier = [identifier integerValue];
        
        self.username = [response objectForKey:@"username"];
        self.password = password;
        callback(response);
    }];
}

- (void)load:(void (^)(id))callback;
{
    [self load:self.username password:self.password callback:callback];
}

- (void)load:(NSString *)username password:(NSString *)password callback:(void (^)(id))callback;
{
    self.username = username;
    self.password = password;
    
    [self sendJsonGetRequest:@"browsers.json" callback:^(NSDictionary *response) {
        NSDictionary *payload = [self.encryption decrypt:response];
        
        if (!payload) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTBrowserCorruptDataNotification object:self];
        } else {
            NSNumber *identifier = [response objectForKey:@"id"];
            self.identifier = [identifier integerValue];
            self.browserDescription = [payload objectForKey:@"description"];
            self.iconURL = [NSURL URLWithString:[payload objectForKey:@"iconURL"]];
            self.label = [payload objectForKey:@"label"];
            self.userAgent = [response objectForKey:@"useragent"];
            
            NSMutableDictionary *mutableResponse = [response mutableCopy];
            [mutableResponse setObject:payload forKey:@"payload"];
            callback([mutableResponse copy]);
        }
    }];
}

- (void)saveTabs:(NSArray *)tabs callback:(void (^)(BOOL success, id repsonse))callback;
{
    NSMutableArray *encryptedTabs = [[NSMutableArray alloc] initWithCapacity:tabs.count];
    
    [tabs enumerateObjectsUsingBlock:^(TTTab *tab, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *tabDict = [[self.encryption encrypt:[tab dictionary]] mutableCopy];
        [tabDict setObject:tab.identifier forKey:@"identifier"];
        [encryptedTabs addObject:tabDict];
    }];
    
    [self sendJsonRequest:@"browsers/tabs.json" method:@"POST" jsonParameters:[encryptedTabs copy] callback:^(id response) {
        BOOL success = [[response objectForKey:@"success"] boolValue];
        callback(success, response);
    }];
}

- (void)createClientWitClaimingPassword:(NSString *)claimingPassword callback:(void (^)(NSString *, id))callback;
{
    NSDictionary *params = @{@"password": claimingPassword};
    
    [self sendJsonRequest:@"browsers/clients.json" method:@"POST" jsonParameters:params callback:^(id response) {
        callback([response objectForKey:@"username"], response);
    }];
}

@end
