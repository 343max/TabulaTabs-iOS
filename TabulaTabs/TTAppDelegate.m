//
//  TTAppDelegate.m
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTDevelopmentHelpers.h"

#import <Crashlytics/Crashlytics.h>

#if CONFIGURATION_AdHoc
#import "TestFlight.h"
#endif
#import "SSKeychain.h"
#import "MWSlidingViewController.h"

#import "NSURL+TabulaTabs.h"
#import "MWURLConnection.h"

#import "TTBrowserController.h"
#import "TTBrowserRepresentation.h"
#import "TTClient.h"
#import "TTTab.h"

#import "TTAddBrowserFlowViewController.h"
#import "TTTabListViewController.h"
#import "TTWebViewController.h"
#import "TTSettingsNavController.h"

#import "TTAppDelegate.h"

CGFloat const TTAppDelegateWebBrowserPeekAmount = 25.0;

@interface TTAppDelegate ()

@property (assign, nonatomic) NSInteger networkConnectionsInProgress;

- (void)browserWillBeRemoved:(NSNotification *)notification;
- (void)restoreBrowserRepresentations;

- (void)registeringClient:(NSNotification *)notification;
- (void)networkConnectionStarted:(NSNotification *)notification;
- (void)networkConnectionFinished:(NSNotification *)notification;

@end


@implementation TTAppDelegate

@synthesize window = _window;
@synthesize currentURL = _currentURL;
@synthesize URLScheme = _URLScheme;
@synthesize slidingViewController = _slidingViewController;
@synthesize browserController = _browserController;
@synthesize networkConnectionsInProgress = _networkConnectionsInProgress;
@synthesize currentBrowser = _currentBrowser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [TTDevelopmentHelpers runAsynchronTests]; return YES;
    
    _URLScheme =  [[[NSBundle mainBundle] infoDictionary] valueForKey:@"MainURLScheme"];
    
#if CONFIGURATION_AdHoc
    [TestFlight takeOff:@"08b2e6be43c442789736edf1fecb1592_MTEwMjYyMDEyLTAzLTI0IDA5OjM1OjM0LjgxMDc5Ng"];
