//
//  TTBrowserController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 10.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTEncryption.h"
#import "TTBrowser.h"

@interface TTBrowser ()

@property (strong) TTEncryption *encryption;

@end


@implementation TTBrowser

@synthesize userAgent, label, description, iconURL;
@synthesize encryption;

- (id)initWithEncryption:(TTEncryption *)theEncryption;
{
    self = [super init];
    if (self) {
        self.encryption = encryption;
    }
    return self;
}

- (void)register:(NSString *)password callback:(void (^)())callback;
{
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
                                           self.userAgent, @"useragent",
                                           self.label, @"label",
                                           self.description, @"description",
                                           self.iconURL.absoluteString, @"iconURL", nil];
    NSMutableDictionary *jsonParams = [[self.encryption encrypt:payload] mutableCopy];
    
    [jsonParams setObject:[self.encryption generatePassword] forKey:@"password"];
    
    [self sendJsonRequest:@"browser.json" method:@"POST" jsonParameters:jsonParams callback:^(id response) {
        NSLog(@"response: %@", response);
    }];
}

@end
