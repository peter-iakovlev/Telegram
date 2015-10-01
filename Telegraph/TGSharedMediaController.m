#import "TGSharedMediaController.h"

#import "TGHacks.h"
#import "TGPeerIdAdapter.h"

#import "ActionStage.h"
#import "TGDownloadManager.h"
#import "TGTelegraph.h"

#import "TGTelegramNetworking.h"
#import "TGMessageSearchSignals.h"
#import "TGSharedMediaCacheSignals.h"
#import "TGMessage.h"

#import "TGSharedMediaCollectionView.h"
#import "TGSharedMediaCollectionLayout.h"
#import "TGSharedMediaSectionHeader.h"
#import "TGSharedMediaSectionHeaderView.h"

#import "TGSharedMediaImageItem.h"
#import "TGSharedMediaVideoItem.h"
#import "TGSharedMediaFileItem.h"
#import "TGSharedMediaLinkItem.h"

#import "TGSharedMediaImageItemView.h"
#import "TGSharedMediaVideoItemView.h"
#import "TGSharedMediaFileItemView.h"
#import "TGSharedMediaFileThumbnailItemView.h"
#import "TGSharedMediaLinkItemView.h"

#import "TGSharedMediaFilter.h"
#import "TGSharedMediaDirectionFilter.h"
#import "TGSharedMediaGroup.h"
#import "TGSharedMediaAvailabilityState.h"

#import "TGImageUtils.h"
#import "TGFont.h"
#import "TGDateUtils.h"
#import "TGStringUtils.h"
#import "TGActionSheet.h"

#import "TGPreparedLocalDocumentMessage.h"

#import "TGSharedMediaTitleButton.h"
#import "TGSharedMediaMenuView.h"
#import "TGSharedMediaImageViewQueue.h"

#import "TGModernGalleryController.h"
#import "TGOverlayControllerWindow.h"
#import "TGGenericPeerMediaGalleryModel.h"
#import "TGGenericPeerGalleryItem.h"

#import "TGDatabase.h"
#import "TGNavigationController.h"
#import "TGDocumentController.h"

#import "TGSearchBar.h"
#import "TGSearchDisplayMixin.h"

#import "TGForwardTargetController.h"

#import "TGTimer.h"

#import <pthread.h>
#import <sys/time.h>

#import "TGSharedMediaAllFilesEmptyView.h"
#import "TGSharedMediaFilesEmptyView.h"
#import "TGSharedMediaLinksEmptyView.h"

#import "TGSharedMediaSelectionPanelView.h"

#import "TGGenericPeerPlaylistSignals.h"

#import "TGAttachmentSheetWindow.h"
#import "TGAttachmentSheetEmbedItemView.h"
#import "TGAttachmentSheetButtonItemView.h"

typedef enum {
    TGSharedMediaControllerModeAll,
    TGSharedMediaControllerModePhoto,
    TGSharedMediaControllerModeVideo,
    TGSharedMediaControllerModeFile,
    TGSharedMediaControllerModeLink
} TGSharedMediaControllerMode;

@interface TGSharedMediaController () <ASWatcher, UICollectionViewDataSource, TGSharedMediaCollectionViewDelegate, TGSearchBarDelegate>
{
    int64_t _peerId;
    int64_t _accessHash;
    bool _important;
    bool _allowActions;
    
    CGSize _normalItemSize;
    CGSize _wideItemSize;
    CGFloat _widescreenWidth;
    CGFloat _normalLineSpacing;
    CGFloat _wideLineSpacing;
    
    UIEdgeInsets _normalEdgeInsets;
    UIEdgeInsets _wideEdgeInsets;
    
    TGSharedMediaCollectionView *_collectionView;
    CGFloat _collectionViewWidth;
    TGSharedMediaCollectionLayout *_collectionLayout;
    UIView *_collectionContainer;
    
    TGSharedMediaCollectionView *_searchCollectionView;
    TGSharedMediaCollectionLayout *_searchCollectionLayout;
    UIView *_searchCollectionContainer;
    
    UIView *_filterPanelView;
    UISegmentedControl *_filterSegmentedControl;
    
    SMetaDisposable *_currentQueryDisposable;
    SMetaDisposable *_currentSearchQueryDisposable;
    SSignal *_currentLoadMoreSignal;
    SDisposableSet *_disposable;
    
    TGSharedMediaControllerMode _mode;
    NSArray *_rawItemGroups;
    NSDictionary *_itemAvailabilityStates;
    NSArray *_currentFilters;
    NSArray *_filteredItemGroups;
    id<TGSharedMediaItem> _hiddenItem;
    
    NSArray *_rawSearchItemGroups;
    NSArray *_filteredSearchItemGroups;
    
    bool _displayNavigationMenu;
    bool _editing;
    
    TGSharedMediaTitleButton *_titleView;
    UILabel *_titleLabel;
    UIView *_titleArrowContainer;
    UIImageView *_titleArrowView;
    TGSharedMediaMenuView *_menuView;
    
    UIActivityIndicatorView *_activityIndicatorView;
    
    TGSharedMediaImageViewQueue *_imageViewQueue;
    
    bool (^_isItemHidden)(id<TGSharedMediaItem>);
    bool (^_isItemSelected)(id<TGSharedMediaItem>);
    void (^_toggleItemSelection)(id<TGSharedMediaItem>);
    
    NSSet *_selectedMessageIds;
    
    TGSearchBar *_searchBar;
    UIView *_searchDimView;
    TGTimer *_searchDelayTimer;
    
    pthread_mutex_t _waitMutex;
    pthread_cond_t _waitCond;
    bool _waitingForItems;
    NSArray *_loadedItems;
    
    __weak TGGenericPeerMediaGalleryModel *_galleryModel;
    
    SMulticastSignalManager *_visibleItemsSignalManager;
    
    UIView *_currentEmptyView;
    
    TGSharedMediaSelectionPanelView *_selectionPanelView;
    TGAttachmentSheetWindow *_attachmentSheetWindow;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGSharedMediaController

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash important:(bool)important
{
    self = [super init];
    if (self != nil)
    {
        pthread_mutex_init(&_waitMutex, NULL);
        pthread_cond_init(&_waitCond, NULL);
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _peerId = peerId;
        _accessHash = accessHash;
        _important = important;
        _allowActions = _peerId > INT_MIN;
        
        CGSize screenSize = TGScreenSize();
        _widescreenWidth = MAX(screenSize.width, screenSize.height);
        
        if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
        {
            if (_widescreenWidth >= 736.0f - FLT_EPSILON)
            {
                _normalItemSize = CGSizeMake(78.5f, 78.5f);
                _wideItemSize = CGSizeMake(78.0f, 78.0f);
                _normalEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
                _wideEdgeInsets = UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f);
                _normalLineSpacing = 2.0f;
                _wideLineSpacing = 3.0f;
            }
            else if (_widescreenWidth >= 667.0f - FLT_EPSILON)
            {
                _normalItemSize = CGSizeMake(93.0f, 93.5f);
                _wideItemSize = CGSizeMake(93.0f, 93.0f);
                _normalEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
                _wideEdgeInsets = UIEdgeInsetsMake(0.0f, 2.0f, 0.0f, 2.0f);
                _normalLineSpacing = 1.0f;
                _wideLineSpacing = 2.0f;
            }
            else
            {
                _normalItemSize = CGSizeMake(78.5f, 78.5f);
                _wideItemSize = CGSizeMake(78.0f, 78.0f);
                _normalEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
                _wideEdgeInsets = UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f);
                _normalLineSpacing = 2.0f;
                _wideLineSpacing = 3.0f;
            }
        }
        else
        {
            _normalItemSize = CGSizeMake(78.5f, 78.5f);
            _wideItemSize = CGSizeMake(78.0f, 78.0f);
            _normalEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            _wideEdgeInsets = UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f);
            _normalLineSpacing = 2.0f;
            _wideLineSpacing = 2.0f;
        }
        
        _disposable = [[SDisposableSet alloc] init];
        _currentQueryDisposable = [[SMetaDisposable alloc] init];
        _currentSearchQueryDisposable = [[SMetaDisposable alloc] init];
        [_disposable add:_currentQueryDisposable];
        [_disposable add:_currentSearchQueryDisposable];
        
        [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Select") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(17.0f);
        _titleArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SharedMediaNavigationBarArrow.png"]];
        _titleView = [[TGSharedMediaTitleButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 2.0f)];
        [_titleView addTarget:self action:@selector(titleTapped) forControlEvents:UIControlEventTouchUpInside];
        [_titleView addSubview:_titleLabel];
        _titleArrowContainer = [[UIView alloc] initWithFrame:_titleArrowView.bounds];
        _titleArrowContainer.userInteractionEnabled = false;
        [_titleArrowContainer addSubview:_titleArrowView];
        [_titleView addSubview:_titleArrowContainer];
        [self.navigationItem setTitleView:_titleView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidden = true;
        
        _imageViewQueue = [[TGSharedMediaImageViewQueue alloc] init];
        
        __weak TGSharedMediaController *weakSelf = self;
        _isItemHidden = ^bool (id<TGSharedMediaItem> item)
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return TGObjectCompare(strongSelf->_hiddenItem, item);
            return false;
        };
        _isItemSelected = ^bool (id<TGSharedMediaItem> item)
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf->_selectedMessageIds containsObject:@([item messageId])];
            return false;
        };
        _toggleItemSelection = ^(id<TGSharedMediaItem> item)
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSMutableSet *selectedMessageIds = [[NSMutableSet alloc] initWithSet:strongSelf->_selectedMessageIds];
                if ([selectedMessageIds containsObject:@([item messageId])])
                    [selectedMessageIds removeObject:@([item messageId])];
                else
                    [selectedMessageIds addObject:@([item messageId])];
                strongSelf->_selectedMessageIds = selectedMessageIds;
                [strongSelf _updateSelectionInterface];
            }
        };
        
        [ActionStageInstance() watchForPaths:@[
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", _peerId],
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId],
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId],
            @"downloadManagerStateChanged",
            @"/as/media/imageThumbnailUpdated"
        ] watcher:self];
        
        _waitingForItems = true;
        [self setMode:TGSharedMediaControllerModeAll filters:@[]];
        
        [[TGDownloadManager instance] requestState:self.actionHandle];
    }
    return self;
}

- (void)dealloc
{
    [_disposable dispose];
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
    CGSize textSize = [title sizeWithFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(CGFloor((_titleLabel.superview.frame.size.width - textSize.width) / 2.0f), CGFloor((_titleLabel.superview.frame.size.height - textSize.height) / 2.0f), textSize.width, textSize.height);
    
    _titleArrowContainer.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame) + 4.0f + TGRetinaPixel, CGFloor((_titleArrowView.superview.frame.size.height - _titleArrowView.frame.size.height) / 2.0f) - 1.0f, _titleArrowView.frame.size.width, _titleArrowView.frame.size.height);
    
    _titleView.buttonTapAreaWidth = textSize.width + 26.0f;
}

- (void)titleTapped
{
    if (!_editing)
        [self setDisplayNavigationMenu:!_displayNavigationMenu];
}

- (CGAffineTransform)titleArrowTransformForDisplayMenu:(bool)displayMenu
{
    if (displayMenu)
        return CGAffineTransformTranslate(CGAffineTransformMakeRotation((CGFloat)M_PI), 0.0f, TGRetinaPixel);
    return CGAffineTransformIdentity;
}

- (void)setDisplayNavigationMenu:(bool)displayNavigationMenu
{
    _displayNavigationMenu = displayNavigationMenu;
    [UIView animateWithDuration:0.2 animations:^{
        _titleArrowView.transform = [self titleArrowTransformForDisplayMenu:_displayNavigationMenu];
    }];
    
    if (_displayNavigationMenu)
        [_menuView showAnimated:true];
    else
        [_menuView hideAnimated:true];
}

