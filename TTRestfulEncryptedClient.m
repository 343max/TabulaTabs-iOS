//
//  TTRestfulEncryptedClient.m
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTRestfulEncryptedClient.h"

@implementation TTRestfulEncryptedClient

@synthesize encryption;

- (id)initWithEncryption:(TTEncryption *)theEncryption;
{
    self = [super init];
    if (self) {
        self.encryption = theEncryption;
    }
    return self;
}

@end
