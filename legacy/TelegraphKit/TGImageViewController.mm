#import "TGImageViewController.h"

#import "TGImagePagingScrollView.h"

#import "TGRemoteImageView.h"

#import "TGViewController.h"
#import "TGToolbarButton.h"
#import "TGImageUtils.h"
#import "TGDateLabel.h"
#import "TGDateUtils.h"

#import "TGImageViewPage.h"

#import <QuartzCore/QuartzCore.h>

#import "TGHacks.h"

#import "TGMessage.h"

#include <set>
#include <map>

#import <objc/runtime.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import "TGImagePanGestureRecognizer.h"

#import "TGImageViewControllerInterfaceView.h"

#import "TGImageViewControllerView.h"

#import "TGAlertView.h"

#define TGDeletePhotoActionSheetTag ((int)0x4B57F962)
#define TGDeleteActionsActionSheetTag ((int)0x675697E8)

#pragma mark -

@interface TGImageViewController () <UIScrollViewDelegate, TGImagePagingScrollViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) TGCache *customCache;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *pagesScrollViewContainer;
@property (nonatomic, strong) TGImagePagingScrollView *pagesScrollView;
@property (nonatomic) bool pagesScrollViewDragging;
@property (nonatomic) bool pagesScrollViewPanning;

@property (nonatomic, strong) TGImageViewControllerInterfaceView *interfaceView;

@property (nonatomic, strong) TGImageViewPage *initialPage;

@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong) UIImage *fromImage;

@property (nonatomic, strong) id<TGMediaItem> imageItem;

@property (nonatomic, strong) UIView *appearFromView;
@property (nonatomic, strong) UIView *appearAboveView;
@property (nonatomic) CGRect appearFromRect;
@property (nonatomic) CGAffineTransform appearTransform;
@property (nonatomic, copy) dispatch_block_t appearStart;

@property (nonatomic) bool alreadyAnimatedAppearance;

@property (nonatomic, strong) UIActionSheet *currentActionSheet;
@property (nonatomic, strong) NSDictionary *currentActionSheetButtonMapping;

@property (nonatomic) float disappearSwipeVelocity;

@property (nonatomic, strong) TGAutorotationLock *autorotationLock;

@end

@implementation TGImageViewController

- (id)initWithImageItem:(id<TGMediaItem>)imageItem placeholder:(UIImage *)placeholder
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _keepAspect = true;
        
        self.wantsFullScreenLayout = true;
        
        _imageItem = imageItem;
        _placeholder = placeholder;
        
        _currentStatusBarStyle = UIStatusBarStyleLightContent;
    }
    return self;
}

- (void)dealloc
{
    for (UIGestureRecognizer *recognizer in _pagesScrollViewContainer.gestureRecognizers)
    {
        recognizer.delegate = nil;
    }
    [_pagesScrollView removeFromSuperview];
    _pagesScrollView = nil;
    _pagesScrollViewContainer = nil;
    
    _currentActionSheet.delegate = nil;
    
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)acquireRotationLock
{
    if (_autorotationLock == nil)
        _autorotationLock = [[TGAutorotationLock alloc] init];
}

- (void)releaseRotationLock
{
    _autorotationLock = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return _currentStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return false;
}

