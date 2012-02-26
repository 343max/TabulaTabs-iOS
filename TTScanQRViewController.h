//
//  TTScanQRViewController.h
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "ZBarSDK.h"

#import <UIKit/UIKit.h>

@interface TTScanQRViewController : UIViewController <ZBarReaderViewDelegate>

@property (strong) IBOutlet ZBarReaderView *readerView;

@end