- (void)editPressed
{
    _editing = true;
    _selectedMessageIds = nil;
    [self _updateSelectionInterface];
    [self _updateSelectedItems];
    [self _updateEditing:true];
    
    [self setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(none)] animated:true];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed)] animated:true];
    [UIView animateWithDuration:0.15 animations:^
    {
        _titleArrowContainer.alpha = 0.0f;
    }];
    
    if (_displayNavigationMenu)
        [self setDisplayNavigationMenu:false];
}

- (void)none
{
}

- (UIView *)_findBackArrow:(UIView *)view
{
    Class backArrowClass = NSClassFromString(TGEncodeText(@"`VJObwjhbujpoCbsCbdlJoejdbupsWjfx", -1));
    
    if ([view isKindOfClass:backArrowClass])
        return view;
    
    for (UIView *subview in view.subviews)
    {
        UIView *result = [self _findBackArrow:subview];
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (UIView *)_findBackButton:(UIView *)view parentView:(UIView *)parentView
{
    Class backButtonClass = NSClassFromString(TGEncodeText(@"VJObwjhbujpoJufnCvuupoWjfx", -1));
    
    if ([view isKindOfClass:backButtonClass])
    {
        if (view.center.x < parentView.frame.size.width / 2.0f)
            return view;
    }
    
    for (UIView *subview in view.subviews)
    {
        UIView *result = [self _findBackButton:subview parentView:parentView];
        if (result != nil)
            return result;
    }
    
    return nil;
}

- (void)cancelPressed
{
    _editing = false;
    [self _updateEditing:true];
    
    [self setLeftBarButtonItem:nil animated:false];
    [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Select") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)] animated:true];
    
    [UIView animateWithDuration:0.17 animations:^
    {
        _titleArrowContainer.alpha = 1.0f;
    }];
    
    if (iosMajorVersion() >= 7)
    {
        UIView *backArrow = [self _findBackArrow:self.navigationController.navigationBar];
        UIView *backButton = [self _findBackButton:self.navigationController.navigationBar parentView:self.navigationController.navigationBar];
        backArrow.alpha = 0.0f;
        backButton.alpha = 0.0f;
        [UIView animateWithDuration:0.17 delay:0.0 options:0 animations:^
        {
            backArrow.alpha = 1.0f;
            backButton.alpha = 1.0f;
        } completion:nil];
    }
}

- (TGMessageSearchFilter)searchFilterForMode:(TGSharedMediaControllerMode)mode
{
    switch (mode)
    {
        case TGSharedMediaControllerModeAll:
            return TGMessageSearchFilterPhotoVideo;
        case TGSharedMediaControllerModePhoto:
            return TGMessageSearchFilterPhoto;
        case TGSharedMediaControllerModeVideo:
            return TGMessageSearchFilterVideo;
        case TGSharedMediaControllerModeFile:
            return TGMessageSearchFilterFile;
        case TGSharedMediaControllerModeLink:
            return TGMessageSearchFilterLink;
    }
}

- (NSString *)titleForMode:(TGSharedMediaControllerMode)mode
{
    switch (mode)
    {
        case TGSharedMediaControllerModeAll:
            return TGLocalized(@"SharedMedia.TitleAll");
        case TGSharedMediaControllerModePhoto:
            return TGLocalized(@"SharedMedia.TitlePhoto");
        case TGSharedMediaControllerModeVideo:
            return TGLocalized(@"SharedMedia.TitleVideo");
        case TGSharedMediaControllerModeFile:
            return TGLocalized(@"SharedMedia.TitleFile");
        case TGSharedMediaControllerModeLink:
            return TGLocalized(@"SharedMedia.TitleLink");
    }
}

- (void)reloadData
{
    for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
    {
        [itemView enqueueImageViewWithUri];
    }
    
    [_collectionView reloadData];
    [_collectionView layoutSubviews];
    
    [_imageViewQueue resetEnqueuedImageViews];
    
    [self _maybeLoadMore];
}

- (void)reloadSearchData
{
    for (TGSharedMediaItemView *itemView in _searchCollectionView.visibleCells)
    {
        [itemView enqueueImageViewWithUri];
    }
    
    [_searchCollectionView reloadData];
    [_searchCollectionView layoutSubviews];
    
    [_imageViewQueue resetEnqueuedImageViews];
}

- (TGSharedMediaCacheItemType)cacheItemTypeForFilter:(TGMessageSearchFilter)filter
{
    switch (filter)
    {
        case TGMessageSearchFilterAny:
            return TGSharedMediaCacheItemTypePhotoVideoFile;
        case TGMessageSearchFilterPhoto:
            return TGSharedMediaCacheItemTypePhoto;
        case TGMessageSearchFilterVideo:
            return TGSharedMediaCacheItemTypeVideo;
        case TGMessageSearchFilterFile:
            return TGSharedMediaCacheItemTypeFile;
        case TGMessageSearchFilterPhotoVideoFile:
            return TGSharedMediaCacheItemTypePhotoVideoFile;
        case TGMessageSearchFilterPhotoVideo:
            return TGSharedMediaCacheItemTypePhotoVideo;
        case TGMessageSearchFilterAudio:
            return TGSharedMediaCacheItemTypeAudio;
        case TGMessageSearchFilterLink:
            return TGSharedMediaCacheItemTypeLink;
    }
}

- (SSignal *)searchSignalWithFilter:(TGMessageSearchFilter)filter maxMessageId:(int32_t)maxMessageId
{
    __weak TGSharedMediaController *weakSelf = self;
    
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        
        SDisposableSet *compositeDisposable = [[SDisposableSet alloc] init];
        
        SSignal *startSignal = [TGSharedMediaCacheSignals cachedMediaForPeerId:strongSelf->_peerId itemType:[strongSelf cacheItemTypeForFilter:filter] important:true];
        if (maxMessageId != 0)
            startSignal = [SSignal single:@[]];
        
        __block NSUInteger cachedMessageCount = 0;
        __block bool indexDownloaded = false;
        [compositeDisposable add:[startSignal startWithNext:^(id next)
        {
            if ([next respondsToSelector:@selector(boolValue)])
                indexDownloaded = [next boolValue];
            else
            {
                NSArray *messages = next;
                [subscriber putNext:messages];
                cachedMessageCount = MAX(messages.count, cachedMessageCount);
            }
        } error:^(id error)
        {
            [subscriber putError:error];
        } completed:^
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (strongSelf->_peerId > INT_MIN && !indexDownloaded)
                {
                    [compositeDisposable add:[[TGMessageSearchSignals searchPeer:strongSelf->_peerId accessHash:_accessHash query:@"" filter:filter maxMessageId:maxMessageId limit:128] startWithNext:^(NSArray *messages)
                    {
                        [subscriber putNext:messages];
                    } error:^(id error)
                    {
                        [subscriber putError:error];
                    } completed:^
                    {
                        [subscriber putCompletion];
                    }]];
                }
                else
                {
                    [subscriber putNext:@false];
                    [subscriber putCompletion];
                }
            }
        }]];
        
        return compositeDisposable;
    }] map:^id (id next)
    {
        if ([next respondsToSelector:@selector(boolValue)])
            return next;
        else
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf sharedMediaItemsForMessages:(NSArray *)next];
            return @[];
        }
    }];
}

- (void)processSearchResult:(NSArray *)items append:(bool)append
{
    NSMutableArray *mergedItems = [[NSMutableArray alloc] init];
    if (append)
    {
        for (TGSharedMediaGroup *group in _rawItemGroups)
        {
            for (id<TGSharedMediaItem> item in group.items)
            {
                [mergedItems addObject:item];
            }
        }
        
        for (id<TGSharedMediaItem> item in items)
        {
            if (![mergedItems containsObject:item])
                [mergedItems addObject:item];
        }
    }
    else
        [mergedItems addObjectsFromArray:items];
    
    NSArray *groups = [self sharedMediaGroupsForItems:mergedItems];
    
    if ([_rawItemGroups isEqualToArray:groups])
        return;
    
    _rawItemGroups = groups;
    NSMutableArray *itemsWithoutAvailabilityState = [[NSMutableArray alloc] initWithArray:items];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSMutableDictionary *mediaAvailabilityStates = [[NSMutableDictionary alloc] initWithDictionary:[self mediaAvailabilityStatesForItems:itemsWithoutAvailabilityState]];
        TGDispatchOnMainThread(^
        {
            [mediaAvailabilityStates removeObjectsForKeys:[_itemAvailabilityStates allKeys]];
            [mediaAvailabilityStates addEntriesFromDictionary:_itemAvailabilityStates];
            _itemAvailabilityStates = mediaAvailabilityStates;
            [self updateMediaAvailabilityStates:false];
        });
    });
    
    _filteredItemGroups = [self filterGroups:groups usingFilters:_currentFilters];
    
    TGGenericPeerMediaGalleryModel *galleryModel = _galleryModel;
    if (galleryModel != nil)
    {
        [galleryModel replaceMessages:[self messagesForItemGroups:_filteredItemGroups]];
    }
    
    if (_filteredItemGroups.count != 0)
    {
        _activityIndicatorView.hidden = true;
        [_activityIndicatorView stopAnimating];
        
        [self _updateEmptyState];
    }
    
    [self reloadData];
}

- (void)setMode:(TGSharedMediaControllerMode)mode filters:(NSArray *)filters
{
    NSArray *filteredItemGroups = _filteredItemGroups;
    
    _currentLoadMoreSignal = nil;
    
    _rawItemGroups = nil;
    _filteredItemGroups = nil;
    
    if (filteredItemGroups.count != 0)
        [self reloadData];
    
    _mode = mode;
    _currentFilters = filters;
    _hiddenItem = nil;
    
    self.title = [self titleForMode:mode];
    
    _searchBar.hidden = mode == TGSharedMediaControllerModeAll;
    
    __weak TGSharedMediaController *weakSelf = self;
    
    _activityIndicatorView.hidden = false;
    if (_activityIndicatorView.superview != nil)
        [_activityIndicatorView startAnimating];
    
    [self _updateEmptyState];
    
    __block bool firstResult = true;
    __block bool gotItems = false;
    [_currentQueryDisposable setDisposable:[[self searchSignalWithFilter:[self searchFilterForMode:mode] maxMessageId:0] startWithNext:^(id next)
    {
        if ([next respondsToSelector:@selector(boolValue)])
            gotItems = [next boolValue];
        else
        {
            NSArray *items = next;
            
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                pthread_mutex_lock(&strongSelf->_waitMutex);
                pthread_cond_broadcast(&strongSelf->_waitCond);
                if (_waitingForItems)
                {
                    _loadedItems = items;
                    _waitingForItems = false;
                }
                pthread_mutex_unlock(&strongSelf->_waitMutex);
            }
            
            TGDispatchOnMainThread(^
            {
                if (items.count != 0)
                    gotItems = true;
                
                __strong TGSharedMediaController *strongSelf = weakSelf;
                [strongSelf processSearchResult:items append:!firstResult];
                firstResult = false;
            });
        }
    } error:^(__unused id error)
    {
        
    } completed:^
    {
        TGDispatchOnMainThread(^
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_activityIndicatorView.hidden = true;
                [strongSelf->_activityIndicatorView stopAnimating];
                [strongSelf updateLoadMoreSignal:gotItems];
                [strongSelf _updateEmptyState];
            }
        });
    }]];
}

- (void)updateLoadMoreSignal:(bool)gotMore
{
    int32_t minMessageId = INT_MAX;
    for (TGSharedMediaGroup *group in _rawItemGroups)
    {
        for (id<TGSharedMediaItem> item in group.items)
        {
            if ([item messageId] != 0)
                minMessageId = MIN([item messageId], minMessageId);
        }
    }
    if (minMessageId != INT_MAX && gotMore)
    {
        _currentLoadMoreSignal = [self searchSignalWithFilter:[self searchFilterForMode:_mode] maxMessageId:minMessageId];
    }
    else
        _currentLoadMoreSignal = nil;
}

- (NSArray *)currentFilteredGroups
{
    return _filteredItemGroups;
}

