//
//  MWImageLoader.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MWHTTPImageCache.h"

#import "NSString+SHA1.h"

@interface MWHTTPImageCache ()

@property (strong) NSMutableDictionary *cache;
@property (strong, nonatomic) NSURL *cacheDirectory;

- (void)didReceiveMemoryWarning:(NSNotification *)notification;
- (NSMutableDictionary *)cacheForIdentifier:(NSString *)processIdentifier;
- (NSString *)cacheFilenameForImageURL:(NSURL *)URL cacheIdentifier:(NSString *)cacheIdentifier format:(MWHTTPImageCachePersistentCacheFormat)format scale:(CGFloat)scale;
- (UIImage *)loadFromDiskURL:(NSURL *)URL cachedIdentifier:(NSString *)cacheIdentifier format:(MWHTTPImageCachePersistentCacheFormat)format;
- (void)saveToDiskImage:(UIImage *)image withURL:(NSURL *)URL cachedIdentifier:(NSString *)cacheIdentifier format:(MWHTTPImageCachePersistentCacheFormat)format;

@end



@implementation MWHTTPImageCache

static MWHTTPImageCache *staticDefaultImageLoader;

+ (MWHTTPImageCache *)defaultCache;
{
    if (staticDefaultImageLoader == nil) {
        staticDefaultImageLoader = [[MWHTTPImageCache alloc] init];
    }
    
    return staticDefaultImageLoader;
}

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
    [self clearRAMCache];
}

- (void)clearDiskCache;
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:self.cacheDirectory error:&error];
}

- (void)clearRAMCache;
{
    self.cache = [NSMutableDictionary dictionary];
}

- (NSMutableDictionary *)cacheForIdentifier:(NSString *)processIdentifier;
{
    if ([self.cache objectForKey:processIdentifier] == nil) {
        [self.cache setObject:[NSMutableDictionary dictionary] forKey:processIdentifier];
    }
    
    return [self.cache objectForKey:processIdentifier];
}

- (NSString *)cacheFilenameForImageURL:(NSURL *)URL cacheIdentifier:(NSString *)cacheIdentifier format:(MWHTTPImageCachePersistentCacheFormat)format;
{
    return [self cacheFilenameForImageURL:URL
                          cacheIdentifier:cacheIdentifier
                                   format:format 
                                    scale:1.0];
}


- (NSString *)cacheFilenameForImageURL:(NSURL *)URL cacheIdentifier:(NSString *)cacheIdentifier format:(MWHTTPImageCachePersistentCacheFormat)format scale:(CGFloat)scale;
{
    NSString *extension;
    
    switch (format) {
        case MWHTTPImageCachePersistentCacheFormatJPG:
            extension = @"jpg";
            break;
            
        case MWHTTPImageCachePersistentCacheFormatPNG:
            extension = @"png";
            break;
            
        case MWHTTPImageCachePersistentCacheFormatNone:
            return nil;
    }
    
    NSString *scaleString = (scale == 2.0 ? @"@2x" : @"");
    
    return [NSString stringWithFormat:@"%@-%@%@.%@", [URL.absoluteString SHA1Digest], [cacheIdentifier SHA1Digest], scaleString, extension];
}

- (UIImage *)loadFromDiskURL:(NSURL *)URL cachedIdentifier:(NSString *)cacheIdentifier format:(MWHTTPImageCachePersistentCacheFormat)format;
{
    if (format == MWHTTPImageCachePersistentCacheFormatNone) {
        return nil;
    }

    NSString *fileName = [self cacheFilenameForImageURL:URL cacheIdentifier:cacheIdentifier format:format];
    NSURL *fileURL = [self.cacheDirectory URLByAppendingPathComponent:fileName];

    return [UIImage imageWithContentsOfFile:fileURL.path];
}


- (void)saveToDiskImage:(UIImage *)image withURL:(NSURL *)URL cachedIdentifier:(NSString *)cacheIdentifier format:(MWHTTPImageCachePersistentCacheFormat)format;
{
    if (format == MWHTTPImageCachePersistentCacheFormatNone) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
    ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:self.cacheDirectory.path]) {
            NSError *error;
            
            [fileManager createDirectoryAtPath:self.cacheDirectory.path
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&error];
            
            if (error) {
                NSLog(@"Could not create directory: %@", error);
                return;
            }
        }
        
        NSString *fileName = [self cacheFilenameForImageURL:URL 
                                            cacheIdentifier:cacheIdentifier
                                                     format:format
                                                      scale:image.scale];
        NSURL *fileURL = [self.cacheDirectory URLByAppendingPathComponent:fileName];
        
        if (format == MWHTTPImageCachePersistentCacheFormatJPG) {
            [UIImageJPEGRepresentation(image, 0.95) writeToURL:fileURL atomically:YES];
        } else {
            [UIImagePNGRepresentation(image) writeToURL:fileURL atomically:YES];
        }
    });
}

- (void)loadImage:(NSURL *)imageURL cacheFormat:(MWHTTPImageCachePersistentCacheFormat)cacheFormat completionBlock:(MWHTTPImageCacheImageLoadedCallback)completionBlock;
{
    UIImage *image;

    if ([[self cacheForIdentifier:@"image"] objectForKey:imageURL]) {
        completionBlock(nil, [[self cacheForIdentifier:@"image"] objectForKey:imageURL], nil);
    } else if((image = [self loadFromDiskURL:imageURL cachedIdentifier:@"image" format:cacheFormat])) {
        [[self cacheForIdentifier:@"image"] setObject:image forKey:imageURL];
        completionBlock(nil, image, nil);
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
                                       [[self cacheForIdentifier:@"image"] setObject:image forKey:imageURL];
                                       [self saveToDiskImage:image withURL:imageURL cachedIdentifier:@"image" format:cacheFormat];
                                   }
                                   
                                   completionBlock(response, image, error);
                               }];
    }
}

- (void)loadImage:(NSURL *)imageURL cacheFormat:(MWHTTPImageCachePersistentCacheFormat)cacheFormat processIdentifier:(NSString *)processIdentifier processingBlock:(MWHTTPImageCacheProcessImageBlock)processingBlock completionBlock:(MWHTTPImageCacheImageProcessedBlock)completionBlock;
{
    UIImage *image;
    
    if ([[self cacheForIdentifier:processIdentifier] objectForKey:imageURL]) {
        completionBlock([[self cacheForIdentifier:processIdentifier] objectForKey:imageURL]);
    } else if((image = [self loadFromDiskURL:imageURL cachedIdentifier:processIdentifier format:cacheFormat])) {
        [[self cacheForIdentifier:processIdentifier] setObject:image forKey:imageURL];
        completionBlock(image);
    } else {
        [self loadImage:imageURL
            cacheFormat:MWHTTPImageCachePersistentCacheFormatNone
        completionBlock:^(NSURLResponse *response, UIImage *image, NSError *error) {
            UIImage *processedImage = processingBlock(image);
            
            if (processedImage) {
                [[self cacheForIdentifier:processIdentifier] setObject:processedImage forKey:imageURL];
                [self saveToDiskImage:processedImage withURL:imageURL cachedIdentifier:processIdentifier format:cacheFormat];
            }
            
            completionBlock(processedImage);
        }];
    }
}

#pragma mark Accessors

- (NSURL *)cacheDirectory;
{
    if (_cacheDirectory == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if (paths.count == 0) return nil;
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
        _cacheDirectory = [NSURL fileURLWithPath:path];
    }
    return _cacheDirectory;
}


@end
