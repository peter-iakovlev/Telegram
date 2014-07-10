/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGImageLuminanceMap : NSObject

- (instancetype)initWithPixels:(uint8_t *)pixels width:(unsigned int)width height:(unsigned int)height stride:(unsigned int)stride;

- (float)averageLuminanceForArea:(CGRect)area maxWeightedDeviation:(float *)maxWeightedDeviation;

@end