- (void)setCurrentFilters:(NSArray *)filters
{
    _currentFilters = filters;
    _filteredItemGroups = [self filterGroups:_rawItemGroups usingFilters:_currentFilters];
    if (_filteredSearchItemGroups != nil)
        _filteredSearchItemGroups = [self filterGroups:_rawSearchItemGroups usingFilters:_currentFilters];
    [self reloadData];
    [self reloadSearchData];
    
    if (_filteredItemGroups.count != 0)
    {
        _activityIndicatorView.hidden = true;
        [_activityIndicatorView stopAnimating];
    }
    [self _updateEmptyState];
}

- (void)updateMediaAvailabilityStates:(bool)animated
{
    for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
    {
        if (itemView.item == nil)
            continue;
        
        if ([itemView isKindOfClass:[TGSharedMediaFileItemView class]])
        {
            id mediaId = mediaIdForItem(itemView.item);
            if (mediaId != nil)
                [(TGSharedMediaFileItemView *)itemView setAvailabilityState:_itemAvailabilityStates[mediaId] animated:animated];
        }
        else if ([itemView isKindOfClass:[TGSharedMediaFileThumbnailItemView class]])
        {
            id mediaId = mediaIdForItem(itemView.item);
            if (mediaId != nil)
                [(TGSharedMediaFileThumbnailItemView *)itemView setAvailabilityState:_itemAvailabilityStates[mediaId] animated:animated];
        }
    }
    
    for (TGSharedMediaItemView *itemView in _searchCollectionView.visibleCells)
    {
        if (itemView.item == nil)
            continue;
        
        if ([itemView isKindOfClass:[TGSharedMediaFileItemView class]])
        {
            id mediaId = mediaIdForItem(itemView.item);
            if (mediaId != nil)
                [(TGSharedMediaFileItemView *)itemView setAvailabilityState:_itemAvailabilityStates[mediaId] animated:animated];
        }
        else if ([itemView isKindOfClass:[TGSharedMediaFileThumbnailItemView class]])
        {
            id mediaId = mediaIdForItem(itemView.item);
            if (mediaId != nil)
                [(TGSharedMediaFileThumbnailItemView *)itemView setAvailabilityState:_itemAvailabilityStates[mediaId] animated:animated];
        }
    }
}

- (NSArray *)directionFilterTitles
{
    return @[TGLocalized(@"SharedMedia.All"), TGLocalized(@"SharedMedia.Incoming"), TGLocalized(@"SharedMedia.Outgoing")];
}

- (void)loadView
{
    struct timespec timeToWait;
    struct timeval now;
    gettimeofday(&now,NULL);
    timeToWait.tv_sec = now.tv_sec + 1;
    
    pthread_mutex_lock(&_waitMutex);
    if (_waitingForItems)
    {
        pthread_cond_timedwait(&_waitCond, &_waitMutex, &timeToWait);
        _waitingForItems = false;
    }
    if (_loadedItems.count != 0)
        [self processSearchResult:_loadedItems append:false];
    _loadedItems = nil;
    pthread_mutex_unlock(&_waitMutex);
    
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize frameSize = self.view.bounds.size;
    
    _collectionContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _collectionContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_collectionContainer];
    
    _searchDimView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    _searchDimView.backgroundColor = UIColorRGBA(0x000000, 0.4f);
    _searchDimView.hidden = true;
    _searchDimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_searchDimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimViewTapGesture:)]];
    [self.view addSubview:_searchDimView];
    
    _searchCollectionContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 20.0f + 44.0f, frameSize.width, frameSize.height - 44.0f - 20.0f)];
    _searchCollectionContainer.hidden = true;
    [self.view addSubview:_searchCollectionContainer];
    
    _collectionLayout = [[TGSharedMediaCollectionLayout alloc] init];
    _collectionView = [[TGSharedMediaCollectionView alloc] initWithFrame:CGRectMake(0.0f, -200.0f, frameSize.width, frameSize.height + 400.0f) collectionViewLayout:_collectionLayout];
    _collectionView.alwaysBounceVertical = true;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    _searchBar = [[TGSearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _collectionView.frame.size.width, 44.0f) style:TGSearchBarStyleLightPlain];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_collectionView addSubview:_searchBar];
    _searchBar.hidden = _mode == TGSharedMediaControllerModeAll;
    _searchBar.delegate = self;
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[TGSharedMediaImageItemView class] forCellWithReuseIdentifier:@"TGSharedMediaImageItemView"];
    [_collectionView registerClass:[TGSharedMediaVideoItemView class] forCellWithReuseIdentifier:@"TGSharedMediaVideoItemView"];
    [_collectionView registerClass:[TGSharedMediaFileItemView class] forCellWithReuseIdentifier:@"TGSharedMediaFileItemView"];
    [_collectionView registerClass:[TGSharedMediaFileThumbnailItemView class] forCellWithReuseIdentifier:@"TGSharedMediaFileThumbnailItemView"];
    [_collectionView registerClass:[TGSharedMediaLinkItemView class] forCellWithReuseIdentifier:@"TGSharedMediaLinkItemView"];
    [_collectionContainer addSubview:_collectionView];
    
    _searchCollectionLayout = [[TGSharedMediaCollectionLayout alloc] init];
    _searchCollectionView = [[TGSharedMediaCollectionView alloc] initWithFrame:_searchCollectionContainer.bounds collectionViewLayout:_searchCollectionLayout];
    _searchCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchCollectionView.alwaysBounceVertical = true;
    _searchCollectionView.backgroundColor = [UIColor whiteColor];
    
    _searchCollectionView.delegate = self;
    _searchCollectionView.dataSource = self;
    [_searchCollectionView registerClass:[TGSharedMediaImageItemView class] forCellWithReuseIdentifier:@"TGSharedMediaImageItemView"];
    [_searchCollectionView registerClass:[TGSharedMediaVideoItemView class] forCellWithReuseIdentifier:@"TGSharedMediaVideoItemView"];
    [_searchCollectionView registerClass:[TGSharedMediaFileItemView class] forCellWithReuseIdentifier:@"TGSharedMediaFileItemView"];
    [_searchCollectionView registerClass:[TGSharedMediaLinkItemView class] forCellWithReuseIdentifier:@"TGSharedMediaLinkItemView"];
    [_searchCollectionContainer addSubview:_searchCollectionView];
    
    self.scrollViewsForAutomaticInsetsAdjustment = @[_collectionView];
    self.explicitTableInset = UIEdgeInsetsMake(200.0f, 0.0f, 200.0f, 0.0f);
    self.explicitScrollIndicatorInset = self.explicitTableInset;
    
    [_collectionLayout invalidateLayout];
    [_collectionView layoutSubviews];
    
    [_searchCollectionLayout invalidateLayout];
    [_searchCollectionView layoutSubviews];
    
    /*_filterPanelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 45.0f, self.view.frame.size.width, 45.0f)];
    _filterPanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _filterPanelView.backgroundColor = [UIColor whiteColor];
    CGFloat separatorHeight = TGIsRetina() ? 0.5f : 1.0f;
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _filterPanelView.frame.size.width, separatorHeight)];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    separatorView.backgroundColor = UIColorRGB(0xb2b2b2);
    [_filterPanelView addSubview:separatorView];
    
    _filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:[self directionFilterTitles]];
    
    [_filterSegmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlBackground.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_filterSegmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlSelected.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_filterSegmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlSelected.png"] forState:UIControlStateSelected | UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [_filterSegmentedControl setBackgroundImage:[UIImage imageNamed:@"ModernSegmentedControlHighlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    UIImage *dividerImage = [UIImage imageNamed:@"ModernSegmentedControlDivider.png"];
    [_filterSegmentedControl setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [_filterSegmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: TGAccentColor(), UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateNormal];
    [_filterSegmentedControl setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor whiteColor], UITextAttributeTextShadowColor: [UIColor clearColor], UITextAttributeFont: TGSystemFontOfSize(13)} forState:UIControlStateSelected];
    
    _filterSegmentedControl.frame = CGRectMake(7.0f, 8.0f, _filterPanelView.frame.size.width - 14.0f, 29.0f);
    _filterSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [_filterSegmentedControl setSelectedSegmentIndex:0];
    [_filterSegmentedControl addTarget:self action:@selector(filterSegmentedControlChanged) forControlEvents:UIControlEventValueChanged];
    
    [_filterPanelView addSubview:_filterSegmentedControl];
    
    [self.view addSubview:_filterPanelView];*/
    
    [self.view addSubview:_activityIndicatorView];
    if (!_activityIndicatorView.hidden)
        [_activityIndicatorView startAnimating];
    _activityIndicatorView.frame = CGRectMake(CGFloor((self.view.frame.size.width - _activityIndicatorView.frame.size.width) / 2.0f), CGFloor((self.view.frame.size.height - _activityIndicatorView.frame.size.height) / 2.0f), _activityIndicatorView.frame.size.width, _activityIndicatorView.frame.size.height);
    _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _menuView = [[TGSharedMediaMenuView alloc] init];
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    [menuItems addObject:[self titleForMode:TGSharedMediaControllerModeAll]];
    [menuItems addObject:[self titleForMode:TGSharedMediaControllerModeFile]];
    if (_peerId > INT_MIN || TGPeerIdIsChannel(_peerId))
        [menuItems addObject:[self titleForMode:TGSharedMediaControllerModeLink]];
    [_menuView setItems:menuItems];
    __weak TGSharedMediaController *weakSelf = self;
    _menuView.willHide = ^
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf->_displayNavigationMenu = false;
            [UIView animateWithDuration:0.2 animations:^
            {
                strongSelf->_titleArrowView.transform = [strongSelf titleArrowTransformForDisplayMenu:strongSelf-> _displayNavigationMenu];
            }];
        }
    };
    
    _menuView.selectedItemIndexChanged = ^(NSUInteger selectedItemIndex)
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            TGSharedMediaControllerMode mode = TGSharedMediaControllerModeAll;
            if (selectedItemIndex == 1)
                mode = TGSharedMediaControllerModeFile;
            else if (selectedItemIndex == 2)
                mode = TGSharedMediaControllerModeLink;
            [strongSelf setMode:mode filters:strongSelf->_currentFilters];
        }
    };
    [self.view addSubview:_menuView];
    
    if (![self _updateControllerInset:false])
        [self controllerInsetUpdated:UIEdgeInsetsZero];
}

