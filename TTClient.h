//
//  TTClient.h
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTRestfulEncryptedClient.h"

@interface TTClient : TTRestfulEncryptedClient

@property (assign, readonly) BOOL unclaimed;
@property (strong) NSString *userAgent;
@property (strong) NSString *label;
@property (strong) NSString *clientDescription;
@property (strong) NSURL *iconURL;
@property (strong) NSString *keychainIdentifier;

@property (strong, nonatomic) NSDictionary *dictionary;

+ (NSString *)generatePassword;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)claimClient:(NSString *)claimingPassword finalPassword:(NSString *)finalPassword callback:(void (^)(BOOL success, id response))callback;
- (void)loadWindowsAndTabs:(void(^)(NSArray *windows, id response))callback;

@end