- (BOOL)shouldAutorotate
{
    if (![TGViewController autorotationAllowed])
        return false;
    
    UIViewController *presentedViewController = [self presentedViewController];
    if (presentedViewController != nil)
    {
        return [presentedViewController shouldAutorotate];
    }
    
    return [TGViewController autorotationAllowed];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (![TGViewController autorotationAllowed])
        return false;
    
    UIViewController *presentedViewController = [self presentedViewController];
    if (presentedViewController != nil)
    {
        return [presentedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
    
    return [TGViewController autorotationAllowed] && toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)loadView
{
    [super loadView];
    object_setClass(self.view, [TGImageViewControllerView class]);
    
    float pageGap = 40;
    
    self.view.opaque = false;
    
    bool editingEnabled = [_imageViewCompanion respondsToSelector:@selector(editingEnabled)] && [_imageViewCompanion editingEnabled];
    
    _interfaceView = [[TGImageViewControllerInterfaceView alloc] initWithFrame:self.view.bounds enableEditing:editingEnabled disableActions:![_imageViewCompanion mediaSavingEnabled]];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.hidden = true;
    _backgroundView.alpha = 0.0f;
    [self.view addSubview:_backgroundView];
    
    _pagesScrollViewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
    _pagesScrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_pagesScrollViewContainer];
    
    _pagesScrollView = [[TGImagePagingScrollView alloc] initWithFrame:CGRectMake(-pageGap / 2, 0, self.view.bounds.size.width + pageGap, self.view.bounds.size.height)];
    _pagesScrollView.reverseOrder = _reverseOrder;
    _pagesScrollView.saveToGallery = _saveToGallery;
    _pagesScrollView.ignoreSaveToGalleryUid = _ignoreSaveToGalleryUid;
    _pagesScrollView.groupIdForDownloadingItems = _groupIdForDownloadingItems;
    _pagesScrollView.pageGap = pageGap;
    _pagesScrollView.delegate = self;
    _pagesScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagesScrollView.directionalLockEnabled = true;
    _pagesScrollView.actionHandle = _actionHandle;
    _pagesScrollView.interfaceHandle = _interfaceView.actionHandle;
    _pagesScrollView.pagingDelegate = self;
    TGImagePanGestureRecognizer *panRecognizer = [[TGImagePanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPanned:)];
    panRecognizer.delegate = self;
    panRecognizer.cancelsTouchesInView = true;
    panRecognizer.maximumNumberOfTouches = 1;
    [_pagesScrollViewContainer addGestureRecognizer:panRecognizer];
    [_pagesScrollViewContainer addSubview:_pagesScrollView];
    
    _initialPage = [[TGImageViewPage alloc] initWithFrame:CGRectMake(_pagesScrollView.pageGap / 2, 0, _pagesScrollView.bounds.size.width - _pagesScrollView.pageGap, _pagesScrollView.bounds.size.height)];
    _initialPage.customCache = _pagesScrollView.customCache;
    _initialPage.delegate = _pagesScrollView;
    _initialPage.saveToGallery = _saveToGallery;
    _initialPage.ignoreSaveToGalleryUid = _ignoreSaveToGalleryUid;
    _initialPage.groupIdForDownloadingItems = _groupIdForDownloadingItems;
    _initialPage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _initialPage.watcherHandle = _actionHandle;
    _initialPage.itemId = _imageItem.itemId;
    [_pagesScrollView addSubview:_initialPage];
    
    if (_disableActions)
        [_interfaceView.bottomPanelView removeFromSuperview];
    if (![_imageViewCompanion deletionEnabled])
        [_interfaceView.deleteButton removeFromSuperview];
    
    _interfaceView.watcherHandle = _actionHandle;
    _interfaceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _interfaceView.reversed = _reverseOrder;
    [self.view addSubview:_interfaceView];
}

- (void)doUnloadView
{
    _customCache = nil;
    
    _imageViewCompanion.imageViewController = nil;
    _actionHandle.delegate = nil;
    _pagesScrollView.pagingDelegate = nil;
    _pagesScrollView.delegate = nil;
    
    _currentActionSheet = nil;
}

- (void)viewDidUnload
{
    [self doUnloadView];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{   
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_alreadyAnimatedAppearance)
    {
        _alreadyAnimatedAppearance = true;
        
        if (_appearFromView != nil)
        {
            _backgroundView.hidden = true;
            [self animateAppear:_appearFromView anchorForImage:_appearAboveView transform:_appearTransform fromRect:_appearFromRect fromImage:_fromImage start:_appearStart];
            
            _appearFromView = nil;
            _appearAboveView = nil;
            _appearFromRect = CGRectZero;
            _fromImage = nil;
            _appearStart = nil;
        }
    }
    
    [super viewDidAppear:animated];
}

- (void)animateAppear:(UIView *)containerForImage anchorForImage:(UIView *)anchorForImage fromRect:(CGRect)fromRect fromImage:(UIImage *)fromImage start:(dispatch_block_t)start
{
    [self animateAppear:containerForImage anchorForImage:anchorForImage transform:CGAffineTransformIdentity fromRect:fromRect fromImage:fromImage start:start];
}

- (void)animateAppear:(UIView *)containerForImage anchorForImage:(UIView *)anchorForImage transform:(CGAffineTransform)transform fromRect:(CGRect)fromRect fromImage:(UIImage *)fromImage start:(dispatch_block_t)start
{
    if (!self.isViewLoaded)
    {
        _appearFromView = containerForImage;
        _appearAboveView = anchorForImage;
        _appearFromRect = fromRect;
        _fromImage = fromImage;
        _appearStart = start;
        _appearTransform = transform;
        
        return;
    }
    
    [TGViewController disableUserInteractionFor:0.302];
    [TGViewController disableAutorotationFor:0.302];
    
    if (start)
        start();
    
    [_interfaceView setPageHandle:_initialPage.actionHandle];
    [_initialPage loadItem:_imageItem placeholder:_placeholder willAnimateAppear:true];
    
    [_interfaceView setPlayerControlsVisible:[_initialPage.imageItem type] == TGMediaItemTypeVideo paused:!_autoplay];
    
    [_initialPage animateAppearFromImage:fromImage fromView:containerForImage aboveView:anchorForImage transform:transform fromRect:fromRect toInterfaceOrientation:self.interfaceOrientation completion:^
    {
        _backgroundView.alpha = 1.0f;
        _backgroundView.hidden = false;
        
        [self hasAnimatedAppear];
    } keepAspect:_keepAspect];
    
    [_interfaceView setActive:true duration:0.23];
    
    [_imageViewCompanion preloadCount];
}

- (void)hasAnimatedAppear
{
    if (_imageViewCompanion != nil)
    {
        _pagesScrollView.scrollEnabled = false;
        
        [_imageViewCompanion updateItems:_imageItem.itemId];
    }
    else
    {
        if (_imageItem != nil)
            [_pagesScrollView setPageList:[NSArray arrayWithObject:_imageItem]];
        [_pagesScrollView setInitialPageState:_initialPage];
    }
}

- (void)animateDisappear:(UIView *)containerForImage anchorForImage:(UIView *)anchor toRect:(CGRect)rectInWindowSpace toImage:(UIImage *)toImage swipeVelocity:(float)swipeVelocity completion:(dispatch_block_t)completion
{
    [self animateDisappear:containerForImage anchorForImage:anchor transform:CGAffineTransformIdentity toRect:rectInWindowSpace toImage:toImage swipeVelocity:swipeVelocity completion:completion];
}

- (void)animateDisappear:(UIView *)containerForImage anchorForImage:(UIView *)anchor transform:(CGAffineTransform)transform toRect:(CGRect)rectInWindowSpace toImage:(UIImage *)toImage swipeVelocity:(float)__unused swipeVelocity completion:(dispatch_block_t)completion
{
    _isDisappearing = true;
    
    if (iosMajorVersion() >= 7)
    {
        _currentStatusBarStyle = UIStatusBarStyleDefault;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    [_interfaceView setActive:false duration:0.2 statusBar:false];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:true];
    
    [UIView animateWithDuration:0.2 animations:^
    {
        [TGHacks setApplicationStatusBarAlpha:1.0f];
    }];
    
    TGImageViewPage *page = [_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex];
    if (page == nil)
    {
        [UIView animateWithDuration:0.2 animations:^
        {
            _backgroundView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            if (completion)
                completion();
        }];
        
        return;
    }
    
    _backgroundView.hidden = true;
    
    [page animateDisappearToImage:nil toView:containerForImage aboveView:anchor transform:transform toRect:rectInWindowSpace toContainerImage:toImage toInterfaceOrientation:self.interfaceOrientation keepAspect:_keepAspect backgroundAlpha:_backgroundView.alpha swipeVelocity:_disappearSwipeVelocity completion:completion];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)contentControllerWillBeDismissed
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:true];
     [TGHacks setApplicationStatusBarAlpha:1.0f];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [TGViewController disableUserInteractionFor:(duration + 0.02)];
    
    [_pagesScrollView willAnimateRotation];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_pagesScrollView didAnimateRotation];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark -

