//
//  TTBrowserController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTRestfulClient.h"

@class TTEncryption;

@interface TTBrowser : TTRestfulClient

@property (strong) NSString *userAgent;
@property (strong) NSString *label;
@property (strong) NSString *description;
@property (strong) NSURL *iconURL;

- (id)initWithEncryption:(TTEncryption *)encryption;

- (void)registerWithPassword:(NSString *)password callback:(void(^)(id response))callback;
- (void)load:(NSString *)username password:(NSString *)password callback:(void(^)(id response))callback;
- (void)load:(void(^)(id response))callback;

@end
