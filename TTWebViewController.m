//
//  TTWebViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestFlight.h"
#import <QuartzCore/QuartzCore.h>

#import "MWSlidingViewController.h"

#import "TTSpinningReloadButton.h"
#import "TTFlippingButton.h"
#import "TTWebViewActionViewController.h"

#import "TTWebViewController.h"

NSString * const TTWebViewControllerStartedLoadingNotification = @"TTWebViewControllerStartedLoadingNotification";
NSString * const TTWebViewControllerFinishedLoadingNotification = @"TTWebViewControllerFinishedLoadingNotification";
CGFloat const TTWebViewControllerNavbarItemWidth = 24.0;

@interface TTWebViewController ()

@property (strong) UIWebView *webView;

@property (strong) UIView *gestureView;
@property (strong) TTFlippingButton *toggleTabListButton;
@property (strong) UIButton *backButton;
@property (strong) UIButton *forwardButton;
@property (strong) TTSpinningReloadButton *reloadButton;
@property (strong) UIButton *actionButton;
@property (strong) UILabel *titleLabel;
@property (strong, nonatomic) NSString *pageTitle;
@property (strong) UINavigationBar *navigationBar;
@property (strong) UIToolbar *toolbar;

@property (strong) TTWebViewActionViewController *actionViewController;

- (void)layoutNavBar;
- (void)didFinishLoading;

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
@synthesize actionViewController = _actionViewController;
@synthesize toolbar = _toolbar;
@synthesize navigationBar = _navigationBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
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

#pragma mark Lifecycle

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    self.view.layer.shadowOffset = CGSizeZero;
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    self.view.clipsToBounds = NO;
    
    [self.navigationBar addGestureRecognizer:self.slidingViewController.panGesture];
    [self.toolbar addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"opened a tab"];
    
    self.toggleTabListButton = [[TTFlippingButton alloc] initWithImage:[UIImage imageNamed:@"BrowserBackToList"]
                                                           shadowImage:[UIImage imageNamed:@"BrowserBackToListShadow"]];
    self.toggleTabListButton.frame = CGRectMake(0.0, 0.0, TTWebViewControllerNavbarItemWidth, 20.0);
    self.toggleTabListButton.showsTouchWhenHighlighted = YES;
    [self.toggleTabListButton addTarget:self 
                                 action:@selector(toggleListVisibility:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, TTWebViewControllerNavbarItemWidth, 20.0)];
    self.backButton.showsTouchWhenHighlighted = YES;
    self.backButton.imageView.contentMode = UIViewContentModeCenter;
    [self.backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"BrowserHistoryBack"] forState:UIControlStateNormal];
    
    self.forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, TTWebViewControllerNavbarItemWidth, 20.0)];
    self.forwardButton.showsTouchWhenHighlighted = YES;
    [self.forwardButton addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton setImage:[UIImage imageNamed:@"BrowserHistoryFwd"] forState:UIControlStateNormal];

    self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, TTWebViewControllerNavbarItemWidth, 20.0)];
    self.actionButton.showsTouchWhenHighlighted = YES;
    [self.actionButton setImage:[UIImage imageNamed:@"BrowserShare"] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(showPageActions:) forControlEvents:UIControlEventTouchUpInside];

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
    [self.gestureView addGestureRecognizer:self.slidingViewController.panGesture];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.slidingViewController
                                                                                           action:@selector(resetTopView)];
    [self.gestureView addGestureRecognizer:tapGestureRecognizer];
    [self.view addSubview:self.gestureView];
    
    self.toolbar = [[UIToolbar alloc] init];
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"BrowserToolbar"]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.toolbar];

    self.toolbar.items = [NSArray arrayWithObjects:
                          [[UIBarButtonItem alloc] initWithCustomView:self.toggleTabListButton],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithCustomView:self.backButton],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithCustomView:self.forwardButton],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [[UIBarButtonItem alloc] initWithCustomView:self.actionButton],
                          nil];
    
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    
    self.reloadButton = [[TTSpinningReloadButton alloc] initWithImage:[UIImage imageNamed:@"BrowserReload"] 
                                                          shadowImage:[UIImage imageNamed:@"BrowserReloadShadow"]];
    self.reloadButton.frame = CGRectMake(0.0, 0.0, TTWebViewControllerNavbarItemWidth, 24.0);
    self.reloadButton.showsTouchWhenHighlighted = YES;
    [self.reloadButton addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.reloadButton];
    
    UIView *emptyLeftView = [[UIView alloc] initWithFrame:self.reloadButton.frame];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:emptyLeftView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    self.titleLabel.numberOfLines = 0;
    navigationItem.titleView = self.titleLabel;
    
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.items = [NSArray arrayWithObject:navigationItem];
    [self.view addSubview:self.navigationBar];
}

