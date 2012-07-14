//
//  TTSocketController.h
//  TabulaTabs
//
//  Created by Max Winde on 14.07.12.
//
//

#import <Foundation/Foundation.h>

extern NSString * const TTSocketControllerCategoryTabs;
extern NSString * const TTSocketControllerCategoryClient;
extern NSString * const TTSocketControllerCategoryBrowsers;

extern NSString * const TTSocketControllerConnectedNotification;
extern NSString * const TTSocketControllerConnectionFailureNotification;

extern NSString * const TTSocketControllerTabsReplacedNotification;
extern NSString * const TTSocketControllerTabsUpdatedNotification;


@class TTEncryption;

@interface TTSocketController : NSObject

@property (assign, readonly) BOOL connected;

- (NSArray *)allCategories;
- (void)connect;

- (void)join:(NSString *)username
    password:(NSString *)password
  categories:(NSArray *)categories
  encryption:(TTEncryption *)encryption;

- (void)leave:(NSString *)username password:(NSString *)password;

@end
