#import "TGStickersSignals.h"

#import "TGTelegramNetworking.h"
#import "TL/TLMetaScheme.h"

#import "TGStickerAssociation.h"

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TGAppDelegate.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGRemoteFileSignal.h"

#import "TGImageInfo+Telegraph.h"
#import "TGTelegraph.h"

#import <libkern/OSAtomic.h>

static bool alreadyReloadedStickerPacksFromRemote = false;

static NSDictionary *cachedPacks = nil;
static OSSpinLock cachedPacksLock = 0;

@implementation TGStickersSignals

+ (int32_t)hashForStickerPacks:(NSArray *)stickerPacks {
    uint32_t acc = 0;
    
    for (TGStickerPack *pack in stickerPacks) {
        if (!pack.hidden) {
            acc = (acc * 20261) + pack.packHash;
        }
    }
    return acc % 0x7FFFFFFF;
}

+ (SSignal *)updateStickerPacks
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
    {
        SSignal *signal = [SSignal complete];
        
        int cacheInvalidationTimeout = 60 * 60;
/*#if TARGET_IPHONE_SIMULATOR
        cacheInvalidationTimeout = 10;
#endif*/
        
        NSDictionary *cachedPacks = [self cachedStickerPacks];
        int currentTime = (int)[[NSDate date] timeIntervalSince1970];
        if (cachedPacks == nil || currentTime > [cachedPacks[@"cacheUpdateDate"] intValue] + cacheInvalidationTimeout || !alreadyReloadedStickerPacksFromRemote)
        {
            signal = [self remoteStickerPacksWithCacheHash:[self hashForStickerPacks:cachedPacks[@"packs"]]];
        }
        else
        {
            int delay = cacheInvalidationTimeout - (currentTime - [cachedPacks[@"cacheUpdateDate"] intValue]);
            signal = [[self remoteStickerPacksWithCacheHash:[self hashForStickerPacks:cachedPacks[@"packs"]]] delay:delay onQueue:[SQueue concurrentDefaultQueue]];
        }
        alreadyReloadedStickerPacksFromRemote = true;
        
        SSignal *periodicFetchSignal = [[[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
        {
            NSDictionary *cachedPacks = [self cachedStickerPacks];
            return [self remoteStickerPacksWithCacheHash:[self hashForStickerPacks:cachedPacks[@"packs"]]];
        }] catch:^SSignal *(__unused id error) {
            return [SSignal complete];
        }];
        
        signal = [signal then:[[periodicFetchSignal delay:cacheInvalidationTimeout onQueue:[SQueue concurrentDefaultQueue]] restart]];
        
        return signal;
    }];
}

+ (void)updateShowStickerButtonModeForStickerPacks:(NSArray *)stickerPacks
{
    for (TGStickerPack *stickerPack in stickerPacks)
    {
        bool isExternalPack = true;
        if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
            isExternalPack = false;
        
        if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
        {
            TGStickerPackIdReference *reference = (TGStickerPackIdReference *)stickerPack.packReference;
            if (reference.shortName.length == 0)
                isExternalPack = false;
        }
        
        if (isExternalPack)
        {
            if (TGAppDelegateInstance.alwaysShowStickersMode == 0)
            {
                TGAppDelegateInstance.alwaysShowStickersMode = 2;
                [TGAppDelegateInstance saveSettings];
            }
            
            break;
        }
    }
}

+ (bool)isStickerPackInstalled:(id<TGStickerPackReference>)packReference
{
    NSString *packShortname = [self stickerPackShortName:packReference];
    
    for (TGStickerPack *pack in [self cachedStickerPacks][@"packs"])
    {
        if ([pack.packReference isEqual:packReference]) {
            return true;
        }
        
        if (packShortname.length != 0 && TGStringCompare(packShortname, [self stickerPackShortName:pack.packReference])) {
            return true;
        }
    }
    return false;
}

