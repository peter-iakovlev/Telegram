#import "TGInstantPageControllerView.h"

#import "TGInstantPageLayout.h"
#import "TGInstantPageTileView.h"
#import "TGInstantPageControllerNavigationBar.h"
#import "TGInstantPageDisplayView.h"
#import "TGInstantPageLinkSelectionView.h"

@interface TGInstantPageControllerViewScrollView : UIScrollView

@end

@implementation TGInstantPageControllerViewScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view {
    return true;
}

@end

@interface TGInstantPageControllerView () <UIScrollViewDelegate> {
    TGInstantPageControllerNavigationBar *_navigationBar;
    UIView *_scrollViewHeader;
    UIScrollView *_scrollView;
    void (^_urlItemTapped)(id);
    void (^_openMediaWrapper)(TGInstantPageMedia *);
    TGEmbedPlayerController *(^_openEmbedFullscreenWrapper)(TGEmbedPlayerView *, UIView *);
    TGEmbedPIPPlaceholderView *(^_openEmbedPIPWrapper)(TGEmbedPlayerView *, UIView *, TGPIPSourceLocation *, TGEmbedPIPCorner, TGEmbedPlayerController *);
    void (^_openFeedbackWrapper)();
    
    TGInstantPageLayout *_currentLayout;
    NSArray<TGInstantPageTile *> *_currentLayoutTiles;
    NSArray<id<TGInstantPageLayoutItem>> *_currentLayoutItemsWithViews;
    NSArray<id<TGInstantPageLayoutItem>> *_currentLayoutItemsWithLinks;
    NSDictionary<NSNumber *, NSNumber *> *_distanceThresholdGroupCount;
    
    NSMutableDictionary<NSNumber *, TGInstantPageTileView *> *_visibleTiles;
    NSMutableDictionary<NSNumber *, UIView<TGInstantPageDisplayView> *> *_visibleItemsWithViews;
    NSMutableDictionary<NSNumber *, NSArray<TGInstantPageLinkSelectionView *> *> *_visibleLinkSelectionViews;
    
    CGPoint _previousContentOffset;
    bool _isDeceleratingBecauseOfDragging;
    
    void (^_scrollAnimationCompletion)(void);
}

@end

@implementation TGInstantPageControllerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _statusBarHeight = 40.0f;
        _navigationBar = [[TGInstantPageControllerNavigationBar alloc] init];
        
        _scrollView = [[TGInstantPageControllerViewScrollView alloc] init];
        
        _scrollViewHeader = [[UIView alloc] init];
        _scrollViewHeader.backgroundColor = [UIColor blackColor];
        [_scrollView addSubview:_scrollViewHeader];
        
        _scrollView.delegate = self;
        _scrollView.alwaysBounceVertical = true;
        _scrollView.delaysContentTouches = false;
        _scrollView.canCancelContentTouches = true;
        
        self.backgroundColor = [UIColor whiteColor];
        
        _visibleTiles = [[NSMutableDictionary alloc] init];
        _visibleItemsWithViews = [[NSMutableDictionary alloc] init];
        _visibleLinkSelectionViews = [[NSMutableDictionary alloc] init];
        
        [self addSubview:_scrollView];
        [self addSubview:_navigationBar];
        
        __weak TGInstantPageControllerView *weakSelf = self;
        _navigationBar.backPressed = ^{
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_backPressed) {
                strongSelf->_backPressed();
            }
        };
        _navigationBar.sharePressed = ^{
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_sharePressed) {
                strongSelf->_sharePressed();
            }
        };
        _navigationBar.scrollToTop = ^{
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_scrollView setContentOffset:CGPointMake(0.0f, -64.0f) animated:true];
            }
        };
        
        _urlItemTapped = ^(id item) {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([item isKindOfClass:[TGRichTextUrl class]]) {
                    NSString *url = ((TGRichTextUrl *)item).url;
                    int64_t webpageId = ((TGRichTextUrl *)item).webpageId;
                    NSRange anchorRange = [url rangeOfString:@"#"];
                    bool foundAnchor = false;
                    if (anchorRange.location != NSNotFound) {
                        NSString *anchor = [url substringFromIndex:anchorRange.location + anchorRange.length];
                        if (anchor.length != 0) {
                            for (id<TGInstantPageLayoutItem> item in strongSelf->_currentLayout.items) {
                                if ([item respondsToSelector:@selector(matchesAnchor:)] && [item matchesAnchor:anchor]) {
                                    [strongSelf->_scrollView setContentOffset:CGPointMake(0.0f, item.frame.origin.y) animated:true];
                                    foundAnchor = true;
                                    break;
                                }
                            }
                        }
                    }
                    if (!foundAnchor && strongSelf->_openUrl) {
                        strongSelf->_openUrl(url, webpageId);
                    }
                }
            }
        };
        
        _openMediaWrapper = ^(TGInstantPageMedia *centralMedia) {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_openMedia) {
                    NSMutableArray *medias = [[NSMutableArray alloc] init];
                    for (id<TGInstantPageLayoutItem> item in strongSelf->_currentLayout.items) {
                        for (TGInstantPageMedia *media in [item medias]) {
                            [medias addObject:media];
                        }
                    }
                    if (medias.count == 0) {
                        [medias addObject:centralMedia];
                    }
                    strongSelf->_openMedia(medias, centralMedia);
                }
            }
        };
        
        _openEmbedFullscreenWrapper = ^TGEmbedPlayerController *(TGEmbedPlayerView *playerView, UIView *view)
        {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_openEmbedFullscreen) {
                    return strongSelf->_openEmbedFullscreen(playerView, view);
                }
            }
            return nil;
        };
        
        _openEmbedPIPWrapper = ^TGEmbedPIPPlaceholderView *(TGEmbedPlayerView *playerView, UIView *view, TGPIPSourceLocation *location, TGEmbedPIPCorner corner, TGEmbedPlayerController *controller)
        {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_openEmbedPIP) {
                    return strongSelf->_openEmbedPIP(playerView, view, location, corner, controller);
                }
            }
            return nil;
        };
        
        _openFeedbackWrapper = ^{
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_openFeedback) {
                    strongSelf->_openFeedback();
                }
            }
        };
    }
    return self;
}

