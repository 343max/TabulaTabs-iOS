//
//  TTGlossyBox.m
//  TabulaTabs
//
//  Created by Max Winde on 21.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTGlossyBox.h"

@implementation TTGlossyBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* white0 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0];
    UIColor* white20 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.2];
    UIColor* white60 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.6];
    UIColor* boxColor = [UIColor colorWithRed: 0.24 green: 0.32 blue: 0.42 alpha: 1];
    CGFloat boxColorRGBA[4];
    [boxColor getRed: &boxColorRGBA[0] green: &boxColorRGBA[1] blue: &boxColorRGBA[2] alpha: &boxColorRGBA[3]];
    
    UIColor* boxColor0 = [boxColor colorWithAlphaComponent: 0];
    UIColor* boxColorDarker = [UIColor colorWithRed: (boxColorRGBA[0] * 0.5) green: (boxColorRGBA[1] * 0.5) blue: (boxColorRGBA[2] * 0.5) alpha: (boxColorRGBA[3] * 0.5 + 0.5)];
    
    //// Gradient Declarations
    NSArray* glossColors = [NSArray arrayWithObjects: 
                            (id)white0.CGColor, 
                            (id)white0.CGColor, 
                            (id)white60.CGColor, 
                            (id)white20.CGColor, nil];
    CGFloat glossLocations[] = {0, 0.5, 0.5, 1};
    CGGradientRef gloss = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)glossColors, glossLocations);
    NSArray* maskColors = [NSArray arrayWithObjects: 
                           (id)boxColor.CGColor, 
                           (id)[UIColor colorWithRed: 0.24 green: 0.32 blue: 0.42 alpha: 0.5].CGColor, 
                           (id)boxColor0.CGColor, nil];
    CGFloat maskLocations[] = {0, 0.75, 1};
    CGGradientRef mask = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)maskColors, maskLocations);
    
    //// Abstracted Graphic Attributes
    CGSize size = self.bounds.size;
    CGRect borderFrame = CGRectMake(0.5, 0.5, size.width - 1, size.height - 1);
    CGRect glossBoxFrame = CGRectMake(1.5, 1.5, size.width - 3, size.height - 3);
    CGRect glossBoxMaskFrame = CGRectMake(1, 1, size.width - 2, size.height - 2);
    
    
    //// border Drawing
    UIBezierPath* borderPath = [UIBezierPath bezierPathWithRoundedRect: borderFrame cornerRadius: 4];
    [boxColor setFill];
    [borderPath fill];
    
    [boxColorDarker setStroke];
    borderPath.lineWidth = 1;
    [borderPath stroke];
    
    
    //// glossBox Drawing
    UIBezierPath* glossBoxPath = [UIBezierPath bezierPathWithRoundedRect: glossBoxFrame cornerRadius: 4];
    CGContextSaveGState(context);
    [glossBoxPath addClip];
    CGContextDrawLinearGradient(context, gloss, CGPointMake(size.width * 0.25, size.width), CGPointMake(size.width * 1.25, 0), 0);
    CGContextRestoreGState(context);
    
    [white60 setStroke];
    glossBoxPath.lineWidth = 1;
    [glossBoxPath stroke];
    
    
    //// glossBoxMask Drawing
    UIBezierPath* glossBoxMaskPath = [UIBezierPath bezierPathWithRoundedRect: glossBoxMaskFrame cornerRadius: 4];
    CGContextSaveGState(context);
    [glossBoxMaskPath addClip];
    CGContextDrawLinearGradient(context, mask, CGPointMake(size.height, size.height - 1), CGPointMake(size.height, 1), 0);
    CGContextRestoreGState(context);
    
    
    //// Cleanup
    CGGradientRelease(gloss);
    CGGradientRelease(mask);
    CGColorSpaceRelease(colorSpace);
}

@end
