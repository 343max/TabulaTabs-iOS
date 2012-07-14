//
//  AZSocketIO.m
//  AZSocketIO
//
//  Created by Patrick Shields on 4/6/12.
//  Copyright 2012 Patrick Shields
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AZSocketIO.h"
#import "AFHTTPClient.h"
#import "AFJSONUtilities.h"
#import "AZSocketIOTransport.h"
#import "AZWebsocketTransport.h"
#import "AZxhrTransport.h"
#import "AZSocketIOPacket.h"

#define PROTOCOL_VERSION @"1"

@interface AZSocketIO ()
@property(nonatomic, strong)NSOperationQueue *queue;

@property(nonatomic, strong)ConnectedBlock connectionBlock;

@property(nonatomic, strong)AFHTTPClient *httpClient;
@property(nonatomic, strong)id<AZSocketIOTransport> transport;

@property(nonatomic, strong)NSMutableDictionary *ackCallbacks;
@property(nonatomic, assign)NSInteger ackCount;
@property(nonatomic, strong)NSTimer *heartbeatTimer;

@property(nonatomic, strong)NSMutableDictionary *specificEventBlocks;

@property(nonatomic, strong)NSArray *availableTransports;
@property(nonatomic, strong)NSString *sessionId;
@property(nonatomic, assign)NSInteger heartbeatInterval;
@property(nonatomic, assign)NSInteger disconnectInterval;
@end

@implementation AZSocketIO
@synthesize host;
@synthesize port;
@synthesize secureConnections;
@synthesize transports;
@synthesize availableTransports;
@synthesize sessionId;
@synthesize heartbeatInterval;
@synthesize disconnectInterval;

@synthesize isConnected;

@synthesize messageRecievedBlock;
@synthesize eventRecievedBlock;
@synthesize disconnectedBlock;
@synthesize errorBlock;

@synthesize queue;

@synthesize connectionBlock;
@synthesize httpClient;
@synthesize transport;

@synthesize ackCallbacks;
@synthesize ackCount;
@synthesize heartbeatTimer;

@synthesize specificEventBlocks;

- (id)initWithHost:(NSString *)_host andPort:(NSString *)_port
{
    self = [super init];
    if (self) {
        self.host = _host;
        self.port = _port;
        self.secureConnections = NO;
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:nil];
        self.ackCallbacks = [NSMutableDictionary dictionary];       
        self.ackCount = 0;
        self.specificEventBlocks = [NSMutableDictionary new];
        
        self.queue = [[NSOperationQueue alloc] init];
        [self.queue setSuspended:YES];
        
        self.transports = [NSMutableSet setWithObjects:@"websocket", @"xhr-polling", nil];
    }
    return self;
}

#pragma mark connection management
- (void)connectWithSuccess:(ConnectedBlock)success andFailure:(ErrorBlock)failure
{
    self.connectionBlock = success;
    self.errorBlock = failure;
    NSString *protocolString = self.secureConnections ? @"https://" : @"http://";
    NSString *urlString = [NSString stringWithFormat:@"%@%@:%@/socket.io/%@", protocolString,
                           self.host, self.port, PROTOCOL_VERSION];
    [self.httpClient getPath:urlString
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                         NSArray *msg = [response componentsSeparatedByString:@":"];
                         if ([msg count] < 4) {
                             NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                             [errorDetail setValue:@"Server handshake message could not be decoded" forKey:NSLocalizedDescriptionKey];
                             failure([NSError errorWithDomain:AZDOMAIN code:100 userInfo:errorDetail]);
                         }
                         self.sessionId = [msg objectAtIndex:0];
                         self.heartbeatInterval = [[msg objectAtIndex:1] intValue];
                         self.disconnectInterval = [[msg objectAtIndex:2] intValue];
                         self.availableTransports = [[msg objectAtIndex:3] componentsSeparatedByString:@","];
                         [self connect];
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         failure(error);
                     }];
}

- (void)connect
{
    for (NSString *transportType in self.availableTransports) {
        if ([self.transports containsObject:transportType]) {
            [self connectViaTransport:transportType];
            return;
        }
    }
    
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:@"None of the available transports are recognized by this server" forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:AZDOMAIN code:100 userInfo:errorDetail];
    self.errorBlock(error);
}

- (void)connectViaTransport:(NSString*)transportType 
{
    if ([transportType isEqualToString:@"websocket"]) {
        self.transport = [[AZWebsocketTransport alloc] initWithDelegate:self secureConnections:self.secureConnections];
    } else if ([transportType isEqualToString:@"xhr-polling"]) {
        self.transport = [[AZxhrTransport alloc] initWithDelegate:self secureConnections:self.secureConnections];
    } else {
        NSLog(@"Transport not implemented");
    }
    [self.transport connect];
}

- (void)disconnect
{
    [self clearHeartbeatTimeout];
    [self.transport disconnect];
}

- (BOOL)isConnected
{
    return self.transport && [self.transport isConnected];
}

#pragma mark data sending
- (BOOL)send:(id)data error:(NSError *__autoreleasing *)error ack:(ACKCallback)callback
{
    AZSocketIOPacket *packet = [[AZSocketIOPacket alloc] init];
    
    if (![data isKindOfClass:[NSString class]]) {
        NSData *jsonData = AFJSONEncode(data, error);
        if (jsonData == nil) {
            return NO;
        }
        
        packet.data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        packet.type = JSON_MESSAGE;
    } else {
        packet.data = data;
        packet.type = MESSAGE;
    }
    
    if (callback != NULL) {
        packet.Id = [NSString stringWithFormat:@"%d", ackCount++];
        [self.ackCallbacks setObject:callback forKey:packet.Id];
        packet.Id = [packet.Id stringByAppendingString:@"+"];
    }
    
    return [self sendPacket:packet error:error];
}

