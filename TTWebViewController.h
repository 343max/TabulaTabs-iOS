//
//  TTWebViewController.h
//  TabulaTabs
//
//  Created by Max Winde on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const TTWebViewControllerStartedLoadingNotification;
extern NSString * const TTWebViewControllerFinishedLoadingNotification;

@interface TTWebViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSURL *URL;
@property (strong, nonatomic, readonly) NSString *pageTitle;

@end
