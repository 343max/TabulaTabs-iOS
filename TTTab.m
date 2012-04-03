//
//  TTTab.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+TabulaTabs.h"

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
        self.title = [dictionary objectForKey:@"title"];
        self.URL = [NSURL URLWithString:[dictionary objectForKey:@"URL"]];
        self.selected = [[dictionary objectForKey:@"selected"] boolValue];
        self.favIconURL = [NSURL URLWithString:[dictionary objectForKey:@"favIconURL"]];
        self.windowId = [dictionary objectForKey:@"windowId"];
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
        if ([rawColorPalette isKindOfClass:[NSArray class]]) {
            self.colorPalette = [NSArray array];
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
        return [self.URL.absoluteString isEqualToString:otherTab.URL.absoluteString];
    }
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
