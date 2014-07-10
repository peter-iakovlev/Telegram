/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoEditingVariantCollectionItem.h"

#import "TGUserInfoEditingVariantCollectionItemView.h"

@interface TGUserInfoEditingVariantCollectionItem ()
{
    SEL _action;
    
    NSString *_title;
    NSString *_variant;
}

@end

@implementation TGUserInfoEditingVariantCollectionItem

- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _variant = variant;
        _action = action;
        
        self.transparent = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoEditingVariantCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
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

- (void)bindView:(TGUserInfoEditingVariantCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setVariant:_variant];
}

- (void)setTitle:(NSString *)title
{
    if (!TGStringCompare(_title, title))
    {
        _title = title;
        [(TGUserInfoEditingVariantCollectionItemView *)[self boundView] setTitle:_title];
    }
}

- (void)setVariant:(NSString *)variant
{
    if (!TGStringCompare(_variant, variant))
    {
        _variant = variant;
        [(TGUserInfoEditingVariantCollectionItemView *)[self boundView] setVariant:_variant];
    }
}

@end
