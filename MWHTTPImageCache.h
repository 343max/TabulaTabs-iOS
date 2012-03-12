//
//  MWImageLoader.h
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MWHTTPImageCacheImageLoadedCallback)(NSURLResponse *response, UIImage *image, NSError *error);
typedef UIImage *(^MWHTTPImageCacheProcessImageBlock)(UIImage *image);
typedef void (^MWHTTPImageCacheImageProcessedBlock)(UIImage *image);

@interface MWHTTPImageCache : NSObject

+ (MWHTTPImageCache *)defaultCache;

- (void)loadImage:(NSURL *)imageURL completionBlock:(MWHTTPImageCacheImageLoadedCallback)completionBlock;
- (void)loadImage:(NSURL *)imageURL processIdentifier:(NSString *)processIdentifier processingBlock:(MWHTTPImageCacheProcessImageBlock)processingBlock completionBlock:(MWHTTPImageCacheImageProcessedBlock)completionBlock;
@end
