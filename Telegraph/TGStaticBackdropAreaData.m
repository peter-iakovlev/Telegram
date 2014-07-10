/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGStaticBackdropAreaData.h"

@implementation TGStaticBackdropAreaData

- (instancetype)initWithBackground:(UIImage *)background
{
    return [self initWithBackground:background mappedRect:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)];
}

- (instancetype)initWithBackground:(UIImage *)background mappedRect:(CGRect)mappedRect
{
    self = [super init];
    if (self != nil)
    {
        _background = background;
        _mappedRect = mappedRect;
    }
    return self;
}

- (void)drawRelativeToImageRect:(CGRect)imageRect
{
    CGRect rect = CGRectMake(imageRect.origin.x + imageRect.size.width * _mappedRect.origin.x, imageRect.origin.y + imageRect.size.height * _mappedRect.origin.y, imageRect.size.width * _mappedRect.size.width, imageRect.size.height * _mappedRect.size.height);
    [_background drawInRect:rect blendMode:kCGBlendModeCopy alpha:1.0f];
}

@end
