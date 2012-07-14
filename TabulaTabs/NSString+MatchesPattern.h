//
//  NSString+MatchesPattern.h
//  SpaceTime
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 nxtbgthng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MatchesPattern)

- (NSInteger)numberOfMatchesWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
- (NSString *)replacePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)template;

@end
