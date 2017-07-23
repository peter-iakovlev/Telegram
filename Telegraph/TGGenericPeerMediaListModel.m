#import "TGGenericPeerMediaListModel.h"

#import "ActionStage.h"
#import "SGraphObjectNode.h"

#import "TGStringUtils.h"

#import "ATQueue.h"

#import "TGDatabase.h"

#import "TGGenericPeerMediaListImageItem.h"
#import "TGGenericPeerMediaListVideoItem.h"

#import "TGModernGalleryController.h"
#import "TGGenericPeerMediaGalleryModel.h"
#import "TGGenericPeerGalleryItem.h"

@interface TGGenericPeerMediaListModel () <ASWatcher>
{
    ATQueue *_queue;
    
    int64_t _peerId;
    bool _allowActions;
    NSArray *_modelItems;
    
    int32_t _incompleteCount;
    bool _loadingCompleted;
    bool _loadingCompletedInternal;
}

@property (nonatomic, strong) ASHandle *actionHandle;

@end

@implementation TGGenericPeerMediaListModel

- (instancetype)initWithPeerId:(int64_t)peerId allowActions:(bool)allowActions
{
    self = [super init];
    if (self != nil)
    {
        _queue = [[ATQueue alloc] init];
        _actionHandle = [[ASHandle alloc] initWithDelegate:self];
        
        _peerId = peerId;
        _allowActions = allowActions;
        
        [self _loadInitialItems];
        
        [ActionStageInstance() watchForPaths:@[
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messages", _peerId],
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesChanged", _peerId],
            [NSString stringWithFormat:@"/tg/conversation/(%lld)/messagesDeleted", _peerId],
            @"/as/media/imageThumbnailUpdated"
        ] watcher:self];
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
    [_queue dispatch:^
    {
        NSArray *messages = [TGDatabaseInstance() loadMediaInConversation:_peerId maxMid:INT_MAX maxLocalMid:INT_MAX maxDate:INT_MAX limit:INT_MAX count:NULL important:true];
        
        _loadingCompletedInternal = true;
        
        TGDispatchOnMainThread(^
        {
            _loadingCompleted = true;
        });
        
        [self _replaceMessages:messages];
    }];
    
    [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/tg/updateMediaHistory/(%" PRIx64 ")", _peerId] options:@{@"peerId": @(_peerId)} flags:0 watcher:self];
}

- (void)_loadInitialItems
{
    int count = 0;
    NSArray *messages = [TGDatabaseInstance() loadMediaInConversation:_peerId maxMid:INT_MAX maxLocalMid:INT_MAX maxDate:INT_MAX limit:128 count:&count important:true];
    
    _incompleteCount = count;
    
    [self _replaceMessages:messages];
}

- (void)_addMessages:(NSArray *)messages
{
    NSMutableArray *updatedModelItems = [[NSMutableArray alloc] initWithArray:_modelItems];
    
    NSMutableSet *currentMessageIds = [[NSMutableSet alloc] init];
    for (id<TGGenericPeerMediaListItem> item in updatedModelItems)
    {
        [currentMessageIds addObject:@([item messageId])];
    }
    
    for (TGMessage *message in messages)
    {
        if (message.messageLifetime > 0 && message.messageLifetime <= 60) {
            continue;
        }
        
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
                
                TGGenericPeerMediaListImageItem *imageItem = [[TGGenericPeerMediaListImageItem alloc] initWithImageId:imageMedia.imageId orLocalId:localImageId peerId:_peerId messageId:message.mid date:message.date legacyImageInfo:imageMedia.imageInfo];
                [updatedModelItems addObject:imageItem];
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                TGVideoMediaAttachment *videoMedia = attachment;
                TGGenericPeerMediaListVideoItem *videoItem = [[TGGenericPeerMediaListVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid date:message.date];
                [updatedModelItems addObject:videoItem];
            }
        }
    }
    
    [updatedModelItems sortUsingComparator:^NSComparisonResult(id<TGGenericPeerMediaListItem> item1, id<TGGenericPeerMediaListItem> item2)
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
    
    [self _replaceItems:_modelItems totalCount:_modelItems.count];
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
    for (id<TGGenericPeerMediaListItem> item in _modelItems)
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
        
        [self _replaceItems:_modelItems totalCount:_modelItems.count];
    }
}

- (void)_replaceMessagesWithNewMessages:(NSDictionary *)messagesById
{
    NSMutableArray *updatedModelItems = [[NSMutableArray alloc] initWithArray:_modelItems];
    
    bool changesFound = false;
    NSInteger index = -1;
    for (id<TGGenericPeerMediaListItem> item in updatedModelItems)
    {
        index++;
        
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
                    
                    TGGenericPeerMediaListImageItem *imageItem = [[TGGenericPeerMediaListImageItem alloc] initWithImageId:imageMedia.imageId orLocalId:localImageId peerId:_peerId messageId:message.mid date:message.date legacyImageInfo:imageMedia.imageInfo];
                    
                    changesFound = true;
                    [updatedModelItems replaceObjectAtIndex:(NSUInteger)index withObject:imageItem];
                }
                else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
                {
                    TGVideoMediaAttachment *videoMedia = attachment;
                    TGGenericPeerMediaListVideoItem *videoItem = [[TGGenericPeerMediaListVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid date:message.date];
                    
                    changesFound = true;
                    [updatedModelItems replaceObjectAtIndex:(NSUInteger)index withObject:videoItem];
                }
            }
        }
    }
    
    [updatedModelItems sortUsingComparator:^NSComparisonResult(id<TGGenericPeerMediaListItem> item1, id<TGGenericPeerMediaListItem> item2)
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
    
    [self _replaceItems:_modelItems totalCount:_modelItems.count];
}

