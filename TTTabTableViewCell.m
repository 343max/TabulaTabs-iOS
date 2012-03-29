//
//  TTTabTableViewCell.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+TabulaTabs.h"

#import "TTTabTableViewCell.h"

@interface TTTabTableViewCell ()

@property (strong) UIView *backgroundColorView;
@property (strong) UIImageView *gradientView;
@property (strong) UIView *textBoxView;

@end


@implementation TTTabTableViewCell
@synthesize faviconView = _faviconView;
@synthesize imageView;
@synthesize pageColor = _pageColor;

@synthesize gradientView = _gradientView, backgroundColorView = _backgroundColorView, textBoxView = _textBoxView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorView = [[UIView alloc] init];
        [self insertSubview:self.backgroundColorView atIndex:0];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self insertSubview:imageView aboveSubview:self.backgroundColorView];
        
        self.gradientView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabCellViewGradient"]];
        [self insertSubview:self.gradientView aboveSubview:imageView];
        
        self.textBoxView = [[UIView alloc] init];
        [self insertSubview:self.textBoxView aboveSubview:imageView];
        
        _faviconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.faviconView];
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.detailTextLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        self.detailTextLabel.font = [UIFont fontWithName:@"Karla-Regular" size:11.0];
        
        self.textLabel.numberOfLines = 3;
        self.textLabel.font = [UIFont fontWithName:@"Karla-Regular" size:15.0];
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
    
    CGFloat saturationFactor = 1;
    if (saturation == 0) {
        saturationFactor = 0;
    }
    
    self.textBoxView.backgroundColor = pageColor;
    self.backgroundColorView.backgroundColor = [UIColor colorWithHue:hue saturation:0.1 * saturationFactor brightness:0.95 alpha:1.0];
    self.textLabel.textColor = pageColor;
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    self.backgroundColorView.frame = self.bounds;
    
    CGRect gradientFrame = self.bounds;
    gradientFrame.origin.y += (gradientFrame.size.height - self.gradientView.image.size.height);
    gradientFrame.size.height = self.gradientView.image.size.height;
    self.gradientView.frame = gradientFrame;
    
    CGRect textboxFrame = self.bounds;
    textboxFrame.size.height = 14;
    textboxFrame.origin.x = 90;
    textboxFrame.size.width -= 90;
    self.textBoxView.frame = textboxFrame;
    
    CGRect imageRect = self.bounds;
    imageRect.size.width = 90;
    imageRect.size.height -= 2;
    imageRect.origin.y += 1;
    self.imageView.frame = imageRect;
    
    CGRect faviconRect = CGRectMake(79, 3, 8, 8);
    self.faviconView.frame = faviconRect;
    
    CGRect labelRect = self.textLabel.frame;
    labelRect.origin.x += imageRect.size.width + 18;
    labelRect.size.width = self.bounds.size.width - labelRect.origin.x - 10;
    self.textLabel.frame = labelRect;
    
    CGRect detailLabelRect = CGRectMake(94.0, 0.0, 320 - 94 - 10, 14);
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
