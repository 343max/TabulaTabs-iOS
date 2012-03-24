//
//  TTWebViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
