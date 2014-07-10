/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGUserInfoVariantCollectionItem.h"

#import "TGUserInfoVariantCollectionItemView.h"

@interface TGUserInfoVariantCollectionItem ()
{
    SEL _action;
}

@end

@implementation TGUserInfoVariantCollectionItem

- (instancetype)initWithTitle:(NSString *)title variant:(NSString *)variant action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        self.transparent = true;
        
        _title = title;
        _variant = variant;
        _action = action;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGUserInfoVariantCollectionItemView class];
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

- (void)bindView:(TGUserInfoVariantCollectionItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title];
    [view setVariant:_variant];
    [view setVariantImage:_variantImage];
}

- (void)setVariant:(NSString *)variant
{
    if (!TGStringCompare(_variant, variant))
    {
        _variant = variant;
        
        [(TGUserInfoVariantCollectionItemView *)[self boundView] setVariant:_variant];
    }
}


- (void)setVariantImage:(UIImage *)variantImage
{
    _variantImage = variantImage;
    
    [(TGUserInfoVariantCollectionItemView *)[self boundView] setVariantImage:_variantImage];
}

@end
