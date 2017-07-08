#import "TGCacheController.h"

#import "TGButtonCollectionItem.h"
#import "TGVariantCollectionItem.h"
#import "TGCommentCollectionItem.h"

#import "TGProgressWindow.h"

#import "TGRemoteImageView.h"

#import "TGActionSheet.h"

#import "TGDatabase.h"

#import "TGStringUtils.h"

#import "TGAlertView.h"

#import "TGAppDelegate.h"

#import "TGMediaCacheIndexData.h"
#import "TGPeerIdAdapter.h"

#import "TGCachePeerItem.h"

#import "TGShareSheetWindow.h"
#import "TGAttachmentSheetCheckmarkVariantItemView.h"
#import "TGShareSheetButtonItemView.h"
#import "TGHeaderCollectionItem.h"

#import "TGProgressAlert.h"

#import "TGCacheIndexingItem.h"

@interface TGEvaluatedPeerMediaCacheIndexDataWithPeer: NSObject

@property (nonatomic, strong) TGEvaluatedPeerMediaCacheIndexData *data;
@property (nonatomic, strong, readonly) id peer;

@end

@implementation TGEvaluatedPeerMediaCacheIndexDataWithPeer

- (instancetype)initWithData:(TGEvaluatedPeerMediaCacheIndexData *)data peer:(id)peer {
    self = [super init];
    if (self != nil) {
        _data = data;
        _peer = peer;
    }
    return self;
}

@end

@interface TGCacheController ()
{
    TGProgressWindow *_progressWindow;
    TGVariantCollectionItem *_cacheItem;
    
    TGVariantCollectionItem *_clearCacheItem;
    
    NSArray *_sortedEvaluatedPeersAndData;
    int64_t _totalSize;
    TGCollectionMenuSection *_evaluatedPeersSection;
    
    id<SDisposable> _diskCacheStatsDisposable;
    TGShareSheetWindow *_attachmentSheetWindow;
    TGProgressAlert *_progressAlert;
    
    SMetaDisposable *_clearDisposable;
}

@end

@implementation TGCacheController

- (NSArray *)keepMediaVariants
{
    NSArray *values = @[//@(1 * 60 * 60 * 24),
                        @(1 * 60 * 60 * 24 * 3),
                        @(1 * 60 * 60 * 24 * 7),
                        @(1 * 60 * 60 * 24 * 7 * 4),
                        @(INT_MAX)];
    
    NSMutableArray *variants = [[NSMutableArray alloc] init];
    for (NSNumber *nValue in values)
    {
        NSString *title = @"";
        
        if ([nValue intValue] == INT_MAX)
            title = TGLocalized(@"MessageTimer.Forever");
        else
            title = [TGStringUtils stringForMessageTimerSeconds:[nValue intValue]];
        
        [variants addObject:@{@"title": title, @"value": nValue}];
    }
    
    return variants;
}

