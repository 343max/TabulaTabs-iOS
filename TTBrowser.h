//
//  TTBrowserController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTRestfulEncryptedClient.h"

@class TTEncryption;

@interface TTBrowser : TTRestfulEncryptedClient

@property (assign) NSInteger identifier;
@property (strong) NSString *userAgent;
@property (strong) NSString *label;
@property (strong) NSString *browserDescription;
@property (strong) NSURL *iconURL;

@property (strong, readonly) NSDictionary *dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSURL *)registrationURLForUsername:(NSString *)username claimingPassword:(NSString *)claimingPassword encryptionKey:(NSData *)encryptionKey;

- (void)registerWithPassword:(NSString *)password callback:(void(^)(id response))callback;
- (void)load:(NSString *)username password:(NSString *)password callback:(void(^)(id response))callback;
- (void)load:(void(^)(id response))callback;
- (void)saveTabs:(NSArray *)tabs callback:(void (^)(BOOL success, id repsonse))callback;
- (void)createClientWitClaimingPassword:(NSString *)claimingPassword callback:(void (^)(NSString *clientUsername, id response))callback;

@end
