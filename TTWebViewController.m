//
//  TTWebViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestFlight.h"
#import <QuartzCore/QuartzCore.h>

#import "TTSpinningReloadButton.h"

#import "TTWebViewController.h"

@interface TTWebViewController ()

@property (strong) UIWebView *webView;

@property (strong) UIButton *backButton;
@property (strong) UIButton *forwardButton;
@property (strong) TTSpinningReloadButton *reloadButton;
@property (strong) UIButton *actionButton;
@property (strong) UILabel *titleLabel;

- (void)startLoading;

- (void)goBack:(id)sender;
- (void)goForward:(id)sender;
- (void)reload:(id)sender;

@end

@implementation TTWebViewController

@synthesize URL = _URL;
@synthesize webView = _webView;
@synthesize backButton = _backButton, forwardButton = _forwardButton, reloadButton = _reloadButton;
@synthesize titleLabel = _titleLabel, actionButton = _actionButton;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"opened a tab"];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 20.0)];
    self.backButton.showsTouchWhenHighlighted = YES;
    [self.backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    
    self.forwardButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 20.0)];
    self.forwardButton.showsTouchWhenHighlighted = YES;
    [self.forwardButton addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton setImage:[UIImage imageNamed:@"Forward"] forState:UIControlStateNormal];
        
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
                                              [[UIBarButtonItem alloc] initWithCustomView:self.backButton],
                                              [[UIBarButtonItem alloc] initWithCustomView:self.forwardButton],
                                              nil];
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
    self.actionButton.showsTouchWhenHighlighted = YES;
    [self.actionButton setImage:[UIImage imageNamed:@"UIButtonBarActionSmall"] forState:UIControlStateNormal];
    
    self.reloadButton = [[TTSpinningReloadButton alloc] initWithImage:[UIImage imageNamed:@"Reload"]];
    self.reloadButton.frame = CGRectMake(0.0, 0.0, 24.0, 20.0);
    self.reloadButton.showsTouchWhenHighlighted = YES;
    [self.reloadButton addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                               [[UIBarButtonItem alloc] initWithCustomView:self.actionButton],
                                               [[UIBarButtonItem alloc] initWithCustomView:self.reloadButton],
                                               nil];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    self.titleLabel.numberOfLines = 0;
    self.navigationItem.titleView = self.titleLabel;
    
    [self startLoading];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Helpers

- (void)startLoading;
{
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    self.actionButton.enabled = NO;
    self.reloadButton.spinning = YES;
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

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    [self startLoading];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.titleLabel.text = pageTitle;
    
    self.backButton.enabled = webView.canGoBack;
    self.forwardButton.enabled = webView.canGoForward;
    self.actionButton.enabled = YES;
    self.reloadButton.spinning = NO;
}

@end