- (void)viewDidBecomeActive:(NSNotification *)notification;
{
    self.webView.scrollView.scrollsToTop = YES;
    CGRect gestureViewFrame = self.webView.frame;
    gestureViewFrame.size.width = 1;
    self.gestureView.frame = gestureViewFrame;
    [self.toggleTabListButton setDirection:TTFlippingButtonDirectionLeft animated:YES];
}

- (void)viewWillBecomeInactive:(NSNotification *)notification;
{
    self.webView.scrollView.scrollsToTop = NO;
    self.gestureView.frame = self.webView.frame;
    [self.toggleTabListButton setDirection:TTFlippingButtonDirectionRight animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
        
    [self.webView stopLoading];

    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
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
    
    CGRect navigationBarFrame = self.view.bounds;
    navigationBarFrame.size = [self.navigationBar sizeThatFits:navigationBarFrame.size];
    self.navigationBar.frame = navigationBarFrame;
    
    CGRect toolbarFrame = self.view.bounds;
    toolbarFrame.size = [self.toolbar sizeThatFits:toolbarFrame.size];
    toolbarFrame.origin.y = CGRectGetMaxY(self.view.bounds) - toolbarFrame.size.height;
    self.toolbar.frame = toolbarFrame;
    
    CGFloat titleHeight = self.navigationBar.bounds.size.height - 2.0;
    CGFloat titleWidth = self.navigationBar.bounds.size.width - 2 * TTWebViewControllerNavbarItemWidth;
    self.titleLabel.frame = CGRectMake(0.0, 0.0, titleWidth, titleHeight);
    
    CGRect webViewFrame = self.view.bounds;
    webViewFrame.size.height -= toolbarFrame.size.height;
    self.webView.frame = webViewFrame;
    
    UIEdgeInsets oldContentInset = self.webView.scrollView.contentInset;
    UIEdgeInsets newContentInset = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0.0, 0.0, 0.0);
    self.webView.scrollView.contentInset = newContentInset;
    
    CGPoint contentOffset = self.webView.scrollView.contentOffset;
    contentOffset.y += fminf(0, oldContentInset.top - newContentInset.top);
    self.webView.scrollView.contentOffset = contentOffset;
    
    if (!self.slidingViewController.underLeftShowing) {
        webViewFrame.size.width = 10.0;
    }
    self.gestureView.frame = webViewFrame;
    
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
    self.titleLabel.text = pageTitle;
}

#pragma mark Helpers

- (void)showPageActions:(id)sender;
{
    self.actionViewController = [[TTWebViewActionViewController alloc] initWithWebView:self.webView];
    [self addChildViewController:self.actionViewController];
    self.actionViewController.view.frame = self.view.frame;
    [self.view addSubview:self.actionViewController.view];
}

- (void)layoutNavBar;
{
    CGRect navBarFrame = self.navigationBar.frame;
    navBarFrame.origin.y = roundf(0 - self.webView.scrollView.contentOffset.y - self.webView.scrollView.contentInset.top);
    self.navigationBar.frame = navBarFrame;
    
    UIEdgeInsets scrollIndicatorInsets = UIEdgeInsetsZero;
    scrollIndicatorInsets.top = fmaxf(0.0, -self.webView.scrollView.contentOffset.y);
    self.webView.scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
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
    if (self.webView.loading) {
        [self.webView stopLoading];
    } else {
        [self.webView reload];
    }
}

- (void)toggleListVisibility:(id)sender;
{
    if (self.slidingViewController.underLeftShowing) {
        [self.toggleTabListButton setDirection:TTFlippingButtonDirectionLeft animated:YES];
        [self.slidingViewController resetTopView];
    } else {
        [self.slidingViewController anchorTopViewTo:ECRight];
        [self.toggleTabListButton setDirection:TTFlippingButtonDirectionRight animated:YES];
    }
}

- (void)didFinishLoading;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TTWebViewControllerFinishedLoadingNotification object:self];
    
    self.pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    self.actionButton.enabled = YES;
    self.reloadButton.spinning = NO;
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TTWebViewControllerStartedLoadingNotification object:self];
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    self.actionButton.enabled = NO;
    self.reloadButton.spinning = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
{
    [self didFinishLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [self didFinishLoading];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    [self layoutNavBar];
}

@end
