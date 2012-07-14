//
//  TTRestfulEncryptedClient.h
//  TabulaTabs
//
//  Created by Max Winde on 14.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTEncryption.h"

#import "TTRestfulClient.h"

@interface TTRestfulEncryptedClient : TTRestfulClient

@property (strong) TTEncryption* encryption;

- (id)initWithEncryption:(TTEncryption *)encryption;

@end
