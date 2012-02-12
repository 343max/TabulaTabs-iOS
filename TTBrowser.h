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

- (void)register:(NSString *)password callback:(void(^)())callback;

@end
