//
//  TTClient.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTClient.h"

@implementation TTClient

@synthesize claimingPassword;
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


#pragma mark Accessors

- (NSDictionary *)dictionary;
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.userAgent, @"useragent",
            self.label, @"label",
            self.description, @"description",
            self.iconURL.absoluteString, @"iconURL",
            nil];
}


- (void)create:(NSString *)username password:(NSString *)password claimngPassword:(NSString *)claimingPassword callback:(void (^)(id))callback;
{
}

@end
