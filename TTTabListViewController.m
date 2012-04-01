//
//  TTTabListViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "ECSlidingViewController.h"

#import "UIImage+Resize.h"
#import "UIImage+ColorOverlay.h"
#import "MWHTTPImageCache.h"

#import "TTBrowser.h"
#import "TTTab.h"

#import "TTAppDelegate.h"
#import "TTBrowserRepresentation.h"

#import "TTWebViewController.h"
#import "TTTopWebViewController.h"

#import "TTTabTableViewCell.h"
#import "TTTabListViewController.h"

@interface TTTabListViewController ()

@property (strong) TTWebViewController *webViewController;
@property (assign) CGFloat browserOverlap;

- (void)browserWasUpdated:(NSNotification *)notification;
- (void)tabsWhereUpdated:(NSNotification *)notification;

- (void)viewDidBecomeInactive:(NSNotification *)notification;
- (void)viewWillBecomeActive:(NSNotification *)notification;

@end

@interface TTTabListViewController ()

@property (weak) NSArray *tabs;

@end


@implementation TTTabListViewController

@synthesize webViewController = _webViewController;
@synthesize browserRepresentation = _browserRepresentation;
@synthesize tabs = _tabs;
@synthesize browserOverlap = _browserOverlap;

- (id)init;
{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewWillBecomeActive:)
                                                     name:ECSlidingViewUnderLeftWillAppear
                                                   object:self.slidingViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewDidBecomeInactive:)
                                                     name:ECSlidingViewTopDidReset
                                                   object:self.slidingViewController];
        
        self.clearsSelectionOnViewWillAppear = NO;
    }
    
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"TabListNavbar"] 
                                                  forBarMetrics:UIBarMetricsDefault];
    
    UIView *stichesView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320, 5)];
    stichesView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TabListStitches"]];
    [self.navigationController.view insertSubview:stichesView atIndex:0];
    
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [settingsButton setImage:[UIImage imageNamed:@"TabListSettingsButton"]
                    forState:UIControlStateNormal];
    [settingsButton addTarget:appDelegate
                       action:@selector(showSettings:)
             forControlEvents:UIControlEventTouchUpInside];
    settingsButton.showsTouchWhenHighlighted = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TabListBackground"]];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.tableView.rowHeight = 70;
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

- (void)viewWillBecomeActive:(NSNotification *)notification;
{
    self.tableView.scrollsToTop = YES;
}

- (void)viewDidBecomeInactive:(NSNotification *)notification;
{
    self.tableView.scrollsToTop = NO;
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
    
    cell.marginRight = self.browserOverlap;
    
    TTTab *tab = [self.tabs objectAtIndex:indexPath.row];
    
    cell.textLabel.text = tab.pageTitle;
    cell.detailTextLabel.text = (tab.siteTitle ? tab.siteTitle : tab.shortDomain);
    cell.imageView.contentMode = UIViewContentModeCenter;
    cell.imageView.clipsToBounds = YES;
    cell.pageColor = [tab.colorPalette objectAtIndex:0];
    
    cell.imageView.image = nil;
    if (tab.pageThumbnailURL) {
        [[MWHTTPImageCache defaultCache] loadImage:tab.pageThumbnailURL
                                 processIdentifier:[NSString stringWithFormat:@"min %@", NSStringFromCGSize(cell.imageView.bounds.size)]
                                   processingBlock:^UIImage *(UIImage *image) {
                                       return [image scaledImageOfMinimumSize:cell.imageSize];
                                   } completionBlock:^(UIImage *image) {
                                       cell.imageView.image = image;
                                       [cell setNeedsLayout];
                                   }];
    }
    
    cell.faviconView.image = nil;
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
    TTTab *tab = [self.tabs objectAtIndex:indexPath.row];

    if ([tab.URL.absoluteString isEqualToString:self.webViewController.URL.absoluteString]) {
        [self.slidingViewController resetTopView];
    } else {
        self.webViewController = [[TTWebViewController alloc] initWithNibName:nil bundle:nil];
        TTTopWebViewController *navigationController = [[TTTopWebViewController alloc] initWithRootViewController:self.webViewController];
        
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            self.slidingViewController.topViewController = navigationController;
            CGRect topViewFrame = self.slidingViewController.underLeftViewController.view.frame;
            topViewFrame.origin.x += topViewFrame.size.width;
            self.slidingViewController.topViewController.view.frame = topViewFrame;
            [self.slidingViewController resetTopViewWithAnimations:nil 
                                                        onComplete:^{
                                                            if (self.browserOverlap == 0) {
                                                                self.browserOverlap = 40.0;
                                                                NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
                                                                [self.tableView reloadData];
                                                                [self.tableView selectRowAtIndexPath:selection
                                                                                            animated:NO
                                                                                      scrollPosition:UITableViewScrollPositionNone];
                                                            }
                                                        }];
        }];
        
        self.webViewController.URL = tab.URL;
    }
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
