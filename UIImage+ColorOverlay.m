//
//  UIImage+ColorOverlay.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+ColorOverlay.h"

@implementation UIImage (ColorOverlay)

- (UIImage *)imageWithColorOverlay:(UIColor *)overlayColor;
{
    UIImage *recoloredImage;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0); {
        CGContextRef imageContext = UIGraphicsGetCurrentContext();
        CGRect imageRect = (CGRect){CGPointZero, self.size};
        CGContextClipToMask(imageContext, imageRect, self.CGImage);
        [overlayColor setFill];
        CGContextFillRect(imageContext, imageRect);
        recoloredImage = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();

    return recoloredImage;
}

@end
