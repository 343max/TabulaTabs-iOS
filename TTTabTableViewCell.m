//
//  TTTabTableViewCell.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTTabTableViewCell.h"

@implementation TTTabTableViewCell
@synthesize imageView, faviconView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        
        faviconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.faviconView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    CGRect imageRect = self.bounds;
    imageRect.size.width = imageRect.size.height;
    self.imageView.frame = imageRect;
    
    CGRect faviconRect = self.textLabel.frame;
    faviconRect.size = CGSizeMake(16.0, 16.0);
    faviconRect.origin.x += imageRect.size.width - 4;
    faviconRect.origin.y += 3;
    self.faviconView.frame = faviconRect;
    
    CGRect labelRect = self.textLabel.frame;
    labelRect.origin.x += imageRect.size.width + 18;
    labelRect.size.width = self.bounds.size.width - labelRect.origin.x - 10;
    self.textLabel.frame = labelRect;
    
    CGRect detailLabelRect = self.detailTextLabel.frame;
    detailLabelRect.origin.x += imageRect.size.width + 18;
    detailLabelRect.size.width = self.bounds.size.width - detailLabelRect.origin.x - 10;
    self.detailTextLabel.frame = detailLabelRect;
}

@end
