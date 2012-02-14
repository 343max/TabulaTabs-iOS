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

@property (strong) NSString *userAgent;
@property (strong) NSString *label;
@property (strong) NSString *description;
@property (strong) NSURL *iconURL;

- (void)registerWithPassword:(NSString *)password callback:(void(^)(id response))callback;
- (void)load:(NSString *)username password:(NSString *)password callback:(void(^)(id response))callback;
- (void)load:(void(^)(id response))callback;
- (void)saveTabs:(NSArray *)tabs callback:(void(^)(id response))callback;
- (void)createClient:(NSString *)claimingPassword callback:(void (^)(NSString *clientUsername, id response))callback;

@end
