#import "TGGenericPeerMediaGalleryModel.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "ATQueue.h"

#import "TGDatabase.h"
#import "TGAppDelegate.h"
#import "TGTelegraph.h"
#import "TGPeerIdAdapter.h"

#import "TGGenericPeerMediaGalleryImageItem.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"

#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"
#import "TGGenericPeerMediaGalleryDefaultFooterView.h"
#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"
#import "TGGenericPeerMediaGalleryDeleteAccessoryView.h"

#import "TGStringUtils.h"
#import "TGActionSheet.h"

#import "ActionStage.h"

#import "TGAccessChecker.h"
#import "TGMediaPickerAssetsLibrary.h"

#import "TGForwardTargetController.h"
#import "TGProgressWindow.h"

#import "TGAlertView.h"

@interface TGGenericPeerMediaGalleryModel () <ASWatcher>
{
    ATQueue *_queue;
    
    NSArray *_modelItems;
    int32_t _atMessageId;
    bool _allowActions;
    
    NSUInteger _incompleteCount;
    bool _loadingCompleted;
    bool _loadingCompletedInternal;
    
    bool _externalMode;
    bool _important;
    
    TGConversation *_conversationAuthorPeer;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGGenericPeerMediaGalleryModel

- (instancetype)initWithPeerId:(int64_t)peerId atMessageId:(int32_t)atMessageId allowActions:(bool)allowActions important:(bool)important
{
    self = [super init];
    if (self != nil)
    {
        _externalMode = false;
        _important = important;

        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _queue = [[ATQueue alloc] init];
        
        _peerId = peerId;
        
        _atMessageId = atMessageId;
        _allowActions = allowActions;
        [self _loadInitialItemsAtMessageId:_atMessageId];
            
        [ActionStageInstance() watchForPaths:@[
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", _peerId],
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId],
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId]
        ] watcher:self];
    }
    return self;
}

