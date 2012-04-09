//
//  UIActionSheetButton.m
//  TabulaTabs
//
//  Created by Max Winde on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTActionSheetButton.h"

#import "UIImage+ColorOverlay.h"

@implementation TTActionSheetButton

+ (TTActionSheetButton *)actionSheetButtonWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;
{
    TTActionSheetButton *button = [[TTActionSheetButton alloc] init];
    
    [button setTitle:title forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.showsTouchWhenHighlighted = YES;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    if (image == nil) {
        image = [UIImage imageNamed:@"Questionmark"];
    }
    
    image = [image imageWithColorOverlay:[UIColor whiteColor]];
    
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGRect titleLabelFrame = self.bounds;
    CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    titleLabelFrame.origin.y = self.bounds.size.height - textSize.height - 5.0;
    titleLabelFrame.size.height = textSize.height;
    self.titleLabel.frame = titleLabelFrame;
    
    CGRect imageViewFrame = CGRectMake(0.0, 0.0, 100.0, 100.0);
    imageViewFrame.origin.x = (self.bounds.size.width - imageViewFrame.size.width) / 2.0;
    imageViewFrame.origin.y = (self.bounds.size.height - imageViewFrame.size.height - textSize.height) / 2.0;
    
    self.imageView.frame = CGRectIntegral(imageViewFrame);
    self.imageView.contentMode = UIViewContentModeCenter;
    
    ((UIImageView *)[self.subviews objectAtIndex:0]).frame = CGRectIntegral(imageViewFrame);
}

@end
