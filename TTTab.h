//
//  TTTab.h
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTTab : NSObject

@property (strong) NSString *identifier;
@property (strong) NSString *title;
@property (strong) NSURL *URL;
@property (assign) BOOL selected;
@property (strong) NSURL *favIconURL;
@property (strong) NSString *windowId;
@property (assign) NSInteger index;
@property (strong) NSArray *colorPalette;
@property (strong) NSString *pageTitle;
@property (strong) NSString *shortDomain;
@property (strong) NSString *siteTitle;
@property (strong) NSURL *pageThumbnailURL;

@property (strong, readonly) NSDictionary *dictionary;

- (id)initWithDictionary:(NSDictionary *)aDictionary;

@end
