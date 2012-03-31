//
//  TTFlippingButton.h
//  TabulaTabs
//
//  Created by Max Winde on 31.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TTFlippingButtonDirectionRight,
    TTFlippingButtonDirectionLeft
} TTFlippingButtonDirection;

@interface TTFlippingButton : UIButton

@property (assign, nonatomic) TTFlippingButtonDirection direction;

- (id)initWithImage:(UIImage *)image shadowImage:(UIImage *)shadowImage;

- (void)setDirection:(TTFlippingButtonDirection)direction animated:(BOOL)animated;

@end
