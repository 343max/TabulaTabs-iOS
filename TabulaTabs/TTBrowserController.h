//
//  TTBrowserRepresentations.h
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTBrowserRepresentation.h"

#import <UIKit/UIKit.h>

@interface TTBrowserController : NSObject

@property (strong, nonatomic) NSArray *allBrowsers;

- (id)initWithClientDictionaries:(NSArray *)clientDictionaries;

- (TTBrowserRepresentation *)browserWithClientIdentifier:(NSString *)identifier;

@end