+ (NSString *)stickerPackShortName:(id<TGStickerPackReference>)packReference {
    if ([packReference isKindOfClass:[TGStickerPackShortnameReference class]]) {
        return ((TGStickerPackShortnameReference *)packReference).shortName;
    } else {
        for (TGStickerPack *pack in [self cachedStickerPacks][@"packs"])
        {
            if ([pack.packReference isEqual:packReference]) {
                if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                    return ((TGStickerPackIdReference *)pack.packReference).shortName;
                }
            }
        }
    }
    
    return nil;
}

+ (NSMutableDictionary *)useCountFromOrderedReferences:(NSArray *)orderedReferences
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    int distance = 1;
    int useCount = distance;
    
    for (id<TGStickerPackReference> reference in orderedReferences.reverseObjectEnumerator)
    {
        if ([reference isKindOfClass:[TGStickerPackIdReference class]])
        {
            result[@(((TGStickerPackIdReference *)reference).packId)] = @(useCount);
            useCount += distance;
        }
    }
    
    return result;
}

+ (void)forceUpdateStickers {
    [[[TGTelegramNetworking instance] genericTasksSignalManager] startStandaloneSignalIfNotRunningForKey:@"forceUpdateStickers" producer:^SSignal *{
        return [[self remoteStickerPacksWithCacheHash:0] onNext:^(NSDictionary *dict) {
            [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:dict toMulticastedPipeForKey:@"stickerPacks"];
        }];
    }];
}

+ (void)dispatchStickers {
    [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:[self cachedStickerPacks] toMulticastedPipeForKey:@"stickerPacks"];
}

+ (SSignal *)stickerPacks
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id defer)
    {
        [[[TGTelegramNetworking instance] genericTasksSignalManager] startStandaloneSignalIfNotRunningForKey:@"updateStickers" producer:^SSignal *
        {
            return [[self updateStickerPacks] onNext:^(NSDictionary *dict)
            {
                [self updateShowStickerButtonModeForStickerPacks:dict[@"packs"]];
                
                [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:dict toMulticastedPipeForKey:@"stickerPacks"];
            }];
        }];
        
        SSignal *signal = [SSignal single:@{@"packs": @[]}];
     
        NSDictionary *cachedPacks = [self cachedStickerPacks];
        if (cachedPacks.count != 0)
            signal = [SSignal single:cachedPacks];

        signal = [signal then:[[[TGTelegramNetworking instance] genericTasksSignalManager] multicastedPipeForKey:@"stickerPacks"]];
        
        return signal;
    }];
}

+ (void)clearCache
{
    OSSpinLockLock(&cachedPacksLock);
    cachedPacks = nil;
    OSSpinLockUnlock(&cachedPacksLock);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TG_stickerPacks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    alreadyReloadedStickerPacksFromRemote = false;
}

+ (NSDictionary *)cachedStickerPacks
{
    OSSpinLockLock(&cachedPacksLock);
    NSDictionary *loadedFromCachePacks = cachedPacks;
    OSSpinLockUnlock(&cachedPacksLock);
    if (loadedFromCachePacks != nil) {
        return loadedFromCachePacks;
    }
    
    NSData *cachedStickerPacksData = [[NSUserDefaults standardUserDefaults] objectForKey:@"TG_stickerPacks"];
    if (cachedStickerPacksData == nil)
        return nil;

    NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:cachedStickerPacksData];
    if ([dict[@"packs"] isKindOfClass:[NSArray class]])
    {
        NSArray *cachedPacks = dict[@"packs"];

        NSMutableIndexSet *legacyStickerPacksIndexes = [[NSMutableIndexSet alloc] init];
        [cachedPacks enumerateObjectsUsingBlock:^(TGStickerPack *stickerPack, NSUInteger index, __unused BOOL * stop)
        {
            if ([stickerPack.packReference isKindOfClass:[TGStickerPackBuiltinReference class]])
                [legacyStickerPacksIndexes addIndex:index];
        }];
        
        if (legacyStickerPacksIndexes.count > 0)
        {
            NSMutableArray *filteredPacks = [cachedPacks mutableCopy];
            [filteredPacks removeObjectsAtIndexes:legacyStickerPacksIndexes];
         
            NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            updatedDict[@"packs"] = filteredPacks;
            dict = updatedDict;
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
        }
    }
    
    OSSpinLockLock(&cachedPacksLock);
    cachedPacks = dict;
    OSSpinLockUnlock(&cachedPacksLock);
    
    return dict;
}

