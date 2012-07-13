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
        self.tabs = @[];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [self init];
    
    if (self) {
        self.identifier = [dictionary objectForKey:@"identifier"];
        self.focused = [[dictionary objectForKey:@"focused"] boolValue];
        _tabs = [[NSArray alloc] init];
        
        NSArray *tabDicts = [dictionary objectForKey:@"tabs"];
        
        [tabDicts enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
            _tabs = [_tabs arrayByAddingObject:[[TTTab alloc] initWithDictionary:dictionary]];
        }];
    }
    
    return self;
}

- (BOOL)isEqual:(TTWindow *)object;
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    } else {
        return [self.identifier isEqualToString:object.identifier];
    }
}

- (NSDictionary *)dictionary;
{
    NSMutableArray *tabs = [[NSMutableArray alloc] initWithCapacity:self.tabs.count];
    
    [self.tabs enumerateObjectsUsingBlock:^(TTTab *tab, NSUInteger idx, BOOL *stop) {
        [tabs addObject:tab.dictionary];
    }];
    
    return @{@"identifier": self.identifier,
                                                      @"focused": @(self.focused),
                                                      @"tabs": tabs};
}

@end
