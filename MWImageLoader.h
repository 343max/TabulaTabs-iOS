//
//  MWImageLoader.h
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MWImageLoaderImageLoadedCallback)(NSURLResponse *response, UIImage *image, NSError *error);

@interface MWImageLoader : NSObject

+ (MWImageLoader *)defaultLoader;

- (void)loadImage:(NSURL *)imageURL completionBlock:(MWImageLoaderImageLoadedCallback)completionBlock;

@end
