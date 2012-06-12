//
//  TTAppDelegate.h
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define appDelegate ((TTAppDelegate *)[[UIApplication sharedApplication] delegate])

extern CGFloat const TTAppDelegateWebBrowserPeekAmount;

@class TTTabListViewController;
@class TTBrowserController;
@class TTBrowserRepresentation;
@class MWSlidingViewController;

@interface TTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, readonly) NSString *URLScheme;
@property (strong, nonatomic) NSURL *currentURL;

@property (strong, nonatomic) UIWindow *window;
@property (strong) MWSlidingViewController *slidingViewController;

@property (strong, readonly) TTBrowserController *browserController;
@property (strong, nonatomic) TTBrowserRepresentation *currentBrowser;

- (IBAction)showSettings:(id)sender;
- (void)loadTablistViewController;

@end
