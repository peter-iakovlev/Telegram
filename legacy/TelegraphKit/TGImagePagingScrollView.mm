#import "TGImagePagingScrollView.h"

#import "TGImageViewPage.h"

#include <map>
#include <set>

#import <MediaPlayer/MediaPlayer.h>

@interface TGImagePagingScrollView ()

@property (nonatomic, strong) NSMutableArray *playersToRecycle;

@end

@implementation TGImagePagingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    [_visiblePages removeAllObjects];
    [self recyclePlayers];
}

- (void)recyclePlayers
{
    for (MPMoviePlayerController *moviePlayer in _playersToRecycle)
    {
        [moviePlayer.view removeFromSuperview];
        [moviePlayer stop];
    }
    [_playersToRecycle removeAllObjects];
}

- (void)recycleMediaPlayer:(id)mediaPlayer
{
    if (mediaPlayer != nil)
        [_playersToRecycle addObject:mediaPlayer];
}

- (void)commonInit
{
    _lastPageIndex = -1;
    
    _playersToRecycle = [[NSMutableArray alloc] init];
    
    self.pagingEnabled = true;
    self.alwaysBounceHorizontal = true;
    self.alwaysBounceVertical = false;
    self.scrollsToTop = false;
    self.showsVerticalScrollIndicator = false;
    self.showsHorizontalScrollIndicator = false;
    self.delaysContentTouches = false;
    
    _visiblePages = [[NSMutableArray alloc] init];
    _pageViewQueue = [[NSMutableArray alloc] init];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return ![view isKindOfClass:[UISlider class]] && view.tag != ((int)0x6FC81BDB);
}

- (TGImageViewPage *)dequeueImageViewPage
{
    if (_pageViewQueue.count != 0)
    {
        TGImageViewPage *page = [_pageViewQueue objectAtIndex:0];
        [_pageViewQueue removeObjectAtIndex:0];
        return page;
    }
    else
    {
        CGRect frame = self.bounds;
        TGImageViewPage *page = [[TGImageViewPage alloc] initWithFrame:frame];
        page.customCache = _customCache;
        page.delegate = self;
        page.saveToGallery = _saveToGallery;
        page.ignoreSaveToGalleryUid = _ignoreSaveToGalleryUid;
        page.groupIdForDownloadingItems = _groupIdForDownloadingItems;
        [page createScrollView];
        page.watcherHandle = _actionHandle;
        
        return page;
    }
    
    return nil;
}

- (void)updateControlsAlpha:(float)alpha
{
    for (TGImageViewPage *page in _visiblePages)
    {
        [page controlsAlphaUpdated:alpha];
    }
}

- (void)enqueueImageViewPage:(TGImageViewPage *)page
{
    [page loadItem:nil placeholder:nil willAnimateAppear:false];
    
    [_pageViewQueue addObject:page];
}

- (void)setCurrentPageIndex:(int)currentPageIndex
{
    [self setCurrentPageIndex:currentPageIndex force:false];
}

