//
//  NSURL+GenerousURLConvertion.m
//  TabulaTabs
//
//  Created by Max Winde on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+MatchesPattern.h"

#import "NSURL+GenerousURLConvertion.h"

@implementation NSURL (GenerousURLConvertion)

+ (NSURL *)URLWithFaultyString:(NSString *)string;
{
    NSURL *URL = [NSURL URLWithString:string];
    
    if (URL) {
        return URL;
    }
    
    if ([string numberOfMatchesWithPattern:@"#" options:NSRegularExpressionCaseInsensitive] > 1) {
        NSRange firstHashRange = [string rangeOfString:@"#"];
        NSRange searchRange;
        searchRange.location = firstHashRange.location + firstHashRange.length;
        searchRange.length = string.length - searchRange.location;
        
        string = [string stringByReplacingOccurrencesOfString:@"#"
                                                   withString:@"%23"
                                                      options:0
                                                        range:searchRange];
    }
    
    return [NSURL URLWithString:string];
}

@end
