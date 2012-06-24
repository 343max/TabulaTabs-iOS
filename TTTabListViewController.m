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
#import "TTWindow.h"
#import "TTTab.h"

#import "TTAppDelegate.h"
#import "TTBrowserController.h"
#import "TTBrowserRepresentation.h"

#import "TTWebViewController.h"

#import "TTTabTableViewCell.h"
#import "TTTabListViewController.h"

@interface TTTabListViewController ()

@property (strong) TTWebViewController *webViewController;
@property (assign) CGFloat browserOverlap;

- (void)browserWasUpdated:(NSNotification *)notification;
- (void)windowsAndTabsWhereUpdated:(NSNotification *)notification;

- (void)viewDidBecomeInactive:(NSNotification *)notification;
- (void)viewWillBecomeActive:(NSNotification *)notification;

@end

@interface TTTabListViewController ()

@property (strong, nonatomic) NSArray *windows;

@end


@implementation TTTabListViewController

@synthesize webViewController = _webViewController;
@synthesize browserRepresentation = _browserRepresentation;
@synthesize windows = _windows;
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

- (void)load;
{
    [self startLoadingAnimation];
    
    [self.browserRepresentation loadWindowsAndTabs];
    [self.browserRepresentation loadBrowser];
}

#pragma mark Accessors

- (void)setBrowserRepresentation:(TTBrowserRepresentation *)browserRepresentation;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:TTBrowserRepresentationBrowserWasUpdatedNotification 
                                                  object:_browserRepresentation];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TTBrowserRepresentationWindowsWhereUpdatedNotification
                                                  object:_browserRepresentation];
    
    _browserRepresentation = browserRepresentation;
    self.windows = _browserRepresentation.windows;

    [self browserWasUpdated:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(browserWasUpdated:)
                                                 name:TTBrowserRepresentationBrowserWasUpdatedNotification
                                               object:_browserRepresentation];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowsAndTabsWhereUpdated:)
                                                 name:TTBrowserRepresentationWindowsWhereUpdatedNotification
                                               object:_browserRepresentation];
}

- (void)setWindows:(NSArray *)windows;
{
// removing random sections for reload table testing
//    NSIndexSet *windowIndexes = [windows indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        return rand() > RAND_MAX / 4;
//    }];
//    windows = [windows objectsAtIndexes:windowIndexes];
    
    windows = [windows sortedArrayUsingComparator:^NSComparisonResult(TTWindow *window1, TTWindow *window2) {
        if (window1.focused != window2.focused) {
            return (window1.focused ? NSOrderedAscending : NSOrderedDescending);
        } else {
            return [window1.identifier compare:window2.identifier]; 
        }
    }];
    
    [windows enumerateObjectsUsingBlock:^(TTWindow *window, NSUInteger idx, BOOL *stop) {
// removing random rows for reload table testing
//        NSIndexSet *tabIndexes = [window.tabs indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//            return rand() > RAND_MAX / 4;
//        }];
//        window.tabs = [window.tabs objectsAtIndexes:tabIndexes];
        
        window.tabs = [window.tabs sortedArrayUsingComparator:^NSComparisonResult(TTTab *tab1, TTTab *tab2) {
            if (tab1.index == tab2.index) {
                return NSOrderedSame;
            } else if (tab1.index < tab2.index) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
    }];

    _windows = windows;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.view.layer.cornerRadius = 8.0;
    self.navigationController.view.clipsToBounds = YES;
        
    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    settingsButton.layer.shadowColor = [UIColor blackColor].CGColor;
    settingsButton.layer.shadowOpacity = 0.4;
    settingsButton.layer.shadowRadius = 3.0;
    
    [settingsButton setImage:[UIImage imageNamed:@"TabListSettingsButton"]
                    forState:UIControlStateNormal];
    [settingsButton addTarget:appDelegate
                       action:@selector(showSettings:)
             forControlEvents:UIControlEventTouchUpInside];
    settingsButton.showsTouchWhenHighlighted = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TabListBackground"]];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImageView *navBarShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabListBottomShadow"]];
    navBarShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    navBarShadowView.frame = CGRectMake(0.0, 30.0, self.tableView.bounds.size.width, 37.0);
    [self.navigationController.view insertSubview:navBarShadowView atIndex:0];
    
    self.tableView.rowHeight = 72;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    
    
    UIImageView *tableFooterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabListBottomShadow"]];
    tableFooterImageView.frame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 37.0);
    tableFooterImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 0.0)];
    tableFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tableFooterView addSubview:tableFooterImageView];
    
    self.tableView.tableFooterView = tableFooterView;
    
    
    UIImageView *tableHeaderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TabListTopShadow"]];
    tableHeaderImageView.frame = CGRectMake(0.0, -37.0, self.tableView.bounds.size.width, 37.0);
    tableHeaderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 0.0)];
    tableHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tableHeaderView addSubview:tableHeaderImageView];

    self.refreshLabel.textColor = [UIColor whiteColor];
    self.refreshLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGRect refreshLabelFrame = self.refreshLabel.frame;
    refreshLabelFrame.origin.y -= 50;
    self.refreshLabel.frame = refreshLabelFrame;
    
    [tableHeaderView addSubview:self.refreshLabel];
    [self.refreshArrow removeFromSuperview];
    self.refreshArrow = nil;
    self.refreshSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    CGRect refreshSpinnerFrame = self.refreshSpinner.frame;
    refreshSpinnerFrame.origin.y -= 50;
    self.refreshSpinner.frame = refreshSpinnerFrame;
    [tableHeaderView addSubview:self.refreshSpinner];
    
    self.tableView.tableHeaderView = tableHeaderView;

    [self.tableView reloadData];

    // Default.png preparations