+ (void)replaceCacheUpdateDate:(int32_t)cacheUpdateDate
{
    NSDictionary *currentDict = [self cachedStickerPacks];
    if (currentDict != nil)
    {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:currentDict];
        newDict[@"cacheUpdateDate"] = @(cacheUpdateDate);
        
        OSSpinLockLock(&cachedPacksLock);
        cachedPacks = newDict;
        OSSpinLockUnlock(&cachedPacksLock);
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newDict];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
    }
}

+ (NSDictionary *)replaceCachedStickerPacks:(NSArray *)stickerPacks cacheUpdateDate:(int32_t)cacheUpdateDate
{
    NSDictionary *currentDict = [self cachedStickerPacks];
    NSDictionary *newDict = nil;
    if (currentDict.count == 0)
    {
        NSMutableArray *orderedReferences = [[NSMutableArray alloc] init];
        for (TGStickerPack *stickerPack in stickerPacks)
        {
            [orderedReferences addObject:stickerPack.packReference];
        }
        newDict = @{@"packs": stickerPacks, @"cacheUpdateDate": @(cacheUpdateDate), @"documentIdsUseCount": @{}};
    }
    else
    {
        NSMutableSet *documentIds = [[NSMutableSet alloc] init];
        
        for (TGStickerPack *stickerPack in stickerPacks)
        {
            for (TGDocumentMediaAttachment *document in stickerPack.documents)
            {
                [documentIds addObject:@(document.documentId)];
            }
        }
        
        NSMutableDictionary *documentIdsUseCount = [[NSMutableDictionary alloc] initWithDictionary:currentDict[@"documentIdsUseCount"]];
        NSMutableArray *removedDocumentIds = [[NSMutableArray alloc] init];
        for (NSNumber *nDocumentId in documentIdsUseCount.allKeys)
        {
            if (![documentIds containsObject:nDocumentId])
                [removedDocumentIds addObject:nDocumentId];
        }
        [documentIdsUseCount removeObjectsForKeys:removedDocumentIds];
        
        newDict = @{@"packs": stickerPacks, @"cacheUpdateDate": @(cacheUpdateDate), @"documentIdsUseCount": documentIdsUseCount};
    }
    
    OSSpinLockLock(&cachedPacksLock);
    cachedPacks = newDict;
    OSSpinLockUnlock(&cachedPacksLock);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newDict];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
    
    return newDict;
}

+ (void)addUseCountForDocumentId:(int64_t)documentId
{
    NSDictionary *dict = [self cachedStickerPacks];
    if (dict == nil)
        return;
    
    bool found = false;
    int64_t packId = 0;
    for (TGStickerPack *stickerPack in dict[@"packs"])
    {
        for (TGDocumentMediaAttachment *document in stickerPack.documents)
        {
            if (document.documentId == documentId)
            {
                if ([stickerPack.packReference isKindOfClass:[TGStickerPackIdReference class]])
                    packId = ((TGStickerPackIdReference *)stickerPack.packReference).packId;
                
                found = true;
                break;
            }
        }
    }
    
    if (found)
    {
        NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary: dict];
        NSNumber *nextUseCount = dict[@"maxDocumentIdsUseCount_v2"];
        if (nextUseCount == nil) {
            __block NSInteger maxUseCount = 0;
            [dict[@"documentIdsUseCount"] enumerateKeysAndObjectsUsingBlock:^(__unused id key, NSNumber *nUseCount, __unused BOOL *stop) {
                maxUseCount = MAX(maxUseCount, [nUseCount integerValue]);
            }];
            nextUseCount = @(maxUseCount);
        }
        NSMutableDictionary *updatedDocumentIdsUseCount = [[NSMutableDictionary alloc] initWithDictionary:dict[@"documentIdsUseCount"]];
        updatedDocumentIdsUseCount[@(documentId)] = @([nextUseCount intValue] + 1);
        updatedDict[@"maxDocumentIdsUseCount_v2"] = @([nextUseCount intValue] + 2);
        
        updatedDict[@"documentIdsUseCount"] = updatedDocumentIdsUseCount;
        
        OSSpinLockLock(&cachedPacksLock);
        cachedPacks = updatedDict;
        OSSpinLockUnlock(&cachedPacksLock);
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:updatedDict];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
    }
}

