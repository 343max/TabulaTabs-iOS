//
//  TTFlippingButton.m
//  TabulaTabs
//
//  Created by Max Winde on 31.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTFlippingButton.h"

@interface TTFlippingButton ()

@property (strong) UIImageView *flippingImageView;
@property (strong) UIImageView *flippingShadowImageView;

@end


@implementation TTFlippingButton

- (id)initWithImage:(UIImage *)image shadowImage:(UIImage *)shadowImage;
{
    self = [super init];
    
    if (self) {
        self.flippingImageView = [[UIImageView alloc] initWithImage:image];
        self.flippingImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.flippingImageView];
        
        self.flippingShadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
        [self insertSubview:self.flippingShadowImageView belowSubview:self.flippingImageView];
    }
    
    return self;
}

- (void)layoutSubviews;
{
    CGRect imageViewFrame = self.flippingImageView.frame;
    imageViewFrame.origin.y -= 1;
    self.flippingShadowImageView.frame = imageViewFrame;
}

- (void)setDirection:(TTFlippingButtonDirection)direction;
{
    [self setDirection:direction animated:NO];
}

- (void)setDirection:(TTFlippingButtonDirection)direction animated:(BOOL)animated;
{
    _direction = direction;
    
    [UIView animateWithDuration:(animated ? 0.3 : 0.0) animations:^{
        CGFloat angle = (direction == TTFlippingButtonDirectionRight ? -M_PI : 0.0);
        self.flippingImageView.transform = self.flippingShadowImageView.transform = CGAffineTransformMakeRotation((angle));
    }];
}

@end
