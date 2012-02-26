//
//  TTAppDelegate.m
//  TabulaTabs
//
//  Created by Max Winde on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AsyncTests.h"

#import "ZBarSDK.h"

#import "TTScanQRViewController.h"
#import "TTWelcomeViewController.h"
#import "TTTabListViewController.h"

#import "TTAppDelegate.h"

@implementation TTAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    AsyncTests* tests = [[AsyncTests alloc] init];
//    [tests runTests];
    
    
    TTTabListViewController* tabListViewController = [[TTTabListViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *mainNavigationController = [[UINavigationController alloc] initWithRootViewController:tabListViewController];
    self.window.rootViewController = mainNavigationController;
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/claim/username/password/key"]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/tour/"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tabulatabs://client/snapcode/"]];
    
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
            NSString* authUsername = [url.pathComponents objectAtIndex:2];
            NSString* authPassword = [url.pathComponents objectAtIndex:3];
            NSString* encryptionKey = [url.pathComponents objectAtIndex:4];
            
            NSLog(@"should claim a new client: %@, %@, %@", authUsername, authPassword, encryptionKey);
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

@end