- (NSString *)keepMediaVariantTitleForSeconds:(int)seconds
{
    for (NSDictionary *record in [self keepMediaVariants])
    {
        if ([record[@"value"] intValue] == seconds)
            return record[@"title"];
    }
    
    return [[NSString alloc] initWithFormat:@"%d seconds", seconds];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.title = TGLocalized(@"Cache.Title");
        
        int keepMediaSeconds = INT_MAX;
        NSNumber *nKeepMediaSeconds = [[NSUserDefaults standardUserDefaults] objectForKey:@"keepMediaSeconds"];
        if (nKeepMediaSeconds != nil)
            keepMediaSeconds = [nKeepMediaSeconds intValue];
        
        _cacheItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.KeepMedia") action:@selector(keepMediaPressed)];
        _cacheItem.variant = [self keepMediaVariantTitleForSeconds:keepMediaSeconds];
        
        _cacheItem.deselectAutomatically = true;
        
        TGCommentCollectionItem *commentItem = [[TGCommentCollectionItem alloc] initWithFormattedText:TGLocalized(@"Cache.Help")];
        
        TGCollectionMenuSection *cacheSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _cacheItem,
            commentItem,
        ]];
        
        UIEdgeInsets topSectionInsets = cacheSection.insets;
        topSectionInsets.top = 32.0f;
        cacheSection.insets = topSectionInsets;
        [self.menuSections addSection:cacheSection];

        _clearCacheItem = [[TGVariantCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.ClearCache") variant:@"" action:@selector(clearCachePressed)];
        _clearCacheItem.deselectAutomatically = true;
        TGCollectionMenuSection *clearSection = [[TGCollectionMenuSection alloc] initWithItems:@[
            _clearCacheItem
        ]];
        [self.menuSections addSection:clearSection];
        
        _evaluatedPeersSection = [[TGCollectionMenuSection alloc] initWithItems:@[]];
        [self.menuSections addSection:_evaluatedPeersSection];
        
        [self setSortedDataWithPeers:@[] totalSize:0 inProgress:true];
        
        __weak TGCacheController *weakSelf = self;
        _diskCacheStatsDisposable = [[[[TGDatabaseInstance() evaluatedDiskCacheStats] map:^id(TGEvaluatedMediaCacheIndexData *data) {
            NSMutableArray *sortedDataWithPeers = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *migratedChannelGroupEntries = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *migratedGroupMapping = [[NSMutableDictionary alloc] init];
            
            [data.dataByPeerId enumerateKeysAndObjectsUsingBlock:^(NSNumber *nPeerId, TGEvaluatedPeerMediaCacheIndexData *peerData, __unused BOOL *stop) {
                int64_t peerId = [nPeerId longLongValue];
                
                bool isMigratedChannelGroupEntry = false;
                
                id peer = nil;
                if (TGPeerIdIsChannel(peerId) || TGPeerIdIsGroup(peerId) || peerId < 0) {
                    TGConversation *conversation = [TGDatabaseInstance() loadConversationWithId:peerId];
                    if (conversation != nil) {
                        if (conversation.isEncrypted) {
                            conversation = [conversation copy];
                            int32_t userId = 0;
                            if (conversation.chatParticipants.chatParticipantUids.count != 0)
                                userId = [conversation.chatParticipants.chatParticipantUids[0] intValue];
                            TGUser *user = [TGDatabaseInstance() loadUser:userId];
                            if (user != nil) {
                                peer = conversation;
                                conversation.additionalProperties = @{@"user": user};
                            }
                        } else {
                            if (conversation.isChannelGroup) {
                                isMigratedChannelGroupEntry = true;
                                TGCachedConversationData *cachedData = [TGDatabaseInstance() _channelCachedDataSync:conversation.conversationId];
                                if (cachedData.migrationData.peerId != 0) {
                                    migratedGroupMapping[@(cachedData.migrationData.peerId)] = @(conversation.conversationId);
                                }
                            } else if (conversation.migratedToChannelId != 0) {
                                migratedGroupMapping[@(conversation.conversationId)] = @(TGPeerIdFromChannelId(conversation.migratedToChannelId));
                            }
                            peer = conversation;
                        }
                    }
                } else {
                    TGUser *user = [TGDatabaseInstance() loadUser:(int32_t)peerId];
                    if (user != nil) {
                        peer = user;
                    }
                }
                
                if (peer != nil) {
                    TGEvaluatedPeerMediaCacheIndexDataWithPeer *currentItem = [[TGEvaluatedPeerMediaCacheIndexDataWithPeer alloc] initWithData:peerData peer:peer];
                    
                    if (isMigratedChannelGroupEntry) {
                        migratedChannelGroupEntries[@(currentItem.data.peerId)] = currentItem;
                    }
                    
                    [sortedDataWithPeers addObject:currentItem];
                }
            }];
            
            NSInteger count = sortedDataWithPeers.count;
            for (NSInteger i = 0; i < count; i++) {
                TGEvaluatedPeerMediaCacheIndexDataWithPeer *item = sortedDataWithPeers[i];
                if ([item.peer isKindOfClass:[TGConversation class]] && migratedGroupMapping[@(((TGConversation *)item.peer).conversationId)] != nil) {
                    int64_t migratedId = [migratedGroupMapping[@(((TGConversation *)item.peer).conversationId)] longLongValue];
                    TGEvaluatedPeerMediaCacheIndexDataWithPeer *entry = migratedChannelGroupEntries[@(migratedId)];
                    if (entry != nil) {
                        NSMutableDictionary *mergedItemsByType = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *mergedTotalSizeByType = [[NSMutableDictionary alloc] init];
                        int64_t mergedTotalSize = 0;
                        
                        [entry.data.itemsByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSArray *items, __unused BOOL *stop) {
                            NSMutableArray *array = mergedItemsByType[nType];
                            if (array == nil) {
                                array = [[NSMutableArray alloc] init];
                                mergedItemsByType[nType] = array;
                            }
                            [array addObjectsFromArray:items];
                        }];
                        
                        [item.data.itemsByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSArray *items, __unused BOOL *stop) {
                            NSMutableArray *array = mergedItemsByType[nType];
                            if (array == nil) {
                                array = [[NSMutableArray alloc] init];
                                mergedItemsByType[nType] = array;
                            }
                            [array addObjectsFromArray:items];
                        }];
                        
                        [entry.data.totalSizeByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSNumber *nSize, __unused BOOL *stop) {
                            mergedTotalSizeByType[nType] = @([mergedTotalSizeByType[nType] longLongValue] + [nSize longLongValue]);
                        }];
                        
                        [item.data.totalSizeByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSNumber *nSize, __unused BOOL *stop) {
                            mergedTotalSizeByType[nType] = @([mergedTotalSizeByType[nType] longLongValue] + [nSize longLongValue]);
                        }];
                        
                        mergedTotalSize = entry.data.totalSize + item.data.totalSize;
                        
                        entry.data = [[TGEvaluatedPeerMediaCacheIndexData alloc] initWithPeerId:entry.data.peerId itemsByType:mergedItemsByType totalSizeByType:mergedTotalSizeByType totalSize:mergedTotalSize];
                        
                        [sortedDataWithPeers removeObjectAtIndex:i];
                        i--;
                        count--;
                    }
                }
            }
            
            [sortedDataWithPeers sortUsingComparator:^NSComparisonResult(TGEvaluatedPeerMediaCacheIndexDataWithPeer *item1, TGEvaluatedPeerMediaCacheIndexDataWithPeer *item2) {
                return item1.data.totalSize < item2.data.totalSize ? NSOrderedDescending : NSOrderedAscending;
            }];
            
            int64_t sortedDataTotalSize = 0;
            NSInteger index = -1;
            for (TGEvaluatedPeerMediaCacheIndexDataWithPeer *item in sortedDataWithPeers) {
                index++;
                if (item.data.totalSize < 100 * 1024) {
                    [sortedDataWithPeers removeObjectsInRange:NSMakeRange(index, sortedDataWithPeers.count - index)];
                    break;
                } else {
                    sortedDataTotalSize += item.data.totalSize;
                }
            }
            
            return @{@"sortedDataWithPeers": sortedDataWithPeers, @"totalSize": @(sortedDataTotalSize)};
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *dict) {
            __strong TGCacheController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf setSortedDataWithPeers:dict[@"sortedDataWithPeers"] totalSize:[dict[@"totalSize"] longLongValue] inProgress:false];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_diskCacheStatsDisposable dispose];
    [_clearDisposable dispose];
    
    [_attachmentSheetWindow dismissAnimated:false completion:nil];
}

