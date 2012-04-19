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

@property (strong) UIImageView *imageView;
@property (strong) UIView *backgroundColorView;
@property (strong) UIView *pageColorStripeView;

@end


@implementation TTTabTableViewCell

@synthesize marginRight = _marginRight;
@synthesize faviconView = _faviconView;
@synthesize imageView = __imageView;
@synthesize pageColor = _pageColor;
@synthesize imageSize = _imageSize;
@synthesize favIconSize = _favIconSize;

@synthesize thumbnailImageURL;
@synthesize favIconURL;

@synthesize backgroundColorView = _backgroundColorView, pageColorStripeView = _pageColorStripeView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorView = [[UIView alloc] init];
        self.backgroundColorView.backgroundColor = [UIColor whiteColor];
        [self insertSubview:self.backgroundColorView atIndex:0];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        [self insertSubview:self.imageView aboveSubview:self.backgroundColorView];
        
        self.pageColorStripeView = [[UIView alloc] init];
        [self insertSubview:self.pageColorStripeView aboveSubview:self.imageView];
        
        self.marginRight = 0.0;

        _faviconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.faviconView];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        
        self.textLabel.numberOfLines = 3;
        self.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.imageView.alpha = (selected ? 0.7 : 1.0);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
    [super setHighlighted:highlighted animated:animated];
    
    self.imageView.alpha = (highlighted ? 0.7 : 1.0);
}

- (void)setPageColor:(UIColor *)pageColor;
{
    _pageColor = pageColor;
    if (!pageColor) {
        pageColor = [UIColor defaultPageColor];
    }
    
    self.pageColorStripeView.backgroundColor = pageColor;
}

- (CGSize)imageSize;
{
    return CGSizeMake(90, 72);
}

- (CGSize)favIconSize;
{
    return CGSizeMake(16, 16);
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    self.backgroundColorView.frame = self.bounds;
        
    CGRect pageColorStripeFrame = self.bounds;
    pageColorStripeFrame.size.width = 6;
    pageColorStripeFrame.origin.x = 0;
    self.pageColorStripeView.frame = pageColorStripeFrame;
    
    CGRect imageRect = self.bounds;
    imageRect.size = self.imageSize;
    
    if (!self.imageView.image) {
        imageRect.size.width = 0;
    }
    imageRect.origin.y = 0;
    imageRect.origin.x = self.bounds.size.width - imageRect.size.width - self.marginRight;
    self.imageView.frame = imageRect;
    
    CGRect faviconRect = CGRectMake(10, 4, self.favIconSize.width, self.favIconSize.height);
    self.faviconView.frame = faviconRect;
    
    CGRect detailLabelRect = CGRectMake(30.0, 6.0, imageRect.origin.x - 40, 14);
    self.detailTextLabel.frame = detailLabelRect;
//    self.textLabel.backgroundColor = self.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    
    CGRect textLabelRect = detailLabelRect;
    textLabelRect.origin.y = 21;
    textLabelRect.size.height = 56;
    textLabelRect.size = [self.textLabel.text sizeWithFont:self.textLabel.font
                                         constrainedToSize:textLabelRect.size
                                             lineBreakMode:self.textLabel.lineBreakMode];
    self.textLabel.frame = textLabelRect;
}

@end
