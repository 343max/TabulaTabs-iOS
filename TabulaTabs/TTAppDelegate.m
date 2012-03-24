//
//  TTAppDelegate.m
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTDevelopmentHelpers.h"

#import "NSData-hex.h"
#import "MTStatusBarOverlay.h"
#import "SSKeychain.h"

#import "TTBrowserRepresentation.h"
#import "TTClient.h"

#import "TTScanQRViewController.h"
#import "TTWelcomeViewController.h"
#import "TTTabListViewController.h"

#import "TTAppDelegate.h"

NSString * const TTAppDelegatePasswordKey = @"ClientPassword";
NSString * const TTAppDelegateEncryptionKeyKey = @"ClientEncryptionKey";

@interface TTAppDelegate ()

@property (assign) NSInteger jobsInProgress;

- (void)registeringClient:(NSNotification *)notification;
- (void)jobDone:(NSNotification *)notification;

@end


@implementation TTAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController, tabListViewController = _tabListViewController;
@synthesize browserRepresentations = _browserRepresentations;
@synthesize jobsInProgress = _jobsInProgress;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [TTDevelopmentHelpers runAsynchronTests]; return YES;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.jobsInProgress = 0;
        
    [self restoreBrowserRepresentations];
    
    self.tabListViewController = [[TTTabListViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabListViewController];
    self.window.rootViewController = self.navigationController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeringClient:) name:TTBrowserReprensentationClaimingClientNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobDone:) name:TTBrowserReprensentationClientWasUpdatedNotification object:nil];
        
    if (self.browserRepresentations.count == 0) {
//#warning debug: claiming an client
//        [TTDevelopmentHelpers registerFakeClient];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/tour/"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/tabs/first"]];
    }
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/claim/username/password/key"]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/tour/"]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/snapcode/"]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
    if (![url.scheme isEqualToString:@"tabulatabs"]) {
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
                [self popToTablistViewControllerForBrowserRepresentation:[self.browserRepresentations objectAtIndex:0] animated:YES];
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark Browser Representations

- (void)setBrowserRepresentations:(NSArray *)newBrowserRepresentations;
{
    _browserRepresentations = newBrowserRepresentations;
    NSLog(@"saving browserRepresentations");
    
    NSMutableArray *clientDictionaries = [NSMutableArray arrayWithCapacity:_browserRepresentations.count];
    [_browserRepresentations enumerateObjectsUsingBlock:^(TTBrowserRepresentation *browser, NSUInteger idx, BOOL *stop) {
        TTClient *client = browser.client;
        [clientDictionaries addObject:client.dictionary];
        
        [SSKeychain setPassword:client.password forService:TTAppDelegatePasswordKey account:client.username];
        [SSKeychain setPassword:client.encryption.encryptionKey.hexString forService:TTAppDelegateEncryptionKeyKey account:client.username];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:[clientDictionaries copy] forKey:@"clients"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreBrowserRepresentations;
{
//#warning debug: claiming an client
//    browserRepresentations = [NSArray array];
//    return;
    
    NSArray *clientDictionaries = [[NSUserDefaults standardUserDefaults] arrayForKey:@"clients"];
    NSMutableArray *restoredBrowsers = [NSMutableArray arrayWithCapacity:clientDictionaries.count];
    
    [clientDictionaries enumerateObjectsUsingBlock:^(NSDictionary *clientDictionary, NSUInteger idx, BOOL *stop) {
        TTClient *client = [[TTClient alloc] initWithDictionary:clientDictionary];
        client.password = [SSKeychain passwordForService:TTAppDelegatePasswordKey account:client.username];
        NSData *encryptionKey = [NSData dataWithHexString:[SSKeychain passwordForService:TTAppDelegateEncryptionKeyKey account:client.username]];
        client.encryption = [[TTEncryption alloc] initWithEncryptionKey:encryptionKey];
        
        TTBrowserRepresentation *browserRepresentation = [[TTBrowserRepresentation alloc] init];
        browserRepresentation.client = client;
        [restoredBrowsers addObject:browserRepresentation];
    }];
    
    _browserRepresentations = [restoredBrowsers copy];
}

#pragma mark Helper

- (void)registeringClient:(NSNotification *)notification;
{
    self.jobsInProgress++;
    [[MTStatusBarOverlay sharedOverlay] postImmediateMessage:@"Handshake" animated:YES];
}

- (void)jobDone:(NSNotification *)notification;
{
    self.jobsInProgress--;
    
    NSAssert(self.jobsInProgress >= 0, @"finished more jobs then started");
    
    if (self.jobsInProgress == 0) {
        [[MTStatusBarOverlay sharedOverlay] hide];
    }
}

@end
