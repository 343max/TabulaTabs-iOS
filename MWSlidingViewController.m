//
//  MWSlidingViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 05.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MWSlidingViewController.h"

@interface MWSlidingViewController ()

@end

@implementation MWSlidingViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.shouldAllowUserInteractionsWhenAnchored = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
