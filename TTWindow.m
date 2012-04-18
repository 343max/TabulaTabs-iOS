//
//  TTWindow.m
//  TabulaTabs
//
//  Created by Max Winde on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTWindow.h"

#import "TTTab.h"

@implementation TTWindow
@synthesize identifier = _identifier;
@synthesize focused = _focused;
@synthesize tabs = _tabs;

@synthesize dictionary = _dictionary;

- (id)init;
{
    self = [super init];
    
    if (self) {
        self.tabs = [NSArray array];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [self init];
    
    if (self) {
        self.identifier = [dictionary objectForKey:@"identifier"];
        self.focused = [[dictionary objectForKey:@"focused"] boolValue];
    }
    
    return self;
}

- (NSDictionary *)dictionary;
{
    NSMutableArray *tabs = [[NSMutableArray alloc] initWithCapacity:self.tabs.count];
    
    [self.tabs enumerateObjectsUsingBlock:^(TTTab *tab, NSUInteger idx, BOOL *stop) {
        [tabs addObject:tab.dictionary];
    }];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:self.identifier, @"identifier",
                                                      [NSNumber numberWithBool:self.focused], @"focused",
                                                      tabs, @"tabs",
                                                      nil];
}

@end
