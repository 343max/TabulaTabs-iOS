//
//  TabulaTabsTests.m
//  TabulaTabsTests
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData-hex.h"
#import "NSURL+TabulaTabs.h"
#import "TTEncryption.h"
#import "TTClient.h"

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
    NSDictionary *encryptedDict = [encryption encrypt:@{@"hello": @"world!"}];
    
    NSDictionary *decryptedPayload = [encryption decrypt:encryptedDict];
    STAssertTrue([@"world!" isEqualToString:[decryptedPayload objectForKey:@"hello"]], @"encryption & decryption works");
}

- (void)testGeneratePassword;
{
    NSString *password = [TTClient generatePassword];
    NSLog(@"generated password: %@", password);
    NSAssert(password.length == 32, @"Password has incorrect length");
}

- (void)testDecryption;
{
    /*
     tabulatabs://client/claim/c_187/6dada457383f4cf8b292a65ce6fc8d37/479ab49af16eda6b711c596071da53d2ba1e57c6dea3b5a11cadfc724ffe4611
     {"iv":"087e8bb8dcb4b20fcfe61b5769e19f8e","ic":"mS0C4rvilkpQaj5sO2E1qWqD7Chs7WOWbUxzgq3v5/9wuTC/uoQJ4iyZCFVVA/+C"}
    */
    
    NSURL* urlWithKey = [NSURL tabulatabsURLWithString:@"client/claim/c_187/6dada457383f4cf8b292a65ce6fc8d37/479ab49af16eda6b711c596071da53d2ba1e57c6dea3b5a11cadfc724ffe4611"];
    NSData* encryptedDataJson = [[NSString stringWithFormat:@"{\"iv\":\"087e8bb8dcb4b20fcfe61b5769e19f8e\",\"ic\":\"mS0C4rvilkpQaj5sO2E1qWqD7Chs7WOWbUxzgq3v5/9wuTC/uoQJ4iyZCFVVA/+C\"}"] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary* encryptedPayload = [NSJSONSerialization JSONObjectWithData:encryptedDataJson options:0 error:&error];
    NSAssert(!error, @"could not decrypt json");
    
    NSLog(@"encryptedPayload: %@", encryptedPayload);
    
    TTEncryption *encryption = [TTEncryption encryptionWithHexKey:[urlWithKey.pathComponents objectAtIndex:4]];
    NSDictionary *unecryptedData = [encryption decrypt:encryptedPayload];
    
    NSLog(@"unencryptedData: %@", unecryptedData);
}

@end
