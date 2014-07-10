/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryItemView.h"

@implementation TGModernGalleryItemView

- (instancetype)initWithItem:(id<TGModernGalleryItem>)item
{
    self = [super init];
    if (self != nil)
    {
        _item = item;
    }
    return self;
}

- (void)prepareForRecycle
{
}

- (void)prepareForReuse
{
}

- (bool)wantsHeader
{
    return true;
}

- (bool)wantsFooter
{
    return true;
}

- (UIView *)headerView
{
    return nil;
}

- (UIView *)footerView
{
    return nil;
}

- (bool)dismissControllerNowOrSchedule
{
    return true;
}

@end