- (BOOL)send:(id)data error:(NSError *__autoreleasing *)error
{        
    return [self send:data error:error ack:NULL];
}

- (BOOL)emit:(NSString *)name args:(id)args error:(NSError *__autoreleasing *)error ack:(ACKCallback)callback
{
    AZSocketIOPacket *packet = [[AZSocketIOPacket alloc] init];
    packet.type = EVENT;
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", args, @"args", nil];
    NSData *jsonData = AFJSONEncode(data, error);
    if (jsonData == nil) {
        return NO;
    }
    
    packet.data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    packet.Id = [NSString stringWithFormat:@"%d", ackCount++];
    
    if (callback != NULL) {
        [self.ackCallbacks setObject:callback forKey:packet.Id];
        packet.Id = [packet.Id stringByAppendingString:@"+"];
    }
    
    return [self sendPacket:packet error:error];
}

- (BOOL)emit:(NSString *)name args:(id)args error:(NSError * __autoreleasing *)error
{
    return [self emit:name args:args error:error ack:NULL];
}

- (BOOL)sendPacket:(AZSocketIOPacket *)packet error:(NSError * __autoreleasing *)error
{
    [self.queue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [self.transport send:[packet encode]];
    }]];
    return !self.queue.isSuspended;
}

#pragma mark event callback registration
- (void)addCallbackForEventName:(NSString *)name callback:(EventRecievedBlock)block
{
    NSMutableArray *callbacks = [self.specificEventBlocks objectForKey:name];
    if (callbacks == nil) {
        callbacks = [NSMutableArray array];
        [self.specificEventBlocks setValue:callbacks forKey:name];
    }
    [callbacks addObject:block];
}
- (BOOL)removeCallbackForEvent:(NSString *)name callback:(EventRecievedBlock)block
{
    NSMutableArray *callbacks = [self.specificEventBlocks objectForKey:name];
    if (callbacks != nil) {
        NSInteger count = [callbacks count];
        [callbacks removeObject:block];
        if ([callbacks count] == 0) {
            [self.specificEventBlocks removeObjectForKey:name];
            return YES;
        }
        return count != [callbacks count];
    }
    return NO;
}
- (NSInteger)removeCallbacksForEvent:(NSString *)name
{
    NSMutableArray *callbacks = [self.specificEventBlocks objectForKey:name];
    [self.specificEventBlocks removeObjectForKey:name];
    return [callbacks count];
}
#pragma mark heartbeat
- (void)clearHeartbeatTimeout
{
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
}
- (void)startHeartbeatTimeout
{
    [self clearHeartbeatTimeout];
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartbeatInterval
                                                           target:self
                                                         selector:@selector(heartbeatTimeout) 
                                                         userInfo:nil
                                                          repeats:NO];
}
- (void)heartbeatTimeout
{
    // TODO: Add reconnect support
    [self disconnect];
}
#pragma mark AZSocketIOTransportDelegate
- (void)didReceiveMessage:(NSString *)message
{
    [self startHeartbeatTimeout];
    AZSocketIOPacket *packet = [[AZSocketIOPacket alloc] initWithString:message];
    id outData; AZSocketIOACKMessage *ackMessage; ACKCallback callback; NSArray *callbackList;
    switch (packet.type) {
        case DISCONNECT:
            [self disconnect];
            break;
        case CONNECT:
            if (self.connectionBlock) {
                self.connectionBlock();
                self.connectionBlock = nil;
            }
            [self.queue setSuspended:NO];
            break;
        case HEARTBEAT:
            [self.transport send:message];
            break;
        case MESSAGE:
            self.messageRecievedBlock(packet.data);
            break;
        case JSON_MESSAGE:
            outData = AFJSONDecode([packet.data dataUsingEncoding:NSUTF8StringEncoding], nil);
            self.messageRecievedBlock(outData);
            break;
        case EVENT:
            outData = AFJSONDecode([packet.data dataUsingEncoding:NSUTF8StringEncoding], nil);
            callbackList = [self.specificEventBlocks objectForKey:[outData objectForKey:@"name"]];
            if (callbackList != nil) {
                for (EventRecievedBlock block in callbackList) {
                    block([outData objectForKey:@"name"], [outData objectForKey:@"args"]);
                }
            } else {
                self.eventRecievedBlock([outData objectForKey:@"name"], [outData objectForKey:@"args"]);
            }
            break;
        case ACK:
            ackMessage = [[AZSocketIOACKMessage alloc] initWithPacket:packet];
            callback = [self.ackCallbacks objectForKey:ackMessage.messageId];
            if (callback != NULL) {
                callback(ackMessage.args);
            }
            [self.ackCallbacks removeObjectForKey:ackMessage.messageId];
            break;
        case ERROR:
            if (self.errorBlock) {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:packet.data forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:AZDOMAIN code:100 userInfo:errorDetail];
                self.errorBlock(error);
            }
            break;
        default:
            break;
    }
}

- (void)didClose
{
    [self.queue setSuspended:YES];
    if (self.disconnectedBlock) {
        self.disconnectedBlock();
    }
}

- (void)didFailWithError:(NSError *)error
{
    if (self.errorBlock) {
        self.errorBlock(error);
    }
}
@end
