//
//  STPColorUtils.m
//  Stripe
//
//  Created by Jack Flintermann on 5/16/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import "STPColorUtils.h"

@implementation STPColorUtils

+ (CGFloat)perceivedBrightnessForColor:(UIColor *)color {
    const CGFloat *component = CGColorGetComponents(color.CGColor);
    CGFloat brightness = ((component[0] * 299) + (component[1] * 587) + (component[2] * 114)) / 1000;
    return brightness;
}

+ (UIColor *)brighterColor:(UIColor *)color1 color2:(UIColor *)color2 {
    CGFloat brightness1 = [self perceivedBrightnessForColor:color1];
    CGFloat brightness2 = [self perceivedBrightnessForColor:color2];
    return brightness1 >= brightness2 ? color1 : color2;
}

+ (BOOL)colorIsBright:(UIColor *)color {
    return [self perceivedBrightnessForColor:color] > 0.3;
}

@end
