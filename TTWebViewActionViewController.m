//
//  TTWebViewActionViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTWebViewActionViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "TTActionSheetButton.h"
#import "NSURL+TabulaTabs.h"
#import "TTGlossyBox.h"
#import <Twitter/TWTweetComposeViewController.h>
#if CONFIGURATION_AdHoc
#import "TestFlight.h"
#endif

@interface TTWebViewActionViewController ()

@property (strong) UIWebView *webView;
@property (strong) TTGlossyBox *backgroundView;
@property (strong, nonatomic, readonly) NSString *pageTitle;
@property (strong, nonatomic, readonly) NSURL *URL;
@property (strong) NSMutableArray *actions;
@property (assign) BOOL animating;

- (void)dismiss:(UITapGestureRecognizer *)gestureRecognizer;

- (void)openWithOnePassword:(id)sender;
- (void)openWithIcab:(id)sender;
- (void)openWithInstapaper:(id)sender;
- (void)copyURL:(id)sender;
- (void)tweetURL:(id)sender;
- (void)emailURL:(id)sender;
- (void)textMessageURL:(id)sender;
- (void)openWithSafari:(id)sender;

@end

@implementation TTWebViewActionViewController

@synthesize webView = _webView;
@synthesize backgroundView = _backgroundView;
@synthesize pageTitle = _pageTitle;
@synthesize URL = _URL;
@synthesize actions = _actions;
@synthesize animating = _animating;

- (id)initWithWebView:(UIWebView *)webView;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.webView = webView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#if CONFIGURATION_AdHoc
    [TestFlight passCheckpoint:@"open action menu"];
#endif
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[TTGlossyBox alloc] init];
    self.backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.backgroundView.layer.shadowOpacity = 1.0;
    self.backgroundView.layer.shadowRadius = 5.0;
    self.backgroundView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    
    [self.view addSubview:self.backgroundView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.actions = [NSMutableArray array];
    
    [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"Copy", @"WebPage Action Sheet action label - copy to clipboard")
                                                                      image:[UIImage imageNamed:@"Clipboard"]
                                                                     target:self
                                                                     action:@selector(copyURL:)]];
    
    if ([MFMessageComposeViewController canSendText]) {
        [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"Message", @"WebPage Action Sheet action label - send as SMS or iMessage")
                                                                          image:[UIImage imageNamed:@"Chat-Bubble"]
                                                                         target:self
                                                                         action:@selector(textMessageURL:)]];
    }
    
    if ([TWTweetComposeViewController canSendTweet]) {
        [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"Twitter", @"WebPage Action Sheet action label")
                                                                          image:[UIImage imageNamed:@"Twitter"]
                                                                         target:self
                                                                         action:@selector(tweetURL:)]];
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"E-Mail", @"WebPage Action Sheet action label")
                                                                          image:[UIImage imageNamed:@"245-paperairplane"]
                                                                         target:self
                                                                         action:@selector(emailURL:)]];
    }
    
    [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"Safari", @"WebPage Action Sheet action label")
                                                                      image:[UIImage imageNamed:@"71-compass"]
                                                                     target:self
                                                                     action:@selector(openWithSafari:)]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"1password://"]]) {
        [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"1Password", @"WebPage Action Sheet action label")
                                                                          image:[UIImage imageNamed:@"1Password"]
                                                                         target:self
                                                                         action:@selector(openWithOnePassword:)]];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"icabmobile://"]]) {
        [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"iCab", @"WebPage Action Sheet action label")
                                                                          image:[UIImage imageNamed:@"iCab"] 
                                                                         target:self
                                                                         action:@selector(openWithIcab:)]];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"x-callback-instapaper://x-callback-url"]]) {
        [self.actions addObject:[TTActionSheetButton actionSheetButtonWithTitle:NSLocalizedString(@"Instapaper", @"WebPage Action Sheet action label")
                                                                          image:[UIImage imageNamed:@"Instapaper"]
                                                                         target:self
                                                                         action:@selector(openWithInstapaper:)]];
    }
    
    [self.actions enumerateObjectsUsingBlock:^(TTActionSheetButton *button, NSUInteger idx, BOOL *stop) {
        [self.backgroundView addSubview:button];
    }];
    
    [self.view setNeedsLayout];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    self.backgroundView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    self.animating = YES;
    self.backgroundView.layer.transform = CATransform3DMakeTranslation(0.0, self.backgroundView.bounds.size.height, 0.0);
    self.backgroundView.alpha = 0.0;
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.backgroundView.layer.transform = CATransform3DIdentity;
                         self.backgroundView.alpha = 1.0;
                     } 
                     completion:^(BOOL finished) {
                         self.animating = NO;
                     }];
}

