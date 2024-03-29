/* HEX specific routines are copyright:
 
 Copyright (c) 2006, Big Nerd Ranch, Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of Big Nerd Ranch, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSData-hex.h"

@implementation NSData (Hex)

+ (NSData *)dataWithHexString:(NSString*)hexString;
{	
	// Hex Lookup Table
	unsigned char HEX_LOOKUP[] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 
		6, 7, 8, 9, -1, -1, -1, -1, -1, -1, -1, 10, 11, 12, 13, 14, 15, -1, -1, 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
		-1, -1, -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
	
	// If we have an odd number of characters, add an extra digit, rounding the
	// size of the NSData up to the nearest byte
	if ([hexString length] % 2 == 1)  {
		hexString = [NSString stringWithFormat:@"0%@", hexString]; 
	}
	
	// Iterate through the string, adding each character (equivilent to 1/2 
	// byte) to the NSData result
	char current;
	const int size = [hexString length] / 2;
	const char * stringBuffer = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
	NSMutableData * result = [NSMutableData dataWithLength:size];
	char * resultBuffer = [result mutableBytes];
	for (int i = 0; i < size; i++) {
		// Get first character, use as high order bits
		current = stringBuffer[i * 2];
        if (HEX_LOOKUP[current] == -1) return nil;
        
		resultBuffer[i] = HEX_LOOKUP[current] << 4;
		
		// Get second character, use as low order bits
		current = stringBuffer[(i * 2) + 1];
        if (HEX_LOOKUP[current] == -1) return nil;
		resultBuffer[i] = resultBuffer[i] | HEX_LOOKUP[current];
	}
	
	return [NSData dataWithData:result];
}

- (NSString *)hexString;
{
    const char * dataBuffer = [self bytes];
    unsigned char HEX_CHARS[] = "0123456789abcdef";
    unsigned char current;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:self.length * 2];
    
    for (int i = 0; i < self.length; i++) {
        current = dataBuffer[i];
        int first = current >> 4;
        int second = current % 16;
        //NSLog(@"c: %c, %i, %i, %i, %c%c", current, current, first, second, HEX_CHARS[first], HEX_CHARS[second]);
        [hexString appendFormat:@"%c%c", HEX_CHARS[first], HEX_CHARS[second]];
    }
    
    return [hexString copy];
}


@end
