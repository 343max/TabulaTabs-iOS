//
//  UIActionSheetButton.h
//  TabulaTabs
//
//  Created by Max Winde on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTActionSheetButton : UIButton

+ (TTActionSheetButton *)actionSheetButtonWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action;

@end
