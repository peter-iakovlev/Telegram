/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <QuartzCore/QuartzCore.h>

@interface TGAnimationBlockDelegate : NSObject

@property (nonatomic) bool removeLayerOnCompletion;
@property (nonatomic) NSNumber *opacityOnCompletion;
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, copy) void (^completion)(BOOL finished);

- (instancetype)initWithLayer:(CALayer *)layer;

@end