- (void)setCurrentPageIndex:(int)currentPageIndex force:(bool)force
{
    if (currentPageIndex != _currentPageIndex || force)
    {        
        int lastPageIndex = _currentPageIndex;
        _currentPageIndex = currentPageIndex;
        
        id<TGMediaItem> page = nil;
        if (currentPageIndex >= 0 && currentPageIndex < _pageList.count)
            page = [_pageList objectAtIndex:currentPageIndex];
        
        id<TGImagePagingScrollViewDelegate> delegate = _pagingDelegate;
        if (delegate != nil)
            [delegate scrollViewCurrentPageChanged:currentPageIndex imageItem:page];
        
        id<ASWatcher> watcher = _actionHandle.delegate;
        if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        {
            if (currentPageIndex >= 0 && currentPageIndex < _pageList.count)
            {
                if (lastPageIndex >= 0 && lastPageIndex < _pageList.count)
                {
                    id<TGMediaItem> lastPage = [_pageList objectAtIndex:lastPageIndex];
                    
                    NSMutableDictionary *hideDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:lastPage.itemId, @"messageId", [[NSNumber alloc] initWithBool:false], @"hide", nil];
                    if ([lastPage imageInfo] != nil)
                        hideDict[@"imageInfo"] = [lastPage imageInfo];
                    
                    id sender = nil;
                    if ([self.delegate respondsToSelector:@selector(actionsSender)])
                        sender = [(id<TGImagePagingScrollViewDelegate>)self.delegate actionsSender];
                    if (sender != nil)
                        hideDict[@"sender"] = sender;
                    
                    [watcher actionStageActionRequested:@"hideImage" options:hideDict];
                }
                
                NSMutableDictionary *hideDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:page.itemId, @"messageId", [[NSNumber alloc] initWithBool:true], @"hide", nil];
                if ([page imageInfo] != nil)
                    hideDict[@"imageInfo"] = [page imageInfo];
                
                id sender = nil;
                if ([self.delegate respondsToSelector:@selector(actionsSender)])
                    sender = [(id<TGImagePagingScrollViewDelegate>)self.delegate actionsSender];
                if (sender != nil)
                    hideDict[@"sender"] = sender;
                
                [watcher actionStageActionRequested:@"hideImage" options:hideDict];
            }
        }
        
        for (TGImageViewPage *page in _visiblePages)
        {
            if (page.pageIndex != _currentPageIndex)
            {
                [page resetMedia];
            }
        }
        
        [_interfaceHandle requestAction:@"bindPage" options:[self pageForIndex:_currentPageIndex].actionHandle];
    }
}

