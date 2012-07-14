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


@interface TTSocketController : NSObject

@property (assign, readonly) BOOL connected;

- (NSArray *)allCategories;
- (void)connect;
- (void)join:(NSString *)username password:(NSString *)password categories:(NSArray *)categories;
- (void)leave:(NSString *)username password:(NSString *)password;

@end
