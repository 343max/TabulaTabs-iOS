//
//  TTReadabilityDomainsController.m
//  TabulaTabs
//
//  Created by Max Winde on 21.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTReadabilityDomainsController.h"

@interface TTReadabilityDomainsController ()

@property (strong) NSMutableSet *readabilityDomains;

@end


@implementation TTReadabilityDomainsController

@synthesize readabilityDomains = _readabilityDomains;

- (id)init;
{
    self = [super init];
    
    if (self) {
        NSArray *savedReadabilityDomains = [[NSUserDefaults standardUserDefaults] objectForKey:@"readabilityDomains"];
        
        if ([savedReadabilityDomains isKindOfClass:[NSArray class]]) {
            self.readabilityDomains = [[NSMutableSet alloc] initWithArray:savedReadabilityDomains];
        } else {
            self.readabilityDomains = [[NSMutableSet alloc] init];
        }
    }
    
    return self;
}

- (BOOL)isInReadabilityMode:(NSURL *)URL;
{
    return [self.readabilityDomains containsObject:URL.host];
}

- (void)setReadabilityMode:(BOOL)readabilityMode forURL:(NSURL *)URL;
{
    if (!URL) {
        return;
    }
    
    if ([self isInReadabilityMode:URL] == readabilityMode) {
        return;
    }
    
    if (readabilityMode) {
        [self.readabilityDomains addObject:URL.host];
    } else {
        [self.readabilityDomains removeObject:URL.host];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[self.readabilityDomains allObjects] forKey:@"readabilityDomains"];
    [userDefaults synchronize];
}

@end
