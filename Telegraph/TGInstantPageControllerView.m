#import "TGInstantPageControllerView.h"

#import "TGMenuView.h"

#import "TGInstantPageScrollState.h"
#import "TGInstantPageLayout.h"
#import "TGInstantPageTileView.h"
#import "TGInstantPageControllerNavigationBar.h"
#import "TGInstantPageDisplayView.h"
#import "TGInstantPageLinkSelectionView.h"
#import "TGInstantPageSettingsView.h"

@interface TGInstantPageControllerViewScrollView : UIScrollView

@end

@implementation TGInstantPageControllerViewScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)__unused view {
    return true;
}

@end

@interface TGInstantPageControllerView () <UIScrollViewDelegate, ASWatcher> {
    TGInstantPageControllerNavigationBar *_navigationBar;
    UIView *_scrollViewHeader;
    UIScrollView *_scrollView;
    TGInstantPageSettingsView *_settingsView;
    void (^_textItemLongPressed)(TGInstantPageTextSelectionView *, NSString *);
    void (^_urlItemTapped)(id);
    void (^_urlItemLongPressed)(id);
    void (^_openMediaWrapper)(TGInstantPageMedia *);
    void (^_openAudioWrapper)(TGDocumentMediaAttachment *);
    TGEmbedPlayerController *(^_openEmbedFullscreenWrapper)(TGEmbedPlayerView *, UIView *);
    TGEmbedPIPPlaceholderView *(^_openEmbedPIPWrapper)(TGEmbedPlayerView *, UIView *, TGPIPSourceLocation *, TGEmbedPIPCorner, TGEmbedPlayerController *);
    void (^_openFeedbackWrapper)();
    void (^_openChannelWrapper)(TGConversation *);
    void (^_joinChannelWrapper)(TGConversation *);
    
    TGInstantPagePresentation *_presentation;
    TGInstantPageLayout *_currentLayout;
    NSArray<TGInstantPageTile *> *_currentLayoutTiles;
    NSArray<id<TGInstantPageLayoutItem>> *_currentLayoutItemsWithViews;
    NSArray<id<TGInstantPageLayoutItem>> *_currentLayoutItemsWithText;
    NSArray<id<TGInstantPageLayoutItem>> *_currentLayoutItemsWithLinks;
    NSDictionary<NSNumber *, NSNumber *> *_distanceThresholdGroupCount;
    
    NSMutableDictionary<NSNumber *, TGInstantPageTileView *> *_visibleTiles;
    NSMutableDictionary<NSNumber *, UIView<TGInstantPageDisplayView> *> *_visibleItemsWithViews;
    NSMutableDictionary<NSNumber *, TGInstantPageTextSelectionView *> *_visibleTextSelectionViews;
    NSMutableDictionary<NSNumber *, NSArray<TGInstantPageLinkSelectionView *> *> *_visibleLinkSelectionViews;
    
    TGMenuContainerView *_menuContainerView;
    
    CGPoint _previousContentOffset;
    bool _isDeceleratingBecauseOfDragging;
    
    void (^_scrollAnimationCompletion)(void);
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGInstantPageControllerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _statusBarHeight = 20.0f;
        _navigationBar = [[TGInstantPageControllerNavigationBar alloc] init];
        
