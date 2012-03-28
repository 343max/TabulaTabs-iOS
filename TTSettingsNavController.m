//
//  TTSettingsNavController.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestFlight.h"

#import "TTSettingsViewController.h"

#import "TTSettingsNavController.h"

@interface TTSettingsNavController ()

- (void)dismiss:(id)sender;

@end


@implementation TTSettingsNavController

- (id)init;
{
    self = [super init];
    
    if (self) {
        [TestFlight passCheckpoint:@"Open Settings"];
        self.delegate = self;
        
        TTSettingsViewController *settingsViewController = [[TTSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self pushViewController:settingsViewController animated:NO];
    }
    
    return self;
}


#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(dismiss:)];
    
    if (!viewController.title) {
        viewController.title = @"Settings";
    }
}


#pragma mark Helpers

- (void)dismiss:(id)sender;
{
    [self dismissModalViewControllerAnimated:YES];
}



@end
