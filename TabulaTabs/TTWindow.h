//
//  TTWindow.h
//  TabulaTabs
//
//  Created by Max Winde on 18.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTWindow : NSObject

@property (strong) NSString *identifier;
@property (assign) BOOL focused;
@property (strong) NSArray *tabs;

@property (strong, readonly) NSDictionary *dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