//    self.title = @"";
//    self.tableView.alpha = 0;
//    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    if (appDelegate.browserController.allBrowsers.count > 1) {
        self.navigationController.navigationBar.topItem.titleView = nil;
    } else {
        UIImage *titleImage = [[UIImage imageNamed:@"ToolbarTitle"] imageWithColorOverlay:[UIColor whiteColor]];
        UIImageView *titleView = [[UIImageView alloc] initWithImage:titleImage];
        CGRect titleViewFrame = CGRectZero;
        titleViewFrame.size = titleImage.size;
        titleView.frame = titleViewFrame;
        
        self.navigationController.navigationBar.topItem.titleView = titleView;
    }
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
    return self.windows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((TTWindow *)[self.windows objectAtIndex:section]).tabs.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 0) {
        return NSLocalizedString(@"Front Window", @"window section in tab list");
    } else if (section == 1) {
        return NSLocalizedString(@"Second Window", @"window section in tab list");
    } else if (section == 2) {
        return NSLocalizedString(@"Third Window", @"window section in tab list");
    } else if (section == 3) {
        return NSLocalizedString(@"Fourth Window", @"window section in tab list");
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"%ith Window", @"window section in tab list - allways bigger then 4"), section + 1];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (self.windows.count == 1) {
        return 0;
    } else {
        return 22;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TTTabTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TTTabTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.marginRight = self.browserOverlap;
    
    TTTab *tab = [self tabForIndexPath:indexPath];
    
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
    cell.thumbnailImageURL = thumbnailImageURL;
    
    if (thumbnailImageURL) {
        CGSize imageSize = cell.imageSize;
        [[MWHTTPImageCache defaultCache] loadImage:thumbnailImageURL
                                       cacheFormat:MWHTTPImageCachePersistentCacheFormatJPG
                                 processIdentifier:[NSString stringWithFormat:@"min %@", NSStringFromCGSize(imageSize)]
                                   processingBlock:^UIImage *(UIImage *image) {
                                       return [image scaledImageOfMinimumSize:imageSize];
                                   } 
                                   completionBlock:^(UIImage *image) {
                                       
                                       if ([cell.thumbnailImageURL isEqual:thumbnailImageURL]) {
                                           cell.imageView.image = image;
                                           [cell setNeedsLayout];
                                       }

                                   }];
    }
    
    NSURL *favIconURL = tab.favIconURL;
    cell.favIconURL = favIconURL;
    
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
                                       if ([cell.favIconURL isEqual:favIconURL]) {
                                           cell.faviconView.image = image;
                                       }
                                   }];
    }
    
    [cell setNeedsLayout];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTTab *tab = [self tabForIndexPath:indexPath];

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
    [self load];
}

