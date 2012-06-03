//
//  TTCreditsViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 03.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTCreditsViewController.h"

@interface TTCreditsViewController ()

@property (strong) UIWebView *webView;

@end

@implementation TTCreditsViewController

@synthesize webView = _webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    NSURL *creditsURL = [[NSBundle mainBundle] URLForResource:@"credits" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:creditsURL]];
    
    [self.view addSubview:self.webView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    } else {
        return YES;
    }
}

@end
