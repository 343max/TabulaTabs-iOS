//
//  NSURL+TabulaTabs.h
//  TabulaTabs
//
//  Created by Max Winde on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (TabulaTabs)

+ (NSURL *)tabulatabsURLWithString:(NSString *)stringURL;
+ (NSURL *)addBrowserRepresentationFlowURL;
+ (NSURL *)firstBrowserURL;
+ (NSURL *)launchTabulatabsURL;

- (NSURL *)buildalizedURL;
- (NSDictionary *)queryParamters;
- (NSURL *)mapImageURLForSize:(CGSize)size scale:(CGFloat)scale;

@end
