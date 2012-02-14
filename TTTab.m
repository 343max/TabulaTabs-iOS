//
//  TTTab.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTTab.h"

@implementation TTTab

@synthesize identifier, title, URL, selected, favIconURL, windowId, index, pageColors;
@synthesize dictionary;

- (id)initWithDictionary:(NSDictionary *)aDictionary;
{
    self = [super init];
    
    if (self) {
        self.title = [aDictionary objectForKey:@"title"];
        self.URL = [NSURL URLWithString:[aDictionary objectForKey:@"URL"]];
        self.selected = [[aDictionary objectForKey:@"selected"] boolValue];
        self.favIconURL = [NSURL URLWithString:[aDictionary objectForKey:@"favIconURL"]];
        self.windowId = [aDictionary objectForKey:@"windowId"];
        self.index = [[aDictionary objectForKey:@"index"] integerValue];
#warning todo pageColors missing
    }
    
    return self;
}


#pragma mark Accessors

- (NSDictionary *)dictionary;
{
#warning todo pageColors missing
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.title, @"title",
            self.URL.absoluteString, @"URL",
            [NSNumber numberWithBool:self.selected], @"selected",
            self.favIconURL.absoluteString, @"favIconURL",
            self.windowId, @"windowId",
            [NSNumber numberWithInteger:self.index], @"index",
            nil];
}

@end