- (void)controllerInsetUpdated:(UIEdgeInsets)previousInset
{
    [super controllerInsetUpdated:previousInset];
    
    _menuView.frame = CGRectMake(0.0f, self.controllerInset.top - self.explicitTableInset.top, self.view.frame.size.width, self.view.frame.size.height);
    if (!self.viewControllerIsChangingInterfaceOrientation)
    {
        _searchCollectionContainer.frame = CGRectMake(0.0f, self.controllerInset.top - self.explicitTableInset.top + 44.0f, self.view.frame.size.width, self.view.frame.size.height - 44.0f - (self.controllerInset.top - self.explicitTableInset.top));
    }
    _searchDimView.frame = CGRectMake(0.0f, self.controllerInset.top - self.explicitTableInset.top + 44.0f, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)filterSegmentedControlChanged
{
    id<TGSharedMediaFilter> filter = [[TGSharedMediaDirectionFilter alloc] initWithDirection:TGSharedMediaDirectionBoth];
    if (_filterSegmentedControl.selectedSegmentIndex == 1)
        filter = [[TGSharedMediaDirectionFilter alloc] initWithDirection:TGSharedMediaDirectionIncoming];
    else if (_filterSegmentedControl.selectedSegmentIndex == 2)
        filter = [[TGSharedMediaDirectionFilter alloc] initWithDirection:TGSharedMediaDirectionOutgoing];
    
    [self setCurrentFilters:@[filter]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize frameSize = self.view.bounds.size;
    CGRect collectionViewFrame = CGRectMake(0.0f, -200.0f, frameSize.width, frameSize.height + 400.0f);
    bool updateLayout = false;
    if (!CGSizeEqualToSize(_collectionView.frame.size, collectionViewFrame.size))
        updateLayout = true;
    _collectionViewWidth = collectionViewFrame.size.width;
    _collectionView.frame = collectionViewFrame;
    _searchCollectionContainer.frame = CGRectMake(0.0f, 20.0f + 44.0f, frameSize.width, frameSize.height - 44.0f - 20.0f);
    
    if (updateLayout)
    {
        [_collectionLayout invalidateLayout];
        [_collectionView layoutSubviews];
        
        [_searchCollectionLayout invalidateLayout];
        [_searchCollectionView layoutSubviews];
    }
    
    if ([_collectionView indexPathsForSelectedItems].count != 0)
        [_collectionView deselectItemAtIndexPath:[_collectionView indexPathsForSelectedItems].firstObject animated:true];
    if ([_searchCollectionView indexPathsForSelectedItems].count != 0)
        [_searchCollectionView deselectItemAtIndexPath:[_searchCollectionView indexPathsForSelectedItems].firstObject animated:true];
}

- (void)layoutControllerForSize:(CGSize)size duration:(NSTimeInterval)duration {
    [super layoutControllerForSize:size duration:duration];
    
    if (duration > DBL_EPSILON) {
        UIView *snapshotView = [_collectionView.superview snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = _collectionView.superview.frame;
        [self.view insertSubview:snapshotView aboveSubview:_collectionView.superview];
        [UIView animateWithDuration:duration animations:^
        {
            snapshotView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
        }];
    }
    
    CGSize screenSize = size;
    
    CGAffineTransform tableTransform = _collectionView.transform;
    _collectionView.transform = CGAffineTransformIdentity;
    
    CGRect tableFrame = CGRectMake(0, 0.0f - 200.0f, screenSize.width, screenSize.height - 0.0f + 400.0f);
    _collectionViewWidth = tableFrame.size.width;
    _collectionView.frame = tableFrame;
    
    _collectionView.transform = tableTransform;
    
    [UIView animateWithDuration:duration animations:^
    {
        _searchCollectionContainer.frame = CGRectMake(0.0f, 20.0f + 44.0f, screenSize.width, screenSize.height - 44.0f - 2.0f);
        [_searchCollectionView.collectionViewLayout invalidateLayout];
    }];
    
    [_collectionView.collectionViewLayout invalidateLayout];
    [_collectionView layoutSubviews];
}

- (NSArray *)sharedMediaItemsForMessages:(NSArray *)messages
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (TGMessage *message in messages)
    {
        bool found = false;
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            {
                [items addObject:[[TGSharedMediaImageItem alloc] initWithMessage:message messageId:message.mid date:message.date incoming:!message.outgoing imageMediaAttachment:attachment]];
                found = true;
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                [items addObject:[[TGSharedMediaVideoItem alloc] initWithMessage:message messageId:message.mid date:message.date incoming:!message.outgoing videoMediaAttachment:attachment]];
                found = true;
            }
            else if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
            {
                [items addObject:[[TGSharedMediaFileItem alloc] initWithMessage:message messageId:message.mid date:message.date incoming:!message.outgoing documentMediaAttachment:attachment]];
                found = true;
            }
        }
        
        if (!found)
        {
            for (id entity in message.entities)
            {
                if ([entity isKindOfClass:[TGMessageEntityUrl class]] || [entity isKindOfClass:[TGMessageEntityTextUrl class]] || [entity isKindOfClass:[TGMessageEntityEmail class]])
                {
                    [items addObject:[[TGSharedMediaLinkItem alloc] initWithMessage:message messageId:message.mid date:message.date incoming:!message.outgoing]];
                }
            }
        }
    }
    
    return items;
}

- (NSArray *)sharedMediaGroupsForItems:(NSArray *)items
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    NSArray *sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(id<TGSharedMediaItem> item1, id<TGSharedMediaItem> item2)
    {
        if (ABS([item1 date] - [item2 date]) < DBL_EPSILON)
            return [item1 messageId] > [item2 messageId] ? NSOrderedAscending : NSOrderedDescending;
        return [item1 date] > [item2 date] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    int currentGroupDate = 0;
    int currentGroupYear = 0;
    int currentGroupMonth = 0;
    NSMutableArray *currentGroupItems = [[NSMutableArray alloc] init];
    
    for (id<TGSharedMediaItem> item in sortedItems)
    {
        time_t t = (int)[item date];
        struct tm timeinfo;
        localtime_r(&t, &timeinfo);
        
        if (timeinfo.tm_year != currentGroupYear || timeinfo.tm_mon != currentGroupMonth)
        {
            if (currentGroupItems.count != 0)
            {
                [groups addObject:[[TGSharedMediaGroup alloc] initWithDate:currentGroupDate items:[[NSArray alloc] initWithArray:currentGroupItems]]];
            }
            
            currentGroupDate = (int)[item date];
            currentGroupYear = timeinfo.tm_year;
            currentGroupMonth = timeinfo.tm_mon;
            [currentGroupItems removeAllObjects];
        }
        
        [currentGroupItems addObject:item];
    }
    
    if (currentGroupItems.count != 0)
    {
        [groups addObject:[[TGSharedMediaGroup alloc] initWithDate:currentGroupDate items:[[NSArray alloc] initWithArray:currentGroupItems]]];
    }
    
    return groups;
}

- (NSArray *)filterGroups:(NSArray *)groups usingFilters:(NSArray *)filters
{
    if (filters.count == 0) {
        return groups;
    }
    
    NSMutableArray *filteredGroups = [[NSMutableArray alloc] init];
    
    for (TGSharedMediaGroup *group in groups)
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (id<TGSharedMediaItem> item in group.items)
        {
            bool passes = true;
            for (id<TGSharedMediaFilter> filter in filters)
            {
                if (![item passesFilter:filter])
                {
                    passes = false;
                    break;
                }
            }
            
            if (passes)
                [items addObject:item];
        }
        
        if (items.count != 0)
            [filteredGroups addObject:[[TGSharedMediaGroup alloc] initWithDate:group.date items:items]];
    }
    
    return filteredGroups;
}

- (NSDictionary *)mediaAvailabilityStatesForItems:(NSArray *)items
{
    NSMutableDictionary *availabilityStates = [[NSMutableDictionary alloc] init];
    
    for (id<TGSharedMediaItem> item in items)
    {
        id mediaId = mediaIdForItem(item);
        if (mediaId == nil)
            continue;
        
        if ([item isKindOfClass:[TGSharedMediaFileItem class]])
        {
            TGSharedMediaFileItem *fileItem = (TGSharedMediaFileItem *)item;
            NSString *filePath = nil;
            if (fileItem.documentMediaAttachment.documentId != 0)
            {
                filePath = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:fileItem.documentMediaAttachment.documentId];
            }
            else
            {
                filePath = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:fileItem.documentMediaAttachment.localDocumentId];
            }
            
            filePath = [filePath stringByAppendingPathComponent:[fileItem.documentMediaAttachment safeFileName]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                availabilityStates[mediaId] = [[TGSharedMediaAvailabilityState alloc] initWithType:TGSharedMediaAvailabilityStateAvailable progress:1.0f];
            }
            else
            {
                availabilityStates[mediaId] = [[TGSharedMediaAvailabilityState alloc] initWithType:TGSharedMediaAvailabilityStateNotAvailable progress:0.0f];
            }
        }
        else
        {
            availabilityStates[mediaId] = [[TGSharedMediaAvailabilityState alloc] initWithType:TGSharedMediaAvailabilityStateAvailable progress:1.0f];
        }
    }
    
    return availabilityStates;
}

