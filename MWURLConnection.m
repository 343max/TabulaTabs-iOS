//
//  MWURLConnection.m
//  tabulatabs-ios
//
//  Created by Max Winde on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

    #import "MWURLConnection.h"


//{
//    NSURLConnection *connection;
//    void(^didFinishLoadingBlock)(NSData *);
//}


@interface MWURLConnection ()

@property (strong) NSURLRequest *request;
@property (strong) NSURLConnection *connection;

@end


@implementation MWURLConnection

@synthesize dataReceived;
@synthesize request, connection;
@synthesize connectionDidFinishLoadingBlock, connectionDidReceiveDataBlock, connectionDidFailWithErrorBlock;
@synthesize username, password;

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

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    if (!challenge.error) {
        NSURLCredential *credentials = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceForSession];
        [challenge.sender useCredential:credentials forAuthenticationChallenge:challenge];
    } else {
        NSLog(@"Could not login!");
    }
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
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
//    NSLog(@"- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;");
    if (self.connectionDidFailWithErrorBlock) {
        self.connectionDidFailWithErrorBlock(error);
    }
    NSLog(@"Connection Error: %@", [error description]);
}

@end
