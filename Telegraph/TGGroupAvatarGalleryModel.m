#import "TGGroupAvatarGalleryModel.h"

#import "TGGroupAvatarGalleryItem.h"

#import "ActionStage.h"
#import "TGDatabase.h"

#import "TGImageMediaAttachment.h"
#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"
#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"

#import "TGActionSheet.h"
#import "TGProgressWindow.h"

#import "TGAccessChecker.h"
#import "TGMediaAssetsLibrary.h"

#import "TGMessageSearchSignals.h"

@interface TGGroupAvatarGalleryModel () {
    bool _displayCounter;
    id<SDisposable> _searchDisposable;
}

@end

@implementation TGGroupAvatarGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId accessHash:(int64_t)accessHash messageId:(int32_t)messageId legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize {
    self = [super init];
    if (self != nil)
    {
        TGGroupAvatarGalleryItem *item = [[TGGroupAvatarGalleryItem alloc] initWithMessageId:messageId legacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:imageSize];
        [self _replaceItems:@[item] focusingOnItem:item];
        
        if (peerId != 0) {
            _displayCounter = true;
            __weak TGGroupAvatarGalleryModel *weakSelf = self;
            _searchDisposable = [[[TGMessageSearchSignals searchPeer:peerId accessHash:accessHash query:@"" filter:TGMessageSearchFilterGroupPhotos maxMessageId:0/*messageId*/ limit:32 around:false/*messageId == 0 ? false : true*/] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *messages) {
                __strong TGGroupAvatarGalleryModel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    NSMutableArray *items = [[NSMutableArray alloc] init];
                    bool addedItem = false;
                    
                    for (TGMessage *message in messages) {
                        TGActionMediaAttachment *actionInfo = message.actionInfo;
                        if (actionInfo != nil && actionInfo.actionType == TGMessageActionChatEditPhoto) {
                            TGImageMediaAttachment *imageMedia = actionInfo.actionData[@"photo"];
                            if (imageMedia != nil) {
                                NSString *imageLegacyThumbnailUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
                                if (TGStringCompare(imageLegacyThumbnailUrl, legacyThumbnailUrl)) {
                                    [items addObject:item];
                                    addedItem = legacyThumbnailUrl;
                                } else {
                                    CGSize imageSize = CGSizeZero;
                                    NSString *legacyUrl = [imageMedia.imageInfo imageUrlForSizeLargerThanSize:CGSizeMake(599.0f, 599.0f) actualSize:&imageSize];
                                    
                                    TGGroupAvatarGalleryItem *photoItem = [[TGGroupAvatarGalleryItem alloc] initWithMessageId:message.mid legacyThumbnailUrl:imageLegacyThumbnailUrl legacyUrl:legacyUrl imageSize:imageSize];
                                    [items addObject:photoItem];
                                }
                            }
                        }
                    }
                    
                    if (!addedItem) {
                        [items insertObject:item atIndex:0];
                    }
                    
                    [strongSelf _replaceItems:items focusingOnItem:item];
                    
                }
            }];
        }
    }
    return self;
}

- (void)dealloc {
    [_searchDisposable dispose];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultLeftAccessoryView
{
    TGGenericPeerMediaGalleryActionsAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryActionsAccessoryView alloc] init];
    __weak TGGroupAvatarGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
        {
            __strong TGGroupAvatarGalleryModel *strongSelf = weakSelf;
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
                        __strong TGGroupAvatarGalleryModel *strongSelf = weakSelf;
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
    if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
    {
        TGGroupAvatarGalleryItem *avatarItem = (TGGroupAvatarGalleryItem *)item;
        return [[NSFileManager defaultManager] fileExistsAtPath:[avatarItem filePath]];
    }
    
    return false;
}

- (void)_commitSaveItemToCameraRoll:(id<TGModernGalleryItem>)item
{
    if ([item isKindOfClass:[TGGroupAvatarGalleryItem class]])
    {
        TGGroupAvatarGalleryItem *avatarItem = (TGGroupAvatarGalleryItem *)item;
        NSData *data = [[NSData alloc] initWithContentsOfFile:[avatarItem filePath]];
        [self _saveImageDataToCameraRoll:data];
    }
}

- (void)_saveImageDataToCameraRoll:(NSData *)data
{
    if (data == nil)
        return;
    
    if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil])
        return;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [[[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImageData:data] deliverOn:[SQueue mainQueue]] startWithNext:nil error:^(__unused id error)
    {
        [TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil];
        [progressWindow dismiss:true];
    } completed:^
    {
        [progressWindow dismissWithSuccess];
    }];
}

- (UIView<TGModernGalleryDefaultHeaderView> *)createDefaultHeaderView
{
    if (_displayCounter) {
        __weak TGGroupAvatarGalleryModel *weakSelf = self;
        return [[TGGenericPeerMediaGalleryDefaultHeaderView alloc] initWithPositionAndCountBlock:^(id<TGModernGalleryItem> item, NSUInteger *position, NSUInteger *count)
        {
            __strong TGGroupAvatarGalleryModel *strongSelf = weakSelf;
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
    } else {
        return nil;
    }
}

@end
