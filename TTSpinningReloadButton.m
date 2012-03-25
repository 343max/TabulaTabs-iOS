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

- (void)spinIfNeeded;

@end


@implementation TTSpinningReloadButton

@synthesize spinning = _spinning;
@synthesize spinningImageView = _spinningImageView;

- (id)initWithImage:(UIImage *)image;
{
    self = [super init];
    
    if (self) {
        CGRect imageViewFrame = CGRectMake(-image.size.width / 2.0, -image.size.height / 2.0, image.size.width, image.size.height);
        self.spinningImageView = [[UIImageView alloc] initWithImage:image];
        self.spinningImageView.frame = imageViewFrame;
        self.spinningImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.spinningImageView];
    }
    
    return self;
}

- (void)spinIfNeeded;
{
    if (self.spinning) {
        [UIView animateWithDuration:1.0/3.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.spinningImageView.transform = CGAffineTransformMakeRotation(M_PI * 2/3);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0/3.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.spinningImageView.transform = CGAffineTransformMakeRotation(M_PI * 4/3);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1.0/3.0 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.spinningImageView.transform = CGAffineTransformMakeRotation(0.0);
                } completion:^(BOOL finished) {
                    [self performSelector:@selector(spinIfNeeded) withObject:nil afterDelay:0.0];
                }];
            }];
        }];
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
