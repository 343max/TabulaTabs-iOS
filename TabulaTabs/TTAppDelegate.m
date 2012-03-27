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

#import "NSURL+TabulaTabs.h"
#import "MWURLConnection.h"

#import "TTBrowserController.h"
#import "TTBrowserRepresentation.h"
#import "TTClient.h"

#import "TTScanQRViewController.h"
#import "TTWelcomeViewController.h"
#import "TTTabListViewController.h"
#import "TTWebViewController.h"

#import "TTAppDelegate.h"

@interface TTAppDelegate ()

@property (assign, nonatomic) NSInteger networkConnectionsInProgress;

- (void)registeringClient:(NSNotification *)notification;
- (void)networkConnectionStarted:(NSNotification *)notification;
- (void)networkConnectionFinished:(NSNotification *)notification;

@end


@implementation TTAppDelegate

@synthesize window = _window;
@synthesize URLScheme = _URLScheme;
@synthesize navigationController = _navigationController, tabListViewController = _tabListViewController;
@synthesize browserController = _browserController;
@synthesize networkConnectionsInProgress = _networkConnectionsInProgress;

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
    
    self.tabListViewController = [[TTTabListViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabListViewController];
    self.window.rootViewController = self.navigationController;
    
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
    
    if (self.browserController.allBrowsers.count == 0) {
//#warning debug: claiming an client
//        [TTDevelopmentHelpers registerFakeClient];
//        [[UIApplication sharedApplication] openURL:[NSURL tabulatabsURLWithString:@"client/claim/c_276/c13171623aa6770c138eabc7325650a0/f2dbe2e55e777013f49661e809012569e804377afb70b5a5a36300981e486edc"]];
        [[UIApplication sharedApplication] openURL:[NSURL tabulatabsURLWithString:@"client/tour/"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL tabulatabsURLWithString:@"client/tabs/first"]];
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
            [self popToTablistViewControllerForBrowserRepresentation:browserRepresentation animated:YES];
        } else if([module isEqualToString:@"client"] && [action isEqualToString:@"tabs"] && url.pathComponents.count == 3) {
            NSString *clientDescriptor = [url.pathComponents objectAtIndex:2];
            if ([clientDescriptor isEqualToString:@"first"]) {
                [self popToTablistViewControllerForBrowserRepresentation:[self.browserController.allBrowsers objectAtIndex:0] animated:YES];
            }
        } else if([module isEqualToString:@"client"] && [action isEqualToString:@"tour"]) {
            TTWelcomeViewController *welcomeViewController = [[TTWelcomeViewController alloc] initWithNibName:nil bundle:nil];
            [(UINavigationController *)self.window.rootViewController pushViewController:welcomeViewController animated:YES];
            
        } else if([module isEqualToString:@"client"] && [action isEqualToString:@"snapcode"]) {
            TTScanQRViewController *scanViewController = [[TTScanQRViewController alloc] initWithNibName:nil bundle:nil];
            [(UINavigationController *)self.window.rootViewController pushViewController:scanViewController animated:YES];
            
        } else {
            NSLog(@"could not handle my URL: %@", url);
        }
        
        return YES;
    }
}

- (TTTabListViewController *)popToTablistViewControllerForBrowserRepresentation:(TTBrowserRepresentation *)browserRepresentation animated:(BOOL)animated;
{
    if (self.tabListViewController.browserRepresentation == browserRepresentation) {
        [self.navigationController popToViewController:self.tabListViewController animated:animated];
    } else {
        
        [self.navigationController popToRootViewControllerAnimated:NO];
        self.tabListViewController = [[TTTabListViewController alloc] init];
        self.tabListViewController.browserRepresentation = browserRepresentation;
        
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabListViewController];
        self.window.rootViewController = self.navigationController;
    }
    
    return self.tabListViewController;
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
    
    NSLog(@"%i network connections in progress", networkConnectionsInProgress);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (networkConnectionsInProgress > 0);
}

- (void)registeringClient:(NSNotification *)notification;
{
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
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"AppSettings" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[settingsStoryboard instantiateInitialViewController]];
    
    [self.window.rootViewController presentModalViewController:navigationController
                                                      animated:YES];
}

@end
