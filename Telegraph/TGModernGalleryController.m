/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGModernGalleryController.h"

#import "TGHacks.h"

#import "TGModernGalleryView.h"

#import "TGModernGalleryItem.h"
#import "TGModernGalleryScrollView.h"
#import "TGModernGalleryItemView.h"

#import "TGModernGalleryModel.h"

#define TGModernGalleryItemPadding 20.0f

@interface TGModernGalleryController () <UIScrollViewDelegate, TGModernGalleryScrollViewDelegate, TGModernGalleryItemViewDelegate>
{
    NSMutableDictionary *_reusableItemViewsByIdentifier;
    NSMutableArray *_visibleItemViews;
    
    TGModernGalleryScrollView *_scrollView;
}

@end

@implementation TGModernGalleryController

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.automaticallyManageScrollViewInsets = false;
    }
    return self;
}

- (void)dealloc
{
    _scrollView.delegate = nil;
    _scrollView.scrollDelegate = nil;
}

- (void)dismissWhenReady
{
    for (TGModernGalleryItemView *itemView in _visibleItemViews)
    {
        if (itemView.index == [self currentItemIndex])
        {
            if ([itemView dismissControllerNowOrSchedule])
                [self dismiss];
            
            return;
        }
    }
    
    [self dismiss];
}

- (void)setModel:(TGModernGalleryModel *)model
{
    if (_model != model)
    {
        _model = model;
        
        __weak TGModernGalleryController *weakSelf = self;
        _model.itemsUpdated = ^(id<TGModernGalleryItem> item)
        {
            __strong TGModernGalleryController *strongSelf = weakSelf;
            [strongSelf reloadDataAtItem:item];
        };
        
        _model.focusOnItem = ^(id<TGModernGalleryItem> item)
        {
            __strong TGModernGalleryController *strongSelf = weakSelf;
            NSUInteger index = [strongSelf.model.items indexOfObject:item];
            [strongSelf setCurrentItemIndex:index == NSNotFound ? 0 : index];
        };
        
        [self reloadDataAtItem:nil];
    }
}

- (void)itemViewIsReadyForScheduledDismiss:(TGModernGalleryItemView *)__unused itemView
{
    [self dismiss];
}

- (TGModernGalleryItemView *)dequeueViewForItem:(id<TGModernGalleryItem>)item
{
    if (item == nil || [item viewClass] == nil)
        return nil;
    
    NSString *identifier = NSStringFromClass([item viewClass]);
    NSMutableArray *views = _reusableItemViewsByIdentifier[identifier];
    if (views == nil)
    {
        views = [[NSMutableArray alloc] init];
        _reusableItemViewsByIdentifier[identifier] = views;
    }
    
    if (views.count == 0)
    {
        Class itemClass = [item viewClass];
        TGModernGalleryItemView *itemView = [[itemClass alloc] init];
        itemView.delegate = self;
        return itemView;
    }

    TGModernGalleryItemView *itemView = [views lastObject];
    [views removeLastObject];
    
    itemView.delegate = self;
    [itemView prepareForReuse];
    return itemView;
}

- (void)enqueueView:(TGModernGalleryItemView *)itemView
{
    if (itemView == nil)
        return;
    
    itemView.delegate = nil;
    [itemView prepareForRecycle];
    
    NSString *identifier = NSStringFromClass([itemView class]);
    if (identifier != nil)
    {
        NSMutableArray *views = _reusableItemViewsByIdentifier[identifier];
        if (views == nil)
        {
            views = [[NSMutableArray alloc] init];
            _reusableItemViewsByIdentifier[identifier] = views;
        }
        [views addObject:itemView];
    }
}

- (void)loadView
{
    _reusableItemViewsByIdentifier = [[NSMutableDictionary alloc] init];
    _visibleItemViews = [[NSMutableArray alloc] init];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:self.interfaceOrientation];
    self.view = [[TGModernGalleryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenSize.width, screenSize.height)];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _scrollView = [[TGModernGalleryScrollView alloc] initWithFrame:CGRectMake(-TGModernGalleryItemPadding, 0.0f, screenSize.width + TGModernGalleryItemPadding * 2.0f, screenSize.height)];
    _scrollView.scrollDelegate = self;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [TGHacks setApplicationStatusBarAlpha:0.0f];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:self.interfaceOrientation];
    CGRect scrollViewFrame = CGRectMake(-TGModernGalleryItemPadding, 0.0f, screenSize.width + TGModernGalleryItemPadding * 2.0f, screenSize.height);
    if (!CGRectEqualToRect(_scrollView.frame, scrollViewFrame))
    {
        NSUInteger currentItemIndex = [self currentItemIndex];
        _scrollView.frame = scrollViewFrame;
        _scrollView.bounds = CGRectMake(currentItemIndex * scrollViewFrame.size.width, 0.0f, scrollViewFrame.size.width, scrollViewFrame.size.height);
    }
    else
        [self scrollViewBoundsChanged:_scrollView.bounds];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [TGHacks setApplicationStatusBarAlpha:1.0f];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGSize screenSize = [TGViewController screenSizeForInterfaceOrientation:toInterfaceOrientation];
    CGRect scrollViewFrame = CGRectMake(-TGModernGalleryItemPadding, 0.0f, screenSize.width + TGModernGalleryItemPadding * 2.0f, screenSize.height);
    if (!CGRectEqualToRect(_scrollView.frame, scrollViewFrame))
    {
        NSUInteger currentItemIndex = [self currentItemIndex];
        _scrollView.frame = scrollViewFrame;
        _scrollView.bounds = CGRectMake(currentItemIndex * scrollViewFrame.size.width, 0.0f, scrollViewFrame.size.width, scrollViewFrame.size.height);
    }
}