        _scrollView = [[TGInstantPageControllerViewScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        
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
        _visibleTextSelectionViews = [[NSMutableDictionary alloc] init];
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
        _navigationBar.settingsPressed = ^{
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf openPresentationSettings];
            }
        };
        _navigationBar.scrollToTop = ^{
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_scrollView setContentOffset:CGPointMake(0.0f, -64.0f) animated:true];
            }
        };
        
        _textItemLongPressed = ^(TGInstantPageTextSelectionView *selectionView, NSString *text) {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf showActionsForSelection:selectionView text:text];
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
        
        _urlItemLongPressed = ^(id item) {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if ([item isKindOfClass:[TGRichTextUrl class]]) {
                    NSString *url = ((TGRichTextUrl *)item).url;
                    int64_t webpageId = ((TGRichTextUrl *)item).webpageId;
                    
                    if (strongSelf->_openUrlOptions) {
                        strongSelf->_openUrlOptions(url, webpageId);
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
        
        _openAudioWrapper = ^(TGDocumentMediaAttachment *centralMedia) {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_openAudio) {
                    NSMutableArray *medias = [[NSMutableArray alloc] init];
                    for (id<TGInstantPageLayoutItem> item in strongSelf->_currentLayout.items) {
                        if ([item respondsToSelector:@selector(audios)]) {
                            for (TGDocumentMediaAttachment *media in [item audios]) {
                                [medias addObject:media];
                            }
                        }
                    }
                    if (medias.count == 0) {
                        [medias addObject:centralMedia];
                    }
                    strongSelf->_openAudio(medias, centralMedia);
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
        
        _openChannelWrapper = ^(TGConversation *channel) {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_openChannel) {
                    strongSelf->_openChannel(channel);
                }
            }
        };
        
        _joinChannelWrapper = ^(TGConversation *channel) {
            __strong TGInstantPageControllerView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                if (strongSelf->_joinChannel) {
                    strongSelf->_joinChannel(channel);
                }
            }
        };
    }
    return self;
}

- (void)dealloc {
    [_actionHandle reset];
}

- (TGInstantPagePresentation *)presentation {
    if (_presentation)
        return _presentation;
    
    return [TGInstantPagePresentation presentationWithFontSizeMultiplier:1.0f fontSerif:false theme:TGInstantPagePresentationThemeDefault forceAutoNight:false];
}

- (void)setPresentation:(TGInstantPagePresentation *)presentation {
    [self setPresentation:presentation animated:false];
}

- (void)setPresentation:(TGInstantPagePresentation *)presentation animated:(bool)animated {
    if ([presentation isEqual:_presentation])
        return;
    
    _presentation = presentation;
    
    UIView *snapshotView = nil;
    
    if (animated) {
        snapshotView = [_scrollView snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = _scrollView.frame;
        [_scrollView.superview insertSubview:snapshotView aboveSubview:_scrollView];
    }
    
    self.backgroundColor = presentation.backgroundColor;
    _scrollView.backgroundColor = self.backgroundColor;
    
    if (_currentLayout) {
        [self updateLayout];
        
        for (UIView<TGInstantPageDisplayView> *itemView in _visibleItemsWithViews.allValues) {
            if ([itemView respondsToSelector:@selector(updatePresentation:)]) {
                [itemView updatePresentation:presentation];
            }
        }
        
        [self updateVisibleItems];
    }
    
    if (animated) {
        [UIView animateWithDuration:0.15 animations:^{
            snapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished) {
            [snapshotView removeFromSuperview];
        }];
    }
    
    if (_settingsView) {
        [_settingsView updatePresentation:presentation animated:animated];
    }
}

- (void)updateLayout {
    _currentLayout = [TGInstantPageLayout makeLayoutForWebPage:_webPage peerId:_peerId messageId:_messageId boundingWidth:self.bounds.size.width presentation:self.presentation];
    [_visibleTiles enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGInstantPageTileView *tileView, __unused BOOL *stop) {
        [tileView removeFromSuperview];
    }];
    [_visibleTiles removeAllObjects];
    
    [_visibleTextSelectionViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, TGInstantPageTextSelectionView *textView, __unused BOOL *stop) {
        [textView removeFromSuperview];
    }];
    [_visibleTextSelectionViews removeAllObjects];
    
    [_visibleLinkSelectionViews enumerateKeysAndObjectsUsingBlock:^(__unused NSNumber *key, NSArray<TGInstantPageLinkSelectionView *> *linkViews, __unused BOOL *stop) {
        for (UIView *linkView in linkViews) {
            [linkView removeFromSuperview];
        }
    }];
    [_visibleLinkSelectionViews removeAllObjects];
    
    _currentLayoutTiles = [TGInstantPageTile tilesWithLayout:_currentLayout boundingWidth:self.bounds.size.width];
    NSMutableArray *currentLayoutItemsWithViews = [[NSMutableArray alloc] init];
    NSMutableArray *currentLayoutItemsWithText = [[NSMutableArray alloc] init];
    NSMutableArray *currentLayoutItemsWithLinks = [[NSMutableArray alloc] init];
    NSMutableDictionary *distanceThresholdGroupCount = [[NSMutableDictionary alloc] init];
    for (id<TGInstantPageLayoutItem> item in _currentLayout.items) {
        if ([item respondsToSelector:@selector(view)]) {
            [currentLayoutItemsWithViews addObject:item];
            int32_t currentCount = [distanceThresholdGroupCount[@([item distanceThresholdGroup])] intValue];
            distanceThresholdGroupCount[@([item distanceThresholdGroup])] = @(currentCount + 1);
        }
        if ([item respondsToSelector:@selector(hasText)]) {
            [currentLayoutItemsWithText addObject:item];
        }
        if ([item hasLinks]) {
            [currentLayoutItemsWithLinks addObject:item];
        }
    }
    _currentLayoutItemsWithViews = currentLayoutItemsWithViews;
    _distanceThresholdGroupCount = distanceThresholdGroupCount;
    _currentLayoutItemsWithText = currentLayoutItemsWithText;
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
    
    if (_settingsView) {
        _settingsView.frame = self.bounds;
    }
    
    if (!CGSizeEqualToSize(bounds.size, _scrollView.bounds.size)) {
        if (ABS(bounds.size.width - _scrollView.bounds.size.width) > FLT_EPSILON) {
            [self updateLayout];
        }
        _scrollView.frame = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height);
        _scrollViewHeader.frame = CGRectMake(0.0f, -2000.0f, bounds.size.width, 2000.0f);
        _scrollView.contentInset = UIEdgeInsetsMake(_statusBarHeight + 44.0f, 0.0f, 0.0f, 0.0f);
        if (_visibleItemsWithViews.count == 0 && _visibleTiles.count == 0) {
            _scrollView.contentOffset = CGPointMake(0.0f, -64.0f);
        }
        if (_initialAnchor != nil) {
            NSString *anchor = _initialAnchor;
            _initialAnchor = nil;
            if (anchor.length != 0) {
                for (id<TGInstantPageLayoutItem> item in self->_currentLayout.items) {
                    if ([item respondsToSelector:@selector(matchesAnchor:)] && [item matchesAnchor:anchor]) {
                        [self->_scrollView setContentOffset:CGPointMake(0.0f, item.frame.origin.y) animated:false];
                        break;
                    }
                }
            }
        }
        [self updateVisibleItems];
        
        [self updateNavigationBar];
    }
}