- (void)setCustomTitle:(NSString *)customTitle
{
    [_interfaceView setCustomTitle:customTitle];
}

- (void)positionInformationChanged:(int)position totalCount:(int)totalCount
{
    [_interfaceView setCurrentIndex:position totalCount:totalCount loadedCount:_pagesScrollView.pageList.count author:[_imageItem author] date:_hideDates ? 0 : (int)_imageItem.date];
}

- (void)itemsChanged:(NSArray *)items totalCount:(int)totalCount tryToStayOnItemId:(bool)tryToStayOnItemId
{
    int lastIndex = _pagesScrollView.currentPageIndex;
    id lastItemId = nil;
    if (lastIndex >= 0 && lastIndex < _pagesScrollView.pageList.count)
        lastItemId = ((id<TGMediaItem>)[_pagesScrollView.pageList objectAtIndex:lastIndex]).itemId;
    
    [self itemsChanged:items totalCount:totalCount canLoadMore:_pagesScrollView.canLoadMore];
    
    if (items.count != 0)
    {
        int newIndex = MIN(lastIndex, items.count - 1);
     
        if (tryToStayOnItemId)
        {
            int index = -1;
            for (id<TGMediaItem> item in items)
            {
                index++;
                if ([item.itemId isEqual:lastItemId])
                {
                    newIndex = index;
                    break;
                }
            }
        }

        [_pagesScrollView setCurrentPageIndex:newIndex force:true];
        [_pagesScrollView resetOffsetForIndex:newIndex];
    }
}

