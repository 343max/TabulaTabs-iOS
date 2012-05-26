//
//  TTAddBrowserFlowViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 27.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImage+ColorOverlay.h"

#import "TTBrowserController.h"
#import "TTAppDelegate.h"
#import "TTWelcomeViewController.h"

#import "TTAddBrowserFlowViewController.h"

@interface TTAddBrowserFlowViewController ()

- (void)dismiss:(id)sender;

@end


@implementation TTAddBrowserFlowViewController

- (id)init;
{
    self = [super init];
    
    if (self) {
        self.delegate = self;
        
        TTWelcomeViewController *welcomeViewController = [[TTWelcomeViewController alloc] init];
        
        [self pushViewController:welcomeViewController animated:NO];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    self.view.layer.cornerRadius = 8.0;
    self.view.clipsToBounds = YES;
}

- (void)dismiss:(id)sender;
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    UIImage *titleImage = [[UIImage imageNamed:@"ToolbarTitle"] imageWithColorOverlay:[UIColor whiteColor]];
    UIImageView *titleView = [[UIImageView alloc] initWithImage:titleImage];
    CGRect titleViewFrame = CGRectZero;
    titleViewFrame.size = titleImage.size;
    titleView.frame = titleViewFrame;
    
    navigationController.navigationBar.topItem.titleView = titleView;
}

@end
