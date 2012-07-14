//
//  TTEncryption.m
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData+Base64.h"
#import "NSData-hex.h"
#import "NSData-AES.h"

#import "TTEncryption.h"

NSString * const TTEncryptionDecryptionErrorNotification = @"TTEncryptionDecryptionErrorNotification";

@implementation TTEncryption

+ (id)encryptionWithHexKey:(NSString *)hexKey;
{
    NSData *key = [NSData dataWithHexString:hexKey];
    
    return [self encryptionWithKey:key];
}

+ (id)encryptionWithKey:(NSData *)encryptionKey;
{
    return [[TTEncryption alloc] initWithEncryptionKey:encryptionKey];
}

- (id)initWithEncryptionKey:(NSData *)theEncryptionKey;
{
    self = [super init];
    
    if (self) {
        self.encryptionKey = theEncryptionKey;
    }
    
    return self;
}

- (NSDictionary *)encrypt:(id)payload;
{
    return [self encrypt:payload iv:[TTEncryption generateIv]];
}

- (NSDictionary *)encrypt:(id)payload iv:(NSData *)iv;
{
    NSError *error;
    NSData *jsonPayload = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
    NSData *ic = [jsonPayload AES256EncryptWithKey:self.encryptionKey iv:iv];
    
    return @{@"ic": [ic base64EncodedString], @"iv": [iv hexString]};
}

- (id)decrypt:(NSDictionary *)encryptedDictionary;
{
    NSData *iv = [NSData dataWithHexString:[encryptedDictionary objectForKey:@"iv"]];
    NSData *ic = [NSData dataFromBase64String:[encryptedDictionary objectForKey:@"ic"]];
    
    NSData *decryptedData = [ic AES256DecryptWithKey:self.encryptionKey iv:iv];
    
    if (decryptedData == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TTEncryptionDecryptionErrorNotification object:self];
        return nil;
    }
    
    NSError *error = nil;
    id payload = [NSJSONSerialization JSONObjectWithData:decryptedData options:0 error:&error];
    
    if (error) {
//        NSLog(@"could not decrypt data: %@", error);
    }
//    NSAssert(!error, @"could not decrypt data: %@", error);
    
    return payload;
}

+ (NSData *)generateIv;
{
    int err = 0;
    NSMutableData* data = [NSMutableData dataWithLength:16];
    err = SecRandomCopyBytes(kSecRandomDefault, 16, [data mutableBytes]);
    return [data copy];
}

+ (NSData *)generateEncryptionKey;
{
    int err = 0;
    NSMutableData* data = [NSMutableData dataWithLength:32];
    err = SecRandomCopyBytes(kSecRandomDefault, 32, [data mutableBytes]);
    return [data copy];    
}

+ (NSString *)generatePassword;
{
    return [[self generateIv] hexString];
}

@end