- (void)itemsChanged:(NSArray *)items totalCount:(int)totalCount canLoadMore:(bool)canLoadMore
{
    [_pagesScrollView itemsChanged:items canLoadMore:canLoadMore];
    [_interfaceView setTotalCount:totalCount loadedCount:items.count];
    
    id<TGMediaItem> mediaItem = _pagesScrollView.currentPageIndex < _pagesScrollView.pageList.count ? _pagesScrollView.pageList[_pagesScrollView.currentPageIndex] : nil;
    if (mediaItem != nil)
    {
        [_interfaceView setCurrentIndex:_pagesScrollView.currentPageIndex totalCount:totalCount loadedCount:_pagesScrollView.pageList.count author:[mediaItem author] date:_hideDates ? 0 : (int)mediaItem.date];
    }
    
    if (items.count == 0)
        [self actionStageActionRequested:@"animateDisappear" options:nil];
}

- (void)scrollViewCurrentPageChanged:(int)currentPage imageItem:(id<TGMediaItem>)imageItem
{
    [_interfaceView setCurrentIndex:currentPage author:imageItem.author date:_hideDates ? 0 : (int)imageItem.date];
}

- (void)applyCurrentItem:(int)position
{
    _pagesScrollView.scrollEnabled = true;
    
    if (position >= 0)
    {
        _initialPage.pageIndex = position;
        [_pagesScrollView setInitialPageState:_initialPage];
        [_interfaceView setPlayerControlsVisible:[_initialPage.imageItem type] == TGMediaItemTypeVideo paused:!_autoplay];
        if (_autoplay)
        {
            TGImageViewPage *page = _initialPage;
            [page prepareToPlay];
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [page playMedia];
            });
        }
        _initialPage = nil;
    }
    else
    {
        [_initialPage removeFromSuperview];
        _initialPage = nil;
        [_pagesScrollView resetOffsetForIndex:0];
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)__unused options
{
    if ([action isEqualToString:@"animateDisappear"])
    {
        id<ASWatcher> watcher = _watcherHandle.delegate;
        if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        {
            TGImageInfo *imageInfo = nil;
            
            if (_pagesScrollView.currentPageIndex >= 0 && _pagesScrollView.currentPageIndex < _pagesScrollView.pageList.count)
            {
                id<TGMediaItem> imageItem = [_pagesScrollView.pageList objectAtIndex:_pagesScrollView.currentPageIndex];
                if (imageItem.itemId != nil)
                    _currentItemId = imageItem.itemId;
                
                imageInfo = [imageItem imageInfo];
            }
            
            NSMutableDictionary *closeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self, @"sender", [NSNumber numberWithDouble:0.2], @"duration", nil];
            if (imageInfo != nil)
                closeDict[@"imageInfo"] = imageInfo;
            
            [watcher actionStageActionRequested:@"closeImage" options:closeDict];
        }
        else
        {
            [TGHacks setApplicationStatusBarAlpha:1.0f];
            [_imageViewCompanion forceDismiss];
        }
    }
    else if ([action isEqualToString:@"activateEditing"])
    {
        if ([_imageViewCompanion respondsToSelector:@selector(activateEditing)])
            [_imageViewCompanion activateEditing];
    }
    else if ([action isEqualToString:@"hideImage"])
    {
        id<ASWatcher> watcher = _watcherHandle.delegate;
        if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        {
            [watcher actionStageActionRequested:action options:options];
        }
    }
    else if ([action isEqualToString:@"pageTapped"])
    {
        [_interfaceView toggleShowHide];
    }
    else if ([action isEqualToString:@"hideInterface"])
    {
        if ([_interfaceView controlsAlpha] > FLT_EPSILON)
            [_interfaceView setActive:false duration:0.3];
    }
    else if ([action isEqualToString:@"loadMoreItems"])
    {
        if (_imageViewCompanion != nil)
        {
            [_imageViewCompanion loadMoreItems];
        }
    }
    else if ([action isEqualToString:@"pageLongPressed"])
    {
    }
    else if ([action isEqualToString:@"deletePage"])
    {
        _currentActionSheet.delegate = nil;
        _currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        _currentActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        _currentActionSheet.tag = TGDeletePhotoActionSheetTag;
        
        NSString *deleteText = TGLocalized(@"Preview.DeletePhoto");
        if ([[_pagesScrollView pageForIndex:[_pagesScrollView currentPageIndex]].imageItem type] == TGMediaItemTypeVideo)
            deleteText = TGLocalized(@"Preview.DeleteVideo");
        
        _currentActionSheet.destructiveButtonIndex = [_currentActionSheet addButtonWithTitle:deleteText];
        _currentActionSheet.cancelButtonIndex = [_currentActionSheet addButtonWithTitle:TGLocalized(@"Common.Cancel")];
        [_currentActionSheet showInView:self.view];
    }
    else if ([action isEqualToString:@"showActions"])
    {
        for (TGImageViewPage *page in _pagesScrollView.visiblePages)
        {
            [page pauseMedia];
        }
        
        _currentActionSheet.delegate = nil;
        _currentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        _currentActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        _currentActionSheet.tag = TGDeleteActionsActionSheetTag;
        
        NSMutableDictionary *buttonMapping = [[NSMutableDictionary alloc] init];
        
        if ([_imageViewCompanion forwardingEnabled])
            [buttonMapping setObject:@"forwardViaTelegraph" forKey:[[NSNumber alloc] initWithInt:[_currentActionSheet addButtonWithTitle:TGLocalized(@"Preview.ForwardViaTelegram")]]];
        if ([_imageViewCompanion mediaSavingEnabled] && ([_imageViewCompanion manualSavingEnabled] || [[_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex].imageItem authorUid] == _ignoreSaveToGalleryUid || [[_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex].imageItem type] == TGMediaItemTypeVideo))
            [buttonMapping setObject:@"saveToCameraRoll" forKey:[[NSNumber alloc] initWithInt:[_currentActionSheet addButtonWithTitle:TGLocalized(@"Preview.SaveToCameraRoll")]]];
        _currentActionSheet.cancelButtonIndex = [_currentActionSheet addButtonWithTitle:TGLocalized(@"Common.Cancel")];
        
        if (buttonMapping.count == 0)
        {
            _currentActionSheet.delegate = nil;
            _currentActionSheet = nil;
        }
        else
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [_currentActionSheet showInView:self.view];
            else
            {
                [_currentActionSheet showFromRect:[_interfaceView.actionButton convertRect:_interfaceView.actionButton.bounds toView:self.view] inView:self.view animated:true];
            }
            _currentActionSheetButtonMapping = buttonMapping;
        }
    }
    else if ([action isEqualToString:@"controlsAlphaChanged"])
    {
        [_pagesScrollView updateControlsAlpha:[[options objectForKey:@"alpha"] floatValue]];
        
        if (_initialPage != nil)
            [_initialPage controlsAlphaUpdated:[[options objectForKey:@"alpha"] floatValue]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _currentActionSheet.delegate = nil;
    _currentActionSheet = nil;
    
    if (actionSheet.tag == TGDeletePhotoActionSheetTag)
    {
        if (buttonIndex == actionSheet.destructiveButtonIndex)
        {
            TGImageViewPage *page = [_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex];
            if (page == nil)
                return;
            
            int index = -1;
            for (id<TGMediaItem> item in _pagesScrollView.pageList)
            {
                index++;
                
                if (index == _pagesScrollView.currentPageIndex)
                {
                    if (![_imageViewCompanion respondsToSelector:@selector(shouldDeleteItemFromList:)] || [_imageViewCompanion shouldDeleteItemFromList:[item itemId]])
                    {
                        int lastIndex = _pagesScrollView.currentPageIndex;
                        NSMutableArray *newItems = [[NSMutableArray alloc] initWithArray:_pagesScrollView.pageList];
                        [newItems removeObjectAtIndex:index];
                        [self itemsChanged:newItems totalCount:MAX(0, _interfaceView.totalCount - 1) canLoadMore:_pagesScrollView.canLoadMore];
                        
                        if (newItems.count != 0)
                        {   
                            int newIndex = MIN(lastIndex, newItems.count - 1);
                            [_pagesScrollView setCurrentPageIndex:newIndex force:true];
                            [_pagesScrollView resetOffsetForIndex:newIndex];
                        }
                    }
                    
                    [_imageViewCompanion deleteItem:item.itemId];
                
                    break;
                }
            }
        }
    }
    else if (actionSheet.tag == TGDeleteActionsActionSheetTag)
    {
        NSString *action = [_currentActionSheetButtonMapping objectForKey:[[NSNumber alloc] initWithInt:buttonIndex]];
        if ([action isEqualToString:@"forwardViaTelegraph"])
        {
            TGImageViewPage *page = [_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex];
            if (page == nil)
                return;
            
            int index = -1;
            for (id<TGMediaItem> item in _pagesScrollView.pageList)
            {
                index++;
                
                if (index == _pagesScrollView.currentPageIndex)
                {
                    [_imageViewCompanion forwardItem:item.itemId];
                }
            }
            
            [_interfaceView setActive:true duration:0.3];
        }
        else if ([action isEqualToString:@"saveToCameraRoll"])
        {
            TGImageViewPage *page = [_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex];
            if (page == nil)
                return;
            
            if ([page.imageItem type] == TGMediaItemTypePhoto)
            {
                NSString *url = [page currentImageUrl];
                NSString *filePath = [[TGRemoteImageView sharedCache] pathForCachedData:url];
                
                NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
                
                if (fileData != nil)
                    [self saveToCameraRoll:fileData];
            }
            else if ([page.imageItem type] == TGMediaItemTypeVideo)
            {
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/as/media/video/(cached:%@)", [page currentVideoUrl]] options:[[NSDictionary alloc] initWithObjectsAndKeys:[page.imageItem videoAttachment], @"videoAttachment", nil] watcher:self];
            }
        }
    }
}

- (void)actorCompleted:(int)__unused status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/as/media/video/(cached"])
    {
        if (result != nil)
        {
            NSString *filePath = [result objectForKey:@"filePath"];
            if (filePath != nil)
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, nil, NULL);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Preview.VideoNotYetDownloaded") delegate:nil cancelButtonTitle:TGLocalized(@"Common.Cancel") otherButtonTitles:TGLocalized(@"Common.OK"), nil];
                [alertView show];
            });
        }
    }
}

