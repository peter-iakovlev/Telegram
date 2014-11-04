/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryItemView.h"

#import "TGModernGalleryDefaultFooterView.h"
#import "TGModernGalleryDefaultFooterAccessoryView.h"

@implementation TGModernGalleryItemView

- (void)prepareForRecycle
{
}

- (void)prepareForReuse
{
}

- (void)setIsVisible:(bool)__unused isVisible
{
}

- (void)setIsCurrent:(bool)__unused isCurrent
{
}

- (UIView *)headerView
{
    return nil;
}

- (UIView *)footerView
{
    return nil;
}

- (UIView *)transitionView
{
    return nil;
}

- (CGRect)transitionViewContentRect
{
    return [self transitionView].bounds;
}

- (bool)dismissControllerNowOrSchedule
{
    return true;
}

- (void)setItem:(id<TGModernGalleryItem>)item
{
    [self setItem:item synchronously:false];
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)__unused synchronously
{
    _item = item;
    [self.defaultFooterView setItem:_item];
    [self.defaultFooterAccessoryLeftView setItem:item];
    [self.defaultFooterAccessoryRightView setItem:item];
}

@end
