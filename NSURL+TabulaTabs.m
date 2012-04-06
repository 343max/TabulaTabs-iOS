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

- (NSDictionary *)queryParamters;
{
    NSMutableDictionary *queryParameters = [[NSMutableDictionary alloc] init];
    
    [[self.query componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop) {
        NSArray *keyValue = [param componentsSeparatedByString:@"="];
        if (keyValue.count != 2) {
            return;
        }
        [queryParameters setObject:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
    }];
    
    return [queryParameters copy];
}

- (NSURL *)mapImageURLForSize:(CGSize)size scale:(CGFloat)scale;
{
    NSDictionary *params = [self queryParamters];
    
    NSString *center = [params objectForKey:@"ll"];
    if (center == nil) {
        center = [params objectForKey:@"sll"];
    }
    
    if (center == nil) {
        return nil;
    }
    
    NSString *zoom = @"13";
    
    if (scale == 0) {
        scale = [UIScreen mainScreen].scale;
    }
    
    NSString *mapsImageURLString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%@&zoom=%@&size=%ix%i&sensor=false&scale=%i", center, zoom, (int)roundf(size.width), (int)roundf(size.height), (int)scale];
    
    return [NSURL URLWithString:mapsImageURLString];
}

@end
