//
//  TTReadabilityDomainsController.h
//  TabulaTabs
//
//  Created by Max Winde on 21.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTReadabilityDomainsController : NSObject

- (BOOL)isInReadabilityMode:(NSURL *)URL;
- (void)setReadabilityMode:(BOOL)readabilityMode forURL:(NSURL *)URL;

@end
