//
//  TTAppSettingsViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

NSInteger const TTAppSettingsViewControllerBrowsersSection = 0;
NSInteger const TTAppSettingsViewControllerAddBrowserSection = 1;
NSInteger const TTAppSettingsViewControllerDebugSettingsSection = 2;

#import "NSURL+TabulaTabs.h"

#import "TTBrowserRepresentation.h"
#import "TTBrowserController.h"

#import "TTWelcomeViewController.h"
#import "TTCreditsViewController.h"
#import "TTAppDelegate.h"

#import "TTSettingsViewController.h"

@interface TTSettingsViewController ()

- (void)toggleEditMode:(id)sender;

@end


@implementation TTSettingsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (id)initWithStyle:(UITableViewStyle)style;
{
    self = [super initWithStyle:style];
    
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                              target:self 
                                                                                              action:@selector(toggleEditMode:)];
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == TTAppSettingsViewControllerBrowsersSection) {
        return appDelegate.browserController.allBrowsers.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == TTAppSettingsViewControllerBrowsersSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BrowserCell"];
        }
        
        TTBrowserRepresentation *browserRepresentation = [appDelegate.browserController.allBrowsers objectAtIndex:indexPath.row];
        cell.textLabel.text = browserRepresentation.browser.label;
        cell.detailTextLabel.text = browserRepresentation.browser.browserDescription;
        
        if (browserRepresentation == appDelegate.currentBrowser) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    } else if(indexPath.section == TTAppSettingsViewControllerAddBrowserSection) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BrowserCell"];
        }

        cell.textLabel.text = NSLocalizedString(@"Add Browser", @"Settings Button");
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BrowserCell"];
        }
        
        cell.textLabel.text = NSLocalizedString(@"Credits", @"Settings Button");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return indexPath.section == TTAppSettingsViewControllerBrowsersSection;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TTBrowserRepresentation *browser = [appDelegate.browserController.allBrowsers objectAtIndex:indexPath.row];
        [appDelegate.browserController removeBrowser:browser
                                            callback:^(BOOL success, id response)
         {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationMiddle];
            
            if (appDelegate.browserController.allBrowsers.count == 0) {
                appDelegate.currentBrowser = nil;
                [self dismissViewControllerAnimated:YES completion:^
                {
                    [appDelegate handleInternalURL:[NSURL addBrowserRepresentationFlowURL]];
                }];
            }
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == TTAppSettingsViewControllerBrowsersSection) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSInteger currentBrowserRow = [appDelegate.browserController.allBrowsers indexOfObject:appDelegate.currentBrowser];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentBrowserRow
                                                                                       inSection:TTAppSettingsViewControllerBrowsersSection]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        TTBrowserRepresentation *browser = [appDelegate.browserController.allBrowsers objectAtIndex:indexPath.row];
        [appDelegate handleInternalURL:browser.tabulatabsURL];

        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else if(indexPath.section == TTAppSettingsViewControllerAddBrowserSection) {
        if (indexPath.row == 0) {
            TTWelcomeViewController *welcomeViewController = [[TTWelcomeViewController alloc] init];
            [self.navigationController pushViewController:welcomeViewController animated:YES];
        }
    } else {
        if (indexPath.row == 0) {
            TTCreditsViewController *viewController = [[TTCreditsViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

#pragma mark Helpers

- (void)toggleEditMode:(id)sender;
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

@end