- (CGSize)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)__unused indexPath
{
    if (collectionView == _collectionView)
    {
        if (_mode != TGSharedMediaControllerModeFile)
        {
            NSUInteger itemIndex = (NSUInteger)indexPath.item;
            
            id<TGSharedMediaItem> item = nil;
            if (collectionView == _collectionView)
                item = ((TGSharedMediaGroup *)_filteredItemGroups[indexPath.section]).items[itemIndex];
            else
                item = ((TGSharedMediaGroup *)_filteredSearchItemGroups[indexPath.section]).items[itemIndex];
            
            if ([item respondsToSelector:@selector(heightForWidth:)])
                return CGSizeMake(_collectionViewWidth, [item heightForWidth:_collectionViewWidth]);
            
            return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideItemSize : _normalItemSize;
        }
        else
            return CGSizeMake(_collectionViewWidth, 52.0f);
    }
    else
    {
        if (_mode != TGSharedMediaControllerModeFile)
        {
            NSUInteger itemIndex = (NSUInteger)indexPath.item;
            
            id<TGSharedMediaItem> item = nil;
            if (collectionView == _collectionView)
                item = ((TGSharedMediaGroup *)_filteredItemGroups[indexPath.section]).items[itemIndex];
            else
                item = ((TGSharedMediaGroup *)_filteredSearchItemGroups[indexPath.section]).items[itemIndex];
            
            if ([item respondsToSelector:@selector(heightForWidth:)])
                return CGSizeMake(_collectionViewWidth, [item heightForWidth:_collectionViewWidth]);
            
            return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideItemSize : _normalItemSize;
        }
        else
            return CGSizeMake(_collectionViewWidth, 52.0f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    if (collectionView == _collectionView)
    {
        if (_mode == TGSharedMediaControllerModeFile || _mode == TGSharedMediaControllerModeLink)
            return UIEdgeInsetsMake(36.0f + (section == 0 ? 44.0f : 0.0f), 0.0f, 0.0f, 0.0f);
        
        UIEdgeInsets insets = UIEdgeInsetsZero;
        
        if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
            insets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        else
            insets = (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideEdgeInsets : _normalEdgeInsets;
        insets.top += 36.0f;
        
        return insets;
    }
    else
    {
        if (_mode == TGSharedMediaControllerModeFile)
            return UIEdgeInsetsMake(36.0f, 0.0f, 0.0f, 0.0f);
        
        UIEdgeInsets insets = UIEdgeInsetsZero;
        
        if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
            insets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        else
            insets = (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideEdgeInsets : _normalEdgeInsets;
        insets.top += 36.0f;
        
        return insets;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section
{
    if (collectionView == _collectionView)
    {
        if (_mode == TGSharedMediaControllerModeFile || _mode == TGSharedMediaControllerModeLink)
            return 0.0f;
        
        if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
            return 10.0f;
        
        return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideLineSpacing : _normalLineSpacing;
    }
    else
    {
        if (_mode == TGSharedMediaControllerModeFile || _mode == TGSharedMediaControllerModeLink)
            return 0.0f;
        
        if (ABS(_collectionViewWidth - 540.0f) < FLT_EPSILON)
            return 10.0f;
        
        return (_collectionViewWidth >= _widescreenWidth - FLT_EPSILON) ? _wideLineSpacing : _normalLineSpacing;
    }
}

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)__unused section
{
    return 0.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == _collectionView)
        return _filteredItemGroups.count;
    else
        return _filteredSearchItemGroups.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _collectionView)
        return ((TGSharedMediaGroup *)_filteredItemGroups[section]).items.count;
    else
        return ((TGSharedMediaGroup *)_filteredSearchItemGroups[section]).items.count;
}

+ (NSArray *)thumbnailColorsForFileName:(NSString *)fileName
{
    static NSDictionary *colors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSArray *redColors = @[UIColorRGB(0xf0625d), UIColorRGB(0xde524e)];
        NSArray *greenColors = @[UIColorRGB(0x72ce76), UIColorRGB(0x54b658)];
        NSArray *blueColors = @[UIColorRGB(0x60b0e8), UIColorRGB(0x4597d1)];
        NSArray *yellowColors = @[UIColorRGB(0xf5c565), UIColorRGB(0xe5a64e)];
        colors = @{
            @"ppt": redColors,
            @"pptx": redColors,
            @"pdf": redColors,
            @"key": redColors,
            
            @"xls": greenColors,
            @"xlsx": greenColors,
            @"csv": greenColors,
            
            @"doc": blueColors,
            @"docx": blueColors,
            @"txt": blueColors,
            @"psd": blueColors,
            @"mp3": blueColors,
            
            @"zip": yellowColors,
            @"rar": yellowColors,
            @"ai": yellowColors,
            
            @"*": blueColors
        };
    });
    
    NSString *extension = [[fileName pathExtension] lowercaseString];
    if (extension == nil)
        return colors[@"*"];
    
    NSArray *fileColors = colors[extension];
    if (fileColors != nil)
        return fileColors;
    
    return colors[@"*"];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<TGSharedMediaItem> item = nil;
    
    NSUInteger itemIndex = (NSUInteger)indexPath.item;
    
    if (collectionView == _collectionView)
        item = ((TGSharedMediaGroup *)_filteredItemGroups[indexPath.section]).items[itemIndex];
    else
        item = ((TGSharedMediaGroup *)_filteredSearchItemGroups[indexPath.section]).items[itemIndex];
    
    id mediaId = mediaIdForItem(item);
    TGSharedMediaAvailabilityState *availabilityState = mediaId == nil ? nil : _itemAvailabilityStates[mediaId];
    if (availabilityState == nil)
    {
        availabilityState = [[TGSharedMediaAvailabilityState alloc] initWithType:TGSharedMediaAvailabilityStateAvailable progress:1.0f];
    }
    
    TGSharedMediaItemView *itemView = nil;
    
    if ([item isKindOfClass:[TGSharedMediaImageItem class]])
    {
        TGSharedMediaImageItem *imageItem = (TGSharedMediaImageItem *)item;
        TGSharedMediaImageItemView *imageItemView = (TGSharedMediaImageItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGSharedMediaImageItemView" forIndexPath:indexPath];
        imageItemView.imageViewQueue = _imageViewQueue;
        imageItemView.isItemHidden = _isItemHidden;
        imageItemView.isItemSelected = _isItemSelected;
        imageItemView.toggleItemSelection = _toggleItemSelection;
        imageItemView.item = item;
        [imageItemView setImageMediaAttachment:imageItem.imageMediaAttachment messageId:[imageItem messageId] peerId:_peerId];
        itemView = imageItemView;
    }
    else if ([item isKindOfClass:[TGSharedMediaVideoItem class]])
    {
        TGSharedMediaVideoItem *videoItem = (TGSharedMediaVideoItem *)item;
        TGSharedMediaVideoItemView *videoItemView = (TGSharedMediaVideoItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGSharedMediaVideoItemView" forIndexPath:indexPath];
        videoItemView.imageViewQueue = _imageViewQueue;
        videoItemView.isItemHidden = _isItemHidden;
        videoItemView.isItemSelected = _isItemSelected;
        videoItemView.toggleItemSelection = _toggleItemSelection;
        videoItemView.item = item;
        [videoItemView setVideoMediaAttachment:videoItem.videoMediaAttachment messageId:[item messageId] peerId:_peerId];
        itemView = videoItemView;
    }
    else if ([item isKindOfClass:[TGSharedMediaFileItem class]])
    {
        if (_mode == TGSharedMediaControllerModeFile)
        {
            TGSharedMediaFileItemView *fileItemView = (TGSharedMediaFileItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGSharedMediaFileItemView" forIndexPath:indexPath];
            fileItemView.imageViewQueue = _imageViewQueue;
            fileItemView.isItemHidden = _isItemHidden;
            fileItemView.isItemSelected = _isItemSelected;
            fileItemView.toggleItemSelection = _toggleItemSelection;
            fileItemView.item = item;
            [fileItemView setDocumentMediaAttachment:((TGSharedMediaFileItem *)item).documentMediaAttachment date:(int)[item date] lastInSection:((TGSharedMediaGroup *)self.currentFilteredGroups[indexPath.section]).items.count == (NSUInteger)indexPath.item + 1 availabilityState:availabilityState thumbnailColors:[TGSharedMediaController thumbnailColorsForFileName:((TGSharedMediaFileItem *)item).documentMediaAttachment.fileName]];
            itemView = fileItemView;
        }
        else
        {
            TGSharedMediaFileThumbnailItemView *fileItemView = (TGSharedMediaFileThumbnailItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGSharedMediaFileThumbnailItemView" forIndexPath:indexPath];
            fileItemView.imageViewQueue = _imageViewQueue;
            fileItemView.isItemHidden = _isItemHidden;
            fileItemView.isItemSelected = _isItemSelected;
            fileItemView.toggleItemSelection = _toggleItemSelection;
            fileItemView.item = item;
            [fileItemView setDocumentMediaAttachment:((TGSharedMediaFileItem *)item).documentMediaAttachment availabilityState:availabilityState thumbnailColors:[TGSharedMediaController thumbnailColorsForFileName:((TGSharedMediaFileItem *)item).documentMediaAttachment.fileName]];
            itemView = fileItemView;
        }
    }
    else if ([item isKindOfClass:[TGSharedMediaLinkItem class]])
    {
        TGSharedMediaLinkItemView *linkItemView = (TGSharedMediaLinkItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TGSharedMediaLinkItemView" forIndexPath:indexPath];
        linkItemView.imageViewQueue = _imageViewQueue;
        linkItemView.isItemHidden = _isItemHidden;
        linkItemView.isItemSelected = _isItemSelected;
        linkItemView.toggleItemSelection = _toggleItemSelection;
        linkItemView.alertViewHost = self.view;
        linkItemView.item = item;
        [linkItemView setMessage:((TGSharedMediaLinkItem *)item).message date:(int)[item date] lastInSection:false textModel:[(TGSharedMediaLinkItem *)item textModel] imageSignal:[(TGSharedMediaLinkItem *)item imageSignal] links:[(TGSharedMediaLinkItem *)item links] webPage:[(TGSharedMediaLinkItem *)item webPage]];
        itemView = linkItemView;
    }
    
    if (collectionView == _collectionView)
    {
        [itemView setEditing:_editing animated:false];
        [itemView updateItemSelected];
    }
    
    return itemView;
}

- (NSString *)dateStringForGroup:(TGSharedMediaGroup *)group
{
    return [TGDateUtils stringForMonthOfYear:(int)group.date];
}

- (NSString *)summaryStringForGroup:(TGSharedMediaGroup *)group
{
    NSString *format = @"";
    switch (group.contentType)
    {
        case TGSharedMediaGroupContentTypeImage:
            if (group.items.count == 1)
                format = TGLocalized(@"SharedMedia.Photo_1");
            else if (group.items.count == 2)
                format = TGLocalized(@"SharedMedia.Photo_2");
            else if (group.items.count >= 3 && group.items.count <= 10)
                format = TGLocalized(@"SharedMedia.Photo_3_10");
            else
                format = TGLocalized(@"SharedMedia.Photo_any");
            break;
        case TGSharedMediaGroupContentTypeVideo:
            if (group.items.count == 1)
                format = TGLocalized(@"SharedMedia.Video_1");
            else if (group.items.count == 2)
                format = TGLocalized(@"SharedMedia.Video_2");
            else if (group.items.count >= 3 && group.items.count <= 10)
                format = TGLocalized(@"SharedMedia.Video_3_10");
            else
                format = TGLocalized(@"SharedMedia.Video_any");
            break;
        case TGSharedMediaGroupContentTypeFile:
            if (group.items.count == 1)
                format = TGLocalized(@"SharedMedia.File_1");
            else if (group.items.count == 2)
                format = TGLocalized(@"SharedMedia.File_2");
            else if (group.items.count >= 3 && group.items.count <= 10)
                format = TGLocalized(@"SharedMedia.File_3_10");
            else
                format = TGLocalized(@"SharedMedia.File_any");
            break;
        case TGSharedMediaGroupContentTypeLink:
            if (group.items.count == 1)
                format = TGLocalized(@"SharedMedia.Link_1");
            else if (group.items.count == 2)
                format = TGLocalized(@"SharedMedia.Link_2");
            else if (group.items.count >= 3 && group.items.count <= 10)
                format = TGLocalized(@"SharedMedia.Link_3_10");
            else
                format = TGLocalized(@"SharedMedia.Link_any");
            break;
        default:
            if (group.items.count == 1)
                format = TGLocalized(@"SharedMedia.Generic_1");
            else if (group.items.count == 2)
                format = TGLocalized(@"SharedMedia.Generic_2");
            else if (group.items.count >= 3 && group.items.count <= 10)
                format = TGLocalized(@"SharedMedia.Generic_3_10");
            else
                format = TGLocalized(@"SharedMedia.Generic_any");
            break;
    }
    
    return [[NSString alloc] initWithFormat:format, [[NSString alloc] initWithFormat:@"%d", (int)group.items.count]];
}

- (void)collectionView:(UICollectionView *)collectionView setupSectionHeaderView:(TGSharedMediaSectionHeaderView *)sectionHeaderView forSectionHeader:(TGSharedMediaSectionHeader *)sectionHeader
{
    if (collectionView == _collectionView)
    {
        TGSharedMediaGroup *group = _filteredItemGroups[sectionHeader.index];
        [sectionHeaderView setDateString:[self dateStringForGroup:group] summaryString:[self summaryStringForGroup:group]];
    }
    else
    {
        TGSharedMediaGroup *group = _filteredSearchItemGroups[sectionHeader.index];
        [sectionHeaderView setDateString:[self dateStringForGroup:group] summaryString:[self summaryStringForGroup:group]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<TGSharedMediaItem> item = nil;
    if (collectionView == _collectionView)
        item = ((TGSharedMediaGroup *)_filteredItemGroups[indexPath.section]).items[indexPath.item];
    else
        item = ((TGSharedMediaGroup *)_filteredSearchItemGroups[indexPath.section]).items[indexPath.item];
    
    if ([item isKindOfClass:[TGSharedMediaFileItem class]])
    {
        TGSharedMediaFileItem *fileItem = (TGSharedMediaFileItem *)item;
        NSString *filePath = nil;
        if (fileItem.documentMediaAttachment.documentId != 0)
        {
            filePath = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:fileItem.documentMediaAttachment.documentId];
        }
        else
        {
            filePath = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:fileItem.documentMediaAttachment.localDocumentId];
        }
        
        filePath = [filePath stringByAppendingPathComponent:[fileItem.documentMediaAttachment safeFileName]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            bool isAudio = false;
            for (id attribute in fileItem.documentMediaAttachment.attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                {
                    isAudio = true;
                    break;
                }
            }
            
            if (isAudio)
            {
                [TGTelegraphInstance.musicPlayer setPlaylist:[TGGenericPeerPlaylistSignals playlistForPeerId:_peerId important:true atMessageId:[item messageId]] initialItemKey:@([item messageId])];
            }
            else
            {
                TGDocumentController *documentController = [[TGDocumentController alloc] initWithURL:[NSURL fileURLWithPath:filePath] messageId:[item messageId]];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    [self.navigationController pushViewController:documentController animated:true];
                else
                {
                    [_collectionView deselectItemAtIndexPath:indexPath animated:true];
                    
                    if (iosMajorVersion() >= 8)
                    {
                        documentController.modalPresentationStyle = UIModalPresentationFormSheet;
                        [self presentViewController:documentController animated:false completion:nil];
                    }
                    else
                    {
                        TGNavigationController *navigationController = [TGNavigationController navigationControllerWithControllers:@[documentController]];
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                        [self presentViewController:navigationController animated:true completion:nil];
                    }
                }
            }
            
            TGMediaId *mediaId = mediaIdForItem(item);
            if (mediaId != nil)
            {
                [TGDatabaseInstance() updateLastUseDateForMediaType:mediaId.type mediaId:mediaId.itemId messageId:[item messageId]];
            }
        }
        else
        {
            [collectionView deselectItemAtIndexPath:indexPath animated:true];
            
            bool cancel = false;
            TGMediaId *mediaId = mediaIdForItem(item);
            if (mediaId != nil)
            {
                TGSharedMediaAvailabilityState *availabilityState = _itemAvailabilityStates[mediaId];
                if (availabilityState != nil && availabilityState.type == TGSharedMediaAvailabilityStateDownloading)
                    cancel = true;
            }
            
            if (cancel)
            {
                [[TGDownloadManager instance] cancelItem:mediaId];
            }
            else
            {
                TGDocumentMediaAttachment *documentAttachment = fileItem.documentMediaAttachment;
                if (documentAttachment.documentId != 0 || documentAttachment.documentUri.length != 0)
                {
                    bool highPriority = true;
                    id mediaId = [[TGMediaId alloc] initWithType:3 itemId:documentAttachment.documentId != 0 ? documentAttachment.documentId : documentAttachment.localDocumentId];
                    [[TGDownloadManager instance] requestItem:[NSString stringWithFormat:@"/tg/media/document/(%d:%" PRId64 ":%@)", documentAttachment.datacenterId, documentAttachment.documentId, documentAttachment.documentUri.length != 0 ? documentAttachment.documentUri : @""] options:[[NSDictionary alloc] initWithObjectsAndKeys:documentAttachment, @"documentAttachment", nil] changePriority:highPriority messageId:[item messageId] itemId:mediaId groupId:_peerId itemClass:TGDownloadItemClassDocument];
                }
            }
        }
    }
    else if ([item isKindOfClass:[TGSharedMediaImageItem class]] || [item isKindOfClass:[TGSharedMediaVideoItem class]])
    {
        __weak TGSharedMediaController *weakSelf = self;
        TGGenericPeerMediaGalleryModel *model = nil;
        TGModernGalleryController *controller = [self createGalleryControllerForItem:item hideItem:^(id<TGSharedMediaItem> item)
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_hiddenItem = item;
                [strongSelf _updateHiddenItems];
            }
        } referenceViewForItem:^UIView *(id<TGSharedMediaItem> item)
        {
            if (item == nil)
                return nil;
            
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                for (TGSharedMediaItemView *itemView in [strongSelf->_collectionView visibleCells])
                {
                    if ([itemView.item isEqual:item])
                        return [itemView transitionView];
                }
            }
            
            return nil;
        } genericPeerGalleryModel:&model];
        if (controller != nil)
        {
            _galleryModel = model;
            TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:self contentController:controller];
            controllerWindow.hidden = false;
        }
    }
    else if ([item isKindOfClass:[TGSharedMediaLinkItem class]])
    {
        [collectionView deselectItemAtIndexPath:indexPath animated:true];
        TGSharedMediaLinkItem *linkItem = (TGSharedMediaLinkItem *)item;
        if (linkItem.webPage.url.length != 0)
        {
            if (linkItem.webPage.embedUrl.length != 0)
                [self openEmbed:linkItem.webPage];
            else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkItem.webPage.url]];
        }
        else if (linkItem.links.count != 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkItem.links[0]]];
        }
    }
}