- (void)updateLayout {
    _currentLayout = [TGInstantPageLayout makeLayoutForWebPage:_webPage peerId:_peerId messageId:_messageId boundingWidth:self.bounds.size.width];
    [_visibleTiles enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGInstantPageTileView *tileView, __unused BOOL *stop) {
        [tileView removeFromSuperview];
    }];
    [_visibleTiles removeAllObjects];
    
    [_visibleLinkSelectionViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, NSArray<TGInstantPageLinkSelectionView *> *linkViews, __unused BOOL *stop) {
        for (UIView *linkView in linkViews) {
            [linkView removeFromSuperview];
        }
    }];
    
    _currentLayoutTiles = [TGInstantPageTile tilesWithLayout:_currentLayout boundingWidth:self.bounds.size.width];
    NSMutableArray *currentLayoutItemsWithViews = [[NSMutableArray alloc] init];
    NSMutableArray *currentLayoutItemsWithLinks = [[NSMutableArray alloc] init];
    NSMutableDictionary *distanceThresholdGroupCount = [[NSMutableDictionary alloc] init];
    for (id<TGInstantPageLayoutItem> item in _currentLayout.items) {
        if ([item respondsToSelector:@selector(view)]) {
            [currentLayoutItemsWithViews addObject:item];
            int32_t currentCount = [distanceThresholdGroupCount[@([item distanceThresholdGroup])] intValue];
            distanceThresholdGroupCount[@([item distanceThresholdGroup])] = @(currentCount + 1);
        }
        if ([item hasLinks]) {
            [currentLayoutItemsWithLinks addObject:item];
        }
    }
    _currentLayoutItemsWithViews = currentLayoutItemsWithViews;
    _distanceThresholdGroupCount = distanceThresholdGroupCount;
    _currentLayoutItemsWithLinks = currentLayoutItemsWithLinks;
    
    _scrollView.contentSize = _currentLayout.contentSize;
    [self updateNavigationBar];
}

- (void)setWebPage:(TGWebPageMediaAttachment *)webPage {
    _webPage = webPage;
    _currentLayout = nil;
    [self updateLayout];
    _scrollView.frame = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    [self setNeedsLayout];
}

