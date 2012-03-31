//
//  TTAnimatedReloadButton.m
//  WebView
//
//  Created by Max Winde on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTSpinningReloadButton.h"

@interface TTSpinningReloadButton ()

@property (strong) UIImageView *spinningImageView;
@property (strong) UIImageView *spinningShadowImageView;

- (void)spinIfNeeded;

@end


@implementation TTSpinningReloadButton

@synthesize spinning = _spinning;
@synthesize spinningImageView = _spinningImageView;
@synthesize spinningShadowImageView = _spinningShadowImageView;

- (id)initWithImage:(UIImage *)image shadowImage:(UIImage *)shadowImage;
{
    self = [super init];
    
    if (self) {
        self.spinningImageView = [[UIImageView alloc] initWithImage:image];
        self.spinningImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.spinningImageView];
        
        self.spinningShadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
        [self insertSubview:self.spinningShadowImageView belowSubview:self.spinningImageView];
        
        [self setNeedsLayout];
    }
    
    return self;
}

- (void)spinIfNeeded;
{
    if (self.spinning) {
        [UIView animateWithDuration:1.0/3.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.spinningImageView.transform = self.spinningShadowImageView.transform = CGAffineTransformMakeRotation(M_PI * 2/3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0/3.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.spinningImageView.transform = self.spinningShadowImageView.transform = CGAffineTransformMakeRotation(M_PI * 4/3);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1.0/3.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.spinningImageView.transform = self.spinningShadowImageView.transform = CGAffineTransformMakeRotation(0.0);
                } completion:^(BOOL finished) {
                    [self performSelector:@selector(spinIfNeeded) withObject:nil afterDelay:0.0];
                }];
            }];
        }];
    }
}

- (void)layoutSubviews;
{
    [super layoutSubviews];

    if (CGAffineTransformIsIdentity(self.spinningImageView.transform)) {
        CGRect imageViewFrame = self.spinningImageView.frame;
        
        imageViewFrame.origin.y -= 1;
        self.spinningShadowImageView.frame = CGRectIntegral(imageViewFrame);
    }
}

- (void)setSpinning:(BOOL)spinning;
{
    if (_spinning && spinning) {
        return;
    }
    
    _spinning = spinning;
    
    [self spinIfNeeded];
}


@end
