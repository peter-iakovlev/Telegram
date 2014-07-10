/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGVariantCollectionItem.h"

#import "TGVariantCollectionItemView.h"

@interface TGVariantCollectionItem ()

@end

@implementation TGVariantCollectionItem

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    return [self initWithTitle:title variant:nil action:action];
}

- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _variant = variant;
        _action = action;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGVariantCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44);
}

- (void)bindView:(TGCollectionItemView *)view
{
    [super bindView:view];
    
    [((TGVariantCollectionItemView *)view) setTitle:_title];
    [((TGVariantCollectionItemView *)view) setVariant:_variant];
}

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (void)setTitle:(NSString *)title
{
    if (!TGStringCompare(_title, title))
    {
        _title = title;
        
        if ([self boundView] != nil)
            [((TGVariantCollectionItemView *)[self boundView]) setTitle:_title];
    }
}

- (void)setVariant:(NSString *)variant
{
    if (!TGStringCompare(_variant, variant))
    {
        _variant = variant;
        
        if ([self boundView] != nil)
            [((TGVariantCollectionItemView *)[self boundView]) setVariant:_variant];
    }
}

@end