- (void)viewDidLayoutSubviews;
{
    if (self.animating) {
        return;
    }
    
    CGSize menuMargin = CGSizeMake(6.0, 3.0);
    CGSize buttonSize = CGSizeMake(55, 55);
    NSInteger buttonsPerRow = 4;
    if (self.actions.count % 3 == 0) buttonsPerRow = 3;
    if (self.actions.count % 5 == 0) buttonsPerRow = 5;
    
    NSInteger rows = (int)ceilf((float)self.actions.count / buttonsPerRow);
    
    CGSize viewSize = CGSizeMake(buttonsPerRow * buttonSize.width + 2 * menuMargin.width,
                                 rows * buttonSize.height + 2 * menuMargin.height);
    
    CGRect backgroundViewFrame = CGRectMake((self.view.bounds.size.width - viewSize.width) / 2.0, 
                                            self.view.bounds.size.height - viewSize.height - 15,
                                            viewSize.width,
                                            viewSize.height + menuMargin.height);
    
    self.backgroundView.frame = CGRectIntegral(backgroundViewFrame);
    
    for (NSInteger row = 0; row < rows; row++) {
        for (NSInteger column = 0; column < buttonsPerRow; column++) {
            NSInteger index = row * buttonsPerRow + column;
            
            if (index < self.actions.count) {
                TTActionSheetButton *button = [self.actions objectAtIndex:index];
                CGRect buttonFrame = CGRectMake(buttonSize.width * column + menuMargin.width,
                                                buttonSize.height * row + menuMargin.height,
                                                buttonSize.width,
                                                buttonSize.height);
                button.frame = CGRectIntegral(buttonFrame);
            }
        }
    }
}

#pragma mark Accessors

- (NSString *)pageTitle;
{
    if (!_pageTitle) {
        _pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    return _pageTitle;
}

- (NSURL *)URL;
{
    return self.webView.request.URL;
}


#pragma mark Helpers

- (void)dismiss:(UITapGestureRecognizer *)gestureRecognizer;
{
    if (gestureRecognizer) {
        UIView *touchedView = [self.backgroundView hitTest:[gestureRecognizer locationInView:self.backgroundView] withEvent:nil];
        if (touchedView) {
            return;
        }
    }
    
    self.animating = YES;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.backgroundView.layer.transform = CATransform3DMakeTranslation(0.0, self.backgroundView.bounds.size.height, 0.0);
                         self.backgroundView.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                         self.animating = NO;
                     }];
    
}


#pragma mark Actions

- (void)openWithOnePassword:(id)sender;
{
    NSURL *onePasswordURL = [NSURL URLWithString:[NSString stringWithFormat:@"1password://%@", self.URL.absoluteString]];
    [[UIApplication sharedApplication] openURL:onePasswordURL];
    
    [self dismiss:nil];
}

- (void)openWithIcab:(id)sender;
{
    NSURL *icabURL = [NSURL URLWithString:[self.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@"icabmobile://"]];
    [[UIApplication sharedApplication] openURL:icabURL];

    [self dismiss:nil];
}

- (void)openWithInstapaper:(id)sender;
{
    NSString *instapaperURLString = [NSString stringWithFormat:@"x-callback-instapaper://x-callback-url/add?url=%@&x-success=%@&x-error=%@",
                                     [self.URL.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                     [NSURL launchTabulatabsURL].absoluteString,
                                     [NSURL launchTabulatabsURL].absoluteString];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instapaperURLString]];

    [self dismiss:nil];
}

- (void)copyURL:(id)sender;
{
    [[UIPasteboard generalPasteboard] setURL:self.URL];

    [self dismiss:nil];
}

- (void)tweetURL:(id)sender;
{
    TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
    [tweetComposer addURL:self.URL];
    [tweetComposer setInitialText:self.pageTitle];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:tweetComposer animated:YES];

    [self dismiss:nil];
}

- (void)emailURL:(id)sender;
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    [mailComposer setSubject:self.pageTitle];
    [mailComposer setMessageBody:self.URL.absoluteString isHTML:NO];
    mailComposer.mailComposeDelegate = self;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:mailComposer animated:YES];

    [self dismiss:nil];
}

- (void)textMessageURL:(id)sender;
{
    MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
    [messageComposer setBody:[NSString stringWithFormat:@"%@ %@", self.pageTitle, self.URL.absoluteString]];
    messageComposer.messageComposeDelegate = self;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:messageComposer animated:YES];

    [self dismiss:nil];
}

- (void)openWithSafari:(id)sender;
{
    [[UIApplication sharedApplication] openURL:self.URL];    

    [self dismiss:nil];
}


#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
{
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
{
    [controller dismissModalViewControllerAnimated:YES];
}

@end
