//
//  TTClient.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTTab.h"

#import "TTClient.h"

@implementation TTClient

@synthesize userAgent, label, description, iconURL;
@synthesize dictionary;

- (id)initWithDictionary:(NSDictionary *)aDictionary;
{
    self = [super init];
    
    if (self) {
        self.userAgent = [aDictionary objectForKey:@"useragent"];
        self.label = [aDictionary objectForKey:@"label"];
        self.description = [aDictionary objectForKey:@"description"];
        self.iconURL = [NSURL URLWithString:[aDictionary objectForKey:@"iconURL"]];
    }
    
    return self;
}

- (NSDictionary *)dictionary;
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.userAgent, @"useragent",
            self.label, @"label",
            self.description, @"description",
            self.iconURL.absoluteString, @"iconURL",
            nil];
}

- (void)claimClient:(NSString *)claimingPassword finalPassword:(NSString *)finalPassword callback:(void (^)(id))callback;
{
    self.password = claimingPassword;
    
    NSMutableDictionary *params = [[self.encryption encrypt:self.dictionary] mutableCopy];
    [params setObject:finalPassword forKey:@"password"];
    
    [self sendJsonRequest:@"browsers/clients/claim.json" method:@"PUT" jsonParameters:params callback:^(id response) {
        if ([[response objectForKey:@"success"] boolValue]) {
            self.password = finalPassword;
        } else {
            self.password = nil;
        }
        
        callback(response);
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
