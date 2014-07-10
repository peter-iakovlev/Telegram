/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryImageItem.h"

#import "TGModernGalleryImageItemView.h"

@implementation TGModernGalleryImageItem

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo
{
    self = [super init];
    if (self != nil)
    {
        _imageInfo = imageInfo;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernGalleryImageItemView class];
}

@end
