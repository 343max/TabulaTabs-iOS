//
//  TTAppSettingsViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

NSInteger const TTAppSettingsViewControllerBrowsersSection = 0;

#import "TestFlight.h"

#import "TTBrowserRepresentation.h"
#import "TTBrowserController.h"
#import "TTAppDelegate.h"

#import "TTAppSettingsViewController.h"

@interface TTAppSettingsViewController ()

- (void)dismiss:(id)sender;

@end

@implementation TTAppSettingsViewController

- (void)awakeFromNib;
{
    [TestFlight passCheckpoint:@"Open Settings"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(dismiss:)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section == TTAppSettingsViewControllerBrowsersSection) {
        return appDelegate.browserController.allBrowsers.count;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section != TTAppSettingsViewControllerBrowsersSection) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrowserCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BrowserCell"];
        }
        
        TTBrowserRepresentation *browserRepresentation = [appDelegate.browserController.allBrowsers objectAtIndex:indexPath.row];
        cell.textLabel.text = browserRepresentation.browser.label;
        cell.detailTextLabel.text = browserRepresentation.browser.description;
        
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
    } else {
        
    }
}

#pragma mark Helpers

- (void)dismiss:(id)sender;
{
    [self dismissModalViewControllerAnimated:YES];
}


@end