- (void)setPageList:(NSArray *)pageList
{
    float offsetFromCurrentPage = 0;
    
    NSMutableDictionary *itemIdToIndexInList = nil;
    if (_visiblePages.count != 0)
    {
        itemIdToIndexInList = [[NSMutableDictionary alloc] init];;
        int index = -1;
        for (id<TGMediaItem> imageItem in pageList)
        {
            index++;
            if ([imageItem itemId] != nil)
            {
                [itemIdToIndexInList setObject:[[NSNumber alloc] initWithInt:index] forKey:[imageItem itemId]];
            }
        }
    }
    
    int newCurrentPageIndex = -1;
    
    for (int i = 0; i < (int)_visiblePages.count; i++)
    {
        TGImageViewPage *page = [_visiblePages objectAtIndex:i];
        id itemId = page.itemId;
        
        bool isCurrentPage = page.pageIndex == _currentPageIndex;
        
        if (isCurrentPage)
            offsetFromCurrentPage = page.frame.origin.x - self.contentOffset.x;
        
        NSNumber *nIndex = itemId != nil ? [itemIdToIndexInList objectForKey:itemId] : nil;
        if (nIndex != nil)
        {
            int itemIndex = [nIndex intValue];
            
            page.pageIndex = itemIndex;
            page.frame = CGRectMake(page.pageIndex * self.bounds.size.width + _pageGap / 2, 0, self.bounds.size.width - _pageGap, self.bounds.size.height);
            
            if (isCurrentPage)
                newCurrentPageIndex = itemIndex;
        }
        else
        {
            [self enqueueImageViewPage:page];
            
            [_visiblePages removeObjectAtIndex:i];
            i--;
        }
    }
    
    [_visiblePages sortUsingComparator:^NSComparisonResult(TGImageViewPage *page1, TGImageViewPage *page2)
    {
        return page1.pageIndex < page2.pageIndex ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    bool invalidOrder = false;
    
    int lastIndex = -1;
    for (TGImageViewPage *page in _visiblePages)
    {
        if (lastIndex != -1 && page.pageIndex != lastIndex + 1)
        {
            invalidOrder = true;
            break;
        }
        lastIndex = page.pageIndex;
    }
    
    if (invalidOrder)
    {
        //int focusPageIndex = newCurrentPageIndex != -1 ? newCurrentPageIndex : _currentPageIndex;
        
        TGLog(@"***** Invalid page order");
        
        for (int i = 0; i < _visiblePages.count; i++)
        {
            //if (i == focusPageIndex)
            //    continue;
            
            TGImageViewPage *page = [_visiblePages objectAtIndex:i];
            
            [self enqueueImageViewPage:page];
            
            [_visiblePages removeObjectAtIndex:i];
            i--;
        }
    }
    
    _pageList = pageList;
    
    if (newCurrentPageIndex != -1)
    {
        self.currentPageIndex = newCurrentPageIndex;
    }
    
    if (_currentPageIndex < _pageList.count)
    {
        id<TGMediaItem> lastPage = [_pageList objectAtIndex:_currentPageIndex];
        
        NSMutableDictionary *hideDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:lastPage.itemId, @"messageId", [[NSNumber alloc] initWithBool:true], @"hide", nil];
        if ([lastPage imageInfo] != nil)
            hideDict[@"imageInfo"] = [lastPage imageInfo];
        
        id sender = nil;
        if ([self.delegate respondsToSelector:@selector(actionsSender)])
            sender = [(id<TGImagePagingScrollViewDelegate>)self.delegate actionsSender];
        if (sender != nil)
            hideDict[@"sender"] = sender;
        
        [_actionHandle requestAction:@"hideImage" options:hideDict];
    }
    
    self.contentSize = CGSizeMake(self.bounds.size.width * _pageList.count, self.bounds.size.height);
    self.contentOffset = CGPointMake(_currentPageIndex * self.bounds.size.width + _pageGap / 2 - offsetFromCurrentPage, 0);
    
    [self setNeedsLayout];
}

- (TGImageViewPage *)pageForIndex:(int)index
{
    for (TGImageViewPage *page in _visiblePages)
    {
        if (page.pageIndex == index)
            return page;
    }
    
    return nil;
}

- (void)willAnimateRotation
{
    for (TGImageViewPage *page in _visiblePages)
    {
        [page willAnimateRotation];
    }
}

- (void)didAnimateRotation
{
    for (TGImageViewPage *page in _visiblePages)
    {
        [page didAnimateRotation];
    }
}

- (void)setInitialPageState:(TGImageViewPage *)page
{
    page.autoresizingMask = 0;
    page.frame = CGRectMake(page.pageIndex * self.bounds.size.width + _pageGap / 2, 0, self.bounds.size.width - _pageGap, self.bounds.size.height);
    [_visiblePages addObject:page];
    [self addSubview:page];
    [page controlsAlphaUpdated:[(id<TGImagePagingScrollViewDelegate>)self.delegate controlsAlpha]];
    [page updateControlsOffset:self.frame.origin.y];
    [page resetScrollView];
    
    self.contentOffset = CGPointMake(page.frame.origin.x - _pageGap / 2, 0);
    
    [self setNeedsLayout];
}

- (void)resetOffsetForIndex:(int)index
{
    self.contentOffset = CGPointMake(index * self.bounds.size.width + _pageGap / 2 - _pageGap / 2, 0);
    [self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
    CGRect bounds = frame;
    
    if (!CGSizeEqualToSize(bounds.size, _validSize))
    {        
        int currentPage = 0;
        if (_validSize.width > 1)
            currentPage = (int)((self.contentOffset.x + _validSize.width / 2.0f) / _validSize.width);
        if (currentPage > _pageList.count - 1)
            currentPage = _pageList.count - 1;
        if (currentPage < 0)
            currentPage = 0;
        
        _validSize = bounds.size;
        
        for (TGImageViewPage *page in _visiblePages)
        {
            page.frame = CGRectMake(page.pageIndex * _validSize.width + _pageGap / 2, 0, _validSize.width - _pageGap, _validSize.height);
        }
        
        self.contentSize = CGSizeMake(_validSize.width * _pageList.count, _validSize.height);
        self.contentOffset = CGPointMake(currentPage * bounds.size.width, 0.0f);
    }
    
    if (ABS(self.frame.origin.y - frame.origin.y) > FLT_EPSILON)
    {
        for (TGImageViewPage *page in _visiblePages)
        {
            [page updateControlsOffset:frame.origin.y];
        }
    }
    
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    
    [super layoutSubviews];
    
    std::set<int> validIndices;
    
    float contentOffset = self.contentOffset.x;
    
    float minX = contentOffset - bounds.size.width;
    float maxX = contentOffset + bounds.size.width * 2;
    
    float minResetX = contentOffset + 0.5f;
    float maxResetX = contentOffset + bounds.size.width  - 0.5f;
    
    int visiblePageCount = _visiblePages.count;
    for (int i = 0; i < visiblePageCount; i++)
    {
        TGImageViewPage *page = [_visiblePages objectAtIndex:i];
        CGRect pageFrame = page.frame;
        
        if (pageFrame.origin.x + pageFrame.size.width <= minX || pageFrame.origin.x > maxX)
        {
            //TGLog(@"delete %d", page.pageIndex);
            [self enqueueImageViewPage:page];
            
            [_visiblePages removeObjectAtIndex:i];
            i--;
            visiblePageCount--;
        }
        else
        {
            validIndices.insert(page.pageIndex);
        }
        
        if (pageFrame.origin.x + pageFrame.size.width <= minResetX || pageFrame.origin.x > maxResetX)
        {
            [page resetScrollView];
        }
    }
    
    int pageCount = _pageList.count;
    
    int startPage = 0;
    int endPage = 0;
    
    if (bounds.size.width > 1)
    {
        startPage = (int)((minX - _pageGap / 2) / bounds.size.width + 0.5f);
        endPage = (int)((maxX - _pageGap / 2) / bounds.size.width);
    }
    if (startPage > pageCount - 1)
        startPage = pageCount - 1;
    if (startPage < 0)
        startPage = 0;
    if (endPage > pageCount - 1)
        endPage = pageCount - 1;
    if (endPage < 0)
        endPage = 0;
    
    float controlsOffset = self.frame.origin.y;
    float controlsAlpha = [(id<TGImagePagingScrollViewDelegate>)self.delegate controlsAlpha];
    
    for (int i = startPage; i <= endPage && i < pageCount; i++)
    {
        if (validIndices.find(i) != validIndices.end())
            continue;
        
        //TGLog(@"add %d", i);
        
        TGImageViewPage *page = [self dequeueImageViewPage];
        page.pageIndex = i;
        page.frame = CGRectMake(i * _validSize.width + _pageGap / 2, 0, bounds.size.width - _pageGap, bounds.size.height);
        
        id<TGMediaItem> imageItem = [_pageList objectAtIndex:page.pageIndex];
        
        page.itemId = imageItem.itemId;
        [page loadItem:imageItem placeholder:nil willAnimateAppear:false];
        [page resetScrollView];
        [_visiblePages addObject:page];
        [self addSubview:page];
        [page controlsAlphaUpdated:controlsAlpha];
        [page updateControlsOffset:controlsOffset];
    }
    
    int currentPageIndex = (int)((contentOffset + bounds.size.width / 2) / bounds.size.width);
    if (currentPageIndex > pageCount - 1)
        currentPageIndex = pageCount - 1;
    if (currentPageIndex < 0)
        currentPageIndex = 0;
    
    self.currentPageIndex = currentPageIndex;
    
    if (_canLoadMore && !_loadingMore && ((_reverseOrder && _currentPageIndex <= 5) || (!_reverseOrder && _currentPageIndex >= pageCount - 5)))
    {
        [self loadMoreItems];
    }
}

- (void)loadMoreItems
{
    if (_canLoadMore)
    {
        _loadingMore = true;
        
        id<ASWatcher> watcher = _actionHandle.delegate;
        if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        {
            [watcher actionStageActionRequested:@"loadMoreItems" options:nil];
        }
    }
}

- (void)itemsChanged:(NSArray *)items canLoadMore:(bool)canLoadMore
{
    _canLoadMore = canLoadMore;
    _loadingMore = false;
    
    [self setPageList:items];
}

- (void)pageWillBeginDragging:(UIScrollView *)scrollView
{
    if (_pagingDelegate != nil)
        [_pagingDelegate pageWillBeginDragging:scrollView];
}

- (void)pageDidScroll:(UIScrollView *)scrollView
{
    if (_pagingDelegate != nil)
        [_pagingDelegate pageDidScroll:scrollView];
}

- (void)pageDidEndDragging:(UIScrollView *)scrollView
{
    if (_pagingDelegate != nil)
        [_pagingDelegate pageDidEndDragging:scrollView];
}

@end