- (void)_replaceMessages:(NSArray *)messages
{
    NSMutableArray *updatedModelItems = [[NSMutableArray alloc] init];
    
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
                
                TGGenericPeerMediaListImageItem *imageItem = [[TGGenericPeerMediaListImageItem alloc] initWithImageId:imageMedia.imageId orLocalId:localImageId peerId:_peerId messageId:message.mid date:message.date legacyImageInfo:imageMedia.imageInfo];
                [updatedModelItems addObject:imageItem];
            }
            else if ([attachment isKindOfClass:[TGVideoMediaAttachment class]])
            {
                TGVideoMediaAttachment *videoMedia = attachment;
                TGGenericPeerMediaListVideoItem *videoItem = [[TGGenericPeerMediaListVideoItem alloc] initWithVideoMedia:videoMedia peerId:_peerId messageId:message.mid date:message.date];
                [updatedModelItems addObject:videoItem];
            }
        }
    }
    
    [updatedModelItems sortUsingComparator:^NSComparisonResult(id<TGGenericPeerMediaListItem> item1, id<TGGenericPeerMediaListItem> item2)
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
    
    [self _replaceItems:_modelItems totalCount:_loadingCompletedInternal ? _modelItems.count : _incompleteCount];
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
    else if ([path isEqualToString:@"/as/media/imageThumbnailUpdated"])
    {
        TGDispatchOnMainThread(^
        {
            for (id<TGGenericPeerMediaListItem> item in self.items)
            {
                if ([item hasThumbnailUri:resource])
                {
                    if (self.itemUpdated)
                        self.itemUpdated(item);
                }
            }
        });
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

- (id<TGModernMediaListItem>)_findGalleryItem:(id<TGGenericPeerGalleryItem>)galleryItem
{
    for (id<TGGenericPeerMediaListItem> item in self.items)
    {
        if ([item messageId] == [galleryItem messageId])
            return item;
    }
    
    return nil;
}

- (TGModernGalleryController *)createGalleryControllerForItem:(id<TGModernMediaListItem>)item hideItem:(void (^)(id<TGModernMediaListItem>))hideItem referenceViewForItem:(UIView *(^)(id<TGModernMediaListItem>))referenceViewForItem
{
    if ([item conformsToProtocol:@protocol(TGGenericPeerMediaListItem)])
    {
        id<TGGenericPeerMediaListItem> concreteItem = (id<TGGenericPeerMediaListItem>)item;
        
        TGModernGalleryController *modernGallery = [[TGModernGalleryController alloc] init];
        modernGallery.model = [[TGGenericPeerMediaGalleryModel alloc] initWithPeerId:_peerId atMessageId:[concreteItem messageId] allowActions:_allowActions important:true];
        
        __weak TGGenericPeerMediaListModel *weakSelf = self;
        
        modernGallery.itemFocused = ^(id<TGModernGalleryItem> item)
        {
            __strong TGGenericPeerMediaListModel *strongSelf = weakSelf;
            if (strongSelf != nil && [item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
            {
                id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                id<TGModernMediaListItem> listItem = [strongSelf _findGalleryItem:concreteItem];
                if (hideItem)
                    hideItem(listItem);
            }
        };
        
        modernGallery.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
        {
            __strong TGGenericPeerMediaListModel *strongSelf = weakSelf;
            if (strongSelf != nil && [item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
            {
                id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                id<TGModernMediaListItem> listItem = [strongSelf _findGalleryItem:concreteItem];
                if (referenceViewForItem)
                    return referenceViewForItem(listItem);
            }
            
            return nil;
        };
        
        modernGallery.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, __unused TGModernGalleryItemView *itemView)
        {
            __strong TGGenericPeerMediaListModel *strongSelf = weakSelf;
            if (strongSelf != nil && [item conformsToProtocol:@protocol(TGGenericPeerGalleryItem)])
            {
                id<TGGenericPeerGalleryItem> concreteItem = (id<TGGenericPeerGalleryItem>)item;
                id<TGModernMediaListItem> listItem = [strongSelf _findGalleryItem:concreteItem];
                if (referenceViewForItem)
                    return referenceViewForItem(listItem);
            }
            
            return nil;
        };
        
        modernGallery.completedTransitionOut = ^
        {
            __strong TGGenericPeerMediaListModel *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                if (hideItem)
                    hideItem(nil);
            }
        };
        
        return modernGallery;
    }
    
    return nil;
}

@end
