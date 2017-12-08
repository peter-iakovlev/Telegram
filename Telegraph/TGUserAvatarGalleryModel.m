#import "TGUserAvatarGalleryModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGUserAvatarGalleryItem.h"

#import <LegacyComponents/ActionStage.h>
#import "TGDatabase.h"

#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"
#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"
#import "TGGenericPeerMediaGalleryDefaultFooterView.h"

#import "TGGenericPeerGalleryGroupItem.h"

#import "TGActionSheet.h"
#import <LegacyComponents/TGProgressWindow.h>

#import <LegacyComponents/TGMediaAssetsLibrary.h>

@interface TGUserAvatarGalleryModel () <ASWatcher>
{
    int64_t _peerId;
    
    TGGenericPeerMediaGalleryDefaultFooterView *_footerView;
    NSMutableDictionary *_groupedItems;
    NSArray *_groupItems;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGUserAvatarGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId currentAvatarLegacyThumbnailImageUri:(NSString *)currentAvatarLegacyThumbnailImageUri currentAvatarLegacyImageUri:(NSString *)currentAvatarLegacyImageUri currentAvatarImageSize:(CGSize)currentAvatarImageSize
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _peerId = peerId;
        
        _groupedItems = [[NSMutableDictionary alloc] init];
        
        TGUserAvatarGalleryItem *firstItem = [self itemForImageId:0 accessHash:0 legacyThumbnailUrl:currentAvatarLegacyThumbnailImageUri legacyUrl:currentAvatarLegacyImageUri imageSize:currentAvatarImageSize isCurrent:true];
        [self _replaceItems:@[firstItem] focusingOnItem:firstItem];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (void)_transitionCompleted
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [ActionStageInstance() watchForPath:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%" PRId64 ")", _peerId] watcher:self];
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/profilePhotos/(%" PRId64 ",cached)", _peerId] options:@{@"peerId": @(_peerId)} flags:0 watcher:self];
    }];
}

- (TGUserAvatarGalleryItem *)itemForImageId:(int64_t)imageId accessHash:(int64_t)__unused accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent
{
    TGUserAvatarGalleryItem *item = [[TGUserAvatarGalleryItem alloc] initWithLegacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageId:imageId imageSize:imageSize isCurrent:isCurrent];
    return item;
}

- (UIView<TGModernGalleryDefaultHeaderView> *)createDefaultHeaderView
{
    __weak TGUserAvatarGalleryModel *weakSelf = self;
    return [[TGGenericPeerMediaGalleryDefaultHeaderView alloc] initWithPositionAndCountBlock:^(id<TGModernGalleryItem> item, NSUInteger *position, NSUInteger *count)
    {
        __strong TGUserAvatarGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (position != NULL)
            {
                NSUInteger index = [strongSelf.items indexOfObject:item];
                if (index != NSNotFound)
                    *position = index;
            }
            if (count != NULL)
                *count = strongSelf.items.count;
        }
    }];
}

- (UIView<TGModernGalleryDefaultFooterView> *)createDefaultFooterView
{
    _footerView = [[TGGenericPeerMediaGalleryDefaultFooterView alloc] init];
    __weak TGUserAvatarGalleryModel *weakSelf = self;
    _footerView.groupItemChanged = ^(TGGenericPeerGalleryGroupItem *item, bool synchronously)
    {
        __strong TGUserAvatarGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        id<TGModernGalleryItem> galleryItem = strongSelf->_groupedItems[@(item.keyId)];
        [strongSelf _focusOnItem:(id<TGModernGalleryItem>)galleryItem synchronously:synchronously];
    };
    return _footerView;
}