- (void)updateVisibleItems {
    NSMutableSet *visibleTileIndices = [[NSMutableSet alloc] init];
    NSMutableSet *visibleItemIndices = [[NSMutableSet alloc] init];
    NSMutableSet *visibleItemTextIndices = [[NSMutableSet alloc] init];
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
                if ([itemView respondsToSelector:@selector(setOpenAudio:)]) {
                    [itemView setOpenAudio:_openAudioWrapper];
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
                if ([itemView respondsToSelector:@selector(setOpenChannel:)]) {
                    [itemView setOpenChannel:_openChannelWrapper];
                }
                if ([itemView respondsToSelector:@selector(setJoinChannel:)]) {
                    [itemView setJoinChannel:_joinChannelWrapper];
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
    for (id<TGInstantPageLayoutItem> item in _currentLayoutItemsWithText) {
        itemIndex++;
        CGRect itemFrame = item.frame;
        if (CGRectIntersectsRect(itemFrame, visibleBounds)) {
            [visibleItemTextIndices addObject:@(itemIndex)];
            
            if (_visibleTextSelectionViews[@(itemIndex)] == nil) {
                TGInstantPageTextSelectionView *selectionView = [item textSelectionView];
                [selectionView setColor:_presentation.textSelectionColor];
                selectionView.itemLongPressed = _textItemLongPressed;
                [_scrollView addSubview:selectionView];
                _visibleTextSelectionViews[@(itemIndex)] = selectionView;
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
                    [linkView setColor:_presentation.textSelectionColor];
                    linkView.itemTapped = _urlItemTapped;
                    linkView.itemLongPressed = _urlItemLongPressed;
                    
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
    
    NSMutableArray *removeItemTextIndices = [[NSMutableArray alloc] init];
    [_visibleTextSelectionViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *nIndex, TGInstantPageTextSelectionView *textView, __unused BOOL *stop) {
        if (![visibleItemTextIndices containsObject:nIndex]) {
            [textView removeFromSuperview];
            [removeItemTextIndices addObject:nIndex];
        }
    }];
    [_visibleTextSelectionViews removeObjectsForKeys:removeItemTextIndices];
    
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
    
    CGFloat delta = contentOffset.y - _previousContentOffset.y;
    _previousContentOffset = contentOffset;
    
    void (^block)(CGRect) = ^(CGRect navigationBarFrame) {
        _navigationBar.frame = navigationBarFrame;
        CGFloat navigationBarHeight = _navigationBar.bounds.size.height;
        if (navigationBarHeight < FLT_EPSILON)
            navigationBarHeight = 64.0f;
        
        CGFloat statusBarOffset = -MAX(0.0f, MIN(_statusBarHeight, _statusBarHeight + 44.0f - navigationBarHeight));
        if (ABS(_statusBarOffset - statusBarOffset) > FLT_EPSILON) {
            _statusBarOffset = statusBarOffset;
            if (_statusBarOffsetUpdated) {
                _statusBarOffsetUpdated(statusBarOffset);
            }
            
            _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(_navigationBar.bounds.size.height, 0.0f, 0.0f, 0.0f);
        };
    };
    
    CGRect navigationBarFrame = CGRectMake(0.0f, 0.0f, bounds.size.width, _navigationBar.frame.size.height);
    if (forceState) {
        [UIView animateWithDuration:0.3 delay:0.0 options:7 << 16 | UIViewAnimationOptionLayoutSubviews animations:^
        {
            CGRect frame = navigationBarFrame;
            if (contentOffset.y <= -_scrollView.contentInset.top || frame.size.height > 32.0f)
                frame.size.height = 64.0f;
            else
                frame.size.height = 20.0f;
             
            _navigationBar.frame = frame;
            block(frame);
         } completion:nil];

    } else {
        if (contentOffset.y <= -_scrollView.contentInset.top)
            navigationBarFrame.size.height = 64.0f;
        else
            navigationBarFrame.size.height -= delta;
        navigationBarFrame.size.height = MAX(20.0f, MIN(64.0f, navigationBarFrame.size.height));
        _navigationBar.frame = navigationBarFrame;
        block(navigationBarFrame);
    }
    
    CGFloat progress = 0.0f;
    if (_scrollView.contentSize.height > FLT_EPSILON) {
        progress = MAX(0.0f, MIN(1.0f, (_scrollView.contentOffset.y + _scrollView.contentInset.top) / (_scrollView.contentSize.height - _scrollView.frame.size.height + _scrollView.contentInset.top)));
    }
    [_navigationBar setProgress:progress];
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

- (void)openPresentationSettings {
    if (_settingsView != nil) {
        return;
    }
    
    __weak TGInstantPageControllerView *weakSelf = self;
    _settingsView = [[TGInstantPageSettingsView alloc] initWithFrame:self.bounds presentation:self.presentation autoNightThemeEnabled:self.autoNightThemeEnabled];
    _settingsView.buttonPosition = ^CGPoint{
        __strong TGInstantPageControllerView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            CGPoint point = [strongSelf->_navigationBar settingsButtonCenter];
            return CGPointMake(strongSelf->_navigationBar.frame.size.width - point.x, point.y);
        }
        return CGPointZero;
    };
    _settingsView.dismiss = ^{
        __strong TGInstantPageControllerView *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_settingsView transitionOut:^{
                __strong TGInstantPageControllerView *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_settingsView removeFromSuperview];
                    strongSelf->_settingsView = nil;
                };
            }];
            
            [strongSelf->_navigationBar setNavigationButtonsDimmed:false animated:true];
        }
    };
    _settingsView.fontSizeChanged = ^(CGFloat multiplier) {
        __strong TGInstantPageControllerView *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_fontSizeChanged) {
            strongSelf->_fontSizeChanged(multiplier);
        }
    };
    _settingsView.fontSerifChanged = ^(bool serif) {
        __strong TGInstantPageControllerView *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_fontSerifChanged) {
            strongSelf->_fontSerifChanged(serif);
        }
    };
    _settingsView.themeChanged = ^(TGInstantPagePresentationTheme theme) {
        __strong TGInstantPageControllerView *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_themeChanged) {
            strongSelf->_themeChanged(theme);
        }
    };
    _settingsView.autoNightThemeChanged = ^(bool enabled) {
        __strong TGInstantPageControllerView *strongSelf = weakSelf;
        if (strongSelf != nil && strongSelf->_autoNightThemeChanged) {
            strongSelf->_autoNightThemeChanged(enabled);
        }
    };
    [self addSubview:_settingsView];
    [_settingsView transitionIn];
    
    [_navigationBar setNavigationButtonsDimmed:true animated:true];
}