- (void)keepMediaPressed
{
    __weak TGCacheController *weakSelf = self;
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    for (NSDictionary *record in [self keepMediaVariants])
    {
        [actions addObject:[[TGActionSheetAction alloc] initWithTitle:record[@"title"] action:[[NSString alloc] initWithFormat:@"%@", record[@"value"]]]];
    }
    [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
    
    [[[TGActionSheet alloc] initWithTitle:nil actions:actions actionBlock:^(__unused id target, NSString *action)
    {
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
           if (![action isEqualToString:@"cancel"])
           {
               [strongSelf applyKeepMediaSeconds:[action intValue]];
           }
        }
    } target:self] showInView:self.view];
}

- (void)applyKeepMediaSeconds:(int)value
{
    [[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:@"keepMediaSeconds"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_cacheItem setVariant:[self keepMediaVariantTitleForSeconds:value]];
    
    [TGDatabaseInstance() processAndScheduleMediaCleanup];
}

- (void)showClearCacheSheet:(NSDictionary *)evaluatedSizeByType clear:(void (^)(NSArray *types))clear {
    [_attachmentSheetWindow dismissAnimated:true completion:nil];
    
    __weak TGCacheController *weakSelf = self;
    _attachmentSheetWindow = [[TGShareSheetWindow alloc] init];
    _attachmentSheetWindow.dismissalBlock = ^
    {
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf->_attachmentSheetWindow.rootViewController = nil;
        strongSelf->_attachmentSheetWindow = nil;
    };
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    int32_t cacheSizeThreshold = 1;
    NSMutableSet *checkedTypes = [[NSMutableSet alloc] initWithArray:@[@(TGMediaCacheItemTypeImage), @(TGMediaCacheItemTypeVideo), @(TGMediaCacheItemTypeMusic), @(TGMediaCacheItemTypeFile)]];
    
    TGShareSheetButtonItemView *clearButtonItem = [[TGShareSheetButtonItemView alloc] initWithTitle:@"" pressed:^ {
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            strongSelf->_attachmentSheetWindow = nil;
            
            if (clear) {
                clear([checkedTypes allObjects]);
            }
        }
    }];
    
    void (^updateCheckedTypes)() = ^{
        __block int64_t totalSize = 0;
        [evaluatedSizeByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSNumber *nSize, __unused BOOL *stop) {
            if ([checkedTypes containsObject:nType]) {
                totalSize += [nSize longLongValue];
            }
        }];
        if (totalSize > 0) {
            [clearButtonItem setTitle:[[NSString alloc] initWithFormat:TGLocalized(@"Cache.Clear"), [TGStringUtils stringForFileSize:totalSize]]];
            //[clearButtonItem setDisabled:false];
        } else {
            [clearButtonItem setTitle:TGLocalized(@"Cache.ClearNone")];
            //[clearButtonItem setDisabled:true];
        }
    };
    
    updateCheckedTypes();
    
    NSArray *possibleTypes = @[@(TGMediaCacheItemTypeImage), @(TGMediaCacheItemTypeVideo), @(TGMediaCacheItemTypeMusic), @(TGMediaCacheItemTypeFile)];
    NSDictionary *typeTitles = @{@(TGMediaCacheItemTypeImage): TGLocalized(@"Cache.Photos"), @(TGMediaCacheItemTypeVideo): TGLocalized(@"Cache.Videos"), @(TGMediaCacheItemTypeMusic): TGLocalized(@"Cache.Music"), @(TGMediaCacheItemTypeFile): TGLocalized(@"Cache.Files")};
    
    for (NSNumber *nType in possibleTypes) {
        if ([evaluatedSizeByType[nType] longLongValue] >= cacheSizeThreshold) {
            TGAttachmentSheetCheckmarkVariantItemView *itemView = [[TGAttachmentSheetCheckmarkVariantItemView alloc] initWithTitle:typeTitles[nType] variant:[TGStringUtils stringForFileSize:[evaluatedSizeByType[nType] longLongValue]] checked:true];
            itemView.onCheckedChanged = ^(bool value) {
                if (value) {
                    [checkedTypes addObject:nType];
                } else {
                    [checkedTypes removeObject:nType];
                }
                updateCheckedTypes();
            };
            [items addObject:itemView];
        }
    }
    
    [items addObject:clearButtonItem];
    
    _attachmentSheetWindow.view.cancel = ^{
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_attachmentSheetWindow dismissAnimated:true completion:nil];
            strongSelf->_attachmentSheetWindow = nil;
        }
    };
    
    _attachmentSheetWindow.view.items = items;
    [_attachmentSheetWindow showAnimated:true completion:nil];
}