- (void)scrollToEmbedIndex:(int32_t)embedIndex animated:(bool)animated completion:(void (^)(void))completion {
    id<TGInstantPageLayoutItem> embedItem = nil;
    
    for (id<TGInstantPageLayoutItem> item in _currentLayout.items) {
        if ([item respondsToSelector:@selector(matchesEmbedIndex:)] && [item matchesEmbedIndex:embedIndex]) {
            embedItem = item;
            break;
        }
    }
    
    if (embedItem == nil) {
        return;
    }
    
    [self layoutSubviews];
    
    CGRect targetFrame = embedItem.frame;
    CGPoint targetContentOffset = CGPointMake(0.0f, MIN(MAX(-_scrollView.contentInset.top, targetFrame.origin.y - (_scrollView.frame.size.height - targetFrame.size.height) / 2.0f), MAX(-_scrollView.contentInset.top, _scrollView.contentSize.height - _scrollView.frame.size.height)));
    
    if (animated) {
        _scrollAnimationCompletion = [completion copy];
        [_scrollView setContentOffset:targetContentOffset animated:true];
    } else {
        _scrollView.contentOffset = targetContentOffset;
        if (completion != nil)
            completion();
    }
}

- (void)cancelPIPWithEmbedIndex:(int32_t)embedIndex {
    id<TGInstantPageLayoutItem> embedItem = nil;
    
    for (id<TGInstantPageLayoutItem> item in _currentLayout.items) {
        if ([item respondsToSelector:@selector(matchesEmbedIndex:)] && [item matchesEmbedIndex:embedIndex]) {
            embedItem = item;
            break;
        }
    }
    
    if (embedItem == nil) {
        return;
    }

    for (UIView<TGInstantPageDisplayView> *itemView in [_visibleItemsWithViews allValues]) {
        if ([embedItem matchesView:itemView]) {
            [itemView cancelPIP];
            break;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    if (!CGSizeEqualToSize(bounds.size, _scrollView.bounds.size)) {
        if (ABS(bounds.size.width - _scrollView.bounds.size.width) > FLT_EPSILON) {
            [self updateLayout];
        }
        _scrollView.frame = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height);
        _scrollViewHeader.frame = CGRectMake(0.0f, -2000.0f, bounds.size.width, 2000.0f);
        _scrollView.contentInset = UIEdgeInsetsMake(_statusBarHeight + 44.0f, 0.0f, 0.0f, 0.0f);
        if (_visibleItemsWithViews.count == 0 && _visibleTiles.count == 0) {
            _scrollView.contentOffset = CGPointMake(0.0f, -20.0f);
        }
        [self updateVisibleItems];
        
        [self updateNavigationBar];
    }
}

- (void)updateVisibleItems {
    NSMutableSet *visibleTileIndices = [[NSMutableSet alloc] init];
    NSMutableSet *visibleItemIndices = [[NSMutableSet alloc] init];
    NSMutableSet *visibleItemLinkIndices = [[NSMutableSet alloc] init];
    
    CGRect visibleBounds = _scrollView.bounds;
    
    UIView *topView = nil;
    for (UIView *subview in _scrollView.subviews.reverseObjectEnumerator) {
        if (subview.tag == 4321) {
            topView = subview;
            break;
        }
    }
    
    NSInteger tileIndex = -1;
    for (TGInstantPageTile *tile in _currentLayoutTiles) {
        tileIndex++;
        if (CGRectIntersectsRect(tile.frame, visibleBounds)) {
            [visibleTileIndices addObject:@(tileIndex)];
            
            if (_visibleTiles[@(tileIndex)] == nil) {
                TGInstantPageTileView *tileView = [[TGInstantPageTileView alloc] initWithTile:tile];
                tileView.frame = tile.frame;
                tileView.tag = 4321;
                if (topView == nil) {
                    [_scrollView insertSubview:tileView atIndex:0];
                } else {
                    [_scrollView insertSubview:tileView aboveSubview:topView];
                }
                topView = tileView;
                _visibleTiles[@(tileIndex)] = tileView;
            }
        }
    }
    
    NSInteger itemIndex = -1;
    for (id<TGInstantPageLayoutItem> item in _currentLayoutItemsWithViews) {
        itemIndex++;
        CGFloat itemThreshold = [item distanceThresholdWithGroupCount:_distanceThresholdGroupCount];
        CGRect itemFrame = item.frame;
        itemFrame.origin.y -= itemThreshold;
        itemFrame.size.height += itemThreshold + itemThreshold;
        if (CGRectIntersectsRect(itemFrame, visibleBounds)) {
            [visibleItemIndices addObject:@(itemIndex)];
            
            UIView<TGInstantPageDisplayView> *itemView = _visibleItemsWithViews[@(itemIndex)];
            if (itemView != nil) {
                if (![item matchesView:itemView]) {
                    [itemView removeFromSuperview];
                    [_visibleItemsWithViews removeObjectForKey:@(itemIndex)];
                    itemView = nil;
                }
            }
            
            if (itemView == nil) {
                UIView<TGInstantPageDisplayView> *itemView = [item view];
                itemView.tag = 4321;
                if (topView == nil) {
                    [_scrollView insertSubview:itemView atIndex:0];
                } else {
                    [_scrollView insertSubview:itemView aboveSubview:topView];
                }
                topView = itemView;
                _visibleItemsWithViews[@(itemIndex)] = itemView;
                if ([itemView respondsToSelector:@selector(setOpenMedia:)]) {
                    [itemView setOpenMedia:_openMediaWrapper];
                }
                if ([itemView respondsToSelector:@selector(setOpenEmbedFullscreen:)]) {
                    [itemView setOpenEmbedFullscreen:_openEmbedFullscreenWrapper];
                }
                if ([itemView respondsToSelector:@selector(setOpenEmbedPIP:)]) {
                    [itemView setOpenEmbedPIP:_openEmbedPIPWrapper];
                }
                if ([itemView respondsToSelector:@selector(setOpenFeedback:)]) {
                    [itemView setOpenFeedback:_openFeedbackWrapper];
                }
            } else if (!CGRectEqualToRect(itemView.frame, item.frame)) {
                itemView.frame = item.frame;
            }
            
            if ([itemView respondsToSelector:@selector(updateScreenPosition:screenSize:)]) {
                [itemView updateScreenPosition:[itemView convertRect:itemView.bounds toView:self] screenSize:self.bounds.size];
            }
        }
    }
    itemIndex = -1;
    for (id<TGInstantPageLayoutItem> item in _currentLayoutItemsWithLinks) {
        itemIndex++;
        CGRect itemFrame = item.frame;
        if (CGRectIntersectsRect(itemFrame, visibleBounds)) {
            [visibleItemLinkIndices addObject:@(itemIndex)];
            
            if (_visibleLinkSelectionViews[@(itemIndex)] == nil) {
                NSArray<TGInstantPageLinkSelectionView *> *linkViews = [item linkSelectionViews];
                for (TGInstantPageLinkSelectionView *linkView in linkViews) {
                    linkView.itemTapped = _urlItemTapped;
                    
                    [_scrollView addSubview:linkView];
                }
                _visibleLinkSelectionViews[@(itemIndex)] = linkViews;
            }
        }
    }
    
    NSMutableArray *removeTileIndices = [[NSMutableArray alloc] init];
    [_visibleTiles enumerateKeysAndObjectsUsingBlock:^(NSNumber *nIndex, TGInstantPageTileView *tileView, __unused BOOL *stop) {
        if (![visibleTileIndices containsObject:nIndex]) {
            [tileView removeFromSuperview];
            [removeTileIndices addObject:nIndex];
        }
    }];
    [_visibleTiles removeObjectsForKeys:removeTileIndices];
    
    NSMutableArray *removeItemIndices = [[NSMutableArray alloc] init];
    [_visibleItemsWithViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *nIndex, UIView<TGInstantPageDisplayView> *itemView, __unused BOOL *stop) {
        if (![visibleItemIndices containsObject:nIndex]) {
            [itemView removeFromSuperview];
            [removeItemIndices addObject:nIndex];
        } else {
            CGRect itemFrame = itemView.frame;
            CGFloat itemThreshold = 200.0f;
            itemFrame.origin.y -= itemThreshold;
            itemFrame.size.height += itemThreshold + itemThreshold;
            [itemView setIsVisible:CGRectIntersectsRect(visibleBounds, itemFrame)];
        }
    }];
    [_visibleItemsWithViews removeObjectsForKeys:removeItemIndices];
    
    NSMutableArray *removeItemLinkIndices = [[NSMutableArray alloc] init];
    [_visibleLinkSelectionViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *nIndex, NSArray<TGInstantPageLinkSelectionView *> *linkViews, __unused BOOL *stop) {
        if (![visibleItemLinkIndices containsObject:nIndex]) {
            for (UIView *linkView in linkViews) {
                [linkView removeFromSuperview];
            }
            [removeItemLinkIndices addObject:nIndex];
        }
    }];
    [_visibleLinkSelectionViews removeObjectsForKeys:removeItemLinkIndices];
}

