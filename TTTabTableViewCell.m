//
//  TTTabTableViewCell.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTTabTableViewCell.h"

@implementation TTTabTableViewCell
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
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
    
    CGRect labelRect = self.textLabel.frame;
    labelRect.origin.x += imageRect.size.width;
    labelRect.size.width = self.bounds.size.width - labelRect.origin.x - 10;
    self.textLabel.frame = labelRect;
    
    CGRect detailLabelRect = self.detailTextLabel.frame;
    detailLabelRect.origin.x += imageRect.size.width;
    detailLabelRect.size.width = self.bounds.size.width - detailLabelRect.origin.x - 10;
    self.detailTextLabel.frame = detailLabelRect;
}

@end