+ (SSignal *)remoteStickerPacksWithCacheHash:(int32_t)cacheHash
{
#if TARGET_IPHONE_SIMULATOR
    //cacheHash = 0;
#endif
    
    TLRPCmessages_getAllStickers$messages_getAllStickers *getAllStickers = [[TLRPCmessages_getAllStickers$messages_getAllStickers alloc] init];
    getAllStickers.n_hash = cacheHash;
    
    return [[[TGTelegramNetworking instance] requestSignal:getAllStickers] mapToSignal:^SSignal *(TLmessages_AllStickers *result)
    {
        if ([result isKindOfClass:[TLmessages_AllStickers$messages_allStickers class]])
        {
            TLmessages_AllStickers$messages_allStickers *allStickers = (TLmessages_AllStickers$messages_allStickers *)result;
            
            NSMutableDictionary *currentStickerPacks = [self cachedStickerPacks][@"packs"];
            
            NSMutableArray *resultingPackReferences = [[NSMutableArray alloc] init];
            NSMutableArray *missingPackSignals = [[NSMutableArray alloc] init];
            
            for (TLStickerSet *resultPack in allStickers.sets)
            {
                TGStickerPackIdReference *resultPackReference = [[TGStickerPackIdReference alloc] initWithPackId:resultPack.n_id packAccessHash:resultPack.access_hash shortName:resultPack.short_name];
                
                TGStickerPack *currentPack = nil;
                for (TGStickerPack *pack in currentStickerPacks)
                {
                    if ([pack.packReference isEqual:resultPackReference])
                    {
                        currentPack = pack;
                        break;
                    }
                }
                
                if (currentPack == nil || currentPack.packHash != resultPack.n_hash)
                {
                    [missingPackSignals addObject:[self stickerPackInfo:resultPackReference packHash:resultPack.n_hash]];
                }
                
                [resultingPackReferences addObject:resultPackReference];
            }
            
            return [[SSignal combineSignals:missingPackSignals] map:^id (NSArray *additionalPacks)
            {
                NSMutableArray *finalStickerPacks = [[NSMutableArray alloc] init];
                
                for (id<TGStickerPackReference> reference in resultingPackReferences)
                {
                    TGStickerPack *foundPack = nil;
                    
                    for (TGStickerPack *pack in additionalPacks)
                    {
                        if ([pack.packReference isEqual:reference])
                        {
                            foundPack = pack;
                            break;
                        }
                    }
                    
                    if (foundPack == nil)
                    {
                        for (TGStickerPack *pack in currentStickerPacks)
                        {
                            if ([pack.packReference isEqual:reference])
                            {
                                foundPack = pack;
                                break;
                            }
                        }
                    }
                    
                    if (foundPack != nil)
                        [finalStickerPacks addObject:foundPack];
                }
                
                NSDictionary *result = [self replaceCachedStickerPacks:finalStickerPacks cacheUpdateDate:(int32_t)[[NSDate date] timeIntervalSince1970]];
                return result;
            }];
        }
        
        [self replaceCacheUpdateDate:(int32_t)[[NSDate date] timeIntervalSince1970]];
        
        return [SSignal complete];
    }];
}