- (void)_replaceItemsFromImageMediaList:(NSArray *)imageMediaList focusOnFirst:(bool)focusOnFirst
{
    NSArray *sortedResult = [(NSArray *)imageMediaList sortedArrayUsingComparator:^NSComparisonResult(TGImageMediaAttachment *imageMedia1, TGImageMediaAttachment *imageMedia2)
    {
        if (imageMedia1.date > imageMedia2.date)
            return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    
    NSMutableArray *updatedItems = [[NSMutableArray alloc] init];
    NSInteger index = -1;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (TGImageMediaAttachment *imageMedia in sortedResult)
    {
        index++;
        
        NSString *legacyThumbnailUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(160.0f, 160.0f) resultingSize:NULL];
        NSString *legacyUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(640.0f, 640.0f) resultingSize:NULL];
        bool isCurrent = false;
        
        if (index == 0)
            isCurrent = true;
        
        TGUserAvatarGalleryItem *item = [self itemForImageId:imageMedia.imageId accessHash:imageMedia.accessHash legacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:CGSizeMake(640.0f, 640.0f) isCurrent:isCurrent];
        [updatedItems addObject:item];
     
        [items addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithImageAttachment:imageMedia]];
        _groupedItems[@(imageMedia.imageId)] = item;
    }
    
    _groupItems = items;
    if (items.count > 1)
        [_footerView setGroupItems:items];
    
    [self _replaceItems:updatedItems focusingOnItem:focusOnFirst ? updatedItems.firstObject : nil];
}

- (void)_commitDeletedGroupItem:(TGUserAvatarGalleryItem *)item
{
    NSMutableArray *updatedGroupItems = [_groupItems mutableCopy];
    for (TGGenericPeerGalleryGroupItem *groupItem in updatedGroupItems)
    {
        if (groupItem.keyId == item.imageId)
        {
            [updatedGroupItems removeObject:groupItem];
            break;
        }
    }
    
    _groupItems = updatedGroupItems;
    [_footerView setGroupItems:updatedGroupItems];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path hasPrefix:@"/tg/profilePhotos/"])
    {
        [self actorCompleted:ASStatusSuccess path:path result:resource];
    }
}

- (void)actorCompleted:(int)status path:(NSString *)path result:(id)result
{
    if ([path hasPrefix:@"/tg/profilePhotos/"])
    {
        TGDispatchOnMainThread(^
        {
            if (status == ASStatusSuccess && ((NSArray *)result).count != 0)
            {   
                [self _replaceItemsFromImageMediaList:result focusOnFirst:false];
            }
        });
    }
}

- (void)_interItemTransitionProgressChanged:(CGFloat)progress
{
    [_footerView setInterItemTransitionProgress:progress];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultLeftAccessoryView
{
    TGGenericPeerMediaGalleryActionsAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryActionsAccessoryView alloc] init];
    __weak TGUserAvatarGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
        {
            __strong TGUserAvatarGalleryModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                UIView *actionSheetView = nil;
                if (strongSelf.actionSheetView)
                    actionSheetView = strongSelf.actionSheetView();
                
                if (actionSheetView != nil)
                {
                    NSMutableArray *actions = [[NSMutableArray alloc] init];
                    
                    if ([strongSelf _isDataAvailableForSavingItemToCameraRoll:item])
                    {
                        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Preview.SaveToCameraRoll") action:@"save" type:TGActionSheetActionTypeGeneric]];
                    }
                    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
                    
                    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
                    {
                        __strong TGUserAvatarGalleryModel *strongSelf = weakSelf;
                        if ([action isEqualToString:@"save"])
                            [strongSelf _commitSaveItemToCameraRoll:item];
                    } target:strongSelf] showInView:actionSheetView];
                }
            }
        }
    };
    return accessoryView;
}

- (bool)_isDataAvailableForSavingItemToCameraRoll:(id<TGModernGalleryItem>)item
{
    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
    {
        TGUserAvatarGalleryItem *avatarItem = (TGUserAvatarGalleryItem *)item;
        return [[NSFileManager defaultManager] fileExistsAtPath:[avatarItem filePath]];
    }
    
    return false;
}

- (void)_commitSaveItemToCameraRoll:(id<TGModernGalleryItem>)item
{
    if ([item isKindOfClass:[TGUserAvatarGalleryItem class]])
    {
        TGUserAvatarGalleryItem *avatarItem = (TGUserAvatarGalleryItem *)item;
        NSData *data = [[NSData alloc] initWithContentsOfFile:[avatarItem filePath]];
        [self _saveImageDataToCameraRoll:data];
    }
}

- (void)_saveImageDataToCameraRoll:(NSData *)data
{
    if (data == nil)
        return;

    if (![[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil])
        return;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [[[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImageData:data] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error)
    {
        [[[LegacyComponentsGlobals provider] accessChecker] checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil];
        [progressWindow dismiss:true];
    } completed:^
    {
        [progressWindow dismissWithSuccess];
    }];
}

@end
