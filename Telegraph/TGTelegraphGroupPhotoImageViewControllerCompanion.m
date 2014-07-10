#import "TGTelegraphGroupPhotoImageViewControllerCompanion.h"

#import "ActionStage.h"

#import "TGAppDelegate.h"

#import "TGImageViewController.h"

@interface TGTelegraphGroupPhotoImageViewControllerCompanion ()

@property (nonatomic, strong) id<TGMediaItem> mediaItem;

@end

@implementation TGTelegraphGroupPhotoImageViewControllerCompanion

@synthesize actionHandle = _actionHandle;

@synthesize imageViewController = _imageViewController;
@synthesize reverseOrder = _reverseOrder;

@synthesize mediaItem = _mediaItem;

- (id)initWithMediaItem:(id<TGMediaItem>)mediaItem
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        _mediaItem = mediaItem;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (bool)manualSavingEnabled
{
    return true;
}

- (bool)mediaSavingEnabled
{
    return true;
}

- (bool)deletionEnabled
{
    return false;
}

- (bool)forwardingEnabled
{
    return false;
}

- (void)forceDismiss
{
    [TGAppDelegateInstance dismissContentController];
}

- (void)updateItems:(id)__unused currentItemId
{
    TGImageViewController *imageViewController = _imageViewController;
    
    [imageViewController itemsChanged:[[NSArray alloc] initWithObjects:_mediaItem, nil] totalCount:1 canLoadMore:false];
    [imageViewController applyCurrentItem:0];
}

- (void)loadMoreItems
{
}

- (void)preloadCount
{
    TGImageViewController *imageViewController = _imageViewController;
    
    [imageViewController setCustomTitle:TGLocalized(@"Preview.GroupPhotoTitle")];
}

- (void)deleteItem:(id)__unused itemId
{
}

- (void)forwardItem:(id)__unused itemId
{
}

- (bool)editingEnabled
{
    return false;
}

@end
