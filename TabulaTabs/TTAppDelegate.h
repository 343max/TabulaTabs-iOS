//
//  TTAppDelegate.h
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define appDelegate ((TTAppDelegate *)[[UIApplication sharedApplication] delegate])

@class TTTabListViewController;
@class TTBrowserController;
@class TTBrowserRepresentation;

@interface TTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, readonly) NSString *URLScheme;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TTTabListViewController *tabListViewController;

@property (strong, readonly) TTBrowserController *browserController;

- (TTTabListViewController *)popToTablistViewControllerForBrowserRepresentation:(TTBrowserRepresentation *)browserRepresentation animated:(BOOL)animated;
- (IBAction)showSettings:(id)sender;

@end
