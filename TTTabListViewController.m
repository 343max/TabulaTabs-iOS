//
//  TTTabListViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "UIImage+Resize.h"
#import "UIImage+ColorOverlay.h"
#import "UIColor+TabulaTabs.h"
#import "MWHTTPImageCache.h"

#import "TTBrowser.h"
#import "TTTab.h"

#import "TTAppDelegate.h"
#import "TTBrowserRepresentation.h"

#import "TTWebViewController.h"

#import "TTTabTableViewCell.h"
#import "TTTabListViewController.h"

@interface TTTabListViewController ()

- (void)browserWasUpdated:(NSNotification *)notification;
- (void)tabsWhereUpdated:(NSNotification *)notification;

@end

@interface TTTabListViewController ()

@property (weak) NSArray *tabs;

@end


@implementation TTTabListViewController

@synthesize browserRepresentation = _browserRepresentation;
@synthesize tabs = _tabs;

- (id)init;
{
    self = [super init];
    
    if (self) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"=" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Gears"] imageWithColorOverlay:[UIColor whiteColor]]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:appDelegate 
                                                                                action:@selector(showSettings:)];
    }
    
    return self;
}

- (void)loadTabs;
{
    [self startLoadingAnimation];
    
    [self.browserRepresentation loadTabs];
    [self.browserRepresentation loadBrowser];
}

#pragma mark Accessors

- (void)setBrowserRepresentation:(TTBrowserRepresentation *)browserRepresentation;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:TTBrowserReprensentationBrowserWasUpdatedNotification 
                                                  object:_browserRepresentation];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TTBrowserReprensentationTabsWhereUpdatedNotification
                                                  object:_browserRepresentation];
    _browserRepresentation = browserRepresentation;
    self.tabs = _browserRepresentation.tabs;

    [self browserWasUpdated:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserWasUpdated:)
                                                 name:TTBrowserReprensentationBrowserWasUpdatedNotification
                                               object:_browserRepresentation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabsWhereUpdated:)
                                                 name:TTBrowserReprensentationTabsWhereUpdatedNotification
                                               object:_browserRepresentation];
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
    cell.textLabel.textColor = (tab.dominantColor ? tab.dominantColor : [UIColor defaultPageColor]);
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTWebViewController *webViewController = [[TTWebViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:webViewController animated:YES];
    TTTab *tab = [self.tabs objectAtIndex:indexPath.row];
    webViewController.URL = tab.URL;
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