- (void)saveToCameraRoll:(NSData *)data
{
    if (data == nil)
        return;
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    __block __strong ALAssetsLibrary *blockLibrary = assetsLibrary;
    [assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
    {
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                TGAlertView *alertView = [[TGAlertView alloc] initWithTitle:nil message:@"An error occured" delegate:nil cancelButtonTitle:TGLocalized(@"Common.Cancel") otherButtonTitles:nil];
                [alertView show];
            });
        }
        else
        {
            TGLog(@"Saved to %@", assetURL);
        }
        
        blockLibrary = nil;
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _pagesScrollView)
    {
        _pagesScrollViewDragging = true;
        
        for (TGImageViewPage *page in _pagesScrollView.visiblePages)
        {
            [page pauseMedia];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _pagesScrollView)
    {
        _pagesScrollViewDragging = false;
        
        if (!decelerate)
            [_pagesScrollView recyclePlayers];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _pagesScrollView)
    {
        [_pagesScrollView recyclePlayers];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _pagesScrollView && _pagesScrollViewDragging)
    {
        if (_interfaceView.navigationBar.alpha > FLT_EPSILON)
            [_interfaceView setActive:false duration:0.3];
    }
}

- (void)pageWillBeginDragging:(UIScrollView *)__unused scrollView
{
    if (_interfaceView.navigationBar.alpha > FLT_EPSILON)
        [_interfaceView setActive:false duration:0.3];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)__unused gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)__unused otherGestureRecognizer
{
    return false;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)__unused gestureRecognizer
{
    TGImageViewPage *currentPage = [_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex];
    
    return ![currentPage isScrubbing];
}