- (void)showActionsForSelection:(TGInstantPageTextSelectionView *)selectionView text:(NSString *)text {
    CGRect contentFrame = [selectionView convertRect:selectionView.bounds toView:self];
    if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
        return;
    
    contentFrame = CGRectIntersection(contentFrame, self.frame);
    if (CGRectIsNull(contentFrame) || CGRectIsEmpty(contentFrame))
        return;
    
    if (_menuContainerView != nil) {
        [_menuContainerView hideMenu];
        _menuContainerView = nil;
    }
    
    _menuContainerView = [[TGMenuContainerView alloc] initWithFrame:self.bounds];
    [self addSubview:_menuContainerView];
    
    
    NSDictionary *copyAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuCopy"), @"title", @"copy", @"action", nil];
    NSDictionary *shareAction = [[NSDictionary alloc] initWithObjectsAndKeys:TGLocalized(@"Conversation.ContextMenuShare"), @"title", @"share", @"action", nil];

    [_menuContainerView.menuView setUserInfo:@{@"text": text}];
    [_menuContainerView.menuView setButtonsAndActions:@[copyAction, shareAction] watcherHandle:_actionHandle];
    [_menuContainerView.menuView sizeToFitToWidth:MIN(self.frame.size.width, self.frame.size.height)];
    [_menuContainerView showMenuFromRect:[_menuContainerView convertRect:contentFrame fromView:self]];
    
    [selectionView setHighlighted:true];
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"menuAction"]) {
        NSString *text = options[@"userInfo"][@"text"];
        NSString *menuAction = options[@"action"];
        if ([menuAction isEqualToString:@"copy"]) {
            if (text.length > 0) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:text];
            }
        } else if ([menuAction isEqualToString:@"share"]) {
            if (_shareText) {
                _shareText(text);
            }
        }
    }

    for (TGInstantPageTextSelectionView *textView in _visibleTextSelectionViews.allValues) {
        [textView setHighlighted:false];
    }
}

