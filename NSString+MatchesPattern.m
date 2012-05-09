//
//  NSString+MatchesPattern.m
//  SpaceTime
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 nxtbgthng. All rights reserved.
//

#import "NSString+MatchesPattern.h"

@implementation NSString (MatchesPattern)

- (NSInteger)numberOfMatchesWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;
{
    NSError* error;
    NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
    
    if (error) {
        NSLog(@"invalid pattern '%@': %@", pattern, error);
    }
    
    return [regularExpression numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)];
}

- (NSString *)replacePattern:(NSString *)pattern options:(NSRegularExpressionOptions)options withTemplate:(NSString *)template;
{
    NSError* error;
    NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
    
    if (error) {
        NSLog(@"invalid pattern '%@': %@", pattern, error);
    }
    
    NSMutableString *mutableSelf = [self mutableCopy];
    [regularExpression replaceMatchesInString:mutableSelf options:0 range:NSMakeRange(0, self.length) withTemplate:template];
    return [mutableSelf copy];
}

@end