- (instancetype)initWithPeerId:(int64_t)peerId allowActions:(bool)allowActions messages:(NSArray *)messages atMessageId:(int32_t)atMessageId
{
    self = [super init];
    if (self != nil)
    {
        _externalMode = true;
        
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _queue = [[ATQueue alloc] init];
        
        _peerId = peerId;
        
        _allowActions = allowActions;
        
        _atMessageId = atMessageId;
        
        _loadingCompleted = true;
        [self _replaceMessages:messages atMessageId:_atMessageId];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
    [ActionStageInstance() removeWatcher:self];
}

- (id)authorPeerForId:(int64_t)peerId {
    if (TGPeerIdIsChannel(peerId)) {
        if (_conversationAuthorPeer == nil) {
            _conversationAuthorPeer = [TGDatabaseInstance() loadChannels:@[@(_peerId)]][@(_peerId)];
        }
        return _conversationAuthorPeer;
    } else {
        return [TGDatabaseInstance() loadUser:(int32_t)peerId];
    }
}

- (void)_transitionCompleted
{
    [super _transitionCompleted];
    
    if (_externalMode)
    {
    }
    else
    {
        [_queue dispatch:^
        {
            NSArray *messages = [[TGDatabaseInstance() loadMediaInConversation:_peerId maxMid:INT_MAX maxLocalMid:INT_MAX maxDate:INT_MAX limit:INT_MAX count:NULL important:_important] sortedArrayUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
            {
                NSTimeInterval date1 = message1.date;
                NSTimeInterval date2 = message2.date;
                
                if (ABS(date1 - date2) < DBL_EPSILON)
                {
                    if (message1.mid > message2.mid)
                        return NSOrderedAscending;
                    else
                        return NSOrderedDescending;
                }
                
                return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            _loadingCompletedInternal = true;
            
            TGDispatchOnMainThread(^
            {
                _loadingCompleted = true;
            });
            
            [self _replaceMessages:messages atMessageId:_atMessageId];
        }];
    
        [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/updateMediaHistory/(%" PRIx64 ")", _peerId] options:@{@"peerId": @(_peerId)} flags:0 watcher:self];
    }
}

- (void)_loadInitialItemsAtMessageId:(int32_t)atMessageId
{
    int count = 0;
    NSArray *messages = [[TGDatabaseInstance() loadMediaInConversation:_peerId atMessageId:atMessageId limitAfter:32 count:&count important:_important] sortedArrayUsingComparator:^NSComparisonResult(TGMessage *message1, TGMessage *message2)
    {
        NSTimeInterval date1 = message1.date;
        NSTimeInterval date2 = message2.date;
        
        if (ABS(date1 - date2) < DBL_EPSILON)
        {
            if (message1.mid > message2.mid)
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }
        
        return date1 > date2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    _incompleteCount = count;
    
    [self _replaceMessages:messages atMessageId:atMessageId];
}

- (void)_addMessages:(NSArray *)messages
{
    NSMutableArray *updatedModelItems = [[NSMutableArray alloc] initWithArray:_modelItems];
    
    NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
    for (id<TGGenericPeerGalleryItem> item in updatedModelItems)
    {
        [currentMessageIds addObject:@([item messageId])];
    }
    
    for (TGMessage *message in messages)
    {
        if ([currentMessageIds containsObject:@(message.mid)])
            continue;
        
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            {
                TGImageMediaAttachment *imageMedia = attachment;
                
                NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                
                int64_t localImageId = 0;
                if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                    localImageId = murMurHash32(legacyCacheUrl);
                
                TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithImageId:imageMedia.imageId orLocalId:localImageId peerId:_peerId messageId:message.mid legacyImageInfo:imageMedia.imageInfo];
                
                imageItem.authorPeer = [self authorPeerForId:message.fromUid];
                
                imageItem.date = message.date;
                imageItem.messageId = message.mid;
                imageItem.caption = imageMedia.caption;
                [updatedModelItems addObject:imageItem];
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                TGVideoMediaAttachment *videoMedia = attachment;
                TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid];
                
                videoItem.authorPeer = [self authorPeerForId:message.fromUid];

                videoItem.date = message.date;
                videoItem.messageId = message.mid;
                videoItem.caption = videoMedia.caption;
                [updatedModelItems addObject:videoItem];
            }
        }
    }
    
    [updatedModelItems sortUsingComparator:^NSComparisonResult(id<TGGenericPeerGalleryItem> item1, id<TGGenericPeerGalleryItem> item2)
    {
        NSTimeInterval date1 = [item1 date];
        NSTimeInterval date2 = [item2 date];
        
        if (ABS(date1 - date2) < DBL_EPSILON)
        {
            if ([item1 messageId] < [item2 messageId])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }
        
        return date1 < date2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    _modelItems = updatedModelItems;
    
    [self _replaceItems:_modelItems focusingOnItem:nil];
}

- (void)_deleteMessagesWithIds:(NSArray *)messageIds
{
    NSMutableSet *messageIdsSet = [[NSMutableSet alloc] init];
    for (NSNumber *nMid in messageIds)
    {
        [messageIdsSet addObject:nMid];
    }
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    NSInteger index = -1;
    for (id<TGGenericPeerGalleryItem> item in _modelItems)
    {
        index++;
        if ([messageIdsSet containsObject:@([item messageId])])
        {
            [indexSet addIndex:(NSUInteger)index];
        }
    }
    
    if (indexSet.count != 0)
    {
        NSMutableArray *updatedModelItems = [[NSMutableArray alloc] initWithArray:_modelItems];
        [updatedModelItems removeObjectsAtIndexes:indexSet];
        _modelItems = updatedModelItems;
        
        [self _replaceItems:_modelItems focusingOnItem:nil];
    }
    
    if (_modelItems.count == 0)
    {
        TGDispatchOnMainThread(^
        {
            UIViewController *viewController = nil;
            if (self.viewControllerForModalPresentation)
                viewController = self.viewControllerForModalPresentation();
            
            if (viewController != nil)
            {
                if (self.dismiss)
                    self.dismiss(false, false);
            }
        });
    }
}

- (void)_replaceMessagesWithNewMessages:(NSDictionary *)messagesById
{
    NSMutableArray *updatedModelItems = [[NSMutableArray alloc] initWithArray:_modelItems];
    
    bool changesFound = false;
    for (NSInteger index = 0; index < (NSInteger)updatedModelItems.count; index++)
    {
        id<TGGenericPeerGalleryItem> item = updatedModelItems[index];
        
        if (messagesById[@([item messageId])] != nil)
        {
            TGMessage *message = messagesById[@([item messageId])];
            
            for (id attachment in message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                {
                    TGImageMediaAttachment *imageMedia = attachment;
                    
                    NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                    
                    int64_t localImageId = 0;
                    if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                        localImageId = murMurHash32(legacyCacheUrl);
                    
                    TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithImageId:imageMedia.imageId orLocalId:localImageId peerId:_peerId messageId:message.mid legacyImageInfo:imageMedia.imageInfo];
                    
                    imageItem.authorPeer = [self authorPeerForId:message.fromUid];

                    imageItem.date = message.date;
                    imageItem.messageId = message.mid;
                    imageItem.caption = imageMedia.caption;
                    changesFound = true;
                    [updatedModelItems replaceObjectAtIndex:(NSUInteger)index withObject:imageItem];
                }
                else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                {
                    TGVideoMediaAttachment *videoMedia = attachment;
                    TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid];
                    
                    videoItem.authorPeer = [self authorPeerForId:message.fromUid];

                    videoItem.date = message.date;
                    videoItem.messageId = message.mid;
                    videoItem.caption = videoMedia.caption;
                    changesFound = true;
                    [updatedModelItems replaceObjectAtIndex:(NSUInteger)index withObject:videoItem];
                }
            }
        }
    }
    
    [updatedModelItems sortUsingComparator:^NSComparisonResult(id<TGGenericPeerGalleryItem> item1, id<TGGenericPeerGalleryItem> item2)
     {
         NSTimeInterval date1 = [item1 date];
         NSTimeInterval date2 = [item2 date];
         
         if (ABS(date1 - date2) < DBL_EPSILON)
         {
             if ([item1 messageId] < [item2 messageId])
                 return NSOrderedAscending;
             else
                 return NSOrderedDescending;
         }
         
         return date1 < date2 ? NSOrderedAscending : NSOrderedDescending;
     }];
    
    _modelItems = updatedModelItems;
    
    [self _replaceItems:_modelItems focusingOnItem:nil];
}

- (void)replaceMessages:(NSArray *)messages
{
    [self _replaceMessages:messages atMessageId:0];
}

- (void)_replaceMessages:(NSArray *)messages atMessageId:(int32_t)atMessageId
{
    NSMutableArray *updatedModelItems = [[NSMutableArray alloc] init];
    
    id<TGModernGalleryItem> focusItem = nil;
    
    for (TGMessage *message in messages)
    {
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            {
                TGImageMediaAttachment *imageMedia = attachment;
                
                NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                
                int64_t localImageId = 0;
                if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                    localImageId = murMurHash32(legacyCacheUrl);
                
                TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithImageId:imageMedia.imageId orLocalId:localImageId peerId:_peerId messageId:message.mid legacyImageInfo:imageMedia.imageInfo];
                
                imageItem.authorPeer = [self authorPeerForId:message.fromUid];
                
                imageItem.date = message.date;
                imageItem.messageId = message.mid;
                imageItem.caption = imageMedia.caption;
                [updatedModelItems insertObject:imageItem atIndex:0];
                
                if (atMessageId != 0 && atMessageId == message.mid)
                    focusItem = imageItem;
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                TGVideoMediaAttachment *videoMedia = attachment;
                TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid];
                
                videoItem.authorPeer = [self authorPeerForId:message.fromUid];
                
                videoItem.date = message.date;
                videoItem.messageId = message.mid;
                videoItem.caption = videoMedia.caption;
                [updatedModelItems insertObject:videoItem atIndex:0];
                
                if (atMessageId != 0 && atMessageId == message.mid)
                    focusItem = videoItem;
            }
        }
    }
    
    _modelItems = updatedModelItems;
    
    [self _replaceItems:_modelItems focusingOnItem:focusItem];
}

