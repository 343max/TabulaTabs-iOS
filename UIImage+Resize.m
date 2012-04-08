//
//  UIImage+Resizing.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)scaledImageOfSize:(CGSize)size;
{
    CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
    
    UIImage *scaledImage;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0.0); {
        [self drawInRect:imageRect];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)scaledImageOfMaximumSize:(CGSize)maxSize;
{
    float scaleFactor = MIN(maxSize.width / self.size.width, maxSize.height / self.size.height);
    
    if(scaleFactor >= 1) {
        scaleFactor = 1;
    }
    
    float width = self.size.width * scaleFactor;
    float height = self.size.height * scaleFactor;
    
    return [self scaledImageOfSize:CGSizeMake(width, height)];
}

- (UIImage *)scaledImageOfMinimumSize:(CGSize)minSize;
{
    float scaleFactor = MAX(minSize.width / self.size.width, minSize.height / self.size.height);
    
    float width = roundf(self.size.width * scaleFactor);
    float height = roundf(self.size.height * scaleFactor);
    
    NSLog(@"minSize: %@, width: %f, height: %f", NSStringFromCGSize(minSize), width, height);
    
    return [self scaledImageOfSize:CGSizeMake(width, height)];
}

@end
