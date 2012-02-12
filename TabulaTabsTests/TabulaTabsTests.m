//
//  TabulaTabsTests.m
//  TabulaTabsTests
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData-hex.h"
#import "TTEncryption.h"

#import "TabulaTabsTests.h"

@implementation TabulaTabsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDataToHexString;
{
    NSString *dataString = @" Hallo!";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *hexString = [data hexString];
    NSLog(@"hexString: %@", hexString);
    
    STAssertTrue([hexString isEqualToString:@"2048616c6c6f21"], @"data to hex works");
    
    data = [NSData dataWithHexString:hexString];
    NSString *reverseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    STAssertTrue([reverseString isEqualToString:dataString], @"reverse works");
}

- (void)testEncryption;
{
    NSString *keyString = @"secretsecretsecretsecretsecretAA";
    TTEncryption *encryption = [[TTEncryption alloc] initWithEncryptionKey:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *encryptedDict = [encryption encrypt:[NSDictionary dictionaryWithObject:@"world!" forKey:@"hello"]];
    
    NSDictionary *decryptedPayload = [encryption decrypt:encryptedDict];
    STAssertTrue([[NSString stringWithString:@"world!"] isEqualToString:[decryptedPayload objectForKey:@"hello"]], @"encryption & decryption works");
}

@end