- (UIView<TGModernGalleryDefaultHeaderView> *)createDefaultHeaderView
{
    __weak TGGenericPeerMediaGalleryModel *weakSelf = self;
    return [[TGGenericPeerMediaGalleryDefaultHeaderView alloc] initWithPositionAndCountBlock:^(id<TGModernGalleryItem> item, NSUInteger *position, NSUInteger *count)
    {
        __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if (position != NULL)
            {
                NSUInteger index = [strongSelf.items indexOfObject:item];
                if (index != NSNotFound)
                {
                    *position = strongSelf->_loadingCompleted ? index : (strongSelf->_incompleteCount - strongSelf.items.count + index);
                }
            }
            if (count != NULL)
                *count = strongSelf->_loadingCompleted ? strongSelf.items.count : strongSelf->_incompleteCount;
        }
    }];
}

- (UIView<TGModernGalleryDefaultFooterView> *)createDefaultFooterView
{
    return [[TGGenericPeerMediaGalleryDefaultFooterView alloc] init];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultLeftAccessoryView
{
    TGGenericPeerMediaGalleryActionsAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryActionsAccessoryView alloc] init];
    __weak TGGenericPeerMediaGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
        {
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
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
                        if (([concreteItem isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]]) || [concreteItem isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
                        {
                            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Preview.SaveToCameraRoll") action:@"save" type:TGActionSheetActionTypeGeneric]];
                        }
                    }
                    
                    if (_allowActions)
                    {
                        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Preview.ForwardViaTelegram") action:@"forward" type:TGActionSheetActionTypeGeneric]];
                    }
                    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
                    
                    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
                    {
                        __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
                        if ([action isEqualToString:@"save"])
                            [strongSelf _commitSaveItemToCameraRoll:item];
                        else if ([action isEqualToString:@"forward"])
                            [strongSelf _commitForwardItem:item];
                    } target:strongSelf] showInView:actionSheetView];
                }
            }
        }
    };
    return accessoryView;
}

