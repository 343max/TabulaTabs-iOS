//
//  TTWelcomeViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TTScanQRViewController.h"
#import "TTAppDelegate.h"

#import "TTWelcomeViewController.h"

@implementation TTWelcomeViewController

- (id)init;
{
    self = [super init];
    
    if (self) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Instructions", @"back button title for scanning QR code instructions")
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:nil
                                                                                action:nil];
        self.title = NSLocalizedString(@"Add Browser", @"navbar button title");
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.scrollView.bounces = NO;
    
    NSURL *registrationGuideURL = [[NSBundle mainBundle] URLForResource:@"registrationGuide" withExtension:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:registrationGuideURL]];
    
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSLog(@"URL: %@", request.URL.absoluteString);
    
    if ([request.URL.absoluteString isEqualToString:@"tabulatabs://client/snapcode/"]) {
        TTScanQRViewController *scanQRViewController = [[TTScanQRViewController alloc] init];
        [self.navigationController pushViewController:scanQRViewController animated:YES];
        
        return NO;
    }
    
    return YES;
}

@end
