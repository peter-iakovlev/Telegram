/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernViewModel.h"

@interface TGModernImageViewModel : TGModernViewModel

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGBlendMode blendMode;

@property (nonatomic) UIEdgeInsets extendedEdges;
@property (nonatomic) bool accountForTransform;

- (instancetype)initWithImage:(UIImage *)image;

@end
