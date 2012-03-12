//
//  MWImageLoader.m
//  TabulaTabs
//
//  Created by Max Winde on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MWImageLoader.h"

@interface MWImageLoader ()

@property (strong) NSMutableDictionary *cache;

- (void)didReceiveMemoryWarning:(NSNotification *)notification;

@end


@implementation MWImageLoader

static MWImageLoader *staticDefaultImageLoader;

+ (MWImageLoader *)defaultLoader;
{
    if (!staticDefaultImageLoader) {
        staticDefaultImageLoader = [[MWImageLoader alloc] init];
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

- (void)loadImage:(NSURL *)imageURL completionBlock:(MWImageLoaderImageLoadedCallback)completionBlock;
{
    if ([self.cache objectForKey:imageURL]) {
        completionBlock(nil, [self.cache objectForKey:imageURL], nil);
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
                                       [self.cache setObject:image forKey:imageURL];
                                   }
                                   
                                   completionBlock(response, image, error);
                               }];
    }
    
}

@end
