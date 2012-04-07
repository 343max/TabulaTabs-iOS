//
//  TTBrowserRepresentations.h
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTBrowserRepresentation.h"

#import <UIKit/UIKit.h>

@interface TTBrowserController : NSObject <UIAlertViewDelegate>

@property (strong, nonatomic) TTBrowserRepresentation *currentBrowser;
@property (strong, nonatomic, readonly) NSArray *allBrowsers;

- (id)initWithClientDictionaries:(NSArray *)clientDictionaries;

- (TTBrowserRepresentation *)browserWithClientIdentifier:(NSString *)clientIdentifier;
- (TTBrowserRepresentation *)browserWithBrowserIdentifier:(NSInteger)identifier;
- (void)addBrowser:(TTBrowserRepresentation *)browserReprensentation;
- (BOOL)removeBrowser:(TTBrowserRepresentation *)browserRepresentation;


@end
