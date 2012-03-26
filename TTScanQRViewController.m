//
//  TTScanQRViewController.m
//  TabulaTabs
//
//  Created by Max Winde on 15.02.12.
//  Copyright (c) 2012 projekt Brot. All rights reserved.
//

#import "NSURL+TabulaTabs.h"
#import "MTStatusBarOverlay.h"
#import "TestFlight.h"

#import "TTScanQRViewController.h"

@interface TTScanQRViewController ()

@property (strong) ZBarCameraSimulator *cameraSimulator;

@end


@implementation TTScanQRViewController

@synthesize readerView = _readerView, cameraSimulator = _cameraSimulator;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
    
    [TestFlight passCheckpoint:@"opened QR Code scanner"];
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
        
        [TestFlight passCheckpoint:@"scanned an QR code"];
        [[UIApplication sharedApplication] openURL:[url buildalizedURL]];
    } else {
        [[MTStatusBarOverlay sharedOverlay] postImmediateErrorMessage:@"Invalid QR Code" duration:3.0 animated:YES];
        [TestFlight passCheckpoint:@"scanned an invalid QR code"];
    }
}

@end