+ (TLInputStickerSet *)_inputStickerSetFromPackReference:(id<TGStickerPackReference>)packReference
{
    if ([packReference isKindOfClass:[TGStickerPackIdReference class]])
    {
        TLInputStickerSet$inputStickerSetID *concreteId = [[TLInputStickerSet$inputStickerSetID alloc] init];;
        concreteId.n_id = ((TGStickerPackIdReference *)packReference).packId;
        concreteId.access_hash = ((TGStickerPackIdReference *)packReference).packAccessHash;
        return concreteId;
    }
    else if ([packReference isKindOfClass:[TGStickerPackShortnameReference class]])
    {
        TLInputStickerSet$inputStickerSetShortName *concreteId = [[TLInputStickerSet$inputStickerSetShortName alloc] init];
        concreteId.short_name = ((TGStickerPackShortnameReference *)packReference).shortName;
        return concreteId;
    }
    
    return [[TLInputStickerSet$inputStickerSetEmpty alloc] init];
}

+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference
{
    return [self stickerPackInfo:packReference packHash:0];
}

+ (SSignal *)stickerPackInfo:(id<TGStickerPackReference>)packReference packHash:(int32_t)packHash
{
    TLRPCmessages_getStickerSet$messages_getStickerSet *getStickerSet = [[TLRPCmessages_getStickerSet$messages_getStickerSet alloc] init];
    getStickerSet.stickerset = [self _inputStickerSetFromPackReference:packReference];
    return [[[TGTelegramNetworking instance] requestSignal:getStickerSet] map:^id (TLmessages_StickerSet *result)
    {
        TGStickerPackIdReference *resultPackReference = [[TGStickerPackIdReference alloc] initWithPackId:result.set.n_id packAccessHash:result.set.access_hash shortName:result.set.short_name];
        
        NSMutableArray *stickerAssociations = [[NSMutableArray alloc] init];
        for (TLStickerPack *resultAssociation in result.packs)
        {
            TGStickerAssociation *association = [[TGStickerAssociation alloc] initWithKey:resultAssociation.emoticon documentIds:resultAssociation.documents];
            [stickerAssociations addObject:association];
        }

        NSMutableArray *documents = [[NSMutableArray alloc] init];
        for (TLDocument *resultDocument in result.documents)
        {
            TGDocumentMediaAttachment *document = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:resultDocument];
            if (document.documentId != 0)
            {
                [documents addObject:document];
            }
        }
        
        return [[TGStickerPack alloc] initWithPackReference:resultPackReference title:result.set.title stickerAssociations:stickerAssociations documents:documents packHash:packHash hidden:(result.set.flags & (1 << 1))];
    }];
}

+ (SSignal *)installStickerPack:(id<TGStickerPackReference>)packReference
{
    TLRPCmessages_installStickerSet$messages_installStickerSet *installStickerSet = [[TLRPCmessages_installStickerSet$messages_installStickerSet alloc] init];
    installStickerSet.stickerset = [self _inputStickerSetFromPackReference:packReference];
    
    return [[[TGTelegramNetworking instance] requestSignal:installStickerSet] then:[[self remoteStickerPacksWithCacheHash:0] onNext:^(NSDictionary *dict)
    {
        NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            
        OSSpinLockLock(&cachedPacksLock);
        cachedPacks = updatedDict;
        OSSpinLockUnlock(&cachedPacksLock);
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:updatedDict];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
        
        [self updateShowStickerButtonModeForStickerPacks:updatedDict[@"packs"]];
        
        [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:updatedDict toMulticastedPipeForKey:@"stickerPacks"];
    }]];
}

+ (SSignal *)removeStickerPack:(id<TGStickerPackReference>)packReference
{
    TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet *uninstallStickerSet = [[TLRPCmessages_uninstallStickerSet$messages_uninstallStickerSet alloc] init];
    uninstallStickerSet.stickerset = [self _inputStickerSetFromPackReference:packReference];
    
    return [[[TGTelegramNetworking instance] requestSignal:uninstallStickerSet] then:[[[self remoteStickerPacksWithCacheHash:0] onNext:^(NSDictionary *dict)
    {
        [self updateShowStickerButtonModeForStickerPacks:dict[@"packs"]];
    }] afterNext:^(id next)
    {
        [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:next toMulticastedPipeForKey:@"stickerPacks"];
    }]];
}

