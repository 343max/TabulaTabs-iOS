//
//  TTTabTableViewCell.h
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTabTableViewCell : UITableViewCell

@property (strong, readonly) UIImageView *faviconView;
@property (strong, nonatomic) UIColor *pageColor;
@property (assign, nonatomic, readonly) CGSize imageSize;
@property (assign, nonatomic, readwrite) CGSize favIconSize;
@property (assign) CGFloat marginRight;

@property (strong) NSURL *thumbnailImageURL;
@property (strong) NSURL *favIconURL;

@end
