//
//  TTTabTableViewCell.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+TabulaTabs.h"

#import "TTTabTableViewCell.h"

@interface TTTabTableViewCell ()

@property (strong) UIView *backgroundColorView;
@property (strong) UIView *textBoxView;

@end


@implementation TTTabTableViewCell
@synthesize faviconView = _faviconView;
@synthesize imageView;
@synthesize pageColor = _pageColor;
@synthesize imageSize = _imageSize;

@synthesize backgroundColorView = _backgroundColorView, textBoxView = _textBoxView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorView = [[UIView alloc] init];
        [self insertSubview:self.backgroundColorView atIndex:0];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self insertSubview:imageView aboveSubview:self.backgroundColorView];
        
        self.textBoxView = [[UIView alloc] init];
        [self insertSubview:self.textBoxView aboveSubview:imageView];
        
        _faviconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.faviconView.layer.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        self.faviconView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.faviconView.layer.shadowRadius = 2.0;
        self.faviconView.layer.shadowOpacity = 1.0;
        self.faviconView.layer.shouldRasterize = YES;
        [self addSubview:self.faviconView];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.detailTextLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        self.detailTextLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:11.0];
        
        self.textLabel.numberOfLines = 3;
        self.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:15.0];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        self.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPageColor:(UIColor *)pageColor;
{
    _pageColor = pageColor;
    if (!pageColor) {
        pageColor = [UIColor defaultPageColor];
    }
    
    CGFloat hue; CGFloat saturation; CGFloat brightness; CGFloat alpha;
    [pageColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    NSLog(@"saturation: %f, brightness: %f", saturation, brightness);
    
    CGFloat saturationFactor = 1;
    if (saturation <= 0.01) {
        saturationFactor = 0;
    }
    
    self.textBoxView.backgroundColor = pageColor;
    self.backgroundColorView.backgroundColor = [UIColor colorWithHue:hue saturation:0.1 * saturationFactor brightness:0.95 alpha:1.0];
    self.textLabel.textColor = pageColor;
}

- (CGSize)imageSize;
{
    CGSize imageSize = self.bounds.size;
    imageSize.width = 90;
    imageSize.height -= 14;
    
    return imageSize;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    self.backgroundColorView.frame = self.bounds;
        
    CGRect textboxFrame = self.bounds;
    textboxFrame.size.height = 14;
    textboxFrame.origin.x = 0;
    self.textBoxView.frame = textboxFrame;
    
    CGRect imageRect = self.bounds;
    imageRect.size = self.imageSize;
    
    if (!self.imageView.image) {
        imageRect.size.width = 0;
    }
    imageRect.origin.y = CGRectGetMaxY(textboxFrame);
    imageRect.origin.x = self.bounds.size.width - imageRect.size.width;
    self.imageView.frame = imageRect;
    
    CGRect faviconRect = CGRectMake(self.bounds.size.width - 18, 3, 8, 8);
    self.faviconView.frame = faviconRect;
    
    CGRect detailLabelRect = CGRectMake(10.0, 0.0, 320 - 20 - imageRect.size.width, 14);
    self.detailTextLabel.frame = detailLabelRect;
    
    CGRect textLabelRect = detailLabelRect;
    textLabelRect.origin.y = 14;
    textLabelRect.size.height = 56;
    textLabelRect.size = [self.textLabel.text sizeWithFont:self.textLabel.font
                                         constrainedToSize:textLabelRect.size
                                             lineBreakMode:self.textLabel.lineBreakMode];
    self.textLabel.frame = textLabelRect;
}

@end
