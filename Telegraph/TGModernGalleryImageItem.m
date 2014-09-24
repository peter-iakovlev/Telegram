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

- (instancetype)initWithUri:(NSString *)uri imageSize:(CGSize)imageSize
{
    self = [super init];
    if (self != nil)
    {
        _uri = uri;
        _imageSize = imageSize;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernGalleryImageItemView class];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TGModernGalleryImageItem class]])
    {
        if (!TGStringCompare(_uri, ((TGModernGalleryImageItem *)object).uri))
            return false;
        
        if (!CGSizeEqualToSize(_imageSize, ((TGModernGalleryImageItem *)object).imageSize))
            return false;
        
        return true;
    }
    
    return false;
}

@end