- (bool)_isDataAvailableForSavingItemToCameraRoll:(id<TGModernGalleryItem>)item
{
    if ([item isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]])
    {
        TGGenericPeerMediaGalleryImageItem *imageItem = (TGGenericPeerMediaGalleryImageItem *)item;
        return [[NSFileManager defaultManager] fileExistsAtPath:[imageItem filePath]];
    }
    else if ([item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
    {
        TGGenericPeerMediaGalleryVideoItem *videoItem = (TGGenericPeerMediaGalleryVideoItem *)item;
        return [[NSFileManager defaultManager] fileExistsAtPath:[videoItem filePath]];
    }
    
    return false;
}

- (void)_commitSaveItemToCameraRoll:(id<TGModernGalleryItem>)item
{
    if ([item isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]])
    {
        TGGenericPeerMediaGalleryImageItem *imageItem = (TGGenericPeerMediaGalleryImageItem *)item;
        NSData *data = [[NSData alloc] initWithContentsOfFile:[imageItem filePath]];
        [self _saveImageDataToCameraRoll:data];
    }
    else if ([item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
    {
        TGGenericPeerMediaGalleryVideoItem *videoItem = (TGGenericPeerMediaGalleryVideoItem *)item;
        [self _saveVideoToCameraRoll:[videoItem filePath]];
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

    [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithImageData:data completionBlock:^(bool success, __unused NSString *uniqueId, __unused NSError *error)
    {
        TGDispatchOnMainThread(^
        {
            if (!success)
            {
                [TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil];
                [progressWindow dismiss:true];
            }
            else
            {
                [progressWindow dismissWithSuccess];
            }
        });
    }];
}

- (void)_saveVideoToCameraRoll:(NSString *)filePath
{
    if (filePath == nil)
        return;
    
    if (![TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil])
        return;
    
    TGProgressWindow *progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [progressWindow show:true];
    
    [[TGMediaPickerAssetsLibrary sharedLibrary] saveAssetWithVideoAtURL:[NSURL fileURLWithPath:filePath] completionBlock:^(bool success, __unused NSString *uniqueId, __unused NSError *error)
    {
        TGDispatchOnMainThread(^
        {
            if (!success)
            {
                [TGAccessChecker checkPhotoAuthorizationStatusForIntent:TGPhotoAccessIntentSave alertDismissCompletion:nil];
                [progressWindow dismiss:true];
            }
            else
            {
                [progressWindow dismissWithSuccess];
            }
        });
    }];
}

- (void)_commitForwardItem:(id<TGModernGalleryItem>)item
{
    if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
    {
        id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
        
        TGDispatchOnMainThread(^
        {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        });
        
        [ActionStageInstance() dispatchOnStageQueue:^
        {
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[concreteItem messageId] peerId:_peerId];
            if (message == nil)
                message = [TGDatabaseInstance() loadMediaMessageWithMid:[concreteItem messageId]];
            
            TGDispatchOnMainThread(^
            {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                UIViewController *viewController = nil;
                if (self.viewControllerForModalPresentation)
                    viewController = self.viewControllerForModalPresentation();
                
                if (viewController != nil && message != nil)
                {
                    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:[[NSArray alloc] initWithObjects:message, nil] sendMessages:nil showSecretChats:true];
                    forwardController.skipConfirmation = true;
                    forwardController.watcherHandle = _actionHandle;
                    TGNavigationController *navigationController = [TGNavigationController navigationControllerWithRootController:forwardController];
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                    {
                        navigationController.presentationStyle = TGNavigationControllerPresentationStyleInFormSheet;
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    
                    [viewController presentViewController:navigationController animated:true completion:nil];
                }
            });
        }];
    }
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultRightAccessoryView
{
    TGGenericPeerMediaGalleryDeleteAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryDeleteAccessoryView alloc] init];
    __weak TGGenericPeerMediaGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([strongSelf _canDeleteItem:item]) {
                UIView *actionSheetView = nil;
                if (strongSelf.actionSheetView)
                    actionSheetView = strongSelf.actionSheetView();
                
                if (actionSheetView != nil)
                {
                    NSMutableArray *actions = [[NSMutableArray alloc] init];
                    
                    NSString *actionTitle = nil;
                    if ([item isKindOfClass:[TGModernGalleryImageItem class]])
                        actionTitle = TGLocalized(@"Preview.DeletePhoto");
                    else
                        actionTitle = TGLocalized(@"Preview.DeleteVideo");
                    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:actionTitle action:@"delete" type:TGActionSheetActionTypeDestructive]];
                    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
                    
                    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
                    {
                        __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
                        if ([action isEqualToString:@"delete"])
                        {
                            [strongSelf _commitDeleteItem:item];
                        }
                    } target:strongSelf] showInView:actionSheetView];
                }
            }
        }
    };
    return accessoryView;
}

