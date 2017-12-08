#import "TGGenericPeerMediaGalleryModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/ActionStage.h>
#import <LegacyComponents/SGraphObjectNode.h>

#import "ATQueue.h"

#import "TGDatabase.h"
#import "TGAppDelegate.h"
#import "TGTelegraph.h"

#import "TGGenericPeerMediaGalleryImageItem.h"
#import "TGGenericPeerMediaGalleryVideoItem.h"
#import "TGGenericPeerGalleryGroupItem.h"

#import "TGGenericPeerMediaGalleryDefaultHeaderView.h"
#import "TGGenericPeerMediaGalleryDefaultFooterView.h"
#import "TGGenericPeerMediaGalleryActionsAccessoryView.h"
#import "TGGenericPeerMediaGalleryDeleteAccessoryView.h"

#import "TGActionSheet.h"

#import "TGForwardTargetController.h"
#import <LegacyComponents/TGProgressWindow.h>

#import "TGAlertView.h"

#import "TGModernConversationController.h"

#import "TGShareMenu.h"
#import <LegacyComponents/TGMediaAssetsUtils.h>
#import <LegacyComponents/TGMenuSheetController.h>

#import "TGGenericModernConversationCompanion.h"

#import "TGLegacyComponentsContext.h"

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
    
    NSMutableDictionary *_groupedItems;
    
    TGConversation *_conversationAuthorPeer;
    
    TGGenericPeerMediaGalleryDefaultFooterView *_footerView;
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
        
        _groupedItems = [[NSMutableDictionary alloc] init];
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
        if (peerId == _peerId) {
            if (_conversationAuthorPeer == nil) {
                _conversationAuthorPeer = [TGDatabaseInstance() loadChannels:@[@(_peerId)]][@(_peerId)];
            }
            return _conversationAuthorPeer;
        } else {
            return [TGDatabaseInstance() loadChannels:@[@(peerId)]][@(peerId)];
        }
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
        
        int64_t authorPeerId = message.fromUid;
        if (_peerId == TGTelegraphInstance.clientUserId)
        {
            for (TGMediaAttachment *attachment in message.mediaAttachments)
            {
                if (attachment.type == TGForwardedMessageMediaAttachmentType)
                {
                    authorPeerId = ((TGForwardedMessageMediaAttachment *)attachment).forwardPeerId;
                    break;
                }
            }
        }
        
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            {
                TGImageMediaAttachment *imageMedia = attachment;
                
                NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                
                int64_t localImageId = 0;
                if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                    localImageId = murMurHash32(legacyCacheUrl);
                
                TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithMedia:imageMedia localId:localImageId peerId:_peerId messageId:message.mid];
                
                imageItem.authorPeer = [self authorPeerForId:authorPeerId];
                
                imageItem.date = message.date;
                imageItem.messageId = message.mid;
                imageItem.caption = imageMedia.caption;
                imageItem.groupedId = message.groupedId;
                [updatedModelItems addObject:imageItem];
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                TGVideoMediaAttachment *videoMedia = attachment;
                if (videoMedia.roundMessage)
                    continue;
                
                TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid];
                
                videoItem.authorPeer = [self authorPeerForId:authorPeerId];

                videoItem.date = message.date;
                videoItem.messageId = message.mid;
                videoItem.caption = videoMedia.caption;
                videoItem.groupedId = message.groupedId;
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
    
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
    for (id<TGGenericPeerGalleryItem> item in updatedModelItems)
    {
        if (item.groupedId != 0)
        {
            NSMutableArray *groupItems = groups[@(item.groupedId)];
            if (groupItems == nil)
            {
                groupItems = [[NSMutableArray alloc] init];
                groups[@(item.groupedId)] = groupItems;
            }
            
            [groupItems addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithGalleryItem:item]];
            item.groupItems = groupItems;
        }
    }
    
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
        
        NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *groupedItems = [[NSMutableDictionary alloc] init];
        for (id<TGGenericPeerGalleryItem> item in updatedModelItems)
        {
            if (item.groupedId != 0)
            {
                NSMutableArray *groupItems = groups[@(item.groupedId)];
                if (groupItems == nil)
                {
                    groupItems = [[NSMutableArray alloc] init];
                    groups[@(item.groupedId)] = groupItems;
                }
                
                [groupItems addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithGalleryItem:item]];
                item.groupItems = groupItems;
                
                groupedItems[@(item.messageId)] = item;
            }
        }
        
        _modelItems = updatedModelItems;
        
        TGDispatchOnMainThread(^
        {
           _groupedItems = groupedItems;
        });
        
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
            
            int64_t authorPeerId = message.fromUid;
            if (_peerId == TGTelegraphInstance.clientUserId)
            {
                for (TGMediaAttachment *attachment in message.mediaAttachments)
                {
                    if (attachment.type == TGForwardedMessageMediaAttachmentType)
                    {
                        authorPeerId = ((TGForwardedMessageMediaAttachment *)attachment).forwardPeerId;
                        break;
                    }
                }
            }
            
            for (id attachment in message.mediaAttachments)
            {
                if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
                {
                    TGImageMediaAttachment *imageMedia = attachment;
                    
                    NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                    
                    int64_t localImageId = 0;
                    if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                        localImageId = murMurHash32(legacyCacheUrl);
                    
                    TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithMedia:imageMedia localId:localImageId peerId:_peerId messageId:message.mid];
                    
                    imageItem.authorPeer = [self authorPeerForId:authorPeerId];

                    imageItem.date = message.date;
                    imageItem.messageId = message.mid;
                    imageItem.caption = imageMedia.caption;
                    imageItem.groupedId = message.groupedId;
                    changesFound = true;
                    [updatedModelItems replaceObjectAtIndex:(NSUInteger)index withObject:imageItem];
                }
                else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                {
                    TGVideoMediaAttachment *videoMedia = attachment;
                    if (videoMedia.roundMessage)
                        continue;
                    
                    TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid];
                    
                    videoItem.authorPeer = [self authorPeerForId:authorPeerId];

                    videoItem.date = message.date;
                    videoItem.messageId = message.mid;
                    videoItem.caption = videoMedia.caption;
                    videoItem.groupedId = message.groupedId;
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
    
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *groupedItems = [[NSMutableDictionary alloc] init];
    for (id<TGGenericPeerGalleryItem> item in updatedModelItems)
    {
        if (item.groupedId != 0)
        {
            NSMutableArray *groupItems = groups[@(item.groupedId)];
            if (groupItems == nil)
            {
                groupItems = [[NSMutableArray alloc] init];
                groups[@(item.groupedId)] = groupItems;
            }
            
            [groupItems addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithGalleryItem:item]];
            item.groupItems = groupItems;
            
            groupedItems[@(item.messageId)] = item;
        }
    }
    
    _modelItems = updatedModelItems;
    
    TGDispatchOnMainThread(^
    {
        _groupedItems = groupedItems;
    });
    
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
        int64_t authorPeerId = message.fromUid;
        if (_peerId == TGTelegraphInstance.clientUserId)
        {
            for (TGMediaAttachment *attachment in message.mediaAttachments)
            {
                if (attachment.type == TGForwardedMessageMediaAttachmentType)
                {
                    authorPeerId = ((TGForwardedMessageMediaAttachment *)attachment).forwardPeerId;
                    break;
                }
            }
        }
        
        for (id attachment in message.mediaAttachments)
        {
            if ([attachment isKindOfClass:[TGImageMediaAttachment class]])
            {
                TGImageMediaAttachment *imageMedia = attachment;
                
                NSString *legacyCacheUrl = [imageMedia.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:NULL pickLargest:true];
                
                int64_t localImageId = 0;
                if (imageMedia.imageId == 0 && legacyCacheUrl.length != 0)
                    localImageId = murMurHash32(legacyCacheUrl);
                
                TGGenericPeerMediaGalleryImageItem *imageItem = [[TGGenericPeerMediaGalleryImageItem alloc] initWithMedia:imageMedia localId:localImageId peerId:_peerId messageId:message.mid];
                
                imageItem.authorPeer = [self authorPeerForId:authorPeerId];
                
                imageItem.date = message.date;
                imageItem.messageId = message.mid;
                imageItem.caption = imageMedia.caption;
                imageItem.groupedId = message.groupedId;
                [updatedModelItems insertObject:imageItem atIndex:0];
                
                if (atMessageId != 0 && atMessageId == message.mid)
                    focusItem = imageItem;
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                TGVideoMediaAttachment *videoMedia = attachment;
                if (videoMedia.roundMessage)
                    continue;
                
                TGGenericPeerMediaGalleryVideoItem *videoItem = [[TGGenericPeerMediaGalleryVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid];
                
                videoItem.authorPeer = [self authorPeerForId:authorPeerId];
                
                videoItem.date = message.date;
                videoItem.messageId = message.mid;
                videoItem.caption = videoMedia.caption;
                videoItem.groupedId = message.groupedId;
                [updatedModelItems insertObject:videoItem atIndex:0];
                
                if (atMessageId != 0 && atMessageId == message.mid)
                    focusItem = videoItem;
            }
        }
    }
    
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *groupedItems = [[NSMutableDictionary alloc] init];
    for (id<TGGenericPeerGalleryItem> item in updatedModelItems)
    {
        if (item.groupedId != 0)
        {
            NSMutableArray *groupItems = groups[@(item.groupedId)];
            if (groupItems == nil)
            {
                groupItems = [[NSMutableArray alloc] init];
                groups[@(item.groupedId)] = groupItems;
            }
            
            [groupItems addObject:[[TGGenericPeerGalleryGroupItem alloc] initWithGalleryItem:item]];
            item.groupItems = groupItems;
            
            groupedItems[@(item.messageId)] = item;
        }
    }
    
    _modelItems = updatedModelItems;
    
    TGDispatchOnMainThread(^
    {
        _groupedItems = groupedItems;
    });
    
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
    _footerView = [[TGGenericPeerMediaGalleryDefaultFooterView alloc] init];
    __weak TGGenericPeerMediaGalleryModel *weakSelf = self;
    _footerView.groupItemChanged = ^(TGGenericPeerGalleryGroupItem *item, bool synchronously)
    {
        __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        id<TGGenericPeerGalleryItem> galleryItem = strongSelf->_groupedItems[@(item.keyId)];
        [strongSelf _focusOnItem:(id<TGModernGalleryItem>)galleryItem synchronously:synchronously];
    };
    return _footerView;
}

