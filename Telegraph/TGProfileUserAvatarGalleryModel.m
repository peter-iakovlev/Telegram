#import "TGProfileUserAvatarGalleryModel.h"

#import "TGTelegraph.h"

#import "TGProfileUserAvatarGalleryItem.h"

#import "TGGenericPeerMediaGalleryDeleteAccessoryView.h"

#import "TGActionSheet.h"

@implementation TGProfileUserAvatarGalleryModel

- (instancetype)initWithCurrentAvatarLegacyThumbnailImageUri:(NSString *)currentAvatarLegacyThumbnailImageUri currentAvatarLegacyImageUri:(NSString *)currentAvatarLegacyImageUri currentAvatarImageSize:(CGSize)currentAvatarImageSize
{
    self = [super initWithPeerId:TGTelegraphInstance.clientUserId currentAvatarLegacyThumbnailImageUri:currentAvatarLegacyThumbnailImageUri currentAvatarLegacyImageUri:currentAvatarLegacyImageUri currentAvatarImageSize:currentAvatarImageSize];
    if (self != nil)
    {
        
    }
    return self;
}

- (TGUserAvatarGalleryItem *)itemForImageId:(int64_t)imageId accessHash:(int64_t)accessHash legacyThumbnailUrl:(NSString *)legacyThumbnailUrl legacyUrl:(NSString *)legacyUrl imageSize:(CGSize)imageSize isCurrent:(bool)isCurrent
{
    return [[TGProfileUserAvatarGalleryItem alloc] initWithImageId:imageId accessHash:accessHash legacyThumbnailUrl:legacyThumbnailUrl legacyUrl:legacyUrl imageSize:imageSize isCurrent:isCurrent];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultRightAccessoryView
{
    TGGenericPeerMediaGalleryDeleteAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryDeleteAccessoryView alloc] init];
    __weak TGProfileUserAvatarGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        __strong TGProfileUserAvatarGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            UIView *actionSheetView = nil;
            if (strongSelf.actionSheetView)
                actionSheetView = strongSelf.actionSheetView();
            
            if (actionSheetView != nil)
            {
                NSMutableArray *actions = [[NSMutableArray alloc] init];
                
                NSString *actionTitle = TGLocalized(@"Preview.DeletePhoto");
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:actionTitle action:@"delete" type:TGActionSheetActionTypeDestructive]];
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
                
                [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
                {
                    __strong TGProfileUserAvatarGalleryModel *strongSelf = weakSelf;
                    if ([action isEqualToString:@"delete"])
                    {
                        [strongSelf _commitDeleteItem:item];
                    }
                } target:strongSelf] showInView:actionSheetView];
            }
        }
    };
    return accessoryView;
}

- (void)_commitDeleteItem:(id<TGModernGalleryItem>)item
{
    NSUInteger index = [self.items indexOfObject:item];
    if (index != NSNotFound)
        item = self.items[index];
    
    if ([item isKindOfClass:[TGProfileUserAvatarGalleryItem class]])
    {
        TGProfileUserAvatarGalleryItem *concreteItem = (TGProfileUserAvatarGalleryItem *)item;
        
        if ([item isEqual:self.items.firstObject])
        {
            if (self.deleteCurrentAvatar)
                self.deleteCurrentAvatar();
            
            if (self.dismiss)
                self.dismiss(true, false);
        }
        else
        {
            if (concreteItem.imageId != 0 && concreteItem.accessHash != 0)
            {
                NSMutableArray *updatedItems = [[NSMutableArray alloc] initWithArray:self.items];
                [updatedItems removeObject:item];
                [self _replaceItems:updatedItems focusingOnItem:nil];
                
                [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/deleteProfilePhoto/(%lld)", concreteItem.imageId] options:@{@"imageId": @(concreteItem.imageId), @"accessHash": @(concreteItem.accessHash)} flags:0 watcher:TGTelegraphInstance];
            }
        }
    }
}

@end
