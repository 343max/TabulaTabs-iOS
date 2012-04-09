//
//  UIColor+ArrayOfColors.m
//  TabulaTabs
//
//  Created by Max Winde on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+TabulaTabs.h"

@implementation UIColor (TabulaTabs)

+ (UIColor *)colorWithArrayOfValues:(NSArray *)arrayOfValues;
{
    if (![arrayOfValues isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    if (arrayOfValues.count != 3) {
        return nil;
    }
    
    NSNumber *red = [arrayOfValues objectAtIndex:0];
    NSNumber *green = [arrayOfValues objectAtIndex:1];
    NSNumber *blue = [arrayOfValues objectAtIndex:2];
    
//    NSLog(@"r: %@ g: %@ b: %@", red, green, blue);
    
    UIColor *color = [UIColor colorWithRed:[red integerValue] / 255.0
                           green:[green integerValue] / 255.0
                            blue:[blue integerValue] / 255.0
                           alpha:1.0];
    
//    NSLog(@"color: %@", color);
    
    return color;
}

- (NSArray *)arrayOfValues;
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:red * 255.0],
            [NSNumber numberWithInt:green * 255.0],
            [NSNumber numberWithInt:blue * 255.0],
            nil];
}

+ (UIColor *)defaultPageColor;
{
    return [UIColor colorWithWhite:0.8 alpha:1.0];
}

@end