- (void)_interItemTransitionProgressChanged:(CGFloat)progress
{
    [_footerView setInterItemTransitionProgress:progress];
}

- (UIView<TGModernGalleryDefaultFooterAccessoryView> *)createDefaultLeftAccessoryView
{
    if (_disableActions) {
        return nil;
    }
    TGGenericPeerMediaGalleryActionsAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryActionsAccessoryView alloc] init];
    __weak TGGenericPeerMediaGalleryActionsAccessoryView *weakAccessoryView = accessoryView;
    __weak TGGenericPeerMediaGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
            return;
        
        __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        TGViewController *viewController = nil;
        if (strongSelf.viewControllerForModalPresentation) {
            viewController = (TGViewController *)strongSelf.viewControllerForModalPresentation();
        }
        
        CGRect (^sourceRect)(void) = ^CGRect
        {
            __strong TGGenericPeerMediaGalleryActionsAccessoryView *strongAccessoryView = weakAccessoryView;
            if (strongAccessoryView == nil)
                return CGRectZero;
            
            return strongAccessoryView.bounds;
        };
        
        __strong TGGenericPeerMediaGalleryActionsAccessoryView *strongAccessoryView = weakAccessoryView;
        id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
        void (^presentShare)(TGMenuSheetController *, NSArray *) = ^(TGMenuSheetController *existingController, NSArray *items)
        {
            bool canSaveAll = true;
            NSMutableArray *messageIds = [[NSMutableArray alloc] init];
            SSignal *externalItemSignal = nil;
            void (^saveAction)(void) = nil;
            for (id<TGGenericPeerGalleryItem> item in items)
            {
                if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                    continue;
                
                [messageIds addObject:@(item.messageId)];
                
                if (items.count == 1)
                {
                    bool isVideo = false;
                    NSURL *itemURL = [strongSelf saveItemURL:(id<TGModernGalleryItem>)item isVideo:&isVideo];
                    if (itemURL != nil)
                    {
                        externalItemSignal = (itemURL != nil) ? [SSignal single:itemURL] : nil;
                        saveAction = ^
                        {
                            if (!isVideo)
                            {
                                if ([itemURL.pathExtension isEqualToString:@"bin"] || itemURL.pathExtension.length == 0)
                                {
                                    NSData *data = [NSData dataWithContentsOfURL:itemURL options:NSDataReadingMappedIfSafe error:nil];
                                    [TGMediaAssetsSaveToCameraRoll saveImageWithData:data silentlyFail:false completionBlock:nil];
                                }
                                else
                                {
                                    [TGMediaAssetsSaveToCameraRoll saveImageAtURL:itemURL];
                                }
                            }
                            else
                            {
                                [TGMediaAssetsSaveToCameraRoll saveVideoAtURL:itemURL];
                            }
                        };
                    }
                }
            }
            
            if (items.count > 1)
            {
                saveAction = ^
                {
                    for (id<TGGenericPeerGalleryItem> item in items)
                    {
                        if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                            continue;
                        
                        bool isVideo = false;
                        NSURL *itemURL = [strongSelf saveItemURL:(id<TGModernGalleryItem>)item isVideo:&isVideo];
                        if (itemURL == nil)
                            return;
                        
                        if (!isVideo)
                        {
                            if ([itemURL.pathExtension isEqualToString:@"bin"] || itemURL.pathExtension.length == 0)
                            {
                                NSData *data = [NSData dataWithContentsOfURL:itemURL options:NSDataReadingMappedIfSafe error:nil];
                                [TGMediaAssetsSaveToCameraRoll saveImageWithData:data silentlyFail:false completionBlock:nil];
                            }
                            else
                            {
                                [TGMediaAssetsSaveToCameraRoll saveImageAtURL:itemURL];
                            }
                        }
                        else
                        {
                            [TGMediaAssetsSaveToCameraRoll saveVideoAtURL:itemURL];
                        }
                    }
                };
            }
            
            NSString *actionTitle = canSaveAll ? TGLocalized(@"Preview.SaveToCameraRoll") : nil;
            if (strongSelf->_allowActions)
            {
                [TGShareMenu presentInParentController:viewController menuController:existingController buttonTitle:actionTitle buttonAction:saveAction shareAction:^(NSArray *peerIds, NSString *caption)
                {
                    __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
                    
                    if (strongSelf != nil && strongSelf.shareAction != nil)
                        strongSelf.shareAction(messageIds, peerIds, caption);
                } externalShareItemSignal:externalItemSignal sourceView:strongAccessoryView sourceRect:sourceRect barButtonItem:nil];
            }
            else if (saveAction != nil)
            {
                TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
                controller.dismissesByOutsideTap = true;
                controller.hasSwipeGesture = true;
                controller.narrowInLandscape = true;
                controller.sourceRect = sourceRect;
                
                __weak TGMenuSheetController *weakController = controller;
                TGMenuSheetButtonItemView *saveItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:actionTitle type:TGMenuSheetButtonTypeDefault action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController == nil)
                        return;
                    
                    [strongController dismissAnimated:true manual:true];
                    saveAction();
                }];
                
                TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    if (strongController == nil)
                        return;
                    
                    [strongController dismissAnimated:true manual:true];
                }];
                
                [controller setItemViews:@[ saveItem, cancelItem ]];
                
                [controller presentInViewController:viewController sourceView:strongAccessoryView animated:true];
            }
        };
        
        if (concreteItem.groupedId == 0 || concreteItem.groupItems.count == 1)
        {
            presentShare(nil, @[item]);
        }
        else
        {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            NSInteger photosCount = 0;
            NSInteger videosCount = 0;
            for (TGGenericPeerGalleryGroupItem *groupItem in concreteItem.groupItems)
            {
                if (groupItem.isVideo)
                    videosCount++;
                else
                    photosCount++;
                
                id<TGGenericPeerGalleryItem> item = strongSelf->_groupedItems[@(groupItem.keyId)];
                if (item != nil)
                    [items addObject:item];
            }
            
            NSInteger totalCount = photosCount + videosCount;
            if (totalCount == 0)
                return;
            
            NSString *title = nil;
            if (photosCount > 0 && videosCount == 0)
            {
                NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Media.SharePhoto_" value:photosCount]);
                title = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%ld", photosCount]];
            }
            else if (videosCount > 0 && photosCount == 0)
            {
                NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Media.ShareVideo_" value:videosCount]);
                title = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%ld", videosCount]];
            }
            else
            {
                NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Media.ShareItem_" value:totalCount]);
                title = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%ld", totalCount]];
            }
            
            TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
            __weak TGMenuSheetController *weakController = controller;
            controller.dismissesByOutsideTap = true;
            controller.hasSwipeGesture = true;
            controller.narrowInLandscape = true;
            controller.sourceRect = sourceRect;
            controller.permittedArrowDirections = (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown);

            bool isVideo = [item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]];
            TGMenuSheetButtonItemView *thisItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:isVideo ? TGLocalized(@"Media.ShareThisVideo") : TGLocalized(@"Media.ShareThisPhoto") type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                presentShare(strongController, @[item]);
            }];
            
            TGMenuSheetButtonItemView *allItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                presentShare(strongController, items);
            }];
            
            TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
            {
                __strong TGMenuSheetController *strongController = weakController;
                [strongController dismissAnimated:true];
            }];
            
            [controller setItemViews:@[thisItem, allItem, cancelItem] animated:false];
            [controller presentInViewController:viewController sourceView:strongAccessoryView animated:true];
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

