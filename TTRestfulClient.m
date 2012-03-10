//
//  TTRestfulController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

NSString const * TTRestfulControllerAPIDomain = @"https://tabulatabs.heroku.com/";

#import "NSData+Base64.h"
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
    
    if (self.username && self.password) {
        NSData *userCredentials = [[NSString stringWithFormat:@"%@:%@", self.username, self.password] dataUsingEncoding:NSUTF8StringEncoding];
        [request addValue:[NSString stringWithFormat:@"Basic %@==", [userCredentials base64EncodedString]]
       forHTTPHeaderField:@"Authorization"];
    }
    
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
    
    connection.connectionDidFinishLoadingBlock = ^(NSData *data) {
        NSError *error;
        id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSString *rawJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"request: %@\nresponse: %@", request.URL.absoluteString, rawJSON);
        
        if (error) {
            NSLog(@"error in %@ request %@", connection.request.HTTPMethod, connection.request.URL.absoluteString);
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@\n\n\n", responseString);
        }
        
        NSAssert(!error, @"JSON deserialization error: %@", error);
        if (callback) {
            callback(response);
        }
    };
    
    return connection;
}

@end
