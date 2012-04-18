//
//  TTTabListViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "MWSlidingViewController.h"

#import "UIImage+Resize.h"
#import "UIImage+ColorOverlay.h"
#import "NSURL+TabulaTabs.h"
#import "MWHTTPImageCache.h"

#import "TTBrowser.h"
#import "TTTab.h"

#import "TTAppDelegate.h"
#import "TTBrowserRepresentation.h"

#import "TTWebViewController.h"

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

@property (strong) NSArray *tabs;

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
                                                    name:TTBrowserRepresentationBrowserWasUpdatedNotification 
                                                  object:_browserRepresentation];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TTBrowserRepresentationTabsWhereUpdatedNotification
                                                  object:_browserRepresentation];
    
    _browserRepresentation = browserRepresentation;
    self.tabs = _browserRepresentation.tabs;

    [self browserWasUpdated:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserWasUpdated:)
                                                 name:TTBrowserRepresentationBrowserWasUpdatedNotification
                                               object:_browserRepresentation];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabsWhereUpdated:)
                                                 name:TTBrowserRepresentationTabsWhereUpdatedNotification
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
    
    self.tableView.rowHeight = 72;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.2];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    if (tab.colorPalette.count > 0) {
        cell.pageColor = [tab.colorPalette objectAtIndex:0];
    } else {
        cell.pageColor = nil;
    }
    
    cell.imageView.image = nil;
    
    NSURL *thumbnailImageURL = tab.pageThumbnailURL;
    
    if ([tab.URL.host isEqualToString:@"maps.google.com"]) {
        thumbnailImageURL = [tab.URL mapImageURLForSize:cell.imageSize scale:0];
    }
    if (thumbnailImageURL) {
        CGSize imageSize = cell.imageSize;
        [[MWHTTPImageCache defaultCache] loadImage:thumbnailImageURL
                                       cacheFormat:MWHTTPImageCachePersistentCacheFormatJPG
                                 processIdentifier:[NSString stringWithFormat:@"min %@", NSStringFromCGSize(imageSize)]
                                   processingBlock:^UIImage *(UIImage *image) {
                                       return [image scaledImageOfMinimumSize:imageSize];
                                   } 
                                   completionBlock:^(UIImage *image) {
                                       cell.imageView.image = image;
                                       [cell setNeedsLayout];
                                   }];
    }
    
    cell.faviconView.image = nil;
    if (tab.favIconURL) {
        CGSize imageSize = cell.favIconSize;
        [[MWHTTPImageCache defaultCache] loadImage:tab.favIconURL
                                       cacheFormat:MWHTTPImageCachePersistentCacheFormatPNG
                                 processIdentifier:[NSString stringWithFormat:@"min %@", NSStringFromCGSize(imageSize)]
                                   processingBlock:^UIImage *(UIImage *image) {
                                       return [image scaledImageOfMinimumSize:imageSize];
                                   } 
                                   completionBlock:^(UIImage *image) {
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
        
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            self.slidingViewController.topViewController = self.webViewController;
            CGRect topViewFrame = self.slidingViewController.underLeftViewController.view.frame;
            topViewFrame.origin.x += topViewFrame.size.width;
            self.slidingViewController.topViewController.view.frame = topViewFrame;
            [self.slidingViewController resetTopViewWithAnimations:nil 
                                                        onComplete:^{
                                                            if (self.browserOverlap == 0) {
                                                                self.browserOverlap = TTAppDelegateWebBrowserPeekAmount;
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
    NSArray *oldTabs = self.tabs;
    NSArray *newTabs = self.browserRepresentation.tabs;
    
    [self stopLoadingAnimation];
    
    self.tabs = newTabs;
    if (!oldTabs) {
        [self.tableView reloadData];
    } else {
        [self.tableView beginUpdates]; {
            NSIndexSet *removedIndexes = [oldTabs indexesOfObjectsPassingTest:^BOOL(TTTab *tab, NSUInteger idx, BOOL *stop) {
                return ![newTabs containsObject:tab];
            }];
            NSMutableArray *removedTabs = [[NSMutableArray alloc] initWithCapacity:removedIndexes.count];
            [removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [removedTabs addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [self.tableView deleteRowsAtIndexPaths:[removedTabs copy] withRowAnimation:UITableViewRowAnimationMiddle];
            
            NSIndexSet *insertedIndexes = [newTabs indexesOfObjectsPassingTest:^BOOL(TTTab *tab, NSUInteger idx, BOOL *stop) {
                return ![oldTabs containsObject:tab];
            }];
            NSMutableArray *insertedTabs = [[NSMutableArray alloc] initWithCapacity:insertedIndexes.count];
            [insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [insertedTabs addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [self.tableView insertRowsAtIndexPaths:[insertedTabs copy] withRowAnimation:UITableViewRowAnimationMiddle];
            NSLog(@"updates: tabsDeleted: %i, tabsInserted: %i", removedTabs.count, insertedTabs.count);
        } [self.tableView endUpdates];
    }
    
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
