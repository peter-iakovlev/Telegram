#import "TGDownloadManager.h"

#import "ActionStage.h"

#include <set>

#import "TGMessage.h"
#import "TGDatabase.h"

@implementation TGDownloadItem

- (id)copyWithZone:(NSZone *)__unused zone
{
    TGDownloadItem *newItem = [[TGDownloadItem alloc] init];
    
    newItem.itemId = _itemId;
    newItem.messageId = _messageId;
    newItem.path = _path;
    newItem.requestDate = _requestDate;
    newItem.progress = _progress;
    
    return newItem;
}

@end

#pragma mark -

@interface TGDownloadManager ()

@property (nonatomic, strong) NSMutableDictionary *itemsQueue;

@end

@implementation TGDownloadManager

+ (TGDownloadManager *)instance
{
    static TGDownloadManager *singleton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        singleton = [[TGDownloadManager alloc] init];
    });
    
    return singleton;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:false];
        
        _itemsQueue = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_actionHandle reset];
}

- (void)requestItem:(NSString *)path options:(NSDictionary *)options changePriority:(bool)changePriority messageId:(int)messageId itemId:(id)itemId groupId:(int64_t)groupId itemClass:(TGDownloadItemClass)itemClass
{
    [self _requestOrJoinItem:path options:options changePriority:changePriority messageId:messageId itemId:itemId groupId:(int64_t)groupId itemClass:itemClass requestIfNotRunning:true];
}

- (void)enqueueItem:(NSString *)path messageId:(int)messageId itemId:(id)itemId groupId:(int64_t)groupId itemClass:(TGDownloadItemClass)itemClass
{
    [self _requestOrJoinItem:path options:nil changePriority:false messageId:messageId itemId:itemId groupId:(int64_t)groupId itemClass:itemClass requestIfNotRunning:false];
}

- (void)_requestOrJoinItem:(NSString *)path options:(NSDictionary *)options changePriority:(bool)changePriority messageId:(int)messageId itemId:(id)itemId groupId:(int64_t)groupId itemClass:(TGDownloadItemClass)__unused itemClass requestIfNotRunning:(bool)requestIfNotRunning
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        bool actorRunning = [ActionStageInstance() requestActorStateNow:path];
        if (actorRunning || requestIfNotRunning)
        {   
            if ([_itemsQueue objectForKey:path] == nil)
            {
                TGDownloadItem *item = [[TGDownloadItem alloc] init];
                item.itemId = itemId;
                item.messageId = messageId;
                item.groupId = groupId;
                item.path = path;
                item.requestDate = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
                
                [_itemsQueue setObject:item forKey:path];
                [self _notifyWatcher:nil failedItemIds:nil];
                
                [ActionStageInstance() requestActor:path options:options flags:(changePriority ? TGActorRequestChangePriority : 0) watcher:self];
            }
            else if (actorRunning && changePriority)
            {
                [ActionStageInstance() changeActorPriority:path];
            }
        }
        else
        {
            TGLog(@"***** Download Manager: being asked to join nonexistent request");
        }
    }];
}

- (void)cancelItem:(id)itemId
{
    if (itemId == nil)
        return;
    
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        NSMutableArray *removeKeys = [[NSMutableArray alloc] init];
        
        [_itemsQueue enumerateKeysAndObjectsUsingBlock:^(NSString *path, TGDownloadItem *item, __unused BOOL *stop)
        {
            if (item.itemId != nil && [item.itemId isEqual:itemId])
            {
                [removeKeys addObject:path];
                
                if ([item.itemId isKindOfClass:[TGMediaId class]])
                {
                    TGMediaId *mediaId = item.itemId;
                    if (mediaId.itemId != 0)
                    {
                        [TGDatabaseInstance() updateLastUseDateForMediaType:mediaId.type mediaId:mediaId.itemId messageId:item.messageId];
                    }
                }
            }
        }];
        
        for (NSString *path in removeKeys)
        {
            [_itemsQueue removeObjectForKey:path];
            [ActionStageInstance() removeWatcher:self fromPath:path];
        }
        
        if (removeKeys.count != 0)
            [self _notifyWatcher:nil failedItemIds:[[NSArray alloc] initWithObjects:itemId, nil]];
    }];
}