- (void)scrollViewPanned:(TGImagePanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        TGImageViewPage *currentPage = [_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex];
        
        if (![currentPage isZoomed])
        {
            _pagesScrollViewPanning = true;
            _pagesScrollView.clipsToBounds = false;
        }
        else
            _pagesScrollViewPanning = false;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (_pagesScrollViewPanning)
        {
            if (_interfaceView.navigationBar.alpha > FLT_EPSILON)
                [_interfaceView setActive:false duration:0.3];
            
            CGPoint translation = [recognizer translationInView:_pagesScrollView];
            if (ABS(translation.y) < 14)
                return;
            
            CGRect frame = _pagesScrollView.frame;
            frame.origin.y = translation.y - (translation.y > 0 ? 14 : -14);
            
            float alpha = MAX(0.4f, 1.0f - MIN(1.0f, ABS(translation.y) / 400.0f));
            _backgroundView.alpha = alpha;
            _pagesScrollView.frame = frame;
            
            [TGHacks setApplicationStatusBarAlpha:MAX(0.0f, MIN(1.0f, ABS(translation.y) / 200.0f))];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (_pagesScrollViewPanning)
        {
            _pagesScrollViewPanning = false;
            
            CGPoint translation = [recognizer translationInView:_pagesScrollView];
            float velocity = [recognizer velocityInView:recognizer.view].y;
            
            TGImageViewPage *currentPage = [_pagesScrollView pageForIndex:_pagesScrollView.currentPageIndex];
            
            if (recognizer.state == UIGestureRecognizerStateEnded && (ABS(translation.y) > 80 || ABS(velocity) > 800) && ABS(_pagesScrollView.contentOffset.x - currentPage.frame.origin.x + 20) < FLT_EPSILON)
            {
                _pagesScrollView.scrollEnabled = false;
                
                _disappearSwipeVelocity = [recognizer velocityInView:[recognizer view]].y;
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    CGRect frame = _pagesScrollView.frame;
                    [currentPage offsetContent:CGPointMake(0, -frame.origin.y)];
                    frame.origin.y = 0;
                    _pagesScrollView.frame = frame;
                    [_interfaceView doneButtonPressed];
                });
            }
            else
            {
                CGRect frame = _pagesScrollView.frame;
                frame.origin.y = 0;
                [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
                {
                    [TGHacks setApplicationStatusBarAlpha:0.0f];
                    _pagesScrollView.frame = frame;
                    _backgroundView.alpha = 1.0f;
                } completion:^(BOOL finished)
                {
                    if (finished)
                        _pagesScrollView.clipsToBounds = true;
                }];
            }
        }
    }
}

- (void)pageDidScroll:(UIScrollView *)__unused scrollView
{   
}

- (void)pageDidEndDragging:(UIScrollView *)__unused scrollView
{
}

- (id)actionsSender
{
    return self;
}

- (float)controlsAlpha
{
    return _interfaceView.controlsAlpha;
}

@end