- (void)setStatusBarHeight:(CGFloat)statusBarHeight {
    _statusBarHeight = statusBarHeight;
    _scrollView.contentInset = UIEdgeInsetsMake(_statusBarHeight + 44.0f, 0.0f, 0.0f, 0.0f);
}

- (void)scrollViewDidScroll:(UIScrollView *)__unused scrollView {
    [self updateVisibleItems];
    
    [self updateNavigationBar];
    _previousContentOffset = _scrollView.contentOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)__unused scrollView willDecelerate:(BOOL)decelerate {
    _isDeceleratingBecauseOfDragging = decelerate;
    if (!decelerate) {
        [self updateNavigationBar:true];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)__unused scrollView {
    [self updateNavigationBar:true];
    _isDeceleratingBecauseOfDragging = false;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)__unused scrollView {
    for (UIView<TGInstantPageDisplayView> *itemView in [_visibleItemsWithViews allValues]) {
        if ([itemView respondsToSelector:@selector(updateScreenPosition:screenSize:)]) {
            [itemView updateScreenPosition:[itemView convertRect:itemView.bounds toView:self] screenSize:self.bounds.size];
        }
    }
    
    if (_scrollAnimationCompletion != nil) {
        _scrollAnimationCompletion();
        _scrollAnimationCompletion = nil;
    }
}

- (void)updateNavigationBar {
    [self updateNavigationBar:false];
}

- (void)updateNavigationBar:(bool)forceState {
    CGRect bounds = _scrollView.bounds;
    CGPoint contentOffset = _scrollView.contentOffset;
    CGRect previousNavigationBarFrame = _navigationBar.frame;
    bool animate = false;
    CGRect navigationBarFrame = _navigationBar.frame;
    navigationBarFrame.size.width = bounds.size.width;
    if (!forceState && contentOffset.y <= -20.0f + FLT_EPSILON) {
        navigationBarFrame = CGRectMake(0.0f, 0.0f, bounds.size.width, MIN(64.0f, MAX(navigationBarFrame.size.height, MAX(-contentOffset.y, 20.0f))));
    } else {
        if (forceState) {
            if (previousNavigationBarFrame.size.height < 40.0f) {
                navigationBarFrame = CGRectMake(0.0f, 0.0f, bounds.size.width, 20.0f);
            } else {
                navigationBarFrame = CGRectMake(0.0f, 0.0f, bounds.size.width, 64.0f);
            }
            animate = true;
        } else {
            CGFloat delta = contentOffset.y - _previousContentOffset.y;
            if (delta > 0.0f || _scrollView.isDecelerating) {
                navigationBarFrame.size.height = MAX(20.0f, MIN(64.0f, navigationBarFrame.size.height - delta));
            }
        }
    }
    
    void (^block)() = ^{
        _navigationBar.frame = navigationBarFrame;
        CGFloat statusBarOffset = -MAX(0.0f, MIN(_statusBarHeight, _statusBarHeight + 44.0f - _navigationBar.bounds.size.height));
        if (ABS(_statusBarOffset - statusBarOffset) > FLT_EPSILON) {
            _statusBarOffset = statusBarOffset;
            if (_statusBarOffsetUpdated) {
                _statusBarOffsetUpdated(statusBarOffset);
            }
            
            _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(_navigationBar.bounds.size.height, 0.0f, 0.0f, 0.0f);
        };
    };
    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            block();
            [_navigationBar layoutSubviews];
        }];
    } else {
        block();
    }
}

- (UIView *)transitionViewForMedia:(TGInstantPageMedia *)media {
    __block UIView *result = nil;
    [_visibleItemsWithViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nIndex, UIView<TGInstantPageDisplayView> *itemView, BOOL *stop) {
        if ([itemView respondsToSelector:@selector(transitionViewForMedia:)]) {
            UIView *view = [itemView transitionViewForMedia:media];
            if (view != nil) {
                result = view;
                *stop = true;
            }
        }
    }];
    return result;
}

- (void)updateHiddenMedia:(TGInstantPageMedia *)media {
    [_visibleItemsWithViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *nIndex, UIView<TGInstantPageDisplayView> *itemView, __unused BOOL *stop) {
        if ([itemView respondsToSelector:@selector(updateHiddenMedia:)]) {
            [itemView updateHiddenMedia:media];
        }
    }];
}

@end
