//
//  UIImage+Resizing.h
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

- (UIImage *)scaledImageOfSize:(CGSize)size;
- (UIImage *)scaledImageOfMaximumSize:(CGSize)manSize;
- (UIImage *)scaledImageOfMinimumSize:(CGSize)minSize;

@end
