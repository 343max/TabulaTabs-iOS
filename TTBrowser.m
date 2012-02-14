//
//  TTBrowserController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTEncryption.h"
#import "TTBrowser.h"

@interface TTBrowser ()

@property (strong) TTEncryption *encryption;

@end


@implementation TTBrowser

@synthesize userAgent, label, description, iconURL;
@synthesize encryption;

- (id)initWithEncryption:(TTEncryption *)theEncryption;
{
    self = [super init];
    if (self) {
        self.encryption = theEncryption;
    }
    return self;
}

- (void)registerWithPassword:(NSString *)password callback:(void (^)(id response))callback;
{
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
                                           self.userAgent, @"useragent",
                                           self.label, @"label",
                                           self.description, @"description",
                                           self.iconURL.absoluteString, @"iconURL", nil];
    NSMutableDictionary *jsonParams = [[self.encryption encrypt:payload] mutableCopy];
    
    [jsonParams setObject:password forKey:@"password"];
    
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
    [self sendJsonGetRequest:@"browsers.json" callback:^(id response) {
        NSDictionary *payload = [self.encryption decrypt:response];
        
        self.description = [payload objectForKey:@"description"];
        self.iconURL = [NSURL URLWithString:[payload objectForKey:@"iconURL"]];
        self.label = [payload objectForKey:@"label"];
        self.userAgent = [payload objectForKey:@"useragent"];
        
        NSMutableDictionary *mutableResponse = [response mutableCopy];
        [mutableResponse setObject:payload forKey:@"payload"];
        callback([mutableResponse copy]);
    }];
}

@end
