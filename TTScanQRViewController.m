//
//  TTScanQRViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "NSURL+TabulaTabs.h"
#import "MTStatusBarOverlay.h"
#if CONFIGURATION_AdHoc
#import "TestFlight.h"
#endif

#import "TTScanQRViewController.h"

@interface TTScanQRViewController ()

@property (strong) ZBarCameraSimulator *cameraSimulator;

@end


@implementation TTScanQRViewController

@synthesize readerView = _readerView, cameraSimulator = _cameraSimulator;

- (id)init;
{
    self = [super init];
    
    if (self) {
        self.title = @"Add Browser";
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad;
{
	ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];

    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];

    self.readerView = [[ZBarReaderView alloc] initWithImageScanner:scanner];

    if (TARGET_IPHONE_SIMULATOR) {
        self.cameraSimulator = [[ZBarCameraSimulator alloc]
                     initWithViewController: self];
        self.cameraSimulator.readerView = self.readerView;
    }
    
    self.readerView.torchMode = 0;
    self.readerView.readerDelegate = self;
    
    self.readerView.frame = self.view.bounds;
    self.readerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.readerView];
    
    #if CONFIGURATION_AdHoc
    [TestFlight passCheckpoint:@"opened QR Code scanner"];
    #endif
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    [self.readerView start];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    
    [self.readerView stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark ZBarReaderViewDelegate

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image;
{
    ZBarSymbol *symbol = nil;
    
    for (symbol in symbols)
        break;
    
    NSURL *url = [NSURL URLWithString:symbol.data];
    
    if ([url.scheme isEqualToString:@"tabulatabs"]) {
        NSLog(@"scanned URL: %@", url.absoluteString);
        
#if CONFIGURATION_AdHoc
        [TestFlight passCheckpoint:@"scanned an QR code"];
#endif
        [self dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] openURL:[url buildalizedURL]];
        }];
    } else {
        [[MTStatusBarOverlay sharedOverlay] postImmediateErrorMessage:NSLocalizedString(@"Invalid QR Code", @"Status Bar Message")
                                                             duration:3.0
                                                             animated:YES];
#if CONFIGURATION_AdHoc
        [TestFlight passCheckpoint:@"scanned an invalid QR code"];
#endif
    }
}

@end
