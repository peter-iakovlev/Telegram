/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryVideoItem.h"

#import "TGModernGalleryVideoItemView.h"

@implementation TGModernGalleryVideoItem

- (instancetype)initWithVideoMedia:(TGVideoMediaAttachment *)videoMedia
{
    self = [super init];
    if (self != nil)
    {
        _videoMedia = videoMedia;
    }
    return self;
}

- (Class)viewClass
{
    return [TGModernGalleryVideoItemView class];
}

@end
