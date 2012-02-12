//
//  TTEncryption.h
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTEncryption : NSObject

@property (strong) NSData *encryptionKey;

- (id)initWithEncryptionKey:(NSData *)encryptionKey;

- (NSDictionary *)encrypt:(id)payload iv:(NSData *)iv;
- (NSDictionary *)encrypt:(id)payload;
- (id)decrypt:(NSDictionary *)encryptedDictionary;
- (NSData *)generateIv;

@end
