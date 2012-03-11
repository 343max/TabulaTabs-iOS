//
//  TTBrowserController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTEncryption.h"
#import "TTBrowser.h"
#import "TTTab.h"

@implementation TTBrowser

@synthesize userAgent, label, browserDescription, iconURL;

- (void)registerWithPassword:(NSString *)password callback:(void (^)(id response))callback;
{
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
                                           self.label, @"label",
                                           self.browserDescription, @"description",
                                           self.iconURL.absoluteString, @"iconURL", nil];
    NSMutableDictionary *jsonParams = [[self.encryption encrypt:payload] mutableCopy];
    
    [jsonParams setObject:password forKey:@"password"];
    [jsonParams setObject:self.userAgent forKey:@"useragent"];
    
    [self sendJsonRequest:@"browsers.json" method:@"POST" jsonParameters:jsonParams callback:^(NSDictionary* response) {
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
    
    [self sendJsonGetRequest:@"browsers.json" callback:^(id response) {
        NSDictionary *payload = [self.encryption decrypt:response];
        
        self.browserDescription = [payload objectForKey:@"description"];
        self.iconURL = [NSURL URLWithString:[payload objectForKey:@"iconURL"]];
        self.label = [payload objectForKey:@"label"];
        self.userAgent = [response objectForKey:@"useragent"];
        
        NSMutableDictionary *mutableResponse = [response mutableCopy];
        [mutableResponse setObject:payload forKey:@"payload"];
        callback([mutableResponse copy]);
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

- (void)createClient:(NSString *)claimingPassword callback:(void (^)(NSString *, id))callback;
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:claimingPassword forKey:@"password"];
    
    [self sendJsonRequest:@"browsers/clients.json" method:@"POST" jsonParameters:params callback:^(id response) {
        callback([response objectForKey:@"username"], response);
    }];
}

@end
