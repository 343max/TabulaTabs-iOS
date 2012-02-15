//
//  TTWelcomeViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "TTWelcomeViewController.h"

@implementation TTWelcomeViewController

- (void)loadView
{
    [super loadView];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSData *htmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"registrationGuide" ofType:@"html"]];
    [webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
    
    webView.delegate = self;
    webView.alpha = 0;
    
    [self.view addSubview:webView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    [UIView animateWithDuration:0.3 animations:^{
        webView.alpha = 1.0;
    }];
}

@end
