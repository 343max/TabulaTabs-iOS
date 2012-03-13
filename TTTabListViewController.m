//
//  TTTabListViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "UIImage+Resizing.h"
#import "MWHTTPImageCache.h"

#import "TTBrowser.h"
#import "TTTab.h"

#import "TTAppDelegate.h"
#import "TTBrowserRepresentation.h"

#import "TTTabTableViewCell.h"
#import "TTTabListViewController.h"

@interface TTTabListViewController ()

- (void)claimClient:(NSString *)claimingPassword;
- (void)browserWasUpdated:(NSNotification *)notification;
- (void)tabsWhereUpdated:(NSNotification *)notification;

@end

@interface TTTabListViewController ()

@property (weak) NSArray *tabs;

@end


@implementation TTTabListViewController

@synthesize browserRepresentation;
@synthesize tabs;

- (void)loadTabs;
{
    [self startLoadingAnimation];
    
    [self.browserRepresentation loadTabs];
    [self.browserRepresentation loadBrowser];
}

#pragma mark Accessors

- (void)setBrowserRepresentation:(TTBrowserRepresentation *)aBrowserRepresentation;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:TTBrowserReprensentationBrowserWasUpdatedNotification 
                                                  object:browserRepresentation];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TTBrowserReprensentationTabsWhereUpdatedNotification
                                                  object:browserRepresentation];
    browserRepresentation = aBrowserRepresentation;
    self.tabs = browserRepresentation.tabs;

    [self browserWasUpdated:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserWasUpdated:)
                                                 name:TTBrowserReprensentationBrowserWasUpdatedNotification
                                               object:browserRepresentation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabsWhereUpdated:)
                                                 name:TTBrowserReprensentationTabsWhereUpdatedNotification
                                               object:browserRepresentation];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tabs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TTTabTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TTTabTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TTTab *tab = [self.tabs objectAtIndex:indexPath.row];
    
    cell.textLabel.text = tab.pageTitle;
    cell.detailTextLabel.text = (tab.siteTitle ? tab.siteTitle : tab.shortDomain);
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.clipsToBounds = YES;
    
    if (tab.pageThumbnailURL) {
        [[MWHTTPImageCache defaultCache] loadImage:tab.pageThumbnailURL
                                 processIdentifier:[NSString stringWithFormat:@"min %@", NSStringFromCGSize(cell.imageView.bounds.size)]
                                   processingBlock:^UIImage *(UIImage *image) {
                                       return [image scaledImageOfMinimumSize:cell.imageView.bounds.size];
                                   } completionBlock:^(UIImage *image) {
                                       cell.imageView.image = image;
                                   }];
    }
    
    if (tab.favIconURL) {
        [[MWHTTPImageCache defaultCache] loadImage:tab.favIconURL
                                   completionBlock:^(NSURLResponse *response, UIImage *image, NSError *error) {
                                       cell.faviconView.image = image;
                                   }];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark PullRefreshTableViewController

- (void)refresh;
{
    [self loadTabs];
}

#pragma mark Helper

- (void)browserWasUpdated:(NSNotification *)notification;
{
    NSLog(@"loaded Browser Info: %@  /  %@", self.browserRepresentation.browser.label, self.browserRepresentation.browser.userAgent);
    self.title = self.browserRepresentation.browser.label;
}

- (void)tabsWhereUpdated:(NSNotification *)notification;
{
    self.tabs = self.browserRepresentation.tabs;
    [self stopLoadingAnimation];
    [self.tableView reloadData];
    
    __block NSIndexPath *selectedRow = nil;
    
    [self.tabs enumerateObjectsUsingBlock:^(TTTab *tab, NSUInteger idx, BOOL *stop) {
        if (tab.selected) {
            selectedRow = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    
    if (selectedRow) {
        [self.tableView selectRowAtIndexPath:selectedRow animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}
     
@end
