//
//  TTWebViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestFlight.h"

#import "TTWebViewController.h"

@interface TTWebViewController ()

@property (strong) UIWebView *webView;

@end

@implementation TTWebViewController

@synthesize URL = _URL;
@synthesize webView = _webView;

- (NSURL *)URL;
{
    return self.webView.request.URL;
}

- (void)setURL:(NSURL *)URL;
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"opened a tab"];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = pageTitle;
}

@end