#endif
    [Crashlytics startWithAPIKey:@"f5afdb7ddba6518ecbf5c81e44e46bf5aae78272"];
    
    UIColor *tintColor = [UIColor colorWithRed:0.238 green:0.319 blue:0.414 alpha:1.000];
    [[UINavigationBar appearance] setTintColor:tintColor];
    [[UIToolbar appearance] setTintColor:tintColor];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]];
    [self.window makeKeyAndVisible];
    
    self.networkConnectionsInProgress = 0;
        
    [self restoreBrowserRepresentations];

    self.slidingViewController = [[MWSlidingViewController alloc] init];
    self.window.rootViewController = self.slidingViewController;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registeringClient:)
                                                 name:TTBrowserRepresentationClaimingClientNotification
                                               object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionFinished:)
                                                 name:TTBrowserRepresentationClientWasUpdatedNotification
                                               object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(networkConnectionStarted:)
                                                 name:TTWebViewControllerStartedLoadingNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionFinished:)
                                                 name:TTWebViewControllerFinishedLoadingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(networkConnectionStarted:)
                                                 name:MWURLConnectionDidStartNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionFinished:) 
                                                 name:MWURLConnectionDidFinishNotification
                                               object:nil];
    
    if (self.currentURL) {
        [[UIApplication sharedApplication] openURL:self.currentURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL firstBrowserURL]];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
    url = [url buildalizedURL];
    
    if (![url.scheme isEqualToString:self.URLScheme]) {
        return NO;
    } else {
        NSLog(@"handleOpenURL: %@", url);
        
        NSString *module = url.host;
        NSString *action = [url.pathComponents objectAtIndex:1];
        
        if ([module isEqualToString:@"client"] && [action isEqualToString:@"claim"] && url.pathComponents.count == 5) {
            TTBrowserRepresentation *browserRepresentation = [[TTBrowserRepresentation alloc] init];
            [browserRepresentation claimURL:url];
            self.currentBrowser = browserRepresentation;
        } else if([module isEqualToString:@"client"] && [action isEqualToString:@"tabs"] && url.pathComponents.count == 3) {
            NSString *clientDescriptor = [url.pathComponents objectAtIndex:2];
            if ([clientDescriptor isEqualToString:@"first"]) {
                if (self.browserController.allBrowsers.count == 0) {
                    [[UIApplication sharedApplication] openURL:[NSURL addBrowserRepresentationFlowURL]];
                } else {
                    self.currentBrowser = [self.browserController.allBrowsers objectAtIndex:0];
                }
            } else {
                self.currentBrowser = [self.browserController browserWithClientIdentifier:clientDescriptor];
                
                if (self.currentBrowser == nil) {
                    [[UIApplication sharedApplication] openURL:[NSURL firstBrowserURL]];
                }
            }
        } else if([module isEqualToString:@"client"] && [action isEqualToString:@"tour"]) {
            TTAddBrowserFlowViewController *addBrowserFlow = [[TTAddBrowserFlowViewController alloc] init];
            [self.window.rootViewController presentModalViewController:addBrowserFlow animated:YES];
        } else {
            NSLog(@"could not handle my URL: %@", url);
        }
        
        self.window.backgroundColor = [UIColor blackColor];
        
        return YES;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application;
{
    [self.currentBrowser loadBrowser];
    [self.currentBrowser loadWindowsAndTabs];
}


#pragma mark Accessors

- (NSURL *)currentURL;
{
    if (!_currentURL) {
        NSString *URLString = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentURL"];
        if (URLString) {
            _currentURL = [NSURL URLWithString:URLString];
        }
    }
    
    return _currentURL;
}

- (void)setCurrentURL:(NSURL *)currentURL;
{
    _currentURL = currentURL;
    
    [[NSUserDefaults standardUserDefaults] setObject:currentURL.absoluteString forKey:@"currentURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)setCurrentBrowser:(TTBrowserRepresentation *)currentBrowser;
{    
    if (self.currentBrowser == currentBrowser) {
        NSLog(@"tried to set already active browser - maybe we should do a little bit more then – well, lets say: nothing.");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:TTBrowserControllerBrowserHasBeenRemovedNotification
                                                  object:_currentBrowser];

    _currentBrowser = currentBrowser;
    self.currentURL = currentBrowser.tabulatabsURL;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserWillBeRemoved:)
                                                 name:TTBrowserControllerBrowserHasBeenRemovedNotification
                                               object:_currentBrowser];
    
    [self loadTablistViewController];
}


#pragma mark Browser Representations

- (void)browserWillBeRemoved:(NSNotification *)notification;
{
    if (self.browserController.allBrowsers.count > 0) {
        self.currentBrowser = [self.browserController.allBrowsers objectAtIndex:0];
    }
}

- (void)restoreBrowserRepresentations;
{
//#warning debug: claiming an client
//    browserRepresentations = [NSArray array];
//    return;
    
    NSArray *clientDictionaries = [[NSUserDefaults standardUserDefaults] arrayForKey:@"clients"];
    _browserController = [[TTBrowserController alloc] initWithClientDictionaries:clientDictionaries];
}

#pragma mark Helper

- (void)setNetworkConnectionsInProgress:(NSInteger)networkConnectionsInProgress;
{
    NSAssert(networkConnectionsInProgress >= 0, @"networkConnectionsInProgress below zero");
    _networkConnectionsInProgress = networkConnectionsInProgress;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (networkConnectionsInProgress > 0);
}

- (void)registeringClient:(NSNotification *)notification;
{
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    [self networkConnectionStarted:nil];
}

- (void)networkConnectionStarted:(NSNotification *)notification;
{
    self.networkConnectionsInProgress++;
}

- (void)networkConnectionFinished:(NSNotification *)notification;
{
    self.networkConnectionsInProgress--;
}

- (IBAction)showSettings:(id)sender;
{
    TTSettingsNavController *settingsNavController = [[TTSettingsNavController alloc] init];
    [self.window.rootViewController presentModalViewController:settingsNavController
                                                      animated:YES];
}

- (void)loadTablistViewController;
{
    TTTabListViewController *tablistViewController = [[TTTabListViewController alloc] init];
    tablistViewController.browserRepresentation = self.currentBrowser;
    
    self.slidingViewController.anchorRightPeekAmount = TTAppDelegateWebBrowserPeekAmount;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tablistViewController];
    self.slidingViewController.underLeftViewController = navigationController;
    self.slidingViewController.topViewController = nil;
}

@end
