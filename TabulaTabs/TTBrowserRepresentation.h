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

extern NSString * const TTBrowserRepresentationClientWasUpdatedNotification;
extern NSString * const TTBrowserRepresentationClaimingClientNotification;
extern NSString * const TTBrowserRepresentationClientAccessWasRevokedNotification;

extern NSString * const TTBrowserRepresentationBrowserWasUpdatedNotification;

extern NSString * const TTBrowserRepresentationWindowsWhereUpdatedNotification;


@interface TTBrowserRepresentation : NSObject <UIAlertViewDelegate>

@property (strong, nonatomic) TTClient *client;
@property (strong, readonly) TTBrowser *browser;
@property (strong, readonly, nonatomic) NSArray *windows;
@property (strong, nonatomic, readonly) NSURL *tabulatabsURL;

- (TTClient *)claimURL:(NSURL *)url;
- (void)claimClient:(TTClient *)client claimingPassword:(NSString *)claimingPassword;

- (void)loadBrowser;
- (void)loadBrowserCompletion:(void (^)(id))callback;
- (void)loadWindowsAndTabs;

@end