- (bool)_canDeleteItem:(id<TGModernGalleryItem>)item {
    if (TGPeerIdIsChannel(_peerId)) {
        if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
        {
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:[concreteItem messageId] peerId:_peerId];
            if (message.outgoing) {
                return true;
            } else {
                TGConversation *conversation = [TGDatabaseInstance() loadChannels:@[@(_peerId)]][@(_peerId)];
                if (conversation != nil) {
                    if (conversation.channelRole == TGChannelRoleCreator || conversation.channelRole == TGChannelRolePublisher || conversation.channelRole == TGChannelRoleModerator) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        }
    }
    return true;
}

- (void)_commitDeleteItem:(id<TGModernGalleryItem>)item
{
    [_queue dispatch:^
    {
        if ([item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
        {
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            
            NSArray *messageIds = @[@([concreteItem messageId])];
            [self _deleteMessagesWithIds:messageIds];
            static int actionId = 1;
            [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(genericPeerMedia%d)", _peerId, actionId++] options:@{@"mids": messageIds} watcher:TGTelegraphInstance];
        }
    }];
}

- (void)actionStageResourceDispatched:(NSString *)path resource:(id)resource arguments:(id)__unused arguments
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messages", _peerId]])
    {
        [_queue dispatch:^
        {
            if (!_loadingCompletedInternal)
                return;
            
            NSArray *messages = [((SGraphObjectNode *)resource).object mutableCopy];
            [self _addMessages:messages];
        }];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId]])
    {
        [_queue dispatch:^
        {
            NSArray *midMessagePairs = ((SGraphObjectNode *)resource).object;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (NSUInteger i = 0; i < midMessagePairs.count; i += 2)
            {
                dict[midMessagePairs[0]] = midMessagePairs[1];
            }
            
            [self _replaceMessagesWithNewMessages:dict];
        }];
    }
    else if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId]])
    {
        [_queue dispatch:^
        {
            [self _deleteMessagesWithIds:((SGraphObjectNode *)resource).object];
        }];
    }
}

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    if ([path isEqualToString:[[NSString alloc] initWithFormat:@"/tg/updateMediaHistory/(%" PRIx64 ")", _peerId]])
    {
        if ([messageType isEqualToString:@"messagesLoaded"])
        {
            [_queue dispatch:^
            {
                [self _addMessages:message];
            }];
        }
    }
}

- (void)actionStageActionRequested:(NSString *)action options:(NSDictionary *)options
{
    if ([action isEqualToString:@"willForwardMessages"])
    {
        UIViewController *controller = [[options objectForKey:@"controller"] navigationController];
        if (controller == nil)
            return;
        
        UIViewController *viewController = nil;
        if (self.viewControllerForModalPresentation)
            viewController = self.viewControllerForModalPresentation();
        
        if (viewController != nil)
        {   
            if (self.dismiss)
                self.dismiss(true, true);
        }
    }
}

@end
