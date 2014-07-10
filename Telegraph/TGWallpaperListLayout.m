/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGWallpaperListLayout.h"

#import "TGWallpaperItemsBackgroundDecorationView.h"

@interface TGWallpaperListLayout ()
{
    bool _updatingCollectionItems;
}

@end

@implementation TGWallpaperListLayout

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        [self registerClass:[TGWallpaperItemsBackgroundDecorationView class] forDecorationViewOfKind:@"TGWallpaperItemsBackgroundDecorationView"];
    }
    return self;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    _updatingCollectionItems = true;
    
    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)finalizeCollectionViewUpdates
{
    _updatingCollectionItems = false;
    
    [super finalizeCollectionViewUpdates];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (_updatingCollectionItems || itemIndexPath.section != 0)
        return [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    return nil;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (_updatingCollectionItems || itemIndexPath.section != 0)
        return [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[TGWallpaperItemsBackgroundDecorationView kind] withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    attributes.frame = CGRectMake(0.0f, 106.0f, self.collectionView.frame.size.width, self.collectionViewContentSize.height - 106.0f - 32.0f);
    attributes.zIndex = -1;
    [array addObject:attributes];
    
    return array;
}

@end
