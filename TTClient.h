//
//  TTClient.h
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTRestfulEncryptedClient.h"

@interface TTClient : TTRestfulEncryptedClient

@property (strong) NSString *userAgent;
@property (strong) NSString *label;
@property (strong) NSString *description;
@property (strong) NSURL *iconURL;

@property (strong, readonly) NSDictionary *dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)claimClient:(NSString *)claimingPassword finalPassword:(NSString *)finalPassword callback:(void(^)(id response))callback;
- (void)loadTabs:(void(^)(NSArray* tabs, id response))callback;

@end