- (void)cancelItemsWithMessageIdsInArray:(NSArray *)messageIds groupId:(int64_t)groupId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (_itemsQueue.count == 0)
            return;
        
        std::set<int> messageIdsSet;
        for (NSNumber *nMessageId in messageIds)
        {
            messageIdsSet.insert([nMessageId intValue]);
        }
        
        NSMutableArray *removeKeys = [[NSMutableArray alloc] init];
        NSMutableArray *removeMediaIds = [[NSMutableArray alloc] init];
        
        [_itemsQueue enumerateKeysAndObjectsUsingBlock:^(NSString *path, TGDownloadItem *item, __unused BOOL *stop)
        {
            if (messageIdsSet.find(item.messageId) != messageIdsSet.end() && item.groupId == groupId)
            {
                if (item.itemId != nil)
                    [removeMediaIds addObject:item.itemId];
                [removeKeys addObject:path];
                
                if ([item.itemId isKindOfClass:[TGMediaId class]])
                {
                    TGMediaId *mediaId = item.itemId;
                    if (mediaId.itemId != 0)
                    {
                        [TGDatabaseInstance() updateLastUseDateForMediaType:mediaId.type mediaId:mediaId.itemId messageId:item.messageId];
                    }
                }
            }
        }];
        
        for (NSString *path in removeKeys)
        {
            [_itemsQueue removeObjectForKey:path];
            [ActionStageInstance() removeWatcher:self fromPath:path];
        }
        
        [self _notifyWatcher:nil failedItemIds:removeMediaIds];
    }];
}

- (void)cancelItemsWithGroupId:(int64_t)groupId
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        if (_itemsQueue.count == 0)
            return;
        
        NSMutableArray *removeKeys = [[NSMutableArray alloc] init];
        NSMutableArray *removeMediaIds = [[NSMutableArray alloc] init];
        
        [_itemsQueue enumerateKeysAndObjectsUsingBlock:^(NSString *path, TGDownloadItem *item, __unused BOOL *stop)
        {
            if (item.groupId == groupId)
            {
                if (item.itemId != nil)
                    [removeMediaIds addObject:item.itemId];
                [removeKeys addObject:path];
                
                if ([item.itemId isKindOfClass:[TGMediaId class]])
                {
                    TGMediaId *mediaId = item.itemId;
                    if (mediaId.itemId != 0)
                    {
                        [TGDatabaseInstance() updateLastUseDateForMediaType:mediaId.type mediaId:mediaId.itemId messageId:item.messageId];
                    }
                }
            }
        }];
        
        for (NSString *path in removeKeys)
        {
            [_itemsQueue removeObjectForKey:path];
            [ActionStageInstance() removeWatcher:self fromPath:path];
        }
        
        [self _notifyWatcher:nil failedItemIds:removeMediaIds];
    }];
}

- (void)requestState:(ASHandle *)watcherHandle
{
    [ActionStageInstance() dispatchOnStageQueue:^
    {
        [watcherHandle notifyResourceDispatched:@"downloadManagerStateChanged" resource:_itemsQueue arguments:@{@"requested": @true}];
    }];
}

#pragma mark -

- (void)_notifyWatcher:(NSArray *)completedItemIds failedItemIds:(NSArray *)failedItemIds
{
    NSDictionary *arguments = nil;
    if (completedItemIds != nil || failedItemIds != nil)
    {
        if (failedItemIds == nil)
            arguments = [[NSDictionary alloc] initWithObjectsAndKeys:completedItemIds, @"completedItemIds", nil];
        else if (completedItemIds == nil)
            arguments = [[NSDictionary alloc] initWithObjectsAndKeys:failedItemIds, @"failedItemIds", nil];
        else
            arguments = [[NSDictionary alloc] initWithObjectsAndKeys:completedItemIds, @"completedItemIds", failedItemIds, @"failedItemIds", nil];
    }
    [ActionStageInstance() dispatchResource:@"downloadManagerStateChanged" resource:_itemsQueue arguments:arguments];
}

#pragma mark -

- (void)actorMessageReceived:(NSString *)path messageType:(NSString *)messageType message:(id)message
{
    TGDownloadItem *item = [_itemsQueue objectForKey:path];
    if (item != nil)
    {
        if ([messageType isEqualToString:@"progress"])
        {
            item = [item copy];
            item.progress = [message floatValue];
            [_itemsQueue setObject:item forKey:path];
            [self _notifyWatcher:nil failedItemIds:nil];
        }
    }
}

- (void)actorReportedProgress:(NSString *)path progress:(float)progress
{
    TGDownloadItem *item = [_itemsQueue objectForKey:path];
    if (item != nil)
    {
        item = [item copy];
        item.progress = progress;
        [_itemsQueue setObject:item forKey:path];
        [self _notifyWatcher:nil failedItemIds:nil];
    }
}

- (void)actorCompleted:(int)__unused status path:(NSString *)path result:(id)__unused result
{
    TGDownloadItem *item = [_itemsQueue objectForKey:path];
    if (item != nil)
    {
        [_itemsQueue removeObjectForKey:path];
        
        [self _notifyWatcher:item.itemId != nil ? [[NSArray alloc] initWithObjects:item.itemId, nil] : nil failedItemIds:nil];
        
        if ([item.itemId isKindOfClass:[TGMediaId class]])
        {
            TGMediaId *mediaId = item.itemId;
            if (mediaId.itemId != 0)
            {
                [TGDatabaseInstance() updateLastUseDateForMediaType:mediaId.type mediaId:mediaId.itemId messageId:item.messageId];
            }
        }
    }
}

@end
