//
//  TTWebViewActionSheet.h
//  TabulaTabs
//
//  Created by Max Winde on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import <UIKit/UIKit.h>

@interface TTWebViewActionSheet : UIActionSheet <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

- (id)initWithWebView:(UIWebView *)webView;

@end
