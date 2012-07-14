//
//  TTSocketController.m
//  TabulaTabs
//
//  Created by Max Winde on 14.07.12.
//
//

#import "AZSocketIO.h"
#import "TTRestfulClient.h"

#import "TTSocketController.h"

NSString * const TTSocketControllerCategoryTabs = @"tabs";
NSString * const TTSocketControllerCategoryClient = @"clients";
NSString * const TTSocketControllerCategoryBrowsers = @"browsers";

NSString * const TTSocketControllerConnectedNotification = @"TTSocketControllerConnectedNotification";
NSString * const TTSocketControllerConnectionFailureNotification = @"TTSocketControllerConnectionFailureNotification";

@interface TTSocketController ()

@property (strong, nonatomic) AZSocketIO *socket;
@property (strong) NSMutableDictionary *encryptions;

@end


@implementation TTSocketController

- (NSArray *)allCategories;
{
    return @[ TTSocketControllerCategoryBrowsers, TTSocketControllerCategoryClient, TTSocketControllerCategoryTabs ];
}

- (void)connect;
{
    NSURL *APIEndpointURL = [NSURL URLWithString:[TTRestfulControllerAPIDomain copy]];
    NSString *port = @"80";
    if (APIEndpointURL.port != nil) {
        port = [NSString stringWithFormat:@"%i", [APIEndpointURL.port integerValue]];
    }
    
    _socket = [[AZSocketIO alloc] initWithHost:APIEndpointURL.host andPort:port];
    
    [_socket connectWithSuccess:^{
        _connected = YES;
        NSLog(@"socket Connected");
        [[NSNotificationCenter defaultCenter] postNotificationName:TTSocketControllerConnectedNotification
                                                            object:self];
    } andFailure:^(NSError *error) {
        NSLog(@"socket Could Not Connect");
        [[NSNotificationCenter defaultCenter] postNotificationName:TTSocketControllerConnectionFailureNotification
                                                            object:self];
    }];
    
    [_socket setEventRecievedBlock:^(NSString *eventName, id data) {
        NSLog(@"eventReceived: %@ data: %@", eventName, data);
    }];
}

- (void)join:(NSString *)username password:(NSString *)password categories:(NSArray *)categories;
{
    if (!self.connected) {
        return;
    }

    if (username == nil || password == nil) {
        return;
    }

    NSDictionary *arguments = @{
    @"username": username,
    @"password": password,
    @"categories": categories
    };
    
    NSLog(@"joining %@", username);
    
    NSError *error = nil;
    [self.socket emit:@"login" args:arguments error:&error ack:^(NSArray *data) {
        NSLog(@"data: %@", data);
    }];
}

- (void)leave:(NSString *)username password:(NSString *)password;
{
    if (!self.connected) {
        return;
    }
    
    if (username == nil || password == nil) {
        return;
    }
    
    NSDictionary *arguments = @{
    @"username": username,
    @"password": password
    };
    
    NSLog(@"leaving %@", username);
    
    NSError *error = nil;
    [self.socket emit:@"logout" args:arguments error:&error ack:^(NSArray *data) {
        NSLog(@"data: %@", data);
    }];
}

@end
