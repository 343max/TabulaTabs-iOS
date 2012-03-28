//
//  TTWebViewActionSheet.m
//  TabulaTabs
//
//  Created by Max Winde on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTWebViewActionSheet.h"
#import <Twitter/TWTweetComposeViewController.h>

@interface TTWebViewActionSheet ()

@property (strong) NSURL *URL;
@property (strong) NSString *pageTitle;

@property (assign) NSInteger tweetButtonIndex;
@property (assign) NSInteger emailButtonIndex;
@property (assign) NSInteger messageButtonIndex;
@property (assign) NSInteger openInSafariIndex;

@end


@implementation TTWebViewActionSheet

@synthesize URL = _URL, pageTitle = _pageTitle;
@synthesize tweetButtonIndex = _tweetButtonIndex, emailButtonIndex = _emailButtonIndex, messageButtonIndex = _messageButtonIndex, openInSafariIndex = _openInSafariIndex;

- (id)initWithPageTitle:(NSString *)pageTitle URL:(NSURL *)URL;
{
    self = [super init];
    
    if (self) {
        self.delegate = self;
        self.title = self.pageTitle = pageTitle;
        self.URL = URL;
        self.delegate = self;
        
        self.tweetButtonIndex = self.emailButtonIndex = self.messageButtonIndex = -1;
        
        if ([TWTweetComposeViewController canSendTweet]) {
            [self addButtonWithTitle:@"Tweet"];
            self.tweetButtonIndex = self.numberOfButtons - 1;
        }
        
        if ([MFMailComposeViewController canSendMail]) {
            [self addButtonWithTitle:@"Email Link"];
            self.emailButtonIndex = self.numberOfButtons - 1;
        }
        
        if ([MFMessageComposeViewController canSendText]) {
            [self addButtonWithTitle:@"Send Link in Message"];
            self.messageButtonIndex = self.numberOfButtons - 1;
        }
        
        [self addButtonWithTitle:@"Open Page in Safari"];
        self.openInSafariIndex = self.numberOfButtons - 1;

        [self addButtonWithTitle:@"Cancel"];
        self.cancelButtonIndex = self.numberOfButtons - 1;
    }
    
    return self;
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSLog(@"buttonIndex: %i", buttonIndex);
    
    if (buttonIndex == self.tweetButtonIndex) {
        TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
        [tweetComposer addURL:self.URL];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:tweetComposer animated:YES];
    } else if (buttonIndex == self.emailButtonIndex) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setSubject:self.pageTitle];
        [mailComposer setMessageBody:self.URL.absoluteString isHTML:NO];
        mailComposer.mailComposeDelegate = self;

        [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:mailComposer animated:YES];
    } else if (buttonIndex == self.messageButtonIndex) {
        MFMessageComposeViewController *messageComposer = [[MFMessageComposeViewController alloc] init];
        [messageComposer setBody:self.URL.absoluteString];
        messageComposer.messageComposeDelegate = self;
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:messageComposer animated:YES];
    } else if (buttonIndex == self.openInSafariIndex) {
        [[UIApplication sharedApplication] openURL:self.URL];
    }
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