- (void)clearCachePressed
{
    if (true) {
        NSMutableDictionary *itemsByType = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *totalSizeByType = [[NSMutableDictionary alloc] init];
        int64_t totalSize = 0;
        
        for (TGEvaluatedPeerMediaCacheIndexDataWithPeer *peerData in _sortedEvaluatedPeersAndData) {
            [peerData.data.itemsByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSArray *items, __unused BOOL *stop) {
                NSMutableArray *array = itemsByType[nType];
                if (array == nil) {
                    array = [[NSMutableArray alloc] init];
                    itemsByType[nType] = array;
                }
                [array addObjectsFromArray:items];
            }];
            [peerData.data.totalSizeByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSNumber *nSize, __unused BOOL *stop) {
                totalSizeByType[nType] = @([totalSizeByType[nType] longLongValue] + [nSize longLongValue]);
            }];
            totalSize += peerData.data.totalSize;
        }
        
        TGEvaluatedPeerMediaCacheIndexData *data = [[TGEvaluatedPeerMediaCacheIndexData alloc] initWithPeerId:0 itemsByType:itemsByType totalSizeByType:totalSizeByType totalSize:totalSize];
        
        __weak TGCacheController *weakSelf = self;
        [self showClearCacheSheet:totalSizeByType clear:^(NSArray *types) {
            __strong TGCacheController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf clearPeerData:data types:types];
            }
        }];
        
        return;
    }
    
    [[[TGAlertView alloc] initWithTitle:nil message:TGLocalized(@"Cache.ClearCacheAlert") cancelButtonTitle:TGLocalized(@"Common.Cancel") okButtonTitle:TGLocalized(@"Common.OK") completionBlock:^(bool okButtonPressed)
    {
        if (okButtonPressed)
        {
            _progressWindow = [[TGProgressWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [_progressWindow show:true];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                [TGDatabaseInstance() clearCachedMedia];
                
                [[TGRemoteImageView sharedCache] clearCache:TGCacheDisk];
                
                NSString *documentsDirectory = [TGAppDelegate documentsPath];
                
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"files"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"audio"] error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"video"] error:nil];
                
                TGDispatchOnMainThread(^
                {
                    [_progressWindow dismissWithSuccess];
                });
            });
        }
    }] show];
}

