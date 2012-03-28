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

+ (UIColor *)defaultPageColor;
{
    return [UIColor grayColor];
}

@end
