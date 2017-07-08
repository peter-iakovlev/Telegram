/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGCollectionMenuView.h"

#import "TGEditableCollectionItemView.h"

@interface UIScrollView () <UIGestureRecognizerDelegate>

@end

@interface TGCollectionMenuView ()
{
    bool _userRequestedEditing;
    NSIndexPath *_editingCellIndexPath;
    
    CFAbsoluteTime _disableTouchesStartTime;
    CGSize _validSize;
}

@end

@implementation TGCollectionMenuView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self != nil)
    {
        _allowEditingCells = true;
    }
    return self;
}

- (void)updateVisibleItemsNow
{
    CGRect bounds = self.bounds;
    [self setBounds:CGRectOffset(bounds, 0.0f, 0.1f)];
    [self setBounds:bounds];
    [self layoutSubviews];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (isnan(bounds.origin.x)) {
        bounds.origin.x = 0.0f;
    }
    if (isnan(bounds.origin.y)) {
        bounds.origin.y = 0.0f;
    }
    if (isnan(bounds.size.width)) {
        bounds.size.width = 0.0f;
    }
    if (isnan(bounds.size.height)) {
        bounds.size.height = 0.0f;
    }
    
    if (!CGSizeEqualToSize(_validSize, bounds.size)) {
        _validSize = bounds.size;
        if (_layoutForSize) {
            _layoutForSize(bounds.size);
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (!CGSizeEqualToSize(_validSize, frame.size)) {
        _validSize = frame.size;
        if (_layoutForSize) {
            _layoutForSize(frame.size);
        }
    }
}

- (void)reloadData
{
    [super reloadData];
    [self updateVisibleItemsNow];
    [self layoutSubviews];
    
    CGPoint offset = self.contentOffset;
    UIEdgeInsets inset = self.contentInset;
    
    if (offset.y < -inset.top)
    {
        offset.y = -inset.top;
        CGRect bounds = self.bounds;
        bounds.origin.y = offset.y;
        self.bounds = bounds;
    }
}

- (BOOL)canCancelContentTouches
{
    return true;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view
{
    return true;
}

- (void)setEditing:(bool)editing
{
    [self setEditing:editing animated:false];
}

- (void)setEditing:(bool)editing animated:(bool)animated
{
    if (_editing != editing)
    {
        _userRequestedEditing = editing;
        
        _editing = editing;
        _editingCellIndexPath = nil;
        
        for (id cell in [self visibleCells])
        {
            if ([cell isKindOfClass:[TGEditableCollectionItemView class]])
            {
                [(TGEditableCollectionItemView *)cell setShowsDeleteIndicator:_userRequestedEditing && _allowEditingCells animated:animated];
                if (!_editing)
                    [(TGEditableCollectionItemView *)cell setShowsEditingOptions:false animated:animated];
            }
        }
    }
}

- (void)setAllowEditingCells:(bool)allowEditingCells
{
    [self setAllowEditingCells:allowEditingCells animated:false];
}

- (void)setAllowEditingCells:(bool)allowEditingCells animated:(bool)animated
{
    if(_allowEditingCells != allowEditingCells)
    {
        _allowEditingCells = allowEditingCells;
        
        for (id cell in [self visibleCells])
        {
            if ([cell isKindOfClass:[TGEditableCollectionItemView class]])
            {
                [(TGEditableCollectionItemView *)cell setShowsDeleteIndicator:_userRequestedEditing && _allowEditingCells animated:animated];
                if (!_editing)
                    [(TGEditableCollectionItemView *)cell setShowsEditingOptions:false animated:animated];
            }
        }
    }
}

- (void)_setEditingCell:(id)cell editing:(bool)editing
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath != nil)
        [self _setEditingIndexPath:indexPath editing:editing];
}

- (void)_setEditingIndexPath:(NSIndexPath *)indexPath editing:(bool)editing
{
    if (editing)
    {
        if (!_editing)
        {
            _editing = true;
            
            id<TGCollectionMenuViewDelegate> delegate = (id<TGCollectionMenuViewDelegate>)self.delegate;
            if ([delegate respondsToSelector:@selector(collectionMenuViewDidEnterEditingMode:)])
                [delegate collectionMenuViewDidEnterEditingMode:self];
        }
        
        if (_editingCellIndexPath != nil && ![_editingCellIndexPath isEqual:indexPath])
        {
            TGEditableCollectionItemView *previousEditingCell = (TGEditableCollectionItemView *)[self cellForItemAtIndexPath:_editingCellIndexPath];
            if ([previousEditingCell isKindOfClass:[TGEditableCollectionItemView class]])
                [previousEditingCell setShowsEditingOptions:false animated:true];
        }
        
        _editingCellIndexPath = indexPath;
    }
    else if ([_editingCellIndexPath isEqual:indexPath])
    {
        _editingCellIndexPath = nil;
        
        _editing = _userRequestedEditing;
        
        if (!_editing)
        {
            id<TGCollectionMenuViewDelegate> delegate = (id<TGCollectionMenuViewDelegate>)self.delegate;
            if ([delegate respondsToSelector:@selector(collectionMenuViewDidLeaveEditingMode:)])
                [delegate collectionMenuViewDidLeaveEditingMode:self];
        }
    }
}

- (void)_selectCell:(id)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath != nil)
    {
        id<UICollectionViewDelegate> delegate = self.delegate;
        if (![delegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)] || [delegate collectionView:self shouldSelectItemAtIndexPath:indexPath])
        {
            [self selectItemAtIndexPath:indexPath animated:false scrollPosition:UICollectionViewScrollPositionNone];
            
            if ([delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
                [delegate collectionView:self didSelectItemAtIndexPath:indexPath];
        }
    }
}