- (NSURL *)saveItemURL:(id<TGModernGalleryItem>)item isVideo:(bool *)isVideo
{
    if (![self _isDataAvailableForSavingItemToCameraRoll:item])
        return nil;
    
    if ([item isKindOfClass:[TGGenericPeerMediaGalleryImageItem class]])
    {
        TGGenericPeerMediaGalleryImageItem *imageItem = (TGGenericPeerMediaGalleryImageItem *)item;
        return [NSURL fileURLWithPath:[imageItem filePath]];
    }
    else if ([item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]])
    {
        if (isVideo != NULL)
            *isVideo = true;
        
        TGGenericPeerMediaGalleryVideoItem *videoItem = (TGGenericPeerMediaGalleryVideoItem *)item;
        return [NSURL fileURLWithPath:[videoItem filePath]];
    }
    
    return nil;
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
            if (message == nil) {
                message = [TGDatabaseInstance() loadMessageWithMid:[concreteItem messageId] - migratedMessageIdOffset peerId:_attachedPeerId];
            }
            if (message == nil) {
                message = [TGDatabaseInstance() loadMediaMessageWithMid:[concreteItem messageId]];
            }
            
            TGDispatchOnMainThread(^
            {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                UIViewController *viewController = nil;
                if (self.viewControllerForModalPresentation)
                    viewController = self.viewControllerForModalPresentation();
                
                if (viewController != nil && message != nil)
                {
                    TGForwardTargetController *forwardController = [[TGForwardTargetController alloc] initWithForwardMessages:[[NSArray alloc] initWithObjects:message, nil] sendMessages:nil shareLink:nil showSecretChats:true];
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
    if (_disableActions || _disableDelete) {
        return nil;
    }
    TGGenericPeerMediaGalleryDeleteAccessoryView *accessoryView = [[TGGenericPeerMediaGalleryDeleteAccessoryView alloc] init];
    __weak TGGenericPeerMediaGalleryDeleteAccessoryView *weakAccessoryView = accessoryView;
    __weak TGGenericPeerMediaGalleryModel *weakSelf = self;
    accessoryView.action = ^(id<TGModernGalleryItem> item)
    {
        __strong TGGenericPeerMediaGalleryModel *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            CGRect (^sourceRect)(void) = ^CGRect
            {
                __strong TGGenericPeerMediaGalleryDeleteAccessoryView *strongAccessoryView = weakAccessoryView;
                if (strongAccessoryView == nil)
                    return CGRectZero;
                
                return strongAccessoryView.bounds;
            };
            
            TGViewController *viewController = nil;
            if (strongSelf.viewControllerForModalPresentation) {
                viewController = (TGViewController *)strongSelf.viewControllerForModalPresentation();
            }
            
            __strong TGGenericPeerMediaGalleryDeleteAccessoryView *strongAccessoryView = weakAccessoryView;
            id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
            void (^presentDelete)(TGMenuSheetController *, NSArray *) = ^(TGMenuSheetController *existingController, NSArray *items)
            {
                bool canDeleteItems = true;
                for (id<TGModernGalleryItem> item in items)
                {
                    if (![strongSelf _canDeleteItem:item])
                    {
                        canDeleteItems = false;
                        break;
                    }
                }
                
                TGMenuSheetController *controller = existingController ?: [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
                __weak TGMenuSheetController *weakController = controller;
                controller.dismissesByOutsideTap = true;
                controller.hasSwipeGesture = true;
                controller.narrowInLandscape = true;
                controller.sourceRect = sourceRect;
                controller.permittedArrowDirections = (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown);
                
                bool canDeleteForEveryone = true;
                if (TGPeerIdIsUser(strongSelf->_peerId) || TGPeerIdIsGroup(strongSelf->_peerId)) {
                    bool isPeerAdmin = false;
                    if (TGPeerIdIsGroup(strongSelf->_peerId)) {
                        TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:strongSelf->_peerId];
                        isPeerAdmin = [conversation isAdmin];
                    }

                    for (id<TGGenericPeerGalleryItem> item in items)
                    {
                        if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                            continue;
                        
                        int32_t messageId = [item messageId];
                        TGMessage *message = [TGDatabaseInstance() loadMessageWithMid:messageId peerId:strongSelf->_peerId];
                        
                        if (message.outgoing) {
                            if (![TGGenericModernConversationCompanion canDeleteMessageForEveryone:message peerId:strongSelf->_peerId isPeerAdmin:isPeerAdmin]) {
                                canDeleteForEveryone = false;
                            }
                        } else {
                            if (!(TGPeerIdIsGroup(strongSelf->_peerId) && [TGGenericModernConversationCompanion canDeleteMessageForEveryone:message peerId:strongSelf->_peerId isPeerAdmin:isPeerAdmin])) {
                                canDeleteForEveryone = false;
                            }
                        }
                    }
                }
                
                int64_t conversationId = strongSelf->_peerId;
                NSMutableArray *itemViews = [[NSMutableArray alloc] init];
                
                NSString *basicDeleteTitle = TGLocalized(@"Common.Delete");
                if (TGPeerIdIsSecretChat(conversationId)) {
                    basicDeleteTitle = TGLocalized(@"Conversation.DeleteMessagesForEveryone");
                } else if (TGPeerIdIsChannel(conversationId)) {
                    basicDeleteTitle = TGLocalized(@"Conversation.DeleteMessagesForEveryone");
                }
                
                if (!TGPeerIdIsSecretChat(conversationId) && !TGPeerIdIsChannel(conversationId) && conversationId != TGTelegraphInstance.clientUserId && canDeleteForEveryone) {
                    NSString *title = TGLocalized(@"Conversation.DeleteMessagesForEveryone");
                    if (TGPeerIdIsUser(conversationId)) {
                        TGUser *user = [TGDatabaseInstance() loadUser:(int)conversationId];
                        if (user != nil) {
                            title = [NSString stringWithFormat:TGLocalized(@"Conversation.DeleteMessagesFor"), user.displayFirstName];
                        }
                    }
                    
                    TGMenuSheetButtonItemView *forItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDestructive action:^
                    {
                        __strong TGMenuSheetController *strongController = weakController;
                        [strongController dismissAnimated:true];
                        
                        [strongSelf _commitDeleteItems:items forEveryone:true];
                    }];
                    [itemViews addObject:forItem];
                }
                
                TGMenuSheetButtonItemView *basicItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:(TGPeerIdIsSecretChat(conversationId) || TGPeerIdIsChannel(conversationId) || conversationId == TGTelegraphInstance.clientUserId) ? basicDeleteTitle : TGLocalized(@"Conversation.DeleteMessagesForMe") type:TGMenuSheetButtonTypeDestructive action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    [strongController dismissAnimated:true];
                    
                    [strongSelf _commitDeleteItems:items forEveryone:false];
                }];
                [itemViews addObject:basicItem];
                
                TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    [strongController dismissAnimated:true];
                }];
                [itemViews addObject:cancelItem];
                
                
                [controller setItemViews:itemViews animated:existingController != nil];

                if (existingController == nil)
                    [controller presentInViewController:viewController sourceView:strongAccessoryView animated:true];
            };
            
            if (concreteItem.groupedId == 0 || concreteItem.groupItems.count == 1)
            {
                presentDelete(nil, @[item]);
            }
            else
            {
                NSMutableArray *items = [[NSMutableArray alloc] init];
                NSInteger photosCount = 0;
                NSInteger videosCount = 0;
                for (TGGenericPeerGalleryGroupItem *groupItem in concreteItem.groupItems)
                {
                    if (groupItem.isVideo)
                        videosCount++;
                    else
                        photosCount++;
                    
                    id<TGGenericPeerGalleryItem> item = strongSelf->_groupedItems[@(groupItem.keyId)];
                    if (item != nil)
                        [items addObject:item];
                }
                
                NSInteger totalCount = photosCount + videosCount;
                if (totalCount == 0)
                    return;
                
                NSString *title = nil;
                if (photosCount > 0 && videosCount == 0)
                {
                    NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Media.SharePhoto_" value:photosCount]);
                    title = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%ld", photosCount]];
                }
                else if (videosCount > 0 && photosCount == 0)
                {
                    NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Media.ShareVideo_" value:videosCount]);
                    title = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%ld", videosCount]];
                }
                else
                {
                    NSString *format = TGLocalized([TGStringUtils integerValueFormat:@"Media.ShareItem_" value:totalCount]);
                    title = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%ld", totalCount]];
                }
                
                TGMenuSheetController *controller = [[TGMenuSheetController alloc] initWithContext:[TGLegacyComponentsContext shared] dark:false];
                __weak TGMenuSheetController *weakController = controller;
                controller.dismissesByOutsideTap = true;
                controller.hasSwipeGesture = true;
                controller.narrowInLandscape = true;
                controller.sourceRect = sourceRect;
                controller.permittedArrowDirections = (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown);
                
                bool isVideo = [item isKindOfClass:[TGGenericPeerMediaGalleryVideoItem class]];
                TGMenuSheetButtonItemView *thisItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:isVideo ? TGLocalized(@"Media.ShareThisVideo") : TGLocalized(@"Media.ShareThisPhoto") type:TGMenuSheetButtonTypeDefault action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    presentDelete(strongController, @[item]);
                }];
                
                TGMenuSheetButtonItemView *allItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:title type:TGMenuSheetButtonTypeDefault action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    presentDelete(strongController, items);
                }];
                
                TGMenuSheetButtonItemView *cancelItem = [[TGMenuSheetButtonItemView alloc] initWithTitle:TGLocalized(@"Common.Cancel") type:TGMenuSheetButtonTypeCancel action:^
                {
                    __strong TGMenuSheetController *strongController = weakController;
                    [strongController dismissAnimated:true];
                }];
                
                [controller setItemViews:@[thisItem, allItem, cancelItem] animated:false];
                [controller presentInViewController:viewController sourceView:strongAccessoryView animated:true];
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

- (void)_commitDeleteItems:(NSArray *)items {
    [self _commitDeleteItems:items forEveryone:false];
}

- (void)_commitDeleteItems:(NSArray *)items forEveryone:(bool)forEveryone
{
    [_queue dispatch:^
    {
        NSMutableArray *messageIds = [[NSMutableArray alloc] init];
        for (id<TGGenericPeerGalleryItem> item in items)
        {
            if (![item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
                continue;
            
            [messageIds addObject:@(item.messageId)];
        }
        
        if (messageIds.count == 0)
            return;
        
        [self _deleteMessagesWithIds:messageIds];
        static int actionId = 1;
        [ActionStageInstance() requestActor:[NSString stringWithFormat:@"/tg/conversation/(%lld)/deleteMessages/(genericPeerMedia%d)", _peerId, actionId++] options:@{@"mids": messageIds, @"forEveryone": @(forEveryone)} watcher:TGTelegraphInstance];
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
