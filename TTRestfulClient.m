//
//  TTRestfulController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#warning don't commit!
//NSString const * TTRestfulControllerAPIDomain = @"http://apiv1.tabulatabs.com/";
NSString const * TTRestfulControllerAPIDomain = @"http://maxbook-air.local:4242/";

#import "NSData+Base64.h"
#import "MWURLConnection.h"

#import "TTRestfulClient.h"

@implementation TTRestfulClient

@synthesize username = _username;
@synthesize password = _password;

@synthesize connectionDidFailWithErrorBlock = _connectionDidFailWithErrorBlock;
@synthesize connectionDidReceiveAuthentificationChallenge = _connectionDidReceiveAuthentificationChallenge;
@synthesize connectionDidReceiveDataBlock = _connectionDidReceiveDataBlock;

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
    
    if ([request.HTTPMethod isEqualToString:@"PUT"] || [request.HTTPMethod isEqualToString:@"POST"]) {
        [request addValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
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
        
        if (error) {
            NSLog(@"error in %@ request %@", connection.request.HTTPMethod, connection.request.URL.absoluteString);
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"responseString: %@\n\n\n", responseString);
        }
        
        NSAssert(!error, @"JSON deserialization error: %@", error);
        if (callback) {
            callback(response);
        }
    };
    
    connection.connectionDidFailWithErrorBlock = self.connectionDidFailWithErrorBlock;
    connection.connectionDidReceiveAuthentificationChallenge = self.connectionDidReceiveAuthentificationChallenge;
    connection.connectionDidReceiveDataBlock = connection.connectionDidReceiveDataBlock;
    
    return connection;
}

@end