- (void)setupCellForEditing:(UICollectionViewCell *)cell
{
    if ([cell isKindOfClass:[TGEditableCollectionItemView class]])
    {
        [(TGEditableCollectionItemView *)cell setShowsDeleteIndicator:_userRequestedEditing && _allowEditingCells animated:false];
        if (!_editing)
            [(TGEditableCollectionItemView *)cell setShowsEditingOptions:false animated:false];
    }
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths
{
    if (_editingCellIndexPath != nil && [indexPaths containsObject:_editingCellIndexPath])
    {
        _editingCellIndexPath = nil;
        
        _editing = _userRequestedEditing;
        
        if (!_editing)
        {
            id<TGCollectionMenuViewDelegate> delegate = (id<TGCollectionMenuViewDelegate>)self.delegate;
            if ([delegate respondsToSelector:@selector(collectionMenuViewDidLeaveEditingMode:)])
                [delegate collectionMenuViewDidLeaveEditingMode:self];
        }
    }
    
    [super deleteItemsAtIndexPaths:indexPaths];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_editingCellIndexPath != nil)
    {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:_editingCellIndexPath];
        if (cell == nil)
        {
            [self _setEditingIndexPath:_editingCellIndexPath editing:false];
            
            return nil;
        }
        else
        {
            CGRect frame = cell.frame;
            
            UIView *cellResult = [cell hitTest:CGPointMake(point.x - frame.origin.x, point.y - frame.origin.y) withEvent:event];
            if (cellResult == nil)
            {
                if ([cell isKindOfClass:[TGEditableCollectionItemView class]])
                    [(TGEditableCollectionItemView *)cell setShowsEditingOptions:false animated:true];
                
                [self _setEditingCell:cell editing:false];
                
                _disableTouchesStartTime = CFAbsoluteTimeGetCurrent();
                
                return nil;
            }
            return cellResult;
        }
    }
    
    if (ABS(CFAbsoluteTimeGetCurrent() - _disableTouchesStartTime) < 0.3)
        return nil;
    
    return [super hitTest:point withEvent:event];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
}

@end
