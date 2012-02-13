//
//  TTRestfulController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

NSString const * TTRestfulControllerAPIDomain = @"https://tabulatabs.heroku.com/";

#import "MWURLConnection.h"

#import "TTRestfulClient.h"

@implementation TTRestfulClient

@synthesize username, password;

- (MWURLConnection *)sendJsonGetRequest:(NSString *)path callback:(void (^)(id))callback;
{
    return [self sendJsonRequest:path method:@"GET" jsonParameters:nil callback:callback];
}

- (MWURLConnection *)sendJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters callback:(void (^)(id))callback;
{
    MWURLConnection *connection = [self prepareJsonConnection:path
                                                       method:method
                                               jsonParameters:jsonParameters
                                                     callback:callback];
    
    [connection start];
    return connection;
}

- (NSMutableURLRequest *)prepareJsonRequest:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters;
{
    NSURL *URL = [NSURL URLWithString:[TTRestfulControllerAPIDomain stringByAppendingString:path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    
    if (jsonParameters) {
        NSError *error;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:jsonParameters options:0 error:&error];
        NSAssert(!error, @"JSON Serialization error: %@", error);
    }
    
    return request;
}

- (MWURLConnection *)prepareJsonConnection:(NSString *)path method:(NSString *)method jsonParameters:(id)jsonParameters callback:(void (^)(id))callback;
{
    NSMutableURLRequest *request = [self prepareJsonRequest:path method:method jsonParameters:jsonParameters];
    MWURLConnection *connection = [[MWURLConnection alloc] initWithRequest:[request copy]];
    
    connection.username = self.username;
    connection.password = self.password;
    
    connection.connectionDidReceiveDataBlock = ^(NSData *data) {
        NSError *error;
        
        NSString *jsonResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"repsonse: %@", jsonResponse);
        
        id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSAssert(!error, @"JSON deserialization error: %@", error);
        if (callback) {
            callback(response);
        }
    };
    
    return connection;
}

@end
