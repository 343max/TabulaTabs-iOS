//
//  NSURL+TabulaTabs.m
//  TabulaTabs
//
//  Created by Max Winde on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTAppDelegate.h"

#import "NSURL+TabulaTabs.h"

@implementation NSURL (TabulaTabs)

+ (NSURL *)tabulatabsURLWithString:(NSString *)stringURL;
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", appDelegate.URLScheme, stringURL]];
}

- (NSURL *)buildalizedURL;
{
    if (![self.scheme isEqualToString:@"tabulatabs"]) {
        return [self copy];
    } else {
        NSURL *newURL = [[NSURL alloc] initWithScheme:appDelegate.URLScheme host:self.host path:self.path];
        return newURL;
    }
}

@end