#pragma mark Helper

- (TTTab *)tabForIndexPath:(NSIndexPath *)indexPath;
{
    TTWindow *window = [self.windows objectAtIndex:indexPath.section];
    return [window.tabs objectAtIndex:indexPath.row];
}

- (void)browserWasUpdated:(NSNotification *)notification;
{
    self.title = self.browserRepresentation.browser.label;
}
     
- (void)windowsAndTabsWhereUpdated:(NSNotification *)notification;
{
    NSArray *oldWindows = self.windows;
    self.windows = self.browserRepresentation.windows;
    NSArray *newWindows = self.windows;

    [self stopLoadingAnimation];
    
    if (!oldWindows) {
        oldWindows = [NSArray array];
    }
    
    [self.tableView beginUpdates]; {
        
        NSIndexSet *deletedSectionIndexes = [oldWindows indexesOfObjectsPassingTest:^BOOL(TTWindow *window, NSUInteger idx, BOOL *stop) {
            return ![newWindows containsObject:window];
        }];
        [self.tableView deleteSections:deletedSectionIndexes withRowAnimation:UITableViewRowAnimationTop];
        
        NSIndexSet *insertedSectionIndexes = [newWindows indexesOfObjectsPassingTest:^BOOL(TTWindow *window, NSUInteger idx, BOOL *stop) {
            return ![oldWindows containsObject:window];
        }];
        [self.tableView insertSections:insertedSectionIndexes withRowAnimation:UITableViewRowAnimationTop];
                
        NSMutableArray *deletedRows = [[NSMutableArray alloc] init];
        NSMutableArray *insertedRows = [[NSMutableArray alloc] init];
        
        [newWindows enumerateObjectsUsingBlock:^(TTWindow *newWindow, NSUInteger newSectionIndex, BOOL *stop) {
            if (![oldWindows containsObject:newWindow]) {
                return;
            }
            
            NSUInteger oldSectionIndex = [oldWindows indexOfObject:newWindow];
            TTWindow *oldWindow = [oldWindows objectAtIndex:oldSectionIndex];
            
            NSIndexSet *deletedRowIndexes = [oldWindow.tabs indexesOfObjectsPassingTest:^BOOL(TTTab *tab, NSUInteger idx, BOOL *stop) {
                return ![newWindow.tabs containsObject:tab];
            }];
            [deletedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger rowIndex, BOOL *stop) {
                [deletedRows addObject:[NSIndexPath indexPathForRow:rowIndex inSection:oldSectionIndex]];
            }];
            
            NSIndexSet *insertedRowIndexes = [newWindow.tabs indexesOfObjectsPassingTest:^BOOL(TTTab *tab, NSUInteger idx, BOOL *stop) {
                return ![oldWindow.tabs containsObject:tab];
            }];
            [insertedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger rowIndex, BOOL *stop) {
                [insertedRows addObject:[NSIndexPath indexPathForRow:rowIndex inSection:newSectionIndex]];
            }];
        }];
        
        [self.tableView deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView insertRowsAtIndexPaths:insertedRows withRowAnimation:UITableViewRowAnimationMiddle];
        
    } @try {
        [self.tableView endUpdates];
    }
    @catch (id Exception) {
        [appDelegate loadTablistViewController];
    }
 }
     
@end
