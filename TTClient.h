//
//  TTClient.h
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTRestfulClient.h"

@interface TTClient : TTRestfulClient

@property (strong) NSString *claimingPassword;

@property (strong) NSString *userAgent;
@property (strong) NSString *label;
@property (strong) NSString *description;
@property (strong) NSURL *iconURL;

@property (strong, readonly) NSDictionary *dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)create:(NSString *)username password:(NSString *)password claimngPassword:(NSString *)claimingPassword callback:(void(^)(id response))callback;

@end
