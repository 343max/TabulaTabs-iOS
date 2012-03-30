//
//  TTWebViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestFlight.h"
#import <QuartzCore/QuartzCore.h>

#import "ECSlidingViewController.h"

#import "TTSpinningReloadButton.h"
#import "TTWebViewActionSheet.h"

#import "TTWebViewController.h"

NSString * const TTWebViewControllerStartedLoadingNotification = @"TTWebViewControllerStartedLoadingNotification";
NSString * const TTWebViewControllerFinishedLoadingNotification = @"TTWebViewControllerFinishedLoadingNotification";

@interface TTWebViewController ()

@property (strong) UIWebView *webView;

@property (strong) UIView *gestureView;
@property (strong) UIBarButtonItem *toggleTabListButton;
@property (strong) UIButton *backButton;
@property (strong) UIButton *forwardButton;
@property (strong) TTSpinningReloadButton *reloadButton;
@property (strong) UIButton *actionButton;
@property (strong) UILabel *titleLabel;
@property (strong, nonatomic) NSString *pageTitle;
@property (assign, nonatomic) NSInteger connectionCount;

@property (strong) TTWebViewActionSheet *actionSheet;

- (void)layoutNavBar;
- (void)loadingStarted;
- (void)loadingFinished;

- (void)goBack:(id)sender;
- (void)goForward:(id)sender;
- (void)reload:(id)sender;
- (void)showPageActions:(id)sender;
- (void)toggleListVisibility:(id)sender;
- (void)viewWillBecomeInactive:(NSNotification *)notification;
- (void)viewDidBecomeActive:(NSNotification *)notification;

@end

@implementation TTWebViewController

@synthesize URL = _URL;
@synthesize webView = _webView;
@synthesize gestureView = _gestureView;
@synthesize toggleTabListButton = _toggleTabListButton;
@synthesize backButton = _backButton, forwardButton = _forwardButton, reloadButton = _reloadButton;
@synthesize titleLabel = _titleLabel, actionButton = _actionButton;
@synthesize pageTitle = _pageTitle;
@synthesize actionSheet = _actionSheet;
@synthesize connectionCount = _connectionCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.navigationController.toolbarHidden = NO;
        self.toggleTabListButton = [[UIBarButtonItem alloc] initWithTitle:@"="
                                                                    style:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(toggleListVisibility:)];
        
        self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 20.0)];
        self.backButton.showsTouchWhenHighlighted = YES;
        [self.backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
        
        self.forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 20.0)];
        self.forwardButton.showsTouchWhenHighlighted = YES;
        [self.forwardButton addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
        [self.forwardButton setImage:[UIImage imageNamed:@"Forward"] forState:UIControlStateNormal];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewWillBecomeInactive:)
                                                     name:ECSlidingViewUnderLeftWillAppear
                                                   object:self.slidingViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewWillBecomeInactive:)
                                                     name:ECSlidingViewUnderRightWillAppear
                                                   object:self.slidingViewController];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewDidBecomeActive:)
                                                     name:ECSlidingViewTopDidReset
                                                   object:self.slidingViewController];
        
        self.navigationItem.leftItemsSupplementBackButton = YES;
    
        self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
        self.actionButton.showsTouchWhenHighlighted = YES;
        [self.actionButton setImage:[UIImage imageNamed:@"UIButtonBarActionSmall"] forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(showPageActions:) forControlEvents:UIControlEventTouchUpInside];
        
        self.reloadButton = [[TTSpinningReloadButton alloc] initWithImage:[UIImage imageNamed:@"Reload"]];
        self.reloadButton.frame = CGRectMake(0.0, 0.0, 24.0, 20.0);
        self.reloadButton.showsTouchWhenHighlighted = YES;
        [self.reloadButton addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.reloadButton];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        self.titleLabel.numberOfLines = 0;
        self.navigationItem.titleView = self.titleLabel;
    }
    
    return self;
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Accessors

- (NSURL *)URL;
{
    if (self.webView) {
        return self.webView.request.URL;
    } else {
        return _URL;
    }
}

- (void)setURL:(NSURL *)URL;
{
    _URL = URL;
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)setConnectionCount:(NSInteger)connectionCount;
{
    BOOL oldConnectionsInProgress = _connectionCount > 0;    
    _connectionCount = connectionCount;
    BOOL newConnectionsInProgress = _connectionCount > 0;
    
    NSAssert(connectionCount >= 0, @"connection count dorpped below zero");
    
    if (oldConnectionsInProgress != newConnectionsInProgress) {
        if (newConnectionsInProgress) {
            [self loadingStarted];
        } else {
            [self loadingFinished];
        }
    }
}

