/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEditingScrollView.h"

#import "TGCollectionItem.h"

#import "TGEditableCollectionItemView.h"
#import "TGEditingScrollViewGestureRecognizer.h"

@interface UIScrollView () <UIGestureRecognizerDelegate>

@end

@interface TGEditingScrollView () <UIScrollViewDelegate>
{   
    bool _processedCurrentScroll;
    
    bool _restoreBounds;
    
    TGEditingScrollViewGestureRecognizer *_editingRecognizer;
}

@end

@implementation TGEditingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.scrollsToTop = false;
        self.showsHorizontalScrollIndicator = false;
        self.showsVerticalScrollIndicator = false;
        self.alwaysBounceHorizontal = true;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        
        //_editingRecognizer = [[TGEditingScrollViewGestureRecognizer alloc] init];
        //[self addGestureRecognizer:_editingRecognizer];
        //[self.panGestureRecognizer requireGestureRecognizerToFail:_editingRecognizer];
        
        self.delegate = self;
    }
    return self;
}

- (CGFloat)optionsWidth
{
    return self.contentSize.width - self.bounds.size.width;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)__unused scrollView withVelocity:(CGPoint)__unused velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat optionsWidth = [self optionsWidth];
    
    if (targetContentOffset != NULL)
    {
        if (targetContentOffset->x > optionsWidth / 2.0f)
        {
            targetContentOffset->x = optionsWidth;
            
            [self _setOptionsAreRevealedAndNotify:true];
        }
        else
        {
            targetContentOffset->x = 0.0f;
            
            [self _setOptionsAreRevealedAndNotify:false];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView
{
    if (ABS(self.contentOffset.x) < FLT_EPSILON)
        _processedCurrentScroll = false;
}

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView
{
    if (self.bounds.origin.x > FLT_EPSILON)
    {   
        if (!_processedCurrentScroll)
        {
            _processedCurrentScroll = true;
            
            id<TGEditingScrollViewDelegate> editingDelegate = _editingDelegate;
            if ([editingDelegate respondsToSelector:@selector(editingScrollViewWillRevealOptions:)])
                [editingDelegate editingScrollViewWillRevealOptions:self];
        }
    }
}

- (void)_setOptionsAreRevealedAndNotify:(bool)optionsAreRevealed
{
    if (_optionsAreRevealed != optionsAreRevealed)
        _optionsAreRevealed = optionsAreRevealed;
    
    if (!_optionsAreRevealed && _processedCurrentScroll)
    {
        id<TGEditingScrollViewDelegate> editingDelegate = _editingDelegate;
        if ([editingDelegate respondsToSelector:@selector(editingScrollViewDidHideOptions:)])
            [editingDelegate editingScrollViewDidHideOptions:self];
    }
}

- (void)setOptionsAreRevealed:(bool)optionsAreRevealed
{
    [self setOptionsAreRevealed:optionsAreRevealed animated:false];
}

- (void)setOptionsAreRevealed:(bool)optionsAreRevealed animated:(bool)animated
{
    if (_optionsAreRevealed != optionsAreRevealed)
    {
        _optionsAreRevealed = optionsAreRevealed;
        
        if (_optionsAreRevealed && _processedCurrentScroll)
        {
            _processedCurrentScroll = true;
            
            id<TGEditingScrollViewDelegate> editingDelegate = _editingDelegate;
            if ([editingDelegate respondsToSelector:@selector(editingScrollViewWillRevealOptions:)])
                [editingDelegate editingScrollViewWillRevealOptions:self];
        }
        
        CGPoint targetContentOffset = CGPointMake(_optionsAreRevealed ? [self optionsWidth] : 0.0f, 0.0f);
        
        if (animated)
        {
            [self _postOffsetChangeNotification];
            
            [UIView animateWithDuration:0.3 delay:0.0 options:(iosMajorVersion() >= 7 ? (7 << 16) : 0) animations:^
            {
                [self setContentOffset:targetContentOffset animated:false];
            } completion:nil];
        }
        else
            [self setContentOffset:targetContentOffset animated:false];
    }
}

- (void)setContentSize:(CGSize)contentSize
{
    _restoreBounds = true;
    [super setContentSize:contentSize];
    _restoreBounds = false;
}

- (void)setFrame:(CGRect)frame
{
    _restoreBounds = true;
    [super setFrame:frame];
    _restoreBounds = false;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    contentOffset.x = MAX(0.0f, contentOffset.x);
    [super setContentOffset:contentOffset];
    if ([self.superview isKindOfClass:[UICollectionViewCell class]]) {
        if (((UICollectionViewCell *)self.superview).highlighted)
            [(UICollectionViewCell *)self.superview setHighlighted:false];
    }
    
    [self _postOffsetChangeNotification];
}

- (void)setBounds:(CGRect)bounds
{
    CGRect previousBounds = self.bounds;
    if (_restoreBounds)
        bounds.origin.x = previousBounds.origin.x;
    bounds.origin.x = MAX(0.0f, bounds.origin.x);
    [super setBounds:bounds];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)_postOffsetChangeNotification
{
    id<TGEditingScrollViewDelegate> editingDelegate = _editingDelegate;
    [editingDelegate editingScrollViewOptionsOffsetChanged:self];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer)
        return self.bounds.origin.x > FLT_EPSILON || (!_lockScroll && !_disableScroll);
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark -

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_lockScroll && self.bounds.origin.x < FLT_EPSILON)
    {
        if ([self.superview isKindOfClass:[UICollectionViewCell class]]) {
            if (((TGCollectionItem *)((TGCollectionItemView *)self.superview).boundItem).selectable)
                [(TGCollectionItemView *)self.superview setHighlighted:true];
        }
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.superview isKindOfClass:[UICollectionViewCell class]]) {
        if (((UICollectionViewCell *)self.superview).highlighted)
        {
            [(UICollectionViewCell *)self.superview setHighlighted:false];
            [(TGEditableCollectionItemView *)self.superview _requestSelection];
        }
        else
            [(TGEditableCollectionItemView *)self.superview setShowsEditingOptions:false animated:true];
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.superview isKindOfClass:[UICollectionViewCell class]]) {
        [(UICollectionViewCell *)self.superview setHighlighted:false];
    }
    
    [super touchesCancelled:touches withEvent:event];
}

@end
