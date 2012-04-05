//
//  TTTopWebViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 29.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MWSlidingViewController.h"

#import "TTTopWebViewController.h"

@interface TTTopWebViewController ()

@end

@implementation TTTopWebViewController

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    
    self.view.layer.shadowOffset = CGSizeZero;
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    self.view.clipsToBounds = NO;
    
    [self.navigationBar addGestureRecognizer:self.slidingViewController.panGesture];
    [self.toolbar addGestureRecognizer:self.slidingViewController.panGesture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
