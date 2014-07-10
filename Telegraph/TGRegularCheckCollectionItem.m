/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGRegularCheckCollectionItem.h"

#import "TGRegularCheckCollectionItemView.h"

@implementation TGRegularCheckCollectionItem

- (instancetype)initWithTitle:(NSString *)title action:(SEL)action
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _action = action;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGRegularCheckCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

- (void)bindView:(TGRegularCheckCollectionItemView *)view
{
    [super bindView:view];
    
    [(TGRegularCheckCollectionItemView *)view setTitle:_title];
    [(TGRegularCheckCollectionItemView *)view setIsChecked:_isChecked];
}

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([NSStringFromSelector(_action) rangeOfString:@":"].location != NSNotFound)
            [actionTarget performSelector:_action withObject:self];
        else
            [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    if ([self boundView] != nil)
        [(TGRegularCheckCollectionItemView *)[self boundView] setTitle:_title];
}

- (void)setIsChecked:(bool)isChecked
{
    _isChecked = isChecked;
    
    if ([self boundView] != nil)
        [(TGRegularCheckCollectionItemView *)[self boundView] setIsChecked:_isChecked];
}

@end
