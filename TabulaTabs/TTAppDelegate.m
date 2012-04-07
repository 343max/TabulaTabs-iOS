//
//  TTAppDelegate.m
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTDevelopmentHelpers.h"

#import "TestFlight.h"
#import "MTStatusBarOverlay.h"
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

@interface TTAppDelegate ()

@property (assign, nonatomic) NSInteger networkConnectionsInProgress;

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
    
    [TestFlight takeOff:@"08b2e6be43c442789736edf1fecb1592_MTEwMjYyMDEyLTAzLTI0IDA5OjM1OjM0LjgxMDc5Ng"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.networkConnectionsInProgress = 0;
        
    [self restoreBrowserRepresentations];

    self.slidingViewController = [[MWSlidingViewController alloc] init];
    self.window.rootViewController = self.slidingViewController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registeringClient:)
                                                 name:TTBrowserReprensentationClaimingClientNotification
                                               object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionFinished:)
                                                 name:TTBrowserReprensentationClientWasUpdatedNotification
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
    } else if (self.browserController.allBrowsers.count == 0) {
//#warning debug: claiming an client
//        [TTDevelopmentHelpers registerFakeClient];
//        [[UIApplication sharedApplication] openURL:[NSURL tabulatabsURLWithString:@"client/claim/c_276/c13171623aa6770c138eabc7325650a0/f2dbe2e55e777013f49661e809012569e804377afb70b5a5a36300981e486edc"]];
        [[UIApplication sharedApplication] openURL:[NSURL addBrowserRepresentationFlowURL]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL firstBrowserURL]];
    }
    
//    [[UIApplication sharedApplication] openURL:[NSURL tabulatabsURLWithString:@"client/claim/username/password/key"]];
//    [[UIApplication sharedApplication] openURL:[NSURL tabulatabsURLWithString:@"client/tour/"]];
//    [[UIApplication sharedApplication] openURL:[NSURL tabulatabsURLWithString:@"client/snapcode/"]];
    
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
                self.currentBrowser = [self.browserController.allBrowsers objectAtIndex:0];
            } else {
                self.currentBrowser = [self.browserController browserWithClientIdentifier:clientDescriptor];
            }
        } else if([module isEqualToString:@"client"] && [action isEqualToString:@"tour"]) {
            TTAddBrowserFlowViewController *addBrowserFlow = [[TTAddBrowserFlowViewController alloc] init];
            [self.window.rootViewController presentModalViewController:addBrowserFlow animated:YES];
        } else {
            NSLog(@"could not handle my URL: %@", url);
        }
        
        return YES;
    }
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

- (TTBrowserRepresentation *)currentBrowser;
{
    return self.browserController.currentBrowser;
}

- (void)setCurrentBrowser:(TTBrowserRepresentation *)currentBrowser;
{
    if (self.currentBrowser == currentBrowser) {
        NSLog(@"tried to set allready active browser - maybe we should do a little bit more then – well, lets say: nothing.");
        return;
    }
    
    self.browserController.currentBrowser = currentBrowser;
    
    TTTabListViewController *tablistViewController = [[TTTabListViewController alloc] init];
    tablistViewController.browserRepresentation = currentBrowser;
    
    self.slidingViewController.anchorRightPeekAmount = 40.0;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tablistViewController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.slidingViewController.underLeftViewController = navigationController;
    self.slidingViewController.topViewController = nil;
}


#pragma mark Browser Representations

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
    [[MTStatusBarOverlay sharedOverlay] postImmediateMessage:@"Handshake" animated:YES];
    [self networkConnectionStarted:nil];
}

- (void)networkConnectionStarted:(NSNotification *)notification;
{
    self.networkConnectionsInProgress++;
}

- (void)networkConnectionFinished:(NSNotification *)notification;
{
    self.networkConnectionsInProgress--;

    if (self.networkConnectionsInProgress == 0) {
        [[MTStatusBarOverlay sharedOverlay] hide];
    }
}

- (IBAction)showSettings:(id)sender;
{
    TTSettingsNavController *settingsNavController = [[TTSettingsNavController alloc] init];
    [self.window.rootViewController presentModalViewController:settingsNavController
                                                      animated:YES];
}

@end