- (void)setSortedDataWithPeers:(NSArray *)sortedDataWithPeers totalSize:(int64_t)totalSize inProgress:(bool)inProgress {
    _sortedEvaluatedPeersAndData = sortedDataWithPeers;
    _totalSize = totalSize;
    
    if (inProgress) {
        _clearCacheItem.variant = @"";
        _clearCacheItem.enabled = false;
    } else {
        if (totalSize == 0) {
            _clearCacheItem.variant = TGLocalized(@"Cache.ClearEmpty");
            _clearCacheItem.enabled = false;
        } else {
            _clearCacheItem.variant = [TGStringUtils stringForFileSize:totalSize];
            _clearCacheItem.enabled = true;
        }
    }
    
    while (_evaluatedPeersSection.items.count != 0) {
        [_evaluatedPeersSection deleteItemAtIndex:0];
    }
    
    if (inProgress || sortedDataWithPeers.count != 0) {
        [_evaluatedPeersSection addItem:[[TGHeaderCollectionItem alloc] initWithTitle:TGLocalized(@"Cache.ByPeerHeader")]];
    }
    
    __weak TGCacheController *weakSelf = self;
    void (^onSelected)(TGEvaluatedPeerMediaCacheIndexData *) = ^(TGEvaluatedPeerMediaCacheIndexData *peerData) {
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf showClearCacheSheet:peerData.totalSizeByType clear:^(NSArray *types) {
                __strong TGCacheController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf clearPeerData:peerData types:types];
                }
            }];
        }
    };
    for (TGEvaluatedPeerMediaCacheIndexDataWithPeer *item in sortedDataWithPeers) {
        TGCachePeerItem *cacheItem = [[TGCachePeerItem alloc] initWithPeer:item.peer evaluatedPeerData:item.data];
        cacheItem.onSelected = onSelected;
        [_evaluatedPeersSection addItem:cacheItem];
    }
    
    if (inProgress) {
        [_evaluatedPeersSection addItem:[[TGCacheIndexingItem alloc] init]];
    }
    
    [self.collectionView reloadData];
}

