//
//  TTBrowserRepresentation.h
//  TabulaTabs
//
//  Created by Max Winde on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTBrowser.h"
#import "TTClient.h"

#import <Foundation/Foundation.h>

extern NSString * const TTBrowserReprensentationClientWasUpdatedNotification;
extern NSString * const TTBrowserReprensentationClaimingClientNotification;
extern NSString * const TTBrowserReprensentationBrowserWasUpdatedNotification;
extern NSString * const TTBrowserReprensentationTabsWhereUpdatedNotification;


@interface TTBrowserRepresentation : NSObject

@property (strong, nonatomic) TTClient *client;
@property (strong, readonly) TTBrowser *browser;
@property (strong, readonly) NSArray *tabs;

- (TTClient *)claimURL:(NSURL *)url;
- (void)claimClient:(TTClient *)client claimingPassword:(NSString *)claimingPassword;

- (void)loadBrowser;
- (void)loadTabs;

@end
