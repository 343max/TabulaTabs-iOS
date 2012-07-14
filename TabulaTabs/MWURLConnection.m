//
//  MWURLConnection.m
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWURLConnection.h"

NSString * const MWURLConnectionDidStartNotification = @"MWURLConnectionDidStartNotification";
NSString * const MWURLConnectionDidFinishNotification = @"MWURLConnectionDidFinishNotification";

@interface MWURLConnection ()

@property (strong) NSURLRequest *request;
@property (strong) NSURLConnection *connection;

@end


@implementation MWURLConnection

- (id)initWithRequest:(NSURLRequest *)aRequest
{
    self = [super init];
    
    if (self) {
        self.request = aRequest;
        self.connection = [[NSURLConnection alloc] initWithRequest:aRequest delegate:self startImmediately:NO];
        
        self.connectionDidFailWithErrorBlock = nil;
        self.connectionDidFinishLoadingBlock = nil;
        self.connectionDidReceiveDataBlock = nil;
    }
    
    return self;
}

- (void)start
{
    self.dataReceived = [[NSMutableData alloc] init];    
    [self.connection start];
}

- (void)cancel
{
    [self.connection cancel];
}

#pragma mark NSURLConnectionDataDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MWURLConnectionDidStartNotification object:self];
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
{
//    NSLog(@"- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;");
    [self.dataReceived appendData:data];
    
    if (self.connectionDidReceiveDataBlock) {
        self.connectionDidReceiveDataBlock(data);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
//    NSLog(@"- (void)connectionDidFinishLoading:(NSURLConnection *)connection;");
    if (self.connectionDidFinishLoadingBlock) {
        self.connectionDidFinishLoadingBlock(self.dataReceived);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MWURLConnectionDidFinishNotification object:self];
}


#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    NSLog(@"invalid authentication: %@", self.request.URL.absoluteString);
    
    if (self.connectionDidReceiveAuthentificationChallenge) {
        self.connectionDidReceiveAuthentificationChallenge(challenge);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
//    NSLog(@"- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;");
    if (self.connectionDidFailWithErrorBlock) {
        self.connectionDidFailWithErrorBlock(error);
    }
    NSLog(@"Connection Error: %@", [error description]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MWURLConnectionDidFinishNotification object:self];
}

@end