- (void)clearPeerData:(TGEvaluatedPeerMediaCacheIndexData *)peerData types:(NSArray *)types {
    __weak TGCacheController *weakSelf = self;
    
    _progressAlert = [[TGProgressAlert alloc] initWithFrame:self.view.bounds];
    _progressAlert.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _progressAlert.text = TGLocalized(@"Cache.ClearProgress");
    _progressAlert.alpha = 0.0f;
    [self.view addSubview:_progressAlert];
    [UIView animateWithDuration:0.3 animations:^
    {
        _progressAlert.alpha = 1.0f;
    }];
    
    _progressAlert.cancel = ^
    {
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_clearDisposable setDisposable:nil];
            
            [UIView animateWithDuration:0.3 animations:^
            {
                strongSelf->_progressAlert.alpha = 0.0f;
            } completion:^(__unused BOOL finished)
            {
                [strongSelf->_progressAlert removeFromSuperview];
                strongSelf->_progressAlert = nil;
            }];
        }
    };
    
    SSignal *clearSignal = [[[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        __block bool cancelled = false;
        
        [[[SQueue alloc] init] dispatch:^{
            NSMutableArray *filePaths = [[NSMutableArray alloc] init];
            [peerData.itemsByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSArray *items, BOOL *stop) {
                if ([types containsObject:nType]) {
                    for (TGEvaluatedCacheItem *item in items) {
                        [filePaths addObjectsFromArray:item.filePaths];
                    }
                }
                
                *stop = cancelled;
            }];
            
            if (!cancelled) {
                int32_t counter = 0;
                int32_t totalCount = (int32_t)filePaths.count;
                for (NSString *filePath in filePaths) {
                    if (counter++ % 20 == 0) {
                        if (cancelled) {
                            break;
                        } else {
                            [subscriber putNext:@(MIN(1.0, ((float)counter) / totalCount))];
                        }
                    }
                    
                    unlink([filePath UTF8String]);
                }
            }
            
            [subscriber putNext:@(1.0f)];
            
            [subscriber putCompletion];
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            cancelled = true;
        }];
    }] then:[[SSignal complete] delay:0.8 onQueue:[SQueue mainQueue]]];
    
    id<SDisposable> clearDisposable = [[clearSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *nProgress) {
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf->_progressAlert setProgress:[nProgress floatValue] animated:true];
        }
    } completed:^{
        __strong TGCacheController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (peerData.peerId == 0) {
                NSMutableArray *filteredDataWithPeers = [[NSMutableArray alloc] init];
                int64_t filteredTotalSize = strongSelf->_totalSize;
                for (TGEvaluatedPeerMediaCacheIndexDataWithPeer *item in strongSelf->_sortedEvaluatedPeersAndData) {
                    __block int64_t filteredItemsTotalSize = 0;
                    NSMutableDictionary *filteredItemsByType = [[NSMutableDictionary alloc] initWithDictionary:item.data.itemsByType];
                    NSMutableDictionary *filteredTotalSizeByType = [[NSMutableDictionary alloc] initWithDictionary:item.data.totalSizeByType];
                    
                    [item.data.totalSizeByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSNumber *nSize, __unused BOOL *stop) {
                        if (![types containsObject:nType]) {
                            filteredItemsTotalSize += [nSize longLongValue];
                        } else {
                            [filteredItemsByType removeObjectForKey:nType];
                            [filteredTotalSizeByType removeObjectForKey:nType];
                        }
                    }];
                    if (filteredItemsTotalSize >= 100 * 1024) {
                        filteredTotalSize = MAX(0, filteredTotalSize + filteredItemsTotalSize - item.data.totalSize);
                        [filteredDataWithPeers addObject:[[TGEvaluatedPeerMediaCacheIndexDataWithPeer alloc] initWithData:[[TGEvaluatedPeerMediaCacheIndexData alloc] initWithPeerId:item.data.peerId itemsByType:filteredItemsByType totalSizeByType:filteredTotalSizeByType totalSize:filteredItemsTotalSize] peer:item.peer]];
                    } else {
                        filteredTotalSize = MAX(0, filteredTotalSize - item.data.totalSize);
                    }
                }
                
                [strongSelf setSortedDataWithPeers:filteredDataWithPeers totalSize:filteredTotalSize inProgress:false];
            } else {
                NSMutableArray *filteredDataWithPeers = [[NSMutableArray alloc] init];
                int64_t filteredTotalSize = strongSelf->_totalSize;
                NSInteger index = -1;
                int64_t peerId = peerData.peerId;
                for (TGEvaluatedPeerMediaCacheIndexDataWithPeer *item in strongSelf->_sortedEvaluatedPeersAndData) {
                    index++;
                    if (item.data.peerId == peerId) {
                        __block int64_t filteredItemsTotalSize = 0;
                        NSMutableDictionary *filteredItemsByType = [[NSMutableDictionary alloc] initWithDictionary:item.data.itemsByType];
                        NSMutableDictionary *filteredTotalSizeByType = [[NSMutableDictionary alloc] initWithDictionary:item.data.totalSizeByType];
                        
                        [item.data.totalSizeByType enumerateKeysAndObjectsUsingBlock:^(NSNumber *nType, NSNumber *nSize, __unused BOOL *stop) {
                            if (![types containsObject:nType]) {
                                filteredItemsTotalSize += [nSize longLongValue];
                            } else {
                                [filteredItemsByType removeObjectForKey:nType];
                                [filteredTotalSizeByType removeObjectForKey:nType];
                            }
                        }];
                        filteredTotalSize = MAX(0, filteredTotalSize + filteredItemsTotalSize - item.data.totalSize);
                        if (filteredItemsTotalSize >= 100 * 1024) {
                            [filteredDataWithPeers addObject:[[TGEvaluatedPeerMediaCacheIndexDataWithPeer alloc] initWithData:[[TGEvaluatedPeerMediaCacheIndexData alloc] initWithPeerId:item.data.peerId itemsByType:filteredItemsByType totalSizeByType:filteredTotalSizeByType totalSize:filteredItemsTotalSize] peer:item.peer]];
                        }
                    } else {
                        [filteredDataWithPeers addObject:item];
                    }
                }
                
                [filteredDataWithPeers sortUsingComparator:^NSComparisonResult(TGEvaluatedPeerMediaCacheIndexDataWithPeer *item1, TGEvaluatedPeerMediaCacheIndexDataWithPeer *item2) {
                    return item1.data.totalSize < item2.data.totalSize ? NSOrderedDescending : NSOrderedAscending;
                }];
                
                [strongSelf setSortedDataWithPeers:filteredDataWithPeers totalSize:filteredTotalSize inProgress:false];
            }
            
            [UIView animateWithDuration:0.3 animations:^ {
                strongSelf->_progressAlert.alpha = 0.0f;
            } completion:^(__unused BOOL finished) {
                [strongSelf->_progressAlert removeFromSuperview];
                strongSelf->_progressAlert = nil;
            }];
        }
    }];
    
    if (_clearDisposable == nil) {
        _clearDisposable = [[SMetaDisposable alloc] init];
    }
    [_clearDisposable setDisposable:clearDisposable];
}

@end
