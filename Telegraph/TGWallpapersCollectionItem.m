#import "TGWallpapersCollectionItem.h"

#import "ActionStage.h"

#import "TGWallpapersCollectionItemView.h"
#import "TGWallpaperManager.h"

#import "TGImageUtils.h"

@interface TGWallpapersCollectionItem ()
{
    NSArray *_wallpaperItems;
    TGWallpaperInfo *_selectedWallpaperInfo;
    
    bool _requestedList;
    bool _firstBind;
    
    SEL _action;
}

@end

@implementation TGWallpapersCollectionItem

- (instancetype)initWithAction:(SEL)action title:(NSString *)title
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
        
        _title = title;
        
        _wallpaperItems = [[TGWallpaperManager instance] builtinWallpaperList];
        _selectedWallpaperInfo = [[TGWallpaperManager instance] currentWallpaperInfo];
        
        _firstBind = true;
        
        _action = action;
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (Class)itemViewClass
{
    return [TGWallpapersCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGSize screenSize = TGScreenSize();
        CGFloat widescreenWidth = MAX(screenSize.width, screenSize.height);
        
        CGSize itemSize = CGSizeZero;
        
        if ([UIScreen mainScreen].scale >= 2.0f - FLT_EPSILON)
        {
            if (widescreenWidth >= 736.0f - FLT_EPSILON)
            {
                itemSize = CGSizeMake(122.0f, 216.0f);
            }
            else if (widescreenWidth >= 667.0f - FLT_EPSILON)
            {
                itemSize = CGSizeMake(108.0f, 163.0f);
            }
            else
            {
                itemSize = CGSizeMake(91.0f, 162.0f);
            }
        }
        else
        {
            itemSize = CGSizeMake(91.0f, 162.0f);
        }
        
        return CGSizeMake(containerSize.width, itemSize.height + 59.0f);
    }
    else
    {
        if (containerSize.width > 320.0f + FLT_EPSILON)
            return CGSizeMake(containerSize.width, 207.0f);
        else
            return CGSizeMake(containerSize.width, 181.0f);
    }
}

- (void)bindView:(TGWallpapersCollectionItemView *)view
{
    [super bindView:view];
    
    view.itemHandle = _actionHandle;
    
    [((TGWallpapersCollectionItemView *)self.view) setSelectedWallpaperInfo:_selectedWallpaperInfo];
    [view setTitle:_title];
    [view setWallpaperInfos:_wallpaperItems synchronous:_firstBind];
    _firstBind = false;
    
    if (!_requestedList)
    {
        _requestedList = true;
        
        [ActionStageInstance() watchForPaths:@[
            //@"/tg/assets/wallpaperList",
            @"/tg/assets/currentWallpaperInfo"
        ] watcher:self];
        //[ActionStageInstance() requestActor:@"/tg/assets/wallpaperList/(cached)" options:nil flags:0 watcher:self];
    }
}

- (void)unbindView
{
    ((TGWallpapersCollectionItemView *)self.view).itemHandle = nil;
    
    [super unbindView];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [((TGWallpapersCollectionItemView *)self.view) setTitle:_title];
}

- (void)setCurrentWallpaperInfo:(TGWallpaperInfo *)currentWallpaperInfo
{
    _selectedWallpaperInfo = currentWallpaperInfo;
    [((TGWallpapersCollectionItemView *)self.view) setSelectedWallpaperInfo:_selectedWallpaperInfo];
}

- (void)itemSelected:(id)actionTarget
{
    if (_action != NULL && [actionTarget respondsToSelector:_action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [actionTarget performSelector:_action];
#pragma clang diagnostic pop
    }
}

#pragma mark -

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/assets/wallpaperList"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
    else if ([path hasPrefix:@"/tg/assets/currentWallpaperInfo"])
    {
        TGDispatchOnMainThread(^
        {
            [self setCurrentWallpaperInfo:resource];
        });
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)__unused result
{
    if ([path hasPrefix:@"/tg/assets/wallpaperList"])
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (status == ASStatusSuccess)
            {
            }
        });
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"wallpaperImagePressed"])
    {
        [_interfaceHandle requestAction:action options:options];
    }
}

@end
