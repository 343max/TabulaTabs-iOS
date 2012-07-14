//
//  TTWebViewActionViewController.h
//  TabulaTabs
//
//  Created by Max Winde on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface TTWebViewActionViewController : UIViewController <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

- (id)initWithWebView:(UIWebView *)webView;

@end