- (void)openEmbed:(TGWebPageMediaAttachment *)webPage
{
    [self.view endEditing:true];
    
    __weak TGSharedMediaController *weakSelf = self;
    _attachmentSheetWindow = [[TGAttachmentSheetWindow alloc] init];
    _attachmentSheetWindow.dismissalBlock = ^
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_attachmentSheetWindow.rootViewController = nil;
        strongSelf->_attachmentSheetWindow = nil;
    };
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    TGAttachmentSheetEmbedItemView *embedView = [[TGAttachmentSheetEmbedItemView alloc] initWithWebPage:webPage];
    [items addObject:embedView];
    
    [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Web.OpenExternal") pressed:^
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webPage.url]];
        }
    }]];
    
    [items addObject:[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Web.CopyLink") pressed:^
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            [[UIPasteboard generalPasteboard] setString:webPage.url];
        }
    }]];
    
    TGAttachmentSheetButtonItemView *cancelItem =[[TGAttachmentSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") pressed:^
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
    }];
    
    [cancelItem setBold:true];
    [items addObject:cancelItem];
    
    _attachmentSheetWindow.view.items = items;
    _attachmentSheetWindow.windowLevel = UIWindowLevelNormal;
    [_attachmentSheetWindow showAnimated:true completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _collectionView)
        [self _maybeLoadMore];
    else
        [_searchBar resignFirstResponder];
}

- (void)_maybeLoadMore
{
    if (_currentLoadMoreSignal != nil && _collectionView.contentOffset.y > _collectionView.contentSize.height - _collectionView.bounds.size.height)
    {
        SSignal *currentLoadMoreSignal = _currentLoadMoreSignal;
        _currentLoadMoreSignal = nil;
        __weak TGSharedMediaController *weakSelf = self;
        
        if (_filteredItemGroups.count == 0)
        {
            _activityIndicatorView.hidden = false;
            [_activityIndicatorView startAnimating];
        }
        else
        {
            _activityIndicatorView.hidden = true;
            [_activityIndicatorView stopAnimating];
        }
        
        [self _updateEmptyState];
        
        __block bool gotItems = false;
        [_currentQueryDisposable setDisposable:[currentLoadMoreSignal startWithNext:^(id next)
        {
            TGDispatchOnMainThread(^
            {
                __strong TGSharedMediaController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    if ([next respondsToSelector:@selector(boolValue)])
                    {
                    }
                    else
                    {
                        NSArray *items = next;
                        if (items.count != 0)
                            gotItems = true;
                        [strongSelf processSearchResult:items append:true];
                    }
                }
            });
        } error:^(__unused id error)
        {
            
        } completed:^
        {
            TGDispatchOnMainThread(^
            {
                __strong TGSharedMediaController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    strongSelf->_activityIndicatorView.hidden = true;
                    [strongSelf->_activityIndicatorView stopAnimating];
                    
                    [strongSelf updateLoadMoreSignal:gotItems];
                    [strongSelf _maybeLoadMore];
                    [strongSelf _updateEmptyState];
                }
            });
        }]];
    }
}

- (void)_updateEmptyState
{
    if (!_activityIndicatorView.hidden || _filteredItemGroups.count != 0)
    {
        [_currentEmptyView removeFromSuperview];
        _currentEmptyView = nil;
        
        if (_mode != TGSharedMediaControllerModeAll)
            _searchBar.hidden = !_activityIndicatorView.hidden && _filteredItemGroups.count == 0;
        else
            _searchBar.hidden = true;
    }
    else
    {
        _searchBar.hidden = true;
        
        if (_mode == TGSharedMediaControllerModeFile)
        {
            if (![_currentEmptyView isKindOfClass:[TGSharedMediaFilesEmptyView class]])
            {
                [_currentEmptyView removeFromSuperview];
                _currentEmptyView = [[TGSharedMediaFilesEmptyView alloc] initWithFrame:self.view.bounds];
                _currentEmptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.view insertSubview:_currentEmptyView aboveSubview:_activityIndicatorView];
            }
        }
        else if (_mode == TGSharedMediaControllerModeLink)
        {
            if (![_currentEmptyView isKindOfClass:[TGSharedMediaLinksEmptyView class]])
            {
                [_currentEmptyView removeFromSuperview];
                _currentEmptyView = [[TGSharedMediaLinksEmptyView alloc] initWithFrame:self.view.bounds];
                _currentEmptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.view insertSubview:_currentEmptyView aboveSubview:_activityIndicatorView];
            }
        }
        else
        {
            if (![_currentEmptyView isKindOfClass:[TGSharedMediaAllFilesEmptyView class]])
            {
                [_currentEmptyView removeFromSuperview];
                _currentEmptyView = [[TGSharedMediaAllFilesEmptyView alloc] initWithFrame:self.view.bounds];
                _currentEmptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.view insertSubview:_currentEmptyView aboveSubview:_activityIndicatorView];
            }
        }
    }
    
    if (_filteredItemGroups.count != 0)
    {
        if (self.navigationItem.rightBarButtonItem == nil)
        {
            [self setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:TGLocalized(@"Common.Select") style:UIBarButtonItemStylePlain target:self action:@selector(editPressed)]];
        }
    }
    else
    {
        if (_editing)
            [self cancelPressed];
        [self setRightBarButtonItem:nil];
    }
}

- (id<TGSharedMediaItem>)_findGalleryItem:(id<TGGenericPeerGalleryItem>)item
{
    int32_t messageId = [item messageId];
    
    for (TGSharedMediaGroup *group in _filteredItemGroups)
    {
        for (id<TGSharedMediaItem> sharedMediaItem in group.items)
        {
            if ([sharedMediaItem messageId] == messageId)
            {
                return sharedMediaItem;
            }
        }
    }
    
    return nil;
}

- (NSArray *)messagesForItemGroups:(NSArray *)groups
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    for (TGSharedMediaGroup *group in groups)
    {
        for (id<TGSharedMediaItem> item in group.items)
        {
            [messages addObject:[item message]];
        }
    }
    
    return messages;
}

- (TGModernGalleryController *)createGalleryControllerForItem:(id<TGSharedMediaItem>)item hideItem:(void (^)(id<TGSharedMediaItem>))hideItem referenceViewForItem:(UIView *(^)(id<TGSharedMediaItem>))referenceViewForItem genericPeerGalleryModel:(__autoreleasing TGGenericPeerMediaGalleryModel **)genericPeerGalleryModel
{
    TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
    TGGenericPeerMediaGalleryModel *model = [[TGGenericPeerMediaGalleryModel alloc] initWithPeerId:_peerId allowActions:_allowActions messages:[[self messagesForItemGroups:_filteredItemGroups].reverseObjectEnumerator allObjects] atMessageId:[item messageId]];
    if (genericPeerGalleryModel)
        *genericPeerGalleryModel = model;
    modernGallery.model = model;
    
    __weak TGSharedMediaController *weakSelf = self;
    
    modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil && [item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
        {
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            id<TGSharedMediaItem> listItem = [strongSelf _findGalleryItem:concreteItem];
            if (hideItem)
                hideItem(listItem);
        }
    };
    
    modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil && [item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
        {
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            id<TGSharedMediaItem> listItem = [strongSelf _findGalleryItem:concreteItem];
            if (referenceViewForItem)
                return referenceViewForItem(listItem);
        }
        
        return nil;
    };
    
    modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item)
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil && [item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
        {
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            id<TGSharedMediaItem> listItem = [strongSelf _findGalleryItem:concreteItem];
            if (referenceViewForItem)
                return referenceViewForItem(listItem);
        }
        
        return nil;
    };
    
    modernGallery.completedTransitionOut = ^
    {
        __strong TGSharedMediaController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (hideItem)
                hideItem(nil);
        }
    };
    
    return modernGallery;
}

