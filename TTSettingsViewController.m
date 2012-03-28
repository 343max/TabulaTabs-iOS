//
//  TTAppSettingsViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

NSInteger const TTAppSettingsViewControllerBrowsersSection = 0;
NSInteger const TTAppSettingsViewControllerAddBrowserSection = 1;

#import "NSURL+TabulaTabs.h"

#import "TTBrowserRepresentation.h"
#import "TTBrowserController.h"

#import "TTWelcomeViewController.h"
#import "TTAppDelegate.h"

#import "TTSettingsViewController.h"

@implementation TTSettingsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
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
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BrowserCell"];
        }
        
        TTBrowserRepresentation *browserRepresentation = [appDelegate.browserController.allBrowsers objectAtIndex:indexPath.row];
        cell.textLabel.text = browserRepresentation.browser.label;
        cell.detailTextLabel.text = browserRepresentation.browser.browserDescription;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BrowserCell"];
        }

        cell.textLabel.text = @"Add Browser";
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == TTAppSettingsViewControllerBrowsersSection) {
        [self dismissViewControllerAnimated:YES completion:^{
            TTBrowserRepresentation *browser = [appDelegate.browserController.allBrowsers objectAtIndex:indexPath.row];
            [[UIApplication sharedApplication] openURL:browser.tabulatabsURL];
        }];
    } else if(indexPath.section == TTAppSettingsViewControllerAddBrowserSection) {
        if (indexPath.row == 0) {
            TTWelcomeViewController *welcomeViewController = [[TTWelcomeViewController alloc] init];
            [self.navigationController pushViewController:welcomeViewController animated:YES];
        }
    }
}

@end
