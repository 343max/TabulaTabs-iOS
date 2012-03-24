//
//  TTTab.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
@synthesize pageColors = _pageColors;
@synthesize pageTitle = _pageTitle;
@synthesize shortDomain = _shortDomain;
@synthesize siteTitle = _siteTitle;
@synthesize pageThumbnailURL = _pageThumbnailURL;

@synthesize dictionary = _dictionary;

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
        if (![self.pageTitle isEqualToString:@""])
            self.pageTitle = [aDictionary objectForKey:@"pageTitle"];
        self.shortDomain = [aDictionary objectForKey:@"shortDomain"];
        self.siteTitle = [aDictionary objectForKey:@"siteTitle"];
        if (![[aDictionary objectForKey:@"pageThumbnail"] isEqualToString:@""])
            self.pageThumbnailURL = [NSURL URLWithString:[aDictionary objectForKey:@"pageThumbnail"]];
        
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