- (void)_updateEditing:(bool)animated
{
    if (_editing)
    {
        if (_selectionPanelView == nil)
        {
            _selectionPanelView = [[TGSharedMediaSelectionPanelView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 45.0f)];
            _selectionPanelView.shareEnabled = _allowActions;
            _selectionPanelView.deleteEnabled = !TGPeerIdIsChannel(_peerId);
            _selectionPanelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            __weak TGSharedMediaController *weakSelf = self;
            _selectionPanelView.deleteSelectedItems = ^
            {
                __strong TGSharedMediaController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    NSString *messageText = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"SharedMedia.DeleteItemsConfirmation_" value:strongSelf->_selectedMessageIds.count]), [[NSString alloc] initWithFormat:@"%d", (int)strongSelf->_selectedMessageIds.count]];
                    
                    [[[TGActionSheet alloc] initWithTitle:messageText actions:@[
                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Delete") action:@"delete" type:TGActionSheetActionTypeDestructive],
                        [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
                    ] actionBlock:^(__unused id target, NSString *action)
                    {
                        if ([action isEqualToString:@"delete"])
                        {
                            __strong TGSharedMediaController *strongSelf = weakSelf;
                            if (strongSelf != nil)
                                [strongSelf _deleteSelectedItems];
                        }
                    } target:strongSelf] showInView:strongSelf.view];
                }
            };
            _selectionPanelView.shareSelectedItems = ^
            {
                __strong TGSharedMediaController *strongSelf = weakSelf;
                if (strongSelf != nil)
                    [strongSelf _shareSelectedItems];
            };
            [self.view addSubview:_selectionPanelView];
        }
        _selectionPanelView.hidden = false;
        CGRect selectionPanelFrame = CGRectMake(0.0f, self.view.frame.size.height - 45.0f, self.view.frame.size.width, 45.0f);
        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:[TGViewController preferredAnimationCurve] << 16 animations:^
            {
                _selectionPanelView.frame = selectionPanelFrame;
                self.explicitTableInset = UIEdgeInsetsMake(200.0f, 0.0f, 200.0f + 45.0f, 0.0f);
                self.explicitScrollIndicatorInset = self.explicitTableInset;
            } completion:nil];
        }
        else
        {
            _selectionPanelView.frame = selectionPanelFrame;
            self.explicitTableInset = UIEdgeInsetsMake(200.0f, 0.0f, 200.0f + 45.0f, 0.0f);
            self.explicitScrollIndicatorInset = self.explicitTableInset;
        }
    }
    else
    {
        if (_selectionPanelView != nil)
        {
            CGRect selectionPanelFrame = CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 45.0f);
            if (animated)
            {
                [UIView animateWithDuration:0.3 animations:^
                {
                    _selectionPanelView.frame = selectionPanelFrame;
                    self.explicitTableInset = UIEdgeInsetsMake(200.0f, 0.0f, 200.0f, 0.0f);
                    self.explicitScrollIndicatorInset = self.explicitTableInset;
                } completion:^(BOOL finished)
                {
                    if (finished)
                        _selectionPanelView.hidden = true;
                }];
            }
            else
            {
                _selectionPanelView.frame = selectionPanelFrame;
                _selectionPanelView.hidden = true;
                self.explicitTableInset = UIEdgeInsetsMake(200.0f, 0.0f, 200.0f, 0.0f);
                self.explicitScrollIndicatorInset = self.explicitTableInset;
            }
        }
    }
    
    if (_collectionView.tracking || _collectionView.decelerating)
    {
        for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
        {
            [itemView setEditing:_editing animated:animated];
        }
    }
    else
    {
        CGFloat lastOrigin = 0.0f;
        NSTimeInterval lastDelay = 0.0;
        NSTimeInterval delayIncrement = 0.0115;
        if (_mode == TGSharedMediaControllerModeFile || _mode == TGSharedMediaControllerModeLink)
            delayIncrement /= 2.0;
        
        for (TGSharedMediaItemView *itemView in [_collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2)
        {
            return view1.frame.origin.y < view2.frame.origin.y ? NSOrderedAscending : NSOrderedDescending;
        }])
        {
            [itemView setEditing:_editing animated:animated delay:lastDelay];
            if (itemView.frame.origin.y > lastOrigin + FLT_EPSILON)
                lastDelay += delayIncrement;
            lastOrigin = itemView.frame.origin.y;
        }
    }
}

- (void)_updateSelectionInterface
{
    _selectionPanelView.selecterItemCount = _selectedMessageIds.count;
}

- (void)_updateSelectedItems
{
    for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
    {
        [itemView updateItemSelected];
    }
}

- (void)_updateHiddenItems
{
    for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
    {
        [itemView updateItemHidden];
    }
}

- (void)_shareSelectedItems
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];

    for (TGSharedMediaGroup *group in _rawItemGroups)
    {
        for (id<TGSharedMediaItem> item in group.items)
        {
            if ([_selectedMessageIds containsObject:@([item messageId])])
                [messages addObject:[item message]];
        }
    }
    
    [messages sortUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
    {
        if (ABS(message1.date - message2.date) < DBL_EPSILON)
            return message1.mid > message2.mid ? NSOrderedAscending : NSOrderedDescending;
        return message1.date > message2.date ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:messages sendMessages:nil showSecretChats:true];
    forwardController.skipConfirmation = true;
    forwardController.watcherHandle = _actionHandle;
    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:forwardController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)_deleteSelectedItems
{
    if (_selectedMessageIds.count != 0)
    {
        NSArray *messageIds = [_selectedMessageIds allObjects];
        _selectedMessageIds = nil;
        static int uniqueId = 0;
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/conversation/(%" PRId64 ")/deleteMessages/(%s%d)", _peerId, __PRETTY_FUNCTION__, uniqueId++] options:@{@"mids": messageIds} watcher:TGTelegraphInstance];
        
        [self _deleteItemsWithMessageIds:messageIds];
        
        [self cancelPressed];
    }
}

- (void)_deleteItemsWithMessageIds:(NSArray *)messageIds
{
    if (messageIds.count == 0)
        return;
    
    NSSet *messageIdsSet = [[NSSet alloc] initWithArray:messageIds];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    bool anyDeleted = false;
    
    for (TGSharedMediaGroup *group in _rawItemGroups)
    {
        for (id<TGSharedMediaItem> item in group.items)
        {
            if (![messageIdsSet containsObject:@([item messageId])])
                [items addObject:item];
            else
                anyDeleted = true;
        }
    }
    
    if (!anyDeleted)
        return;
    
    
    _rawItemGroups = [self sharedMediaGroupsForItems:items];
    _filteredItemGroups = [self filterGroups:_rawItemGroups usingFilters:_currentFilters];
    
    NSMutableArray *removedViews = [[NSMutableArray alloc] init];
    NSMutableDictionary *previousItemFrames = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *updatedItemFrames = [[NSMutableDictionary alloc] init];
    
    for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
    {
        if ([messageIdsSet containsObject:@([itemView.item messageId])])
        {
            UIView *snapshotView = [itemView snapshotViewAfterScreenUpdates:false];
            snapshotView.frame = itemView.frame;
            [removedViews addObject:snapshotView];
        }
        else
            previousItemFrames[@([itemView.item messageId])] = [NSValue valueWithCGRect:itemView.frame];
    }
    
    [self reloadData];
    
    for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
    {
        if (![messageIdsSet containsObject:@([itemView.item messageId])])
        {
            updatedItemFrames[@([itemView.item messageId])] = [NSValue valueWithCGRect:itemView.frame];
            if (previousItemFrames[@([itemView.item messageId])] != nil)
                itemView.frame = [(NSValue *)previousItemFrames[@([itemView.item messageId])] CGRectValue];
            else
                itemView.frame = CGRectMake(itemView.frame.origin.x, _collectionView.contentOffset.y + _collectionView.bounds.size.height, itemView.frame.size.width, itemView.frame.size.height);
        }
    }
    
    for (UIView *snapshotView in removedViews)
    {
        [_collectionView addSubview:snapshotView];
    }
    
    CGAffineTransform selectedItemsTransform = CGAffineTransformIdentity;
    CGFloat selectedItemsAlpha = 0.0f;
    if (_mode != TGSharedMediaControllerModeFile && _mode != TGSharedMediaControllerModeLink)
    {
        selectedItemsTransform = CGAffineTransformMakeScale(0.01f, 0.01f);
        selectedItemsAlpha = 1.0f;
    }
    [UIView animateWithDuration:0.2 animations:^
    {
        for (UIView *snapshotView in removedViews)
        {
            snapshotView.transform = selectedItemsTransform;
            snapshotView.alpha = selectedItemsAlpha;
        }
    } completion:^(__unused BOOL finished)
    {
        for (UIView *snapshotView in removedViews)
        {
            [snapshotView removeFromSuperview];
        }
    }];
    
    NSTimeInterval currentDelay = 0.0;
    for (TGSharedMediaItemView *itemView in [_collectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2)
    {
        if (view1.frame.origin.y < view2.frame.origin.y)
            return NSOrderedAscending;
        return view1.frame.origin.x < view2.frame.origin.x ? NSOrderedAscending : NSOrderedDescending;
    }])
    {
        if (updatedItemFrames[@([itemView.item messageId])] != nil)
        {
            [UIView animateWithDuration:0.2 delay:currentDelay options:[TGViewController preferredAnimationCurve] << 16 animations:^
            {
                itemView.frame = [(NSValue *)updatedItemFrames[@([itemView.item messageId])] CGRectValue];
            } completion:nil];
        }
        currentDelay += 0.008;
    }
}

static id mediaIdForItem(id<TGSharedMediaItem> item)
{
    if ([item isKindOfClass:[TGSharedMediaFileItem class]])
    {
        TGSharedMediaFileItem *fileItem = (TGSharedMediaFileItem *)item;
        
        if (fileItem.documentMediaAttachment.documentId != 0)
            return [[TGMediaId alloc] initWithType:3 itemId:fileItem.documentMediaAttachment.documentId];
        else if (fileItem.documentMediaAttachment.localDocumentId != 0 && fileItem.documentMediaAttachment.documentUri.length != 0)
            return [[TGMediaId alloc] initWithType:3 itemId:fileItem.documentMediaAttachment.localDocumentId];
    }
    
    return nil;
}