+ (SSignal *)toggleStickerPackHidden:(id<TGStickerPackReference>)packReference hidden:(bool)hidden
{
    TLRPCmessages_installStickerSet$messages_installStickerSet *installStickerSet = [[TLRPCmessages_installStickerSet$messages_installStickerSet alloc] init];
    installStickerSet.stickerset = [self _inputStickerSetFromPackReference:packReference];
    installStickerSet.disabled = hidden;
    
    return [[[[TGTelegramNetworking instance] requestSignal:installStickerSet] mapToSignal:^SSignal *(__unused id result) {
        return [SSignal complete];
    }] afterCompletion:^{
        NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:[self cachedStickerPacks]];
        
        NSMutableArray *updatedPacks = [[NSMutableArray alloc] initWithArray:updatedDict[@"packs"]];
        
        NSInteger index = -1;
        for (TGStickerPack *pack in updatedPacks) {
            index++;
            
            if (TGObjectCompare(pack.packReference, packReference)) {
                TGStickerPack *updatedPack = [[TGStickerPack alloc] initWithPackReference:pack.packReference title:pack.title stickerAssociations:pack.stickerAssociations documents:pack.documents packHash:pack.packHash hidden:hidden];
                [updatedPacks replaceObjectAtIndex:index withObject:updatedPack];
                break;
            }
        }
        updatedDict[@"packs"] = updatedPacks;
        
        OSSpinLockLock(&cachedPacksLock);
        cachedPacks = updatedDict;
        OSSpinLockUnlock(&cachedPacksLock);
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:updatedDict];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
        
        [self updateShowStickerButtonModeForStickerPacks:updatedDict[@"packs"]];
        
        [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:updatedDict toMulticastedPipeForKey:@"stickerPacks"];
    }];
}

+ (SSignal *)reorderStickerPacks:(NSArray *)packReferences {
    TLRPCmessages_reorderStickerSets$messages_reorderStickerSets *reorderStickerSets = [[TLRPCmessages_reorderStickerSets$messages_reorderStickerSets alloc] init];
    NSMutableArray *order = [[NSMutableArray alloc] init];
    
    for (id<TGStickerPackReference> reference in packReferences) {
        if ([reference isKindOfClass:[TGStickerPackIdReference class]]) {
            [order addObject:@(((TGStickerPackIdReference *)reference).packId)];
        }
    }
    
    reorderStickerSets.order = order;
    
    return [[[TGTelegramNetworking instance] requestSignal:reorderStickerSets] afterCompletion:^{
        NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:[self cachedStickerPacks]];
        
        NSMutableArray *packs = [[NSMutableArray alloc] init];
        NSMutableString *packOrderString = [[NSMutableString alloc] init];
        for (id<TGStickerPackReference> packReference in packReferences) {
            for (TGStickerPack *pack in updatedDict[@"packs"]) {
                if (TGObjectCompare(pack.packReference, packReference)) {
                    [packs addObject:pack];
                    if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]]) {
                        if (packOrderString.length != 0) {
                            [packOrderString appendString:@", "];
                        }
                        [packOrderString appendFormat:@"%lld", ((TGStickerPackIdReference *)pack.packReference).packId];
                    }
                    break;
                }
            }
        }
        updatedDict[@"packs"] = packs;
        
        OSSpinLockLock(&cachedPacksLock);
        cachedPacks = updatedDict;
        OSSpinLockUnlock(&cachedPacksLock);
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:updatedDict];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TG_stickerPacks"];
        
        [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:updatedDict toMulticastedPipeForKey:@"stickerPacks"];
    }];
}

