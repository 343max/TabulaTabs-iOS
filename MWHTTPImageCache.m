//
//  MWImageLoader.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MWHTTPImageCache.h"

@interface MWHTTPImageCache ()

@property (strong) NSMutableDictionary *cache;

- (void)didReceiveMemoryWarning:(NSNotification *)notification;
- (NSMutableDictionary *)cacheForIdentifier:(NSString *)processIdentifier;

@end



@implementation MWHTTPImageCache

static MWHTTPImageCache *staticDefaultImageLoader;

+ (MWHTTPImageCache *)defaultCache;
{
    if (!staticDefaultImageLoader) {
        staticDefaultImageLoader = [[MWHTTPImageCache alloc] init];
    }
    
    return staticDefaultImageLoader;
}

@synthesize cache;

- (id)init;
{
    self = [super init];
    
    if (self) {
        self.cache = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification;
{
    self.cache = [NSMutableDictionary dictionary];
}

- (NSMutableDictionary *)cacheForIdentifier:(NSString *)processIdentifier;
{
    if (![self.cache objectForKey:processIdentifier]) {
        [self.cache setObject:[NSMutableDictionary dictionary] forKey:processIdentifier];
    }
    
    return [self.cache objectForKey:processIdentifier];
}

- (void)loadImage:(NSURL *)imageURL completionBlock:(MWHTTPImageCacheImageLoadedCallback)completionBlock;
{
    if ([[self cacheForIdentifier:@"loaded"] objectForKey:imageURL]) {
        completionBlock(nil, [[self cacheForIdentifier:@"loaded"] objectForKey:imageURL], nil);
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   UIImage *image = nil;
                                   if (data) {
                                       image = [[UIImage alloc] initWithData:data];
                                   }
                                   
                                   if (image) {
                                       [[self cacheForIdentifier:@"loaded"] setObject:image forKey:imageURL];
                                   }
                                   
                                   completionBlock(response, image, error);
                               }];
    }
}

- (void)loadImage:(NSURL *)imageURL processIdentifier:(NSString *)processIdentifier processingBlock:(MWHTTPImageCacheProcessImageBlock)processingBlock completionBlock:(MWHTTPImageCacheImageProcessedBlock)completionBlock;
{
    if ([[self cacheForIdentifier:processIdentifier] objectForKey:imageURL]) {
        completionBlock([[self cacheForIdentifier:processIdentifier] objectForKey:imageURL]);
    } else {
        [self loadImage:imageURL completionBlock:^(NSURLResponse *response, UIImage *image, NSError *error) {
            UIImage *processedImage = processingBlock(image);
            
            if (processedImage) {
                [[self cacheForIdentifier:processIdentifier] setObject:processedImage forKey:imageURL];
            }
            
            completionBlock(processedImage);
        }];
    }
}

@end
