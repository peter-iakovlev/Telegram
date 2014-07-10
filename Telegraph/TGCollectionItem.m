/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionItem.h"

#import "TGCollectionItemView.h"

@interface TGCollectionItem ()
{
    NSString *_viewIdentifier;
}

@end

@implementation TGCollectionItem

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _highlightable = true;
        _selectable = true;
    }
    return self;
}

- (Class)itemViewClass
{
    return nil;
}

- (TGCollectionItemView *)dequeueItemView:(UICollectionView *)collectionView registeredIdentifiers:(NSMutableSet *)registeredIdentifiers forIndexPath:(NSIndexPath *)indexPath
{
    if (_viewIdentifier == nil)
        _viewIdentifier = [[NSString alloc] initWithFormat:@"View_%@", NSStringFromClass([self itemViewClass])];
    if (![registeredIdentifiers containsObject:_viewIdentifier])
    {
        [collectionView registerClass:[self itemViewClass] forCellWithReuseIdentifier:_viewIdentifier];
        [registeredIdentifiers addObject:_viewIdentifier];
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:_viewIdentifier forIndexPath:indexPath];
}

- (void)updateView:(TGCollectionItemView *)view
{
    [self updateView:view animated:false];
}

- (void)updateView:(TGCollectionItemView *)__unused view animated:(bool)__unused animated
{
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 0);
}

- (void)bindView:(TGCollectionItemView *)view
{
    _view = view;
    _view.boundItem = self;
}

- (void)unbindView
{
    _view.boundItem = nil;
    _view = nil;
}

- (TGCollectionItemView *)boundView
{
    return _view;
}

- (void)itemSelected:(id)__unused actionTarget
{
}

- (bool)itemWantsMenu
{
    return false;
}

- (bool)itemCanPerformAction:(SEL)__unused action
{
    return false;
}

- (void)itemPerformAction:(SEL)__unused action
{
}

@end
