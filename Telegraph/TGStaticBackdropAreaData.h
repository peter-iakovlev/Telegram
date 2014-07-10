/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGStaticBackdropAreaData : NSObject

@property (nonatomic, strong) UIImage *background;
@property (nonatomic) CGRect mappedRect;
@property (nonatomic) CGFloat luminance;

- (instancetype)initWithBackground:(UIImage *)background;
- (instancetype)initWithBackground:(UIImage *)background mappedRect:(CGRect)mappedRect;

- (void)drawRelativeToImageRect:(CGRect)imageRect;

@end