+ (void)remoteAddedStickerPack:(TGStickerPack *)stickerPack {
    NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:[self cachedStickerPacks]];
    
    bool found = false;
    for (TGStickerPack *pack in updatedDict[@"packs"]) {
        if (TGObjectCompare(pack.packReference, stickerPack)) {
            found = true;
            break;
        }
    }
    
    if (!found) {
        NSMutableArray *updatedPacks = [[NSMutableArray alloc] initWithArray:updatedDict[@"packs"]];
        [updatedPacks insertObject:stickerPack atIndex:0];
        updatedDict[@"packs"] = updatedPacks;
        
        OSSpinLockLock(&cachedPacksLock);
        cachedPacks = updatedDict;
        OSSpinLockUnlock(&cachedPacksLock);
        
        [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:updatedDict toMulticastedPipeForKey:@"stickerPacks"];
    }
}

+ (void)remoteReorderedStickerPacks:(NSArray *)updatedOrder {
    NSMutableDictionary *updatedDict = [[NSMutableDictionary alloc] initWithDictionary:[self cachedStickerPacks]];
    
    NSMutableArray *allPacks = [[NSMutableArray alloc] initWithArray:updatedDict[@"packs"]];
    NSMutableArray *updatedPacks = [[NSMutableArray alloc] init];
    
    for (NSNumber *nPackId in updatedOrder) {
        NSInteger index = -1;
        for (TGStickerPack *pack in allPacks) {
            index++;
            
            if ([pack.packReference isKindOfClass:[TGStickerPackIdReference class]] && ((TGStickerPackIdReference *)pack.packReference).packId == [nPackId longLongValue]) {
                [updatedPacks addObject:pack];
                [allPacks removeObjectAtIndex:index];
                break;
            }
        }
    }
    
    [updatedPacks addObjectsFromArray:allPacks];
    
    updatedDict[@"packs"] = updatedPacks;
    
    OSSpinLockLock(&cachedPacksLock);
    cachedPacks = updatedDict;
    OSSpinLockUnlock(&cachedPacksLock);
    
    [[[TGTelegramNetworking instance] genericTasksSignalManager] putNext:updatedDict toMulticastedPipeForKey:@"stickerPacks"];
}

+ (SSignal *)preloadedStickerPreviews:(NSArray *)documents count:(NSUInteger)count
{
    return [[SSignal single:nil] mapToSignal:^SSignal *(__unused id next)
    {
        SSignal *signal = [SSignal complete];
        
        for (NSUInteger i = 0; i < count && i < documents.count; i++)
        {
            TGDocumentMediaAttachment *document = documents[i];
            
            NSString *directory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId];
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:true attributes:nil error:NULL];
            
            NSString *path = [directory stringByAppendingPathComponent:@"thumbnail-high"];
            
            NSString *thumbnailUrl = [document.thumbnailInfo imageUrlForLargestSize:NULL];
            int32_t datacenterId = 0;
            int64_t volumeId = 0;
            int32_t localId = 0;
            int64_t secret = 0;
            if (extractFileUrlComponents(thumbnailUrl, &datacenterId, &volumeId, &localId, &secret))
            {
                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    TLInputFileLocation$inputFileLocation *location = [[TLInputFileLocation$inputFileLocation alloc] init];
                    location.volume_id = volumeId;
                    location.local_id = localId;
                    location.secret = secret;
                    
                    SSignal *downloadSignal = [[TGRemoteFileSignal dataForLocation:location datacenterId:datacenterId size:0 reportProgress:false] onNext:^(id next)
                    {
                        if ([next isKindOfClass:[NSData class]])
                        {
                            TGLog(@"preloaded sticker preview to %@", path);
                            [(NSData *)next writeToFile:path atomically:true];
                        }
                    }];
                    
                    signal = [signal then:downloadSignal];
                }
            }
        }
        
        return [[signal reduceLeft:nil with:^id(__unused id current, __unused id next)
        {
            return current;
        }] then:[SSignal single:documents]];
    }];
}

@end