- (bool)itemMatchesMode:(id<TGSharedMediaItem>)item {
    switch (_mode) {
        case TGSharedMediaControllerModeAll:
            return [item isKindOfClass:[TGSharedMediaImageItem class]] || [item isKindOfClass:[TGSharedMediaVideoItem class]];
        case TGSharedMediaControllerModeFile:
            return [item isKindOfClass:[TGSharedMediaFileItem class]];
        case TGSharedMediaControllerModeLink:
            return [item isKindOfClass:[TGSharedMediaLinkItem class]];
        default:
            return false;
    }
    return false;
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)arguments
{
    if ([path isEqualToString:@"/as/media/imageThumbnailUpdated"])
    {
        TGDispatchOnMainThread(^
        {
            for (TGSharedMediaItemView *itemView in _collectionView.visibleCells)
            {
                [itemView imageThumbnailUpdated:resource];
            }
        });
    }
    else if ([path isEqualToString:@"downloadManagerStateChanged"])
    {
        NSMutableDictionary *availabilityStates = [[NSMutableDictionary alloc] init];
        
        bool animated = ![arguments[@"requested"] boolValue];
        
        NSDictionary *mediaList = resource;
        
        if (mediaList == nil || mediaList.count == 0)
        {
        }
        else
        {
            [mediaList enumerateKeysAndObjectsUsingBlock:^(__unused NSString *path, TGDownloadItem *item, __unused BOOL *stop)
            {
                if (item.itemId != nil)
                {
                    TGSharedMediaAvailabilityState *availabilityState = [[TGSharedMediaAvailabilityState alloc] initWithType:TGSharedMediaAvailabilityStateDownloading progress:item.progress];
                    
                    availabilityStates[item.itemId] = availabilityState;
                }
            }];
        }
        
        if (arguments != nil)
        {
            for (id mediaId in [arguments objectForKey:@"completedItemIds"])
            {
                TGSharedMediaAvailabilityState *availabilityState = [[TGSharedMediaAvailabilityState alloc] initWithType:TGSharedMediaAvailabilityStateAvailable progress:0.0f];
                availabilityStates[mediaId] = availabilityState;
            }
            
            for (id mediaId in [arguments objectForKey:@"failedItemIds"])
            {
                TGSharedMediaAvailabilityState *availabilityState = [[TGSharedMediaAvailabilityState alloc] initWithType:TGSharedMediaAvailabilityStateNotAvailable progress:0.0f];
                availabilityStates[mediaId] = availabilityState;
            }
        }
        
        TGDispatchOnMainThread(^
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:_itemAvailabilityStates];
            [dict addEntriesFromDictionary:availabilityStates];
            
            _itemAvailabilityStates = dict;
            
            [self updateMediaAvailabilityStates:animated];
        });
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", _peerId]])
    {
        NSArray *messages = [((SGraphObjectNode *)resource).object copy];
        NSArray *items = [self sharedMediaItemsForMessages:messages];
        if (items.count != 0)
        {
            TGDispatchOnMainThread(^
            {
                NSMutableArray *mergedItems = [[NSMutableArray alloc] init];
                for (TGSharedMediaGroup *group in _rawItemGroups)
                {
                    for (id<TGSharedMediaItem> item in group.items)
                    {
                        [mergedItems addObject:item];
                    }
                }
                
                for (id<TGSharedMediaItem> item in items)
                {
                    if ([self itemMatchesMode:item]) {
                        if (![mergedItems containsObject:item])
                            [mergedItems addObject:item];
                    }
                }
                
                NSArray *groups = [self filterGroups:[self sharedMediaGroupsForItems:mergedItems] usingFilters:_currentFilters];
                _rawItemGroups = groups;
                NSMutableArray *itemsWithoutAvailabilityState = [[NSMutableArray alloc] initWithArray:items];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                {
                    NSMutableDictionary *mediaAvailabilityStates = [[NSMutableDictionary alloc] initWithDictionary:[self mediaAvailabilityStatesForItems:itemsWithoutAvailabilityState]];
                    TGDispatchOnMainThread(^
                    {
                        [mediaAvailabilityStates removeObjectsForKeys:[_itemAvailabilityStates allKeys]];
                        [mediaAvailabilityStates addEntriesFromDictionary:_itemAvailabilityStates];
                        _itemAvailabilityStates = mediaAvailabilityStates;
                        [self updateMediaAvailabilityStates:false];
                    });
                });
                
                _filteredItemGroups = [self filterGroups:groups usingFilters:_currentFilters];
                
                if (_filteredItemGroups.count != 0)
                {
                    [_activityIndicatorView stopAnimating];
                    _activityIndicatorView.hidden = true;
                    
                    [self _updateEmptyState];
                    [self reloadData];
                }
            });
        }
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId]])
    {
        NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSUInteger i = 0; i < midMessagePairs.count; i += 2)
        {
            dict[midMessagePairs[0]] = midMessagePairs[1];
        }
        
        TGDispatchOnMainThread(^
        {
            NSMutableArray *itemsForMediaAvailabilityChecking = [[NSMutableArray alloc] init];
            
            NSMutableArray *updatedGroups = nil;
            NSUInteger groupIndex = 0;
            for (TGSharedMediaGroup *group in _rawItemGroups)
            {
                NSMutableArray *updatedItems = nil;
                NSUInteger itemIndex = 0;
                for (id<TGSharedMediaItem> item in group.items)
                {
                    TGMessage *updatedMessage = dict[@([item messageId])];
                    if (updatedMessage != nil)
                    {
                        NSArray *itemsArrayForMessage = [self sharedMediaItemsForMessages:@[updatedMessage]];
                        if (itemsArrayForMessage.count != 0)
                        {
                            if (updatedItems == nil)
                                updatedItems = [[NSMutableArray alloc] initWithArray:group.items];
                            updatedItems[itemIndex] = itemsArrayForMessage[0];
                            [itemsForMediaAvailabilityChecking addObject:itemsArrayForMessage[0]];
                        }
                    }
                    itemIndex++;
                }
                
                if (updatedItems != nil)
                {
                    TGSharedMediaGroup *group = [self sharedMediaGroupsForItems:updatedItems].firstObject;
                    if (group != nil)
                    {
                        if (updatedGroups == nil)
                            updatedGroups = [[NSMutableArray alloc] initWithArray:_rawItemGroups];
                        updatedGroups[groupIndex] = group;
                    }
                }
                
                groupIndex++;
            }
            
            if (itemsForMediaAvailabilityChecking.count != 0)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                {
                    NSMutableDictionary *mediaAvailabilityStates = [[NSMutableDictionary alloc] initWithDictionary:[self mediaAvailabilityStatesForItems:itemsForMediaAvailabilityChecking]];
                    TGDispatchOnMainThread(^
                    {
                        [mediaAvailabilityStates removeObjectsForKeys:[_itemAvailabilityStates allKeys]];
                        [mediaAvailabilityStates addEntriesFromDictionary:_itemAvailabilityStates];
                        _itemAvailabilityStates = mediaAvailabilityStates;
                        [self updateMediaAvailabilityStates:false];
                    });
                });
            }
            
            if (updatedGroups != nil)
            {
                _rawItemGroups = updatedGroups;
                _filteredItemGroups = [self filterGroups:_rawItemGroups usingFilters:_currentFilters];
                [self reloadData];
            }
        });
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId]])
    {
        NSArray *messageIds = ((SGraphObjectNode *)resource).object;
        
        TGDispatchOnMainThread(^
        {
            [self _deleteItemsWithMessageIds:messageIds];
        });
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)__unused searchBar
{
    [self setSearchActive:true];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)__unused searchBar
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)__unused searchBar
{
    [self setSearchActive:false];
}

- (void)dimViewTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self setSearchActive:false];
    }
}

- (void)setSearchActive:(bool)active
{
    if (active)
    {
        _searchDimView.hidden = false;
        _searchDimView.alpha = 0.0f;
        [_searchBar setShowsCancelButton:true animated:true];
        [UIView animateWithDuration:0.3 animations:^
        {
            _searchDimView.alpha = 1.0f;
        }];
        
        [self setNavigationBarHidden:true animated:true];
        [_collectionView setContentOffset:CGPointMake(0.0f, -_collectionView.contentInset.top) animated:true];
        _collectionView.scrollEnabled = false;
        _selectionPanelView.hidden = true;
    }
    else
    {
        [_currentSearchQueryDisposable setDisposable:nil];
        _rawSearchItemGroups = nil;
        _filteredSearchItemGroups = nil;
        [self reloadSearchData];
        _searchCollectionContainer.hidden = true;
        
        [UIView animateWithDuration:0.3 animations:^
        {
            _searchDimView.alpha = 0.0f;
        } completion:^(BOOL finished)
        {
            if (finished)
            {
                _searchDimView.hidden = true;
            }
        }];
        
        [_searchBar setShowsCancelButton:false animated:true];
        
        _collectionView.scrollEnabled = true;
        [self setNavigationBarHidden:false animated:true];
        
        [_searchBar resignFirstResponder];
        _selectionPanelView.hidden = false;
    }
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    [_searchDelayTimer invalidate];
    
    if (searchText.length == 0)
    {
        [_currentSearchQueryDisposable setDisposable:nil];
        _searchCollectionContainer.hidden = true;
        _searchDimView.alpha = 1.0f;
        _rawSearchItemGroups = nil;
        _filteredSearchItemGroups = nil;
        [self reloadSearchData];
    }
    else
    {
        __weak TGSharedMediaController *weakSelf = self;
        _searchDelayTimer = [[TGTimer alloc] initWithTimeout:0.1 repeat:false completion:^
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf beginSearch:searchText];
        } queue:dispatch_get_main_queue()];
        [_searchDelayTimer start];
    }
}

- (SSignal *)searchSignalForQuery:(NSString *)query
{
    __weak TGSharedMediaController *weakSelf = self;
    
    SSignal *remoteSignal = [SSignal complete];
    if (_peerId > INT_MIN || TGPeerIdIsChannel(_peerId))
    {
        remoteSignal = [[[TGMessageSearchSignals searchPeer:_peerId accessHash:_accessHash query:query filter:[self searchFilterForMode:_mode] maxMessageId:0 limit:128] map:^id (NSArray *messages)
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
                return [strongSelf sharedMediaItemsForMessages:messages];
            return @[];
        }] startOn:[SQueue concurrentDefaultQueue]];
    }

    NSString *normalizedQuery = [query lowercaseString];
    NSArray *groups = [_filteredItemGroups copy];
    SAtomic *localItems = [[SAtomic alloc] initWithValue:@[]];
    return [[[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        __block bool cancelled = false;
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        int index = 0;
        
        for (TGSharedMediaGroup *group in groups)
        {
            for (id item in group.items)
            {
                if ([item isKindOfClass:[TGSharedMediaFileItem class]])
                {
                    index++;
                    
                    if (index % 256 == 0)
                    {
                        if (cancelled)
                            break;
                    }
                    
                    NSString *fileName = ((TGSharedMediaFileItem *)item).documentMediaAttachment.fileName;
                    
                    if ([[fileName lowercaseString] rangeOfString:normalizedQuery].location != NSNotFound)
                        [items addObject:item];
                }
            }
        }
        
        [localItems swap:items];
        
        [subscriber putNext:items];
        [subscriber putCompletion];

        return [[SBlockDisposable alloc] initWithBlock:^
        {
            cancelled = true;
        }];
    }] then:[remoteSignal map:^id(NSArray *remoteItems)
    {
        NSMutableSet *messageIdsSet = [[NSMutableSet alloc] init];
        NSArray *localItemsResult = [localItems with:^id(id value)
        {
            return value;
        }];
        
        for (id<TGSharedMediaItem> item in localItemsResult)
        {
            [messageIdsSet addObject:@([item messageId])];
        }
        
        NSMutableArray *combinedResult = [[NSMutableArray alloc] initWithArray:localItemsResult];
        for (id<TGSharedMediaItem> item in remoteItems)
        {
            if (![messageIdsSet containsObject:@([item messageId])])
                [combinedResult addObject:item];
        }
        
        [combinedResult sortUsingComparator:^NSComparisonResult(id<TGSharedMediaItem> item1, id<TGSharedMediaItem> item2)
        {
            if (ABS([item1 date] - [item2 date]) < DBL_EPSILON)
                return [item1 messageId] > [item2 messageId] ? NSOrderedAscending : NSOrderedDescending;
            return [item1 date] > [item2 date] ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        return combinedResult;
    }]];
}

- (void)beginSearch:(NSString *)query
{
    _searchBar.delayActivity = false;
    _searchBar.showActivity = true;
    __weak TGSharedMediaController *weakSelf = self;
    [_currentSearchQueryDisposable setDisposable:[[[self searchSignalForQuery:query] onDispose:^
    {
        TGDispatchOnMainThread(^
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_searchBar.showActivity = false;
            }
        });
    }] startWithNext:^(NSArray *items)
    {
        TGDispatchOnMainThread(^
        {
            __strong TGSharedMediaController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf processSearchBarSearchResult:items];
        });
    } error:^(__unused id error)
    {
    } completed:^
    {
    }]];
}

- (void)processSearchBarSearchResult:(NSArray *)items
{
    bool append = false;
    NSMutableArray *mergedItems = [[NSMutableArray alloc] init];
    if (append)
    {
        for (TGSharedMediaGroup *group in _rawSearchItemGroups)
        {
            for (id<TGSharedMediaItem> item in group.items)
            {
                [mergedItems addObject:item];
            }
        }
        
        for (id<TGSharedMediaItem> item in items)
        {
            if (![mergedItems containsObject:item])
                [mergedItems addObject:item];
        }
    }
    else
        [mergedItems addObjectsFromArray:items];
    
    NSArray *groups = [self sharedMediaGroupsForItems:mergedItems];
    _rawSearchItemGroups = groups;
    NSMutableArray *itemsWithoutAvailabilityState = [[NSMutableArray alloc] initWithArray:items];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSMutableDictionary *mediaAvailabilityStates = [[NSMutableDictionary alloc] initWithDictionary:[self mediaAvailabilityStatesForItems:itemsWithoutAvailabilityState]];
        TGDispatchOnMainThread(^
        {
            [mediaAvailabilityStates removeObjectsForKeys:[_itemAvailabilityStates allKeys]];
            [mediaAvailabilityStates addEntriesFromDictionary:_itemAvailabilityStates];
            _itemAvailabilityStates = mediaAvailabilityStates;
            [self updateMediaAvailabilityStates:false];
        });
    });
    
    _filteredSearchItemGroups = [self filterGroups:groups usingFilters:_currentFilters];
    
    _searchDimView.alpha = 0.0f;
    
    _searchCollectionContainer.hidden = false;
    [self reloadSearchData];
}

- (void)searchBar:(TGSearchBar *)__unused searchBar willChangeHeight:(CGFloat)__unused newHeight
{
}
                  
- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"willForwardMessages"])
    {
        UIViewController *controller = [[options objectForKey:@"controller"] navigationController];
        if (controller == nil)
            return;
        
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

@end