- (void)applyScrollState:(TGInstantPageScrollState *)scrollState {
    if (scrollState != nil && _currentLayout != nil && (int32_t)_currentLayout.items.count > scrollState.blockId) {
        id<TGInstantPageLayoutItem> item = _currentLayout.items[scrollState.blockId];
        
        CGPoint contentOffset = CGPointMake(0.0f, -_scrollView.contentInset.top + item.frame.origin.y + scrollState.blockOffset - 5.0f);
        [_scrollView setContentOffset:contentOffset animated:false];
    }
}

- (TGInstantPageScrollState *)currentScrollState {
    if (_currentLayout != nil) {
        __block NSNumber *blockIndex;
        __block int32_t offset = 0.0f;
        
        CGPoint point = CGPointMake(_scrollView.frame.size.width / 2.0f, _scrollView.contentOffset.y + _scrollView.contentInset.top + 5.0f);
        
        [_currentLayout.items enumerateObjectsUsingBlock:^(id<TGInstantPageLayoutItem> item, NSUInteger index, BOOL *stop) {
            if (CGRectContainsPoint(item.frame, point)) {
                blockIndex = @(index);
                *stop = true;
                
                offset = (int32_t)(point.y - item.frame.origin.y);
            }
        }];
        
        if (blockIndex) {
            return [[TGInstantPageScrollState alloc] initWithBlockId:blockIndex.int32Value blockOffest:offset];
        }
    }
    return nil;
}

@end