#pragma mark -

- (void)setCurrentItemIndex:(NSUInteger)currentItemIndex
{
    _scrollView.bounds = CGRectMake(_scrollView.bounds.size.width * currentItemIndex, 0.0f, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    
    [self scrollViewBoundsChanged:_scrollView.bounds];
}

- (NSUInteger)currentItemIndex
{
    return _model.items.count == 0 ? 0 : (NSUInteger)[self currentItemFuzzyIndex];
}

- (CGFloat)currentItemFuzzyIndex
{
    if (_model.items.count == 0)
        return 0.0f;
    
    return CGFloor((_scrollView.bounds.origin.x + _scrollView.bounds.size.width / 2.0f) / _scrollView.bounds.size.width);
}

- (void)reloadDataAtItem:(id<TGModernGalleryItem>)item
{
    if (_visibleItemViews.count != 0)
    {
        for (TGModernGalleryItemView *itemView in _visibleItemViews)
        {
            [itemView removeFromSuperview];
            [self enqueueView:itemView];
        }
        [_visibleItemViews removeAllObjects];
    }
    
    NSUInteger index = (item == nil || _model.items == nil) ? NSNotFound : [_model.items indexOfObject:item];
    [self setCurrentItemIndex:index == NSNotFound ? 0 : index];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)__unused scrollView
{
}

- (void)scrollViewBoundsChanged:(CGRect)bounds
{
    CGFloat itemWidth = bounds.size.width;
    
    NSUInteger leftmostVisibleItemIndex = 0;
    if (bounds.origin.x > 0.0f)
        leftmostVisibleItemIndex = (NSUInteger)floor((bounds.origin.x + 1.0f) / itemWidth);
    
    NSUInteger rightmostVisibleItemIndex = _model.items.count - 1;
    if (bounds.origin.x + bounds.size.width < _model.items.count * itemWidth)
    {
        rightmostVisibleItemIndex = (NSUInteger)floorf((bounds.origin.x + bounds.size.width - 1.0f) / itemWidth);
    }
    
    if (leftmostVisibleItemIndex <= rightmostVisibleItemIndex && _model.items.count != 0)
    {
        CGSize contentSize = CGSizeMake(_model.items.count * itemWidth, bounds.size.height);
        if (!CGSizeEqualToSize(_scrollView.contentSize, contentSize))
            _scrollView.contentSize = contentSize;
        
        NSUInteger loadedVisibleViewIndices[16];
        NSUInteger loadedVisibleViewIndexCount = 0;
        
        NSUInteger visibleViewCount = _visibleItemViews.count;
        for (NSUInteger i = 0; i < visibleViewCount; i++)
        {
            TGModernGalleryItemView *itemView = _visibleItemViews[i];
            if (itemView.index < leftmostVisibleItemIndex || itemView.index > rightmostVisibleItemIndex)
            {
                [self enqueueView:itemView];
                [itemView removeFromSuperview];
                [_visibleItemViews removeObjectAtIndex:i];
                i--;
                visibleViewCount--;
            }
            else
            {
                if (loadedVisibleViewIndexCount < 16)
                    loadedVisibleViewIndices[loadedVisibleViewIndexCount++] = itemView.index;
                
                CGRect itemFrame = CGRectMake(itemWidth * itemView.index + TGModernGalleryItemPadding, 0.0f, itemWidth - TGModernGalleryItemPadding * 2.0f, bounds.size.height);
                if (!CGRectEqualToRect(itemView.frame, itemFrame))
                    itemView.frame = itemFrame;
            }
        }
        
        for (NSUInteger i = leftmostVisibleItemIndex; i <= rightmostVisibleItemIndex; i++)
        {
            bool itemHasVisibleView = false;
            for (NSUInteger j = 0; j < loadedVisibleViewIndexCount; j++)
            {
                if (loadedVisibleViewIndices[j] == i)
                {
                    itemHasVisibleView = true;
                    break;
                }
            }
            
            if (!itemHasVisibleView)
            {
                id<TGModernGalleryItem> item = _model.items[i];
                TGModernGalleryItemView *itemView = [self dequeueViewForItem:item];
                if (itemView != nil)
                {
                    itemView.item = item;
                    itemView.index = i;
                    itemView.frame = CGRectMake(itemWidth * i + TGModernGalleryItemPadding, 0.0f, itemWidth - TGModernGalleryItemPadding * 2.0f, bounds.size.height);
                    [_scrollView addSubview:itemView];
                    [_visibleItemViews addObject:itemView];
                }
            }
        }
    }
    else if (_visibleItemViews.count != 0)
    {
        _scrollView.contentSize = CGSizeZero;
        
        for (TGModernGalleryItemView *itemView in _visibleItemViews)
        {
            [itemView removeFromSuperview];
            [self enqueueView:itemView];
        }
        [_visibleItemViews removeAllObjects];
    }
}

@end
