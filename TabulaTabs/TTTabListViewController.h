//
//  TTTabListViewController.h
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTBrowserRepresentation;

@interface TTTabListViewController : UITableViewController

@property (strong, nonatomic) TTBrowserRepresentation* browserRepresentation;

- (void)load;

@end
