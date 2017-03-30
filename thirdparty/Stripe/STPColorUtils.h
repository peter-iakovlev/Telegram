//
//  STPColorUtils.h
//  Stripe
//
//  Created by Jack Flintermann on 5/16/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STPColorUtils : NSObject

+ (CGFloat)perceivedBrightnessForColor:(UIColor *)color;

+ (UIColor *)brighterColor:(UIColor *)color1 color2:(UIColor *)color2;

+ (BOOL)colorIsBright:(UIColor *)color;

@end
