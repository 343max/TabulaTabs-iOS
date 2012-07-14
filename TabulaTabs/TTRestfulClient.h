//
//  TTRestfulController.h
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const * TTRestfulControllerAPIDomain;

@class MWURLConnection;

@interface TTRestfulClient : NSObject

@property (strong) NSString *username;
@property (strong) NSString *password;

@property (copy, nonatomic) void(^connectionDidReceiveDataBlock)(NSData *);
@property (copy, nonatomic) void(^connectionDidFailWithErrorBlock)(NSError *);
@property (copy, nonatomic) void(^connectionDidReceiveAuthentificationChallenge)(NSURLAuthenticationChallenge *);

- (MWURLConnection *)sendJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters callback:(void(^)(id response))callback;
- (MWURLConnection *)sendJsonGetRequest:(NSString *)path callback:(void(^)(id response))callback;
- (NSMutableURLRequest *)prepareJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters;
- (MWURLConnection *)prepareJsonConnection:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters callback:(void(^)(id response))callback;

@end
