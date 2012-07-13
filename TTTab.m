//
//  TTTab.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+TabulaTabs.h"
#import "NSURL+GenerousURLConvertion.h"

#import "TTTab.h"

/*
 this.pageTitle = data.pageTitle;
 this.shortDomain = data.shortDomain;
 this.siteTitle = data.siteTitle;
 this.pageThumbnail = data.pageThumbnail;
*/

@implementation TTTab

@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize URL = _URL;
@synthesize selected = _selected;
@synthesize favIconURL = _favIconURL;
@synthesize windowId = _windowId;
@synthesize windowFocused = _windowFocused;
@synthesize index = _index;
@synthesize colorPalette = _colorPalette;
@synthesize pageTitle = _pageTitle;
@synthesize shortDomain = _shortDomain;
@synthesize siteTitle = _siteTitle;
@synthesize pageThumbnailURL = _pageThumbnailURL;

@synthesize dictionary = _dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;
{
    self = [super init];
    
    if (self) {
        self.identifier = [dictionary objectForKey:@"identifier"];
        self.title = [dictionary objectForKey:@"title"];
        
        self.URL = [NSURL URLWithFaultyString:[dictionary objectForKey:@"URL"]];
        
        if (!self.URL) {
            NSLog(@"could not parse URL: %@", [dictionary objectForKey:@"URL"]);
            return nil;
        }

        self.selected = [[dictionary objectForKey:@"selected"] boolValue];
        self.favIconURL = [NSURL URLWithString:[dictionary objectForKey:@"favIconURL"]];
        
        id windowId = [dictionary objectForKey:@"windowId"];
        if ([windowId isKindOfClass:[NSString class]]) {
            self.windowId = [dictionary objectForKey:@"windowId"];
        } else if ([windowId respondsToSelector:@selector(stringValue)]) {
            self.windowId = [windowId stringValue];
        } else if (windowId == nil) {
            self.windowId = nil;
        } else {
            NSAssert(NO, @"Dont know how to handle this windowId");
        }
        
        if ([[dictionary objectForKey:@"windowFocused"] respondsToSelector:@selector(boolValue)]) {
            self.windowFocused = [[dictionary objectForKey:@"windowFocused"] boolValue];
        } else {
            self.windowFocused = NO;
        }
        
        self.index = [[dictionary objectForKey:@"index"] integerValue];
        self.pageTitle = [dictionary objectForKey:@"pageTitle"];
        self.shortDomain = [dictionary objectForKey:@"shortDomain"];
        self.siteTitle = [dictionary objectForKey:@"siteTitle"];
        if (![[dictionary objectForKey:@"pageThumbnail"] isEqualToString:@""])
            self.pageThumbnailURL = [NSURL URLWithString:[dictionary objectForKey:@"pageThumbnail"]];
        
        if ([self.pageTitle isEqualToString:@""]) {
            self.pageTitle = nil;
        }
        if ([self.siteTitle isEqualToString:@""]) {
            self.siteTitle = nil;
        }
        if ([self.shortDomain isEqualToString:@""]) {
            self.shortDomain = nil;
        }
        
        NSArray *rawColorPalette = [dictionary objectForKey:@"colorPalette"];
        self.colorPalette = @[];

        if ([rawColorPalette isKindOfClass:[NSArray class]]) {
            [rawColorPalette enumerateObjectsUsingBlock:^(NSArray *rawColor, NSUInteger idx, BOOL *stop) {
                UIColor *color = [UIColor colorWithArrayOfValues:rawColor];
                if (color) {
                    self.colorPalette = [self.colorPalette arrayByAddingObject:color];
                }
            }];
        }
    }
    
    return self;
}

- (BOOL)isEqual:(TTTab *)otherTab;
{
    if (![otherTab isKindOfClass:[TTTab class]]) {
        return NO;
    } else {
        if (self.index != otherTab.index) {
            return NO;
        }
        
        if (![self.identifier isEqualToString:otherTab.identifier]) {
            return NO;
        }
        
        if (![self.URL.absoluteString isEqualToString:otherTab.URL.absoluteString]) {
            return NO;
        }
        
        if (!([self.favIconURL.absoluteString isEqualToString:otherTab.favIconURL.absoluteString]
              || (self.favIconURL == nil && otherTab.favIconURL == nil))) {
            return NO;
        }
        
        if (![self.windowId isEqualToString:otherTab.windowId]) {
            return NO;
        }
        
        if ([self.title compare:otherTab.title] != NSOrderedSame) {
            return NO;
        }
        
        if ([self.pageTitle compare:otherTab.pageTitle] != NSOrderedSame) {
            return NO;
        }
        
        if ([self.shortDomain compare:otherTab.shortDomain] != NSOrderedSame) {
            return NO;
        }
        
        if ([self.siteTitle compare:otherTab.siteTitle] != NSOrderedSame) {
            return NO;
        }
        
        if (!([self.pageThumbnailURL.absoluteString isEqualToString:otherTab.pageThumbnailURL.absoluteString]
              || (self.pageThumbnailURL == nil && otherTab.pageThumbnailURL == nil))) {
            return NO;
        }

        return YES;
    }
}


#pragma mark Accessors

- (NSDictionary *)dictionary;
{
    NSMutableArray *colorPalette = [NSMutableArray arrayWithCapacity:self.colorPalette.count];
    [self.colorPalette enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
        [colorPalette addObject:[color arrayOfValues]];
    }];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.identifier)
        [dict setObject:self.identifier forKey:@"identifier"];
    if (self.title)
        [dict setObject:self.title forKey:@"title"];
    [dict setObject:self.URL.absoluteString forKey:@"URL"];
    [dict setObject:@(self.selected) forKey:@"selected"];
    if (self.favIconURL)
        [dict setObject:self.favIconURL.absoluteString forKey:@"favIconURL"];
    if (self.windowId)
        [dict setObject:self.windowId forKey:@"windowId"];
    [dict setObject:@(self.windowFocused) forKey:@"windowFocused"];
    [dict setObject:@(self.index) forKey:@"index"];
    [dict setObject:colorPalette forKey:@"colorPalette"];
    if (self.pageTitle)
        [dict setObject:self.pageTitle forKey:@"pageTitle"];
    if (self.shortDomain)
        [dict setObject:self.shortDomain forKey:@"shortDomain"];
    if (self.siteTitle)
        [dict setObject:self.siteTitle forKey:@"siteTitle"];
    if (self.pageThumbnailURL)
        [dict setObject:self.pageThumbnailURL.absoluteString forKey:@"pageThumbnail"];
     
    return [dict copy];
}

@end