#pragma mark Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"opened a tab"];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
    
    self.gestureView = [[UIView alloc] initWithFrame:CGRectZero];
    self.gestureView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gestureView.userInteractionEnabled = YES;
    self.gestureView.hidden = YES;
    [self.gestureView addGestureRecognizer:self.slidingViewController.panGesture];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.slidingViewController
                                                                                           action:@selector(resetTopView)];
    [self.gestureView addGestureRecognizer:tapGestureRecognizer];
    [self.view addSubview:self.gestureView];

    self.toolbarItems = [NSArray arrayWithObjects:
                         self.toggleTabListButton,
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithCustomView:self.backButton],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithCustomView:self.forwardButton],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc] initWithCustomView:self.actionButton],
                         nil];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidBecomeActive:(NSNotification *)notification;
{
    self.webView.scrollView.scrollsToTop = YES;
    self.gestureView.hidden = YES;
}

- (void)viewWillBecomeInactive:(NSNotification *)notification;
{
    self.webView.scrollView.scrollsToTop = NO;
    self.gestureView.hidden = NO;
    self.gestureView.frame = self.webView.frame;
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
    
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
    
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect navBarFrame = self.navigationController.navigationBar.frame;
        navBarFrame.origin.y = 0;
        self.navigationController.navigationBar.frame = navBarFrame;
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    self.titleLabel.frame = CGRectZero;
}

- (void)viewDidLayoutSubviews;
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    } else {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    }
    
    CGFloat leftBorder = CGRectGetMaxX(((UIView *)[[self.navigationItem.leftBarButtonItems lastObject] valueForKey:@"view"]).frame);
    CGFloat rightBorder = CGRectGetMinX(((UIView *)[[self.navigationItem.rightBarButtonItems lastObject] valueForKey:@"view"]).frame);
    CGFloat titleHeight = self.navigationController.navigationBar.bounds.size.height - 2.0;
    CGFloat titleWidth = rightBorder - leftBorder;
    NSLog(@"%f |<- %f ->| %f", leftBorder, titleWidth, rightBorder);    
    self.titleLabel.frame = CGRectMake(0.0, 0.0, titleWidth, titleHeight);
    
    CGRect webViewFrame = self.view.bounds;
    webViewFrame.origin.y -= self.navigationController.navigationBar.frame.size.height;
    webViewFrame.size.height += self.navigationController.navigationBar.frame.size.height;
    self.webView.frame = webViewFrame;
    UIEdgeInsets oldContentInset = self.webView.scrollView.contentInset;
    UIEdgeInsets newContentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0.0, 0.0, 0.0);
    self.webView.scrollView.contentInset = newContentInset;
    
    CGPoint contentOffset = self.webView.scrollView.contentOffset;
    contentOffset.y += fminf(0, oldContentInset.top - newContentInset.top);
    self.webView.scrollView.contentOffset = contentOffset;
    
    
    [self layoutNavBar];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.view setNeedsLayout];
}

- (void)setPageTitle:(NSString *)pageTitle;
{
    _pageTitle = pageTitle;
    
    if (_pageTitle) {
        self.titleLabel.text = pageTitle;
        [UIView animateWithDuration:0.1 animations:^{
            self.titleLabel.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.titleLabel.alpha = 0.0;
        }];

    }
}

#pragma mark Helpers

- (void)showPageActions:(id)sender;
{
    self.actionSheet = [[TTWebViewActionSheet alloc] initWithPageTitle:self.pageTitle URL:self.webView.request.URL];
    [self.actionSheet showInView:self.view];
}

- (void)layoutNavBar;
{
    CGRect navBarFrame = self.navigationController.navigationBar.frame;
    navBarFrame.origin.y = roundf(0 - self.webView.scrollView.contentOffset.y - self.webView.scrollView.contentInset.top);
    self.navigationController.navigationBar.frame = navBarFrame;
    
    UIEdgeInsets scrollIndicatorInsets = UIEdgeInsetsZero;
    scrollIndicatorInsets.top = fmaxf(0.0, -self.webView.scrollView.contentOffset.y);
    self.webView.scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (void)loadingStarted;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TTWebViewControllerStartedLoadingNotification object:self];
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    self.actionButton.enabled = NO;
    self.reloadButton.spinning = YES;
    
    self.pageTitle = nil;
}

- (void)loadingFinished;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TTWebViewControllerFinishedLoadingNotification object:self];
    
    self.pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    self.actionButton.enabled = YES;
    self.reloadButton.spinning = NO;
}

- (void)goBack:(id)sender;
{
    [self.webView goBack];
}

- (void)goForward:(id)sender;
{
    [self.webView goForward];
}

- (void)reload:(id)sender;
{
    [self.webView reload];
}

- (void)toggleListVisibility:(id)sender;
{
    if (self.slidingViewController.underLeftShowing) {
        [self.slidingViewController resetTopView];
    } else {
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    self.connectionCount++;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    self.connectionCount--;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    self.connectionCount--;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self layoutNavBar];
}

@end
